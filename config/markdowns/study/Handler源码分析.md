---
title: Hanler源码分析
date: 2020-03-12 09:56:23
index_img: /img/handler.png
tags: 源码系列
---

# 序

我到底为什么要分析 `Hanler` 的源码呢？

在之前，我分析 `HashMap` 的源码是因为面试中有问到这个，我也确实没看过。而 `Handler` 也会是比较常问的一个知识点。考虑过了我稀疏的源码阅读量，以及分析了 `HashMap` 的源码后一种莫名舒畅的感觉，我决定完成一个源码分析的系列，`Handler` 就是其中之一了。

# 引子

我们从哪里开始分析好呢？在 `Handler` 的日常使用中，我们肯定会用到它的 `handleMessage(Message msg)` 方法，所以我们可以从这里开始。


```
    public void handleMessage(Message msg) {
    }
```

然后你可以发现，这个方法属实没什么好分析的。

我们还是从构造函数那里开始入手吧，分析一遍后你会发现， `Handler` 的源码还是蛮简洁清晰的

# 分析

在构造函数之前，可以先看一下 `Handler` 中，有哪些对象


```
public class Handler {
    
    ...
    final Looper mLooper;
    final MessageQueue mQueue;
    final Callback mCallback;
    final boolean mAsynchronous;
    IMessenger mMessenger;
    ...
}
```

可以看到， `Handler` 中存放了 `Looper` 和 `MessageQueue` ，并且没有存储 `Message`对象，后面的几个对象，后面再来看。接下来，看一下构造函数吧


## Handler

### Handler(...)

 `Handler` 的构造函数有好几种
 
 
```
    ...
    public Handler() { this(null, false); }
    
    public Handler(Callback callback) { this(callback, false); }
    
    public Handler(Looper looper) { this(looper, null, false); }
    
    public Handler(Looper looper, Callback callback) { this(looper, callback, false); }
    
    public Handler(boolean async) { this(null, async); }
    
    public Handler(Looper looper, Callback callback, boolean async) {
        mLooper = looper;
        mQueue = looper.mQueue;
        mCallback = callback;
        mAsynchronous = async;
    }
    
    public Handler(Callback callback, boolean async) { ... }
    ...
```

上面给出的构造函数，都指向了最后的两个。

先看第一个，可以知道这个构造函数创建的  `Handler` ，它的 `Looper` 来自于构造函数。并且 `MessageQueue` 是来自于 `Looper` 的

`Callback` 其实是一个接口，里面有一个 `handleMessage` 方法

```
    public interface Callback {
        public boolean handleMessage(Message msg);
    }
```

至于 `mAsynchronous` ,暂时从字面上来看它是用于控制是否异步加载的。不过是不是这样呢？看后面的代码分析就知道了。

接下来，我们看一下 `Handler` 的另外一个构造函数吧

```
    public Handler(Callback callback, boolean async) {
        if (FIND_POTENTIAL_LEAKS) {
            ...
            //如果发现有内存泄漏的可能，提示有内存泄漏的风险
        }

        mLooper = Looper.myLooper();
        if (mLooper == null) {
            //抛出异常
        }
        mQueue = mLooper.mQueue;
        mCallback = callback;
        mAsynchronous = async;
    }
```
上面的代码，我们简化了一下，和之前构造函数不同的是 `Handler` 的 `Looper`是通过 **Looper.myLooper()** 方法传递的，来看一下这个方法


```
public final class Looper {
    ...
    
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
    
    public static @Nullable Looper myLooper() {
        return sThreadLocal.get();
    }
    ...
}
```

可以看到，这个 `Looper` 是通过 `ThreadLocal` 对象获取的, 这里就先不详细介绍 `ThreadLocal` 了(我还没仔细的看它的源码)，但是我们通过它的说明可以知道， `ThreadLocal` 的作用是：

> 每一个 Thread 都会持有自己的局部变量，而 ThreadLocal 是一种管理这些变量的结构，它可以让 Thread 使用它自己的局部变量，而不与其他 Thread 分享。
也就是实现了线程之间的资源隔离，达到安全并发的目的

