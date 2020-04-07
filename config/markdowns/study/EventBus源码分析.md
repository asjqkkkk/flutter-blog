---
title: EventBus源码分析
date: 2020-04-07 11:24:16
index_img: /img/eventbus.png
tags: 源码系列
---
# 序

[EventBus](https://github.com/greenrobot/EventBus) 也是Android开发者们非常熟知的库了

这一篇文章我们将来了解一下它的源码，看看它是如何进行事件的订阅与通知的。


# 引子

`EventBus` 的用法十分简单，我们直接从 `EventBus.getDefault().register(...)` 开始看吧


# EventBus

## getDefault()


```
    public static EventBus getDefault() {
        if (defaultInstance == null) {
            synchronized (EventBus.class) {
                if (defaultInstance == null) {
                    defaultInstance = new EventBus();
                }
            }
        }
        return defaultInstance;
    }
```
`getDefault()` 是一个双重检查锁获取的单例对象，关于单例模式之前的文章已经介绍过，这里就不重复了。

## EventBus()


```
public class EventBus {
    private static final EventBusBuilder DEFAULT_BUILDER = new EventBusBuilder();
    ...
    private final Map<Class<?>, CopyOnWriteArrayList<Subscription>> subscriptionsByEventType;
    private final Map<Object, List<Class<?>>> typesBySubscriber;
    private final Map<Class<?>, Object> stickyEvents;

    public EventBus() {
        this(DEFAULT_BUILDER);
    }
    
    EventBus(EventBusBuilder builder) {
        ...
        subscriptionsByEventType = new HashMap<>();
        typesBySubscriber = new HashMap<>();
        stickyEvents = new ConcurrentHashMap<>();
        mainThreadSupport = builder.getMainThreadSupport();
        mainThreadPoster = mainThreadSupport != null ? mainThreadSupport.createPoster(this) : null;
        backgroundPoster = new BackgroundPoster(this);
        ...
    }
}
```
`EventBus()` 最后调用的 `EventBus(builder)` 完成了一系列初始化的操作。这里，简单说明一下，`ConcurrentHashMap` 和 `CopyOnWriteArrayList` 分别是线程操作安全的 `Map` 与 线程操作安全的 `List` 结构

上面有三个非常主要的数据结构，下面分别介绍一下：
- `subscriptionsByEventType` 对象的 `key` 是自定义的 `Event` 事件的 `Type`，而 `value` 则是一个列表，这个列表由该 `Event` 相关的所有被 `@Subscribe` 修饰的方法所组成，每个方法的各种信息都被封装在了 `Subscription` 中
- `typesBySubscriber` 的 `key` 则是 `register(...)` 时传入的类信息，而 `value` 则是由该类中各种自定义的 `Event` 事件组成的列表
- `stickyEvents` 的 `key` 是自定义 `Event` 事件的 `Type`，而 `value` 则是该 `Event`

接下来，我们来看 `register(...)` 方法

## register(...)


```
    public void register(Object subscriber) {
        Class<?> subscriberClass = subscriber.getClass();
        List<SubscriberMethod> subscriberMethods = subscriberMethodFinder.findSubscriberMethods(subscriberClass);
        synchronized (this) {
            for (SubscriberMethod subscriberMethod : subscriberMethods) {
                subscribe(subscriber, subscriberMethod);
            }
        }
    }
```
可以看到，在 `register(...)` 中，通过 `findSubscriberMethods(...)` 找到了注册类里面声明的所有方法，然后进行遍历调用 `subscribe(...)` 进行数据存放操作，我们可以先看一下 `findSubscriberMethods(...)`

## SubscriberMethodFinder


```
class SubscriberMethodFinder {
    private static final Map<Class<?>, List<SubscriberMethod>> METHOD_CACHE = new ConcurrentHashMap<>();
    ...
    List<SubscriberMethod> findSubscriberMethods(Class<?> subscriberClass) {
        List<SubscriberMethod> subscriberMethods = METHOD_CACHE.get(subscriberClass);
        if (subscriberMethods != null) {
            return subscriberMethods;
        }

        if (ignoreGeneratedIndex) {
            subscriberMethods = findUsingReflection(subscriberClass);
        } else {
            subscriberMethods = findUsingInfo(subscriberClass);
        }
        if (subscriberMethods.isEmpty()) {
            throw new EventBusException("Subscriber " + subscriberClass
                    + " and its super classes have no public methods with the @Subscribe annotation");
        } else {
            METHOD_CACHE.put(subscriberClass, subscriberMethods);
            return subscriberMethods;
        }
    }
}
```
可以看到，`METHOD_CACHE` 实现了一个缓存的功能，避免列表的重复创建。

当列表 `subscriberMethods` 为空时，则会根据  `ignoreGeneratedIndex` 来通过不同的方式初始化，说到这个变量，它其实和 **EventBus 3.0** 引入的 `EventBusAnnotationProcessor` 有关，它可以在编译时生成相关的索引文件，这样比通过反射来获取各种信息所带来的性能提升要高得多，不过使用它需要进行额外的配置，这里就不细说了。

 `ignoreGeneratedIndex` 为 **true** 则表示强制使用反射来获取索引信息，而它默认是为 **false** 的
 
 不过如果你没有去配置 `EventBusAnnotationProcessor` ，那么最后其实两种获取索引的方法都是通过反射来完成的。这里关于 `SubscriberMethodFinder` 的分析大概就是这样，接下来，我们继续回到 `EventBus` 的 `subscribe(...)` 方法
 
 ## subscribe(...)
 
 
```
    public void register(Object subscriber) {
        ...
        synchronized (this) {
            for (SubscriberMethod subscriberMethod : subscriberMethods) {
                subscribe(subscriber, subscriberMethod);
            }
        }
    }
```
可以看到，`subscribe(...)` 方法是在 `synchronized` 修饰的代码块中进行的操作


```
    private void subscribe(Object subscriber, SubscriberMethod subscriberMethod) {
        Class<?> eventType = subscriberMethod.eventType;
        Subscription newSubscription = new Subscription(subscriber, subscriberMethod);
        CopyOnWriteArrayList<Subscription> subscriptions = subscriptionsByEventType.get(eventType);
        if (subscriptions == null) {
            subscriptions = new CopyOnWriteArrayList<>();
            subscriptionsByEventType.put(eventType, subscriptions);
        }
        ...
        //根据优先级，最优先的放在列表最前面
        int size = subscriptions.size();
        for (int i = 0; i <= size; i++) {
            if (i == size || subscriberMethod.priority > subscriptions.get(i).subscriberMethod.priority) {
                subscriptions.add(i, newSubscription);
                break;
            }
        }
        
        List<Class<?>> subscribedEvents = typesBySubscriber.get(subscriber);
        if (subscribedEvents == null) {
            subscribedEvents = new ArrayList<>();
            typesBySubscriber.put(subscriber, subscribedEvents);
        }
        subscribedEvents.add(eventType);
        
        if (subscriberMethod.sticky) {
            ...
        }
    }
```
在 `subscribe(...)` 中，进行的一系列操作，就是我们之前介绍过的三种数据结构，将各种订阅消息存放到数据结构中。

同时，在 `if (subscriberMethod.sticky)` 的逻辑中，还会对 `stickyEvent` 进行一次检查，如果存在的话，则会触发它。这也就是为什么在前一个 **Activity** 注册了 `stickyEvent` 后，在后启动的 **Activity** 可以触发 `stickyEvent` 的原因了。

`EventBus` 的注册流程大概就是这样，接下来我们看一下调用 `post(event)` 方法时，`EventBus` 是如何触发订阅事件的吧


## post(event)


```
    public void post(Object event) {
        PostingThreadState postingState = currentPostingThreadState.get();
        List<Object> eventQueue = postingState.eventQueue;
        eventQueue.add(event);

        if (!postingState.isPosting) {
            postingState.isMainThread = isMainThread();
            postingState.isPosting = true;
            if (postingState.canceled) {
                throw new EventBusException("Internal error. Abort state was not reset");
            }
            try {
                while (!eventQueue.isEmpty()) {
                    postSingleEvent(eventQueue.remove(0), postingState);
                }
            } finally {
                postingState.isPosting = false;
                postingState.isMainThread = false;
            }
        }
    }
```
可以看到，这里先将需要触发的 `event` 放在列表尾部，然后遍历这个列表，依次调用 `postSingleEvent(event)` 从头到尾处理所有事件

接下来，就看一下 `postSingleEvent(event)` 

## postSingleEvent(event)


```
    private void postSingleEvent(Object event, PostingThreadState postingState) throws Error {
        Class<?> eventClass = event.getClass();
        boolean subscriptionFound = false;
        if (eventInheritance) {
            List<Class<?>> eventTypes = lookupAllEventTypes(eventClass);
            int countTypes = eventTypes.size();
            for (int h = 0; h < countTypes; h++) {
                Class<?> clazz = eventTypes.get(h);
                subscriptionFound |= postSingleEventForEventType(event, postingState, clazz);
            }
        } else {
            subscriptionFound = postSingleEventForEventType(event, postingState, eventClass);
        }
        ...
    }
```
`eventInheritance` 默认为true，它表示会将订阅的 `event` 父类也添加到 `event` 触发列表中

最后会走到 `postSingleEventForEventType(...)` 方法

## postSingleEventForEventType(...)


```
    private boolean postSingleEventForEventType(Object event, PostingThreadState postingState, Class<?> eventClass) {
        CopyOnWriteArrayList<Subscription> subscriptions;
        synchronized (this) {
            subscriptions = subscriptionsByEventType.get(eventClass);
        }
        if (subscriptions != null && !subscriptions.isEmpty()) {
            for (Subscription subscription : subscriptions) {
                postingState.event = event;
                postingState.subscription = subscription;
                boolean aborted = false;
                try {
                    postToSubscription(subscription, event, postingState.isMainThread);
                    aborted = postingState.canceled;
                } finally {
                    postingState.event = null;
                    postingState.subscription = null;
                    postingState.canceled = false;
                }
                if (aborted) {
                    break;
                }
            }
            return true;
        }
        return false;
    }
```
这里先从 `subscriptionsByEventType` 取出当前注册 `event` 对应的订阅方法列表，然后遍历这个列表，调用 `postToSubscription(...)` 来触发事件。如果最后返回false的话，就说明没有找到订阅的方法

接下来，就看一下 `postToSubscription(...)` 了

## postToSubscription(...)


```
    private void postToSubscription(Subscription subscription, Object event, boolean isMainThread) {
        switch (subscription.subscriberMethod.threadMode) {
            case POSTING:
                invokeSubscriber(subscription, event);
                break;
            case MAIN:
                if (isMainThread) {
                    invokeSubscriber(subscription, event);
                } else {
                    mainThreadPoster.enqueue(subscription, event);
                }
                break;
            case MAIN_ORDERED:
                if (mainThreadPoster != null) {
                    mainThreadPoster.enqueue(subscription, event);
                } else {
                    // temporary: technically not correct as poster not decoupled from subscriber
                    invokeSubscriber(subscription, event);
                }
                break;
            case BACKGROUND:
                if (isMainThread) {
                    backgroundPoster.enqueue(subscription, event);
                } else {
                    invokeSubscriber(subscription, event);
                }
                break;
            case ASYNC:
                asyncPoster.enqueue(subscription, event);
                break;
            default:
                throw new IllegalStateException("Unknown thread mode: " + subscription.subscriberMethod.threadMode);
        }
    }
```
到这里，其实就是对应各种 `ThreadMode` 来处理相对应的 `event` 了。其中你可以发现三个个比较特殊的对象，分别是 `mainThreadPoster`、`backgroundPoster` 以及 `asyncPoster`。

这三者的 `enqueue(...)` 方法最终都是将对象插入了其内部维护的 `PendingPostQueue`，而 `PendingPostQueue` 内部维护了两个链表，实现了一个 `event` 栈

下面就分别简单的介绍一下三个 `Poster` 对象，感兴趣的同学可以直接看源码

- `mainThreadPoster` : 是 `HandlerPoster` 对象，父类为 `Handler` ，内部持有 `MainLooper`。 `enqueue(...)` 在插入 `event` 的同时，会调用 `sendMessage(msg)` 通知其内部的 `handleMessage(msg)` 触发事件
- `backgroundPoster` : 是 `BackgroundPoster` 对象，实现了 `Runnable` 接口， `enqueue(...)` 插入 `event` 同时调用 `ExecutorService` 对象执行 `run()` 方法，在里面遍历队列触发事件，每个事件触发都需要等待 **1000ms**
- `asyncPoster` : 是 `AsyncPoster` 对象，也实现了 `Runnable` 接口，其他逻辑与 `backgroundPoster` 类似，只不过它不用等待，并且不对队列进行遍历一次只处理一个事件

这里其实就可以知道，`BACKGROUND` 是针对 **Android** 设计的，如果当前 `post(event)` 发生在主线程，会通过线程池来触发各个事件。 `ASYNC` 也差不多，但是它没有对主线程进行判断，应该是针对 **java平台** 使用的

最终，事件的触发都调用到了 `invokeSubscriber(...)` 方法

## invokeSubscriber(...)

```
    void invokeSubscriber(PendingPost pendingPost) {
        ...
        if (subscription.active) {
            invokeSubscriber(subscription, event);
        }
    }

    void invokeSubscriber(Subscription subscription, Object event) {
        try {
            subscription.subscriberMethod.method.invoke(subscription.subscriber, event);
        } catch (InvocationTargetException e) {
            handleSubscriberException(subscription, event, e.getCause());
        } catch (IllegalAccessException e) {
            throw new IllegalStateException("Unexpected exception", e);
        }
    }
```
当我们在 `post(event)` 时如果没有找到有方法订阅了该 `event`，就会发送一个 `SubscriberExceptionEvent` 事件，
这里的 `handleSubscriberException(...)` 除了处理其他的错误，也会处理这个事件

可以看到，最后调用的是 `Method` 对象的 `invoke(...)` 方法。所以这里我们就知道了，所有事件的触发，其实都是通过反射来完成的。

那么关于 `EventBus` 的源码，也就分析结束啦！整体来看可读性还是蛮高的，分析起来没有太大的障碍，就不写总结了。