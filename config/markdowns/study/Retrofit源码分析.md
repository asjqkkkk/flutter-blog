---
title: Retrofit源码分析
date: 2020-04-05 04:03:43
index_img: /img/retrofit.png
tags: 源码系列
---
# 序

[Retrofit](https://square.github.io/retrofit/) 在Android开发者中，应该属于人尽皆知人尽皆用的程度了。

这一篇文章就是用来了解它的源码，并顺便了解一下它使用到的一个重要特性：**动态代理**


# 引子

用过 `Retrofit` 的小伙伴应该都知道，使用它，会创建一个接口存放所有的网络请求。接口里的每个方法都会使用注解去修饰，最后的代码看起来统一而又美观。

那这次我们在哪里作为入口呢？还是很简单的，从  `Retrofit` 创建的地方作为入口吧

# Retrofit

一般，我们创建 `Retrofit` 都是类似下面这的代码

首先，创建请求接口


```
public interface GitHubService {
    @GET("users/{user}/repos")
    Call<List<Repo>> listRepos(@Path("user") String user);
  
    @FormUrlEncoded
    @POST("user/edit")
    Call<User> updateUser(@Field("first_name") String first, @Field("last_name") String last);
    ...
}
```
然后，创建 `Retrofit` 对象

```
Retrofit retrofit = new Retrofit.Builder()
        .client(okHttpClient)
        .baseUrl(baseUrl)
        .addConverterFactory(GsonConverterFactory.create())
        .build();
        
GitHubService service = retrofit.create(GitHubService.class);
```

> 为了简洁起见，就不再加入 rxjava 或其他相关的内容了。做一个纯净的代码分析

我们直接从 `Retrofit.Builder()` 开始看起吧

## Builder()


```
public final class Retrofit {
  ...
  public static final class Builder {
    private final Platform platform;
    ...
    public Builder() {
      this(Platform.get());
    }
    ...
    Builder(Platform platform) {
      this.platform = platform;
    }
    ...
  }
  ...
}
```
在 `Builder()` 中，初始化了 `Platform` 对象。因为 `Retrofit` 不仅支持在Android上使用，还可以支持纯java的项目。所以这里的  `Platform` 中处理的就是这两种情况

我们可以简单的看一下  `Platform` 对象

## Platform


```
class Platform {
  private static final Platform PLATFORM = findPlatform();

  static Platform get() {
    return PLATFORM;
  }

  private static Platform findPlatform() {
    ...
    if (Build.VERSION.SDK_INT != 0) {
        return new Android();
    }
    ...
    return new Java8();
    ...
  }
  ...
  static class Android extends Platform {
    ...

    @Override public Executor defaultCallbackExecutor() {
      return new MainThreadExecutor();
    }

    ...

    static class MainThreadExecutor implements Executor {
      private final Handler handler = new Handler(Looper.getMainLooper());

      @Override public void execute(Runnable r) {
        handler.post(r);
      }
    }
  }
}
```
这里，我们主要关注 `Platform` 中 `Android` 的实现，可以看到其中有一个 `MainThreadExecutor` 对象，它其中持有了一个主线程 `Handler` ，想必这里就是用于异步回调后的线程切换。

接下来，我们继续看 `Retrofit` 的 `build()` 方法

## Builder.build()


```
public final class Retrofit {
    ...
  public static final class Builder {
    public Retrofit build() {
      ...
      okhttp3.Call.Factory callFactory = this.callFactory;
      if (callFactory == null) {
        callFactory = new OkHttpClient();
      }

      Executor callbackExecutor = this.callbackExecutor;
      if (callbackExecutor == null) {
        callbackExecutor = platform.defaultCallbackExecutor();
      }

      ...

      return new Retrofit(callFactory, baseUrl, unmodifiableList(converterFactories),
          unmodifiableList(callAdapterFactories), callbackExecutor, validateEagerly);
    }
    ...
  }
  ...
}
```
在这个方法中，主要做一些初始化的赋值操作。我们的主角其实还是 `Retrofit` 的 `create()` 方法

## create()


```
public final class Retrofit {
  ...
  public <T> T create(final Class<T> service) {
    Utils.validateServiceInterface(service);
    if (validateEagerly) {
      eagerlyValidateMethods(service);
    }
    return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
        new InvocationHandler() {
          private final Platform platform = Platform.get();
          private final Object[] emptyArgs = new Object[0];

          @Override public @Nullable Object invoke(Object proxy, Method method,
              @Nullable Object[] args) throws Throwable {
            // If the method is a method from Object then defer to normal invocation.
            if (method.getDeclaringClass() == Object.class) {
              return method.invoke(this, args);
            }
            if (platform.isDefaultMethod(method)) {
              return platform.invokeDefaultMethod(method, service, proxy, args);
            }
            return loadServiceMethod(method).invoke(args != null ? args : emptyArgs);
          }
        });
  }
  ...
}
```
这里的 `validateEagerly` 默认为 **false**，如果设为 **ture** 会提前遍历 class 对象的所有方法，并将获取到的信息进行处理

我们直接看 **return** 的内容 `Proxy.newProxyInstance(...)` 

很显然，这里就是我们本篇文章的主角了，**动态代理** 就是通过它来实现的

在重写的 `invoke(...)` 方法中，`isDefaultMethod(method)` 最终调用的是 `Method.isDefault()`,如果接口中的方法被 `default` 关键字修饰，则返回 **true** ，当然这个只在android api 24以上可以用

我们看 `loadServiceMethod(...)` 方法做了些什么


## loadServiceMethod(...)


```
public final class Retrofit {
  private final Map<Method, ServiceMethod<?>> serviceMethodCache = new ConcurrentHashMap<>();
  ...
  ServiceMethod<?> loadServiceMethod(Method method) {
    ServiceMethod<?> result = serviceMethodCache.get(method);
    if (result != null) return result;

    synchronized (serviceMethodCache) {
      result = serviceMethodCache.get(method);
      if (result == null) {
        result = ServiceMethod.parseAnnotations(this, method);
        serviceMethodCache.put(method, result);
      }
    }
    return result;
  }
  ...
}

```
显然，这里将所有获取到的 `Method` 放入了一个 `ConcurrentHashMap` 进行维护，这样做的目的自然是为了避免多次调用同一个方法时会`involk` 多次。也许这样可以提升一些性能，不过我还没有研究过。

到这里 `Retrofit` 为什么可以做到通过接口的方式来进行请求的根本原因已经找到了。

还剩下一个问题，就是那些注解，类似于 `@POST`、`@GET` 等，是如何起作用的。接下来，我们从 `ServiceMethod` 的 `parseAnnotations(...)` 中寻找答案

## ServiceMethod

### parseAnnotations(...)

```
abstract class ServiceMethod<T> {
  static <T> ServiceMethod<T> parseAnnotations(Retrofit retrofit, Method method) {
    RequestFactory requestFactory = RequestFactory.parseAnnotations(retrofit, method);
    ...
    return HttpServiceMethod.parseAnnotations(retrofit, method, requestFactory);
  }

  abstract @Nullable T invoke(Object[] args);
}
```
可以看到 `parseAnnotations(...)` 最后返回了 `HttpServiceMethod` 对象，而上面的 `invoke()` 方法会在其中实现对 `OkHttp` 的请求调用。不过这里我们先关注注解相关的内容，我们看一下 `RequestFactory` 的 `parseAnnotations(...)` 方法

## RequestFactory

### parseAnnotations(...)

```
final class RequestFactory {
  static RequestFactory parseAnnotations(Retrofit retrofit, Method method) {
    return new Builder(retrofit, method).build();
  }
  ...
}
```
`Builder(...)` 中主要做的初始化的赋值操作，我们直接来看 `build()` 方法

### Builder.build()


```
    RequestFactory build() {
      for (Annotation annotation : methodAnnotations) {
        parseMethodAnnotation(annotation);
      }
      ...
      return new RequestFactory(this);
    }
```
可以看到，这里遍历了当前方法所有的注解，然后调用了 `parseMethodAnnotation(annotation)` 方法

### parseMethodAnnotation(annotation)

```
    private void parseMethodAnnotation(Annotation annotation) {
      if (annotation instanceof DELETE) {
        parseHttpMethodAndPath("DELETE", ((DELETE) annotation).value(), false);
      } else if (annotation instanceof GET) {
        parseHttpMethodAndPath("GET", ((GET) annotation).value(), false);
      } else if (annotation instanceof HEAD) {
        parseHttpMethodAndPath("HEAD", ((HEAD) annotation).value(), false);
      } else if (annotation instanceof PATCH) {
        parseHttpMethodAndPath("PATCH", ((PATCH) annotation).value(), true);
      } else if (annotation instanceof POST) {
        parseHttpMethodAndPath("POST", ((POST) annotation).value(), true);
      } else if (annotation instanceof PUT) {
        parseHttpMethodAndPath("PUT", ((PUT) annotation).value(), true);
      } else if (annotation instanceof OPTIONS) {
        parseHttpMethodAndPath("OPTIONS", ((OPTIONS) annotation).value(), false);
      } else if (annotation instanceof HTTP) {
        HTTP http = (HTTP) annotation;
        parseHttpMethodAndPath(http.method(), http.path(), http.hasBody());
      } else if (annotation instanceof retrofit2.http.Headers) {
        String[] headersToParse = ((retrofit2.http.Headers) annotation).value();
        if (headersToParse.length == 0) {
          throw methodError(method, "@Headers annotation is empty.");
        }
        headers = parseHeaders(headersToParse);
      } else if (annotation instanceof Multipart) {
        if (isFormEncoded) {
          throw methodError(method, "Only one encoding annotation is allowed.");
        }
        isMultipart = true;
      } else if (annotation instanceof FormUrlEncoded) {
        if (isMultipart) {
          throw methodError(method, "Only one encoding annotation is allowed.");
        }
        isFormEncoded = true;
      }
    }
```
显然，在 `parseMethodAnnotation(annotation)` 中，处理了各种类型的注解，而各个注解所携带的参数，则是在 `parseHttpMethodAndPath(...)` 中进行处理

### parseHttpMethodAndPath(...)


```
    private void parseHttpMethodAndPath(String httpMethod, String value, boolean hasBody) {
      ...
      int question = value.indexOf('?');
      if (question != -1 && question < value.length() - 1) {
        
        String queryParams = value.substring(question + 1);
        Matcher queryParamMatcher = PARAM_URL_REGEX.matcher(queryParams);
        ...
      }

      this.relativeUrl = value;
      this.relativeUrlParamNames = parsePathParameters(value);
    }
    
    static Set<String> parsePathParameters(String path) {
      Matcher m = PARAM_URL_REGEX.matcher(path);
      Set<String> patterns = new LinkedHashSet<>();
      while (m.find()) {
        patterns.add(m.group(1));
      }
      return patterns;
    }
```

到这里其实关于 `Retrofit` 主要想了解的问题已经解开了。如果想知道 `Retrofit` 是在哪里调用 `OkHttp` 的，下面可以进入 `HttpServiceMethod` 做一个简单的说明

## HttpServiceMethod

### parseAnnotations(...)


```
  static <ResponseT, ReturnT> HttpServiceMethod<ResponseT, ReturnT> parseAnnotations(
      Retrofit retrofit, Method method, RequestFactory requestFactory) {
    ...
    CallAdapter<ResponseT, ReturnT> callAdapter =
        createCallAdapter(retrofit, method, adapterType, annotations);
    ...
    }
```
接下来，会从 `createCallAdapter(...)` 开始，进入下面的各个方法

### createCallAdapter(...)

```
  private static <ResponseT, ReturnT> CallAdapter<ResponseT, ReturnT> createCallAdapter(
      Retrofit retrofit, Method method, Type returnType, Annotation[] annotations) {
    try {
      //noinspection unchecked
      return (CallAdapter<ResponseT, ReturnT>) retrofit.callAdapter(returnType, annotations);
    } catch (RuntimeException e) { // Wide exception range because factories are user code.
      throw methodError(method, e, "Unable to create call adapter for %s", returnType);
    }
  }
```
下面进入 `Retrofit` 的 `callAdapter(...)`， 然后是 `nextCallAdapter(...)`, 通过 `DefaultCallAdapterFactory` 的 `get(...)` 方法得到 `CallAdapter` 对象

而当你调用代理对象的方法，即你写的接口的方法时，通过 `invoke(...)` 最后调用的就是 `CallAdapter` 对象的 `adapt` 方法，在里面进行了网络请求

那么 `Retrofit` 的源码就到此为止啦！

接下来，我们简单的聊一下动态代理吧。不过在动态代理之前，我们可以介绍一下静态代理

# 静态代理

拿生活中比较常见的例子来举例吧。

**点外卖**。当你想吃烤鸭店里的烤鸭，而又懒得去拿时，叫个外卖就好了，外卖小哥会代替你从店里取来烤鸭。

这里，我们 **取外卖** 就是被代理的功能，而 **外卖小哥** 是你的代理对象，**你自己** 则是被代理的目标对象

那么接下来就简单了，先定义一个接口，实现功能


```
public interface IProxy {
    public void takeFood();
}
```
然后，你本身具备这个功能


```
public class LazyMan implements IProxy{

    @Override
    public void takeFood() {
        System.out.println("我拿到烤鸭啦！");
    }
}
```

外卖小哥具备这个功能，并且他可以代替你实现这个功能


```
public class DeliveryMan implements IProxy{

    private LazyMan target;
    
    public DeliveryMan(LazyMan target) {
        this.target = target;
    }

    @Override
    public void takeFood() {
        System.out.println("我帮客户拿到烤鸭啦！");
        target.takeFood();
    }
}
```
实现整个流程则如下

```
public void testProxy(){
    //目标对象
    LazyMan target = new LazyMan();
    //代理对象
    IProxy proxy = new DeliveryMan(target);
    proxy.takeFood();
}
```

静态代理之所以叫 **静态** 的原因就是因为功能接口是已知的。那么以此类推，动态代理自然就是当功能未知时所使用的一种代理模式

# 动态代理

动态代理的实现主要依赖于 `Proxy.newProxyInstance(...)` 方法。这时候，我们将 `IProxy` 的功能增加一些


```
public interface IProxy {

    default void payMoney(){
        System.out.println("默认方法:我已经付款啦.");
    };

    void takeFood();

    void eatFood();
}
```
这里加了一个 `default` 也是为了说明之前 `Retrofit` 中的相关方法

再看目标对象 `LazyMan` 的实现


```
public class LazyMan implements IProxy {
    @Override
    public void eatFood() { System.out.println("开始吃烤鸭！"); }

    @Override
    public void takeFood() {  System.out.println("我拿到烤鸭啦！"); }
}
```
这时候，要实现之前的流程，操作如下


```
public void testProxy(){
        final IProxy target = new LazyMan();
        ClassLoader classLoader = target.getClass().getClassLoader();
        Class<?>[] interfaces = target.getClass().getInterfaces();

        IProxy iProxy = (IProxy)Proxy.newProxyInstance(classLoader, interfaces, (proxy, method, args) -> {
            System.out.println("-------------开始调用:" + method.getName() +"-----------");
            method.invoke(target, args);
            System.out.println("是否是默认方法:" + method.isDefault());
            System.out.println("-------------结束调用" + method.getName() +"-----------\n");
            return null;
        });
        iProxy.payMoney();
        iProxy.takeFood();
        iProxy.eatFood();
}
```
打印内容如下：


```
-------------开始调用:payMoney-----------
默认方法:我已经付款啦.
是否是默认方法:true
-------------结束调用payMoney-----------

-------------开始调用:takeFood-----------
我拿到烤鸭啦！
是否是默认方法:false
-------------结束调用takeFood-----------

-------------开始调用:eatFood-----------
开始吃烤鸭！
是否是默认方法:false
-------------结束调用eatFood-----------
```

可以看到，每次对代理对象的调用，都会执行一次 `InvocationHandler` 的 `invoke(...)` 方法

> ps:上面用lambda将 `InvocationHandler` 隐藏了

那么到这里文章就结束了。这一篇就不写总结啦。