那么这里的 `Looper` 其实就是获取与当前 `Thread` 关联的  `Looper` 。不过到这里，我就产生了一个疑问，不知道你们有木有：

    `Looper` 和 `Tread` 是一一对应的关系吗？还是其他的关系？
    
这个我们通过后面的源码来解释。

接下来，`Handler` 中，有几个比较典型的方法，通过这些方法，我们可以更加清晰的了解 `Handler` 的作用机制


```
    ...
    
    public void dispatchMessage(Message msg) {...}
    
    public static Handler getMain() {...}
    
    public final boolean post(Runnable r) {
       return  sendMessageDelayed(getPostMessage(r), 0);
    }
    
    public final boolean postDelayed(Runnable r, long delayMillis) {...}
    
    public final boolean sendMessageDelayed(Message msg, long delayMillis) {...}
    
    public final boolean sendEmptyMessage(int what) { return sendEmptyMessageDelayed(what, 0); }
    
    public final boolean sendEmptyMessageDelayed(int what, long delayMillis) {...}
    
    public final boolean sendMessageDelayed(Message msg, long delayMillis) {...}
    
    public boolean sendMessageAtTime(Message msg, long uptimeMillis) {...}
    
    
    
    public final void removeCallbacksAndMessages(Object token) {
        mQueue.removeCallbacksAndMessages(this, token);
    }
    
    
    ...
```

其中，`dispatchMessage`、`postXXXX`、`sendXXXX` 都是我们常用的一些方法，我们来逐个解析

### dispatchMessage(Message msg)


```
    public void dispatchMessage(Message msg) {
        if (msg.callback != null) {
            handleCallback(msg);
        } else {
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            handleMessage(msg);
        }
    }
```
显然，这个方法是用来分发 `Message` 的，先看一下 `Message` 中的 `callback`是什么：

```
public final class Message implements Parcelable {
    ...
    Runnable callback;
    ...
}
```
原来是 `Runnable`，这里也把大家最熟悉的 `Runnable` 贴出来一下:

```
public interface Runnable {
    public abstract void run();
}
```
我们看一下，当 `msg` 中的 `callback`不为空的时候，是怎么处理的

```
    private static void handleCallback(Message message) {
        message.callback.run();
    }
```
其实看到这里上面的分发流程就清楚了：

- 如果 `Message` 中的 `callback` 存在，则优先交给它去处理
- 否则，如果 `Handler` 中的 `mCallback` 存在，则交由这个 `mCallback` 处理
- 否则，交给 `handleMessage()` 处理，也就是你实现的 `Handler` 类，重写了这个方法的话

### getMain()

```
public class Handler {
    ...
    public static Handler getMain() {
        if (MAIN_THREAD_HANDLER == null) {
            MAIN_THREAD_HANDLER = new Handler(Looper.getMainLooper());
        }
        return MAIN_THREAD_HANDLER;
    }
    ...
}


public final class Looper {
    ...
    private static Looper sMainLooper; 
    
    public static Looper getMainLooper() {
        synchronized (Looper.class) {
            return sMainLooper;
        }
    }
    
    public static void prepareMainLooper() {
        prepare(false);
        synchronized (Looper.class) {
            if (sMainLooper != null) {
                throw new IllegalStateException("The main Looper has already been prepared.");
            }
            sMainLooper = myLooper();
        }
    }
    
    private static void prepare(boolean quitAllowed) {
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new Looper(quitAllowed));
    }
    ...
}


```

上面还贴了一段和 `getMain()` 相关的 `Looper` 的方法

`getMain()` 就是用来获取引用了 **主线程Looper** 的 `Handler`,从这一段代码其实就可以看出，每个 `Handler` 对此方法未做限制，也就是说一个**主线程Looper**是可以对应多个 `Handler` 的

然后是 `Looper` 中，关于`prepareMainLooper()`方法其实还有一段说明，上面没贴出来，意思是：
> prepareMainLooper()用于初始化主线程的Looper，它是由系统调用的，所以作为开发者，你不应该调用这个方法(ps:那为什么不设置成private的呢，也许是为了方便系统调用？)

再看一下 `prepare(boolean quitAllowed)` 方法，他是用于给当前线程设置 `Looper` 对象的。从这里就可以看出，一个线程只能有一个 `Looper` 对象，多了的话，就会报错啦！

接下来，看一下比较常用的 `postXXXX(...)` 、`sendXXXX(...)`相关的方法,我们经常用它去进行通知操作。

### postXXXX(...) && sendXXXX(...)


```
    ...
    public final boolean post(Runnable r) {
       return  sendMessageDelayed(getPostMessage(r), 0);
    }
    
    public final boolean postAtTime(Runnable r, long uptimeMillis) {
        return sendMessageAtTime(getPostMessage(r), uptimeMillis);
    }
    
    public final boolean sendMessageDelayed(Message msg, long delayMillis) {
        if (delayMillis < 0) { delayMillis = 0; }
        return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
    }
    
    private static Message getPostMessage(Runnable r) {
        Message m = Message.obtain();
        m.callback = r;
        return m;
    }
    
    public final boolean sendMessage(Message msg) {
        return sendMessageDelayed(msg, 0);
    }
    
    public final boolean sendEmptyMessage(int what) {
        return sendEmptyMessageDelayed(what, 0);
    }
    
    public final boolean sendEmptyMessageDelayed(int what, long delayMillis) {
        Message msg = Message.obtain();
        msg.what = what;
        return sendMessageDelayed(msg, delayMillis);
    }
    
    public final boolean sendMessageDelayed(Message msg, long delayMillis) {
        if (delayMillis < 0) { delayMillis = 0; }
        return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
    }
    
```

`post` 传递的 `Runnable` 会被设置到 `Message` 中去, `send` 传递的 `waht` 也会被设置到 `Message` 中去，`Message.obtain()` 我们后面再看。

这些方法最终都会走到 `sendMessageAtTime` 的方法中去，所以我们直接看这个吧

### sendMessageAtTime(...)

```
    public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }
```

`sendMessageAtTime` 方法又会调用 `enqueueMessage`


```
    private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
```

`Message` 中的 `target` 是一个 `Handler` 对象,从这个方法其实可以知道一个 `Message` 对应一个  `Handler` ，但是一个 `Handler` 可以对应多个 `Message` 。因为一个 `Handler` 可以 `post` 多次，但是一个 `Message` 只有一个  `target`

上面的方法，就是向 `MessageQueue` 中插入一个 `Message`, 到这里Handler的部分大概就结束了。

接下来, 我们对于 `MessageQueue` 和  `Message`  的分析就要开始啦

我们先简单分析一下 `Message` 对象

## Message


```
public final class Message implements Parcelable {
    ...
    public int what;
    public Object obj;
    public long when;
    Handler target;
    Runnable callback;
    Message next;
    
    public static final Object sPoolSync = new Object();
    private static Message sPool;
    private static int sPoolSize = 0;

    private static final int MAX_POOL_SIZE = 50;
    
}
```

上面的 `sPoolSync` 的作用是实现 **对象锁**， 它分别在获取 `Message`对象的 `obtain()` 方法以及回收  `Message` 对象的 `recycleUnchecked()` 方法中使用到

看到上面的 `next` 对象，熟悉的队列结构，所以 `Message` 其实是一个队列

而 `sPool` 作为一个静态对象，再根据它的命名来看，初步判断它是一个维护多个 `Message` 的队列，最大长度是 **50** ，作用是复用 `Message` 吗？来看一看代码就知道了


### obtain()


```
    public static Message obtain() {
        synchronized (sPoolSync) {
            if (sPool != null) {
                Message m = sPool;
                sPool = m.next;
                m.next = null;
                m.flags = 0; // clear in-use flag
                sPoolSize--;
                return m;
            }
        }
        return new Message();
    }
```

可以看到，上面的代码逻辑如下：
- 当 `sPool` 不为空的时候，从 `sPool` 取出队列头对象，并返回这个对象
- `sPool` 为空的话，就直接返回一个新的 `Message` 对象啦！

我们之前在 `Handler` 中遇到过的各种 `post` 方法，使用的 `Message` 就是这样获得的

`Message` 还剩下一个 `recycleUnchecked()` 方法需要了解一下，因为剩下的都比较简单，不需要进行分析了



### recycleUnchecked()

```
    public void recycle() {
        if (isInUse()) {
            ...
            return;
        }
        recycleUnchecked();
    }
    
    void recycleUnchecked() {
        flags = FLAG_IN_USE;
        //这里进行各种置空、状态初始化操作
        ...
        synchronized (sPoolSync) {
            if (sPoolSize < MAX_POOL_SIZE) {
                next = sPool;
                sPool = this;
                sPoolSize++;
            }
        }
    }
```

可以看到，上面的回收操作，其实就是将这个 `Message` 对象 **进行还原**，然后放入 `sPool` 的队列头中，也就是说，我们之前对于 `sPool` 复用的猜想，是正确的。

接下来，开始康康 `MessageQueue` 吧

## MessageQueue


### MessageQueue(boolean quitAllowed)
先来看构造函数吧

```
    private final boolean mQuitAllowed;
    private long mPtr;
    
    MessageQueue(boolean quitAllowed) {
        mQuitAllowed = quitAllowed;
        mPtr = nativeInit();
    }
    
    private native static long nativeInit();
```

在之前，我们看 `Looper` 的 `prepare()` 和 `prepareMainLooper()` 方法中，都会创建一个新的 `Looper` 对象，我们看一下 `Looper` 的构造函数

```
    private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
        mThread = Thread.currentThread();
    }
```
可以知道，`MessageQueue` 是在 `Looper` 创建的时候，一起创建的。

同时， `prepareMainLooper()`中的 `quitAllowed` 是 **false**, 这表示，由 `主线程Looper` 创建的 `MessageQueue` 是不允许退出的。至于原因嘛，因为这个 `MessageQueue` 是和当前app共同生存的呀，退出了app也就结束了。具体的逻辑，再看后面的代码吧。

关于 `mPtr` 对象的作用，因为涉及到 **native** 方法，所以它已经不是java层面的内容了，我查阅了一下

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/handler_sourcecode/001.jpg)

是调用的 C++ 方法，并且从上面这个方法可以看出来，在 C++ 层面创建了另一个 `NativeMessageQueue` 对象，并且返回的内容看起来是可以用来和 `NativeMessageQueue` 对象进行关联的值

`MessageQueue` 许多方法都是和 **native** 进行交互的，暂时先不管(主要是也管不了)，我们这里就先看一下之前在 `Handler` 中的 `enqueueMessage` 和 `removeMessages` 方法，它们都调用到了 `MessageQueue` 相对应的方法

### enqueueMessage(Message msg, long when)


```
    boolean enqueueMessage(Message msg, long when) {
        ...
        ///target为空或者isInUse()的话就抛出异常
        ...
        synchronized (this) {
            //如果正在退出，回收当前 msg，并返回false
            ...
            msg.markInUse();
            msg.when = when;
            Message p = mMessages;
            boolean needWake;
            if (p == null || when == 0 || when < p.when) {
                // New head, wake up the event queue if blocked.
                msg.next = p;
                mMessages = msg;
                needWake = mBlocked;
            } else {
                needWake = mBlocked && p.target == null && msg.isAsynchronous();
                Message prev;
                for (;;) {
                    prev = p;
                    p = p.next;
                    if (p == null || when < p.when) {
                        break;
                    }
                    if (needWake && p.isAsynchronous()) {
                        needWake = false;
                    }
                }
                msg.next = p; // invariant: p == prev.next
                prev.next = msg;
            }

            // We can assume mPtr != 0 because mQuitting is false.
            if (needWake) {
                nativeWake(mPtr);
            }
        }
        return true;
    }
```
上面的代码中，可以把第一个 **if** 逻辑简单改一下，看起来更加清晰：

```
            ...
            Message p = mMessages;
            if (p == null || when == 0 || when < p.when) {
                // New head, wake up the event queue if blocked.
                msg.next = null;
                mMessages = msg;
                needWake = mBlocked;
            } 
```
可以看到， `MessageQueue` 中本身就存放了一个 `Message` 对象: `mMessages`

所以第一个 **if** 的逻辑就是：
- 当 `mMessages` 为 **null** 时，`mMessages` 队列设置成只有一个节点，这个节点就由插入的 `msg` 提供，并且如果此时 `event quene` 处于阻塞状态的话，就唤醒它

接下来看 **else** 的逻辑：
- 遍历 `mMessages` 队列，根据 `when` 的大小来决定插入的地方，`when` 越小越靠近队列头部。
- 只有当`event quene` 头部阻塞了并且队列中存在很早添加的 **异步** `Message` 对象的时候才去唤醒

然后是 `removeMessages(...)` 、`removeCallbacksAndMessages(...)`方法，也是遍历 `mMessages` 对  `Message` 对象进行删除。因为都调用到了 `Message` 对象的 `recycleUnchecked()` 方法，所以被 **remove** 掉的对象，会以初始状态存储在 `Message` 的 `sPool` 中方便复用

 `MessageQueue` 还有一个最为关键的方法 `next()`, 在分析这个方法之前, 我们先解决掉 `Looper`是如何分发 `Message` 的，一起来瞧一瞧

## Looper


```
public final class Looper {
    ...
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
    private static Looper sMainLooper;
    final MessageQueue mQueue;
    final Thread mThread;
    
    private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
        mThread = Thread.currentThread();
    }
    
    public static void prepareMainLooper() {...}
    
    public static Looper getMainLooper() {...}
    
    public static void loop() {...}
    
}
```
除了 `loop()` 方法外，其他的部分在前面已经分析过了，这里直接开始看 `loop()` 吧

### loop()


```
    public static void loop() {
        final Looper me = myLooper();
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
        final MessageQueue queue = me.mQueue;

        // Make sure the identity of this thread is that of the local process,
        // and keep track of what that identity token actually is.
        Binder.clearCallingIdentity();
        final long ident = Binder.clearCallingIdentity();

        for (;;) {
            Message msg = queue.next(); // might block
            if (msg == null) {
                // No message indicates that the message queue is quitting.
                return;
            }

            ...
            
            try {
                msg.target.dispatchMessage(msg);
            } finally {
                if (traceTag != 0) {
                    Trace.traceEnd(traceTag);
                }
            }

            ...

            msg.recycleUnchecked();
        }
    }
```

上面选取的是 `loop()` 方法中,和 `Message` 相关的部分.

可以看到, `loop()` 就是在一个**死循环**中,通过 `MessageQuene` 的 `next()` 方法来获取 `Message`, 然后调用这个 `Message` 持有的 `Handler` 对象的 `dispatchMessage(msg)` 方法来分发 `Message`. 

只有当 `queue.next()` 返回 **null** 的时候,循环才能停止

关于 **Looper** 就到这里


最后,我们再来看 `MessageQueue` 中最关键的一个方法: `next()`

### MessageQueue -> next()

`next()` 的逻辑操作比较多,其中还有一部分是关于 `IdelHandler` 的,这里就先不管他们,只看主要的部分


```
    Message next() {
        //判断ptr值,为0的话,说明C++那里的NativeMessageQuene已经destory了,直接返回null
        ...

        int pendingIdleHandlerCount = -1; // -1 only during first iteration
        int nextPollTimeoutMillis = 0;
        for (;;) {
            if (nextPollTimeoutMillis != 0) {
                Binder.flushPendingCommands();
            }

            nativePollOnce(ptr, nextPollTimeoutMillis);

            synchronized (this) {
                // Try to retrieve the next message.  Return if found.
                final long now = SystemClock.uptimeMillis();
                Message prevMsg = null;
                Message msg = mMessages;
                if (msg != null && msg.target == null) {
                    // Stalled by a barrier.  Find the next asynchronous message in the queue.
                    do {
                        prevMsg = msg;
                        msg = msg.next;
                    } while (msg != null && !msg.isAsynchronous());
                }
                if (msg != null) {
                    if (now < msg.when) {
                        // Next message is not ready.  Set a timeout to wake up when it is ready.
                        nextPollTimeoutMillis = (int) Math.min(msg.when - now, Integer.MAX_VALUE);
                    } else {
                        // Got a message.
                        mBlocked = false;
                        if (prevMsg != null) {
                            prevMsg.next = msg.next;
                        } else {
                            mMessages = msg.next;
                        }
                        msg.next = null;
                        if (DEBUG) Log.v(TAG, "Returning message: " + msg);
                        msg.markInUse();
                        return msg;
                    }
                } else {
                    // No more messages.
                    nextPollTimeoutMillis = -1;
                }

                // Process the quit message now that all pending messages have been handled.
                if (mQuitting) {
                    dispose();
                    return null;
                }
                
                ...
                //IdelHandler相关操作
                ...
            }
            
            ...
            //IdelHandler相关操作
            ...

            nextPollTimeoutMillis = 0;
        }
    }
```

来逐步分析一下上面的代码:

`pendingIdleHandlerCount` 和 `IdleHandler` 有关,暂时不管

`nextPollTimeoutMillis` 表示休眠时间,当还没有到达 `Message` 中 `when` 所指定的时间时, 会先去处理 `IdleHandler` ,此时没有 `IdleHandler` 可供处理的话,就会进入休眠时间,并在指定时间唤醒, 对应代码:

```
if (now < msg.when) {
    // Next message is not ready.  Set a timeout to wake up when it is ready.
    nextPollTimeoutMillis = (int) Math.min(msg.when - now, Integer.MAX_VALUE);
} 
```

我们接下来看第一个 **if** 的逻辑:
- 如果 `msg.target` 为 **null**, 表示遇到了一个障碍,因为只有在 `Message` 回收的时候才会将 `target` 置空,所以这里我们需要寻找下一个 **异步的Message**

然后开始看第二个 **if**:
- 当 `msg` 不为 null时
    - 如果 `now < msg.when`,说明未到这个msg的执行时间,设置休眠时间 `nextPollTimeoutMillis`,之后会去处理 `IdelHandler`,这个循环会持续下去,直到时间可以处理这个 `msg` 为止
    - 否则,返回这个 `msg`,如果`prevMsg` 不为 **null** 的话,就说明这个 `msg` 是之前遇到障碍时,所找到的 **异步Message**; 不然就是常规的 `msg`
- 否则,将 `nextPollTimeoutMillis` 设置为 -1. 此时,表明 `MessageQuene` 已经没有可以消耗的 `Message` 啦. **for** 循环会一直执行,此时就会进入阻塞状态啦.

当进入阻塞状态的时候,就有很多问题了,比如:  

**1.“UI线程为什么没有因此卡死?”**  
**2.“没看见哪里有相关代码为这个死循环准备了一个新线程去运转？”**  
**3.“Activity的生命周期这些方法这些都是在主线程里执行的吧，那这些生命周期方法是怎么实现在死循环体外能够执行起来的？”**  
**4.“什么时候会退出阻塞?”**  

下面,对于这些问题来进行解释(此处Google了不少):

#### 1.UI线程为什么没有因此卡死?

这里涉及**线程**，先说说说**进程/线程**.

**进程**：每个app运行时前首先创建一个进程，该进程是由Zygote fork出来的，用于承载App上运行的各种Activity/Service等组件。进程对于上层应用来说是完全透明的，这也是google有意为之，让App程序都是运行在Android Runtime。大多数情况一个App就运行在一个进程中，除非在AndroidManifest.xml中配置Android:process属性，或通过native代码fork进程。

**线程**：线程对应用来说非常常见，比如每次new Thread().start都会创建一个新的线程。该线程与App所在进程之间资源共享，从Linux角度来说进程与线程除了是否共享资源外，并没有本质的区别，都是一个task_struct结构体，**在CPU看来进程或线程无非就是一段可执行的代码**，CPU采用CFS调度算法，保证每个task都尽可能公平的享有CPU时间片。

有了这些准备，再说说**死循环**问题：

对于线程既然是一段可执行的代码，当可执行代码执行完成后，线程生命周期便该终止了，线程退出。而对于主线程，我们是绝不希望会被运行一段时间，自己就退出，那么如何保证能一直存活呢？简单做法就是可执行代码是能一直执行下去的，**死循环便能保证不会被退出**，例如，binder线程也是采用死循环的方法，通过循环方式不同与Binder驱动进行读写操作，当然并非简单地死循环，无消息时会休眠。

真正会卡死主线程的操作是在回调方法onCreate/onStart/onResume等操作时间过长，会导致掉帧，甚至发生ANR，looper.loop本身不会导致应用卡死。

但这里可能又引发了另一个问题，既然是死循环又如何去处理其他事务呢？通过创建新线程的方式。

#### 2.没看见哪里有相关代码为这个死循环准备了一个新线程去运转？

事实上，会在进入死循环之前便创建了新 `Binder` 线程，在代码 `ActivityThread.main()` 中：


```
public static void main(String[] args) { 
      .... 
      //创建Looper和MessageQueue对象，用于处理主线程的消息 
      Looper.prepareMainLooper(); 
      //创建ActivityThread对象 
      ActivityThread thread = new ActivityThread(); 
      //建立Binder通道 (创建新线程) 
      thread.attach(false); 
      Looper.loop(); //消息循环运行
      throw new RuntimeException("Main thread loop unexpectedly exited"); 
}
```
`thread.attach(false)` 便会创建一个 `Binder` 线程（具体是指 `ApplicationThread` ，`Binder` 的服务端，用于接收系统服务**AMS**发送来的事件），该 `Binder` 线程通过 `Handler` 将 `Message` 发送给主线程,具体过程可查看 [startService流程分析](http://gityuan.com/2016/03/06/start-service/)

另外，`ActivityThread` 实际上并非线程，不像 `HandlerThread` 类，`ActivityThread` 并没有真正继承 `Thread` 类，只是往往运行在主线程，给人以线程的感觉，其实承载 `ActivityThread` 的主线程就是由 **Zygote fork** 而创建的进程。

主线程的死循环一直运行是不是特别消耗CPU资源呢？ 其实不然，这里就涉及到 **Linux pipe/epoll** 机制，简单说就是在主线程的 `MessageQueue` 没有消息时，便阻塞在 `Looper` 的 `queue.next()` 中的 `nativePollOnce()` 方法里，此时主线程会释放CPU资源进入休眠状态，直到下个消息到达或者有事务发生，通过往 **pipe管道** 写端写入数据来唤醒主线程工作,也就是 `MessageQueue` 中 `enqueueMessage(...)` 方法被调用时, `Message` 被添加到空的队列中触发的 `nativeWake(mPtr)` 方法。

这里采用的 **epoll机制**，是一种IO多路复用机制，可以同时监控多个描述符，当某个描述符就绪(读或写就绪)，则立刻通知相应程序进行读或写操作，本质同步I/O，即读写是阻塞的。 所以说，主线程大多数时候都是处于休眠状态，并不会消耗大量CPU资源。

#### 3.Activity的生命周期是怎么实现在死循环体外能够执行起来的？

`ActivityThread` 的内部类 `H` 继承于 `Handler`，通过 `Handler` 消息机制，简单说 `Handler` 机制用于同一个进程的线程间通信。

`Activity` 的生命周期都是依靠主线程的 `Looper.loop()` ，当收到不同 `Message` 时则采用相应措施：

在 `H.handleMessage(msg)` 方法中，根据接收到不同的 `msg`，执行相应的生命周期。

比如收到 `msg.what=H.LAUNCH_ACTIVITY`，则调用 `ActivityThread.handleLaunchActivity()` 方法，最终会通过反射机制，创建 `Activity` 实例，然后再执行 `Activity.onCreate()` 等方法；

再比如收到 `msg.what=H.PAUSE_ACTIVITY`，则调用 `ActivityThread.handlePauseActivity()` 方法，最终会执行 `Activity.onPause()` 等方法。 上述过程，只挑核心逻辑讲，真正该过程远比这复杂。

**主线程的消息又是哪来的呢?** 当然是App进程中的其他线程通过Handler发送给主线程，请看接下来的内容：

最后，从进程与线程间通信的角度，通过一张图加深大家对App运行过程的理解：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/handler_sourcecode/002.jpg)

**system_server进程是系统进程**，java framework框架的核心载体，里面运行了大量的系统服务，比如这里提供ApplicationThreadProxy（简称ATP），ActivityManagerService（简称AMS），这个两个服务都运行在system_server进程的不同线程中，由于ATP和AMS都是基于IBinder接口，都是binder线程，binder线程的创建与销毁都是由binder驱动来决定的。

**App进程则是我们常说的应用程序**，主线程主要负责Activity/Service等组件的生命周期以及UI相关操作都运行在这个线程； 另外，每个App进程中至少会有两个binder线程 ApplicationThread(简称AT)和ActivityManagerProxy（简称AMP），除了图中画的线程，其中还有很多线程，比如signal catcher线程等，这里就不一一列举。

Binder用于不同进程之间通信，由一个进程的Binder客户端向另一个进程的服务端发送事务，比如图中线程2向线程4发送事务；而handler用于同一个进程中不同线程的通信，比如图中线程4向主线程发送消息。

**结合图说说Activity生命周期，比如暂停Activity**，流程如下：

- 1.线程1的AMS中调用线程2的ATP；（由于同一个进程的线程间资源共享，可以相互直接调用，但需要注意多线程并发问题）
- 2.线程2通过binder传输到App进程的线程4；
- 3.线程4通过handler消息机制，将暂停Activity的消息发送给主线程；
- 4.主线程在looper.loop()中循环遍历消息，当收到暂停Activity的消息时，便将消息分发给ActivityThread.H.handleMessage()方法，再经过方法的调用，最后便会调用到Activity.onPause()，当onPause()处理完后，继续循环loop下去。
 
# 总结


回顾一下之前的 `Handler` 流程，总结一下就是：

- 创建 `Handler` : 因为 `Handler` 需要获取当前线程的 `Looper` ，如果不是在主线程创建，则需要先调用 `Looper.prepare()` 给当前线程创建一个 `Looper`
-  `Looper` 初始化 : 一个 `Looper` 在创建的同时，也会创建一个 `MessageQuene` 与之对应
- 发送 `Message` : `Handler` 调用 `postXXX` 方法，会通过 `Looper` 进入到 `MessageQuene` 的 `enqueueMessage(...)` 方法。这个方法会在 `MessageQuene` 中维护的 `Message` 队列插入 `Message`，插入顺序根据  `Message` 的 `when` 来决定
- 复用 `Message` : `Message` 中存在一个静态变量 `sPool` ,它用于复用  `Message` ，每当 `MessageQuene` 中的 `Message` 被回收掉时，就会调用 `Message` 对象的 `recycleUnchecked()` 方法， `sPool` 就会新增一个节点。它的最大长度是50。而 `Handler` 调用 `postXXX` 相关方法时候，传递给 `MessageQuene` 的 `Message` 就是从这里复用的，没有可复用的对象时候，会创建新的 `Message` 
- 进入循环：通过 `Looper` 的 `loop()` 方法，会一直调用 `MessageQuene` 的 `next()` 方法来获取 `Message`，并通过这个  `Message` 中的 `Handler`对象 `target` 的 `dispatchMessage()` 方法，来进行事件的分发
- 事件分发：有三个优先级分别处理 `msg` 对象：
    - 如果 `msg` 的 `Runnable` 对象存在，交给它处理，否则下一步
    - 如果 `Handler` 的 `CallBack` 对象存在，调用 `CallBack`的 `handleMessage(msg)` 方法 ，返回 **true** 的话结束，否则继续下一步
    - 交给 `Handler` 的  `handleMessage(msg)` 方法
- 循环结束 : `Looper` 通过 `quit()` 方法结束循环，不过主线程的 `Looper` 是无法退出的，具体原因上面已经说明


那么，关于 `Handler` 相关源码就到此结束了！