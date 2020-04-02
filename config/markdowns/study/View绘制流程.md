---
title: View绘制流程
date: 2020-03-29 02:59:57
index_img: /img/view_step.png
tags: 源码系列
---
# 序

上一篇分析完了Activity的启动流程。这一篇就要来分析View的绘制流程啦。


# 引子

每次分析都需要一个入口。那么这次入口在哪里呢？有过自定义View经验的同学都遇到过那三个熟知的方法: `onMeasure`、`onLayout`、`onDraw` 

所以一般都会从这里开始入手，不过因为刚刚了解了Activity的启动流程，所以这里我们会从启动流程的末尾部分开始作为入口进行分析

# 开始

在之前的文章 [Activity启动流程分析](http://oldben.gitee.io/flutter-blog/#/articlePage/Activity%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B%E5%88%86%E6%9E%90) 中，有介绍过，Activity启动流程最后需要经过 `ActivityThread` 的 `performLaunchActivity(...)` 方法


## 开始之前

在 `ActivityThread` 的 `performLaunchActivity(...)` 方法中，调用了下面的方法：

```
    private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
                ...
                activity.attach(appContext, this, getInstrumentation(), r.token,
                        r.ident, app, r.intent, r.activityInfo, title, r.parent,
                        r.embeddedID, r.lastNonConfigurationInstances, config,
                        r.referrer, r.voiceInteractor, window, r.configCallback);
                ...
                if (r.isPersistable()) {
                    mInstrumentation.callActivityOnCreate(activity, r.state, r.persistentState);
                } else {
                    mInstrumentation.callActivityOnCreate(activity, r.state);
                }
                ...
    }
```
在我们熟知的 Activity的生命周期里，`attach(...)` 方法是就用于做周期前的准备工作。

我们看一下它具体都做了些什么：


```
    //Activity
    
    private Window mWindow;

    final void attach(Context context, ActivityThread aThread,
            Instrumentation instr, IBinder token, int ident,
            Application application, Intent intent, ActivityInfo info,
            CharSequence title, Activity parent, String id,
            NonConfigurationInstances lastNonConfigurationInstances,
            Configuration config, String referrer, IVoiceInteractor voiceInteractor,
            Window window, ActivityConfigCallback activityConfigCallback) {
        ...        
        mWindow = new PhoneWindow(this, window, activityConfigCallback);
        ...
        mWindow.setWindowManager(...);
    }

```


上面的内容主要展示了 `PhoneWindow` 对象的初始化。在这里，就简单看一下 `Window` 和 `PhoneWindow` 的关系吧：


```
//Window
public abstract class Window {...}

//PhoneWindow
public class PhoneWindow extends Window implements MenuBuilder.Callback {...}
```
可以看到，`Window` 是一个抽象类，而 `PhoneWindow` 是 `Window` 的子类，算是`Window` 的实现之一。


我们已经知道了在 `attach(...)` 中初始化了 `PhoneWindow` 对象，那么接下来的流程该往哪里走呢？


我们知道，Activity的生命周期，从 `onCreate` 开始，到 `onStart` 再到 `onResume`, 而在 `attach(...)` 之后，就会通过 `Instrumentation` 进入到 Activity的 `onCreate`中。

由于这篇文章主要关注 **View的绘制流程**，所以生命周期相关的流程，不会详细到每一步。我们看一下到了 `onCreate` 中具体做了些什么


```
    @CallSuper
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        ...
        mFragments.dispatchCreate();
        getApplication().dispatchActivityCreated(this, savedInstanceState);
        ...
    }
```
在 `onCreate` 中，并没有找到和View相关的内容。但是我们知道,我们每写的 `Activity` 的 `onCreate` 方法中,都存在一个方法 `setContentView(...)` 方法,它做了些什么呢?我们看一下

```
    //AppCompatActivity
    @Override
    public void setContentView(@LayoutRes int layoutResID) {
        getDelegate().setContentView(layoutResID);
    }
    ...
    //AppCompatDelegateImpl
    @Override
    public void setContentView(int resId) {
        ensureSubDecor();
        ...
    }
    ...
    private void ensureSubDecor() {
        if (!mSubDecorInstalled) {
            mSubDecor = createSubDecor();
            ...
        }
        ...
    }
    ...
    private ViewGroup createSubDecor() {
        ...
        mWindow.getDecorView();
        ...
    }
    ...
    //PhoneWindow
    @Override
    public final View getDecorView() {
        if (mDecor == null || mForceDecorInstall) {
            installDecor();
        }
        return mDecor;
    }

```
可以看到,在 `setContentView(...)` 中,我们对 `AppCompatDelegateImpl` 的各种方法调用,最后来到 `PhoneWindow` 的 `getDecorView()` 中,通过 `installDecor()` 完成了 `DecorView` 的初始化。当然,除了这些,还有其他布局的初始化等,在这里就不详说了。既然在 `onCreate` 中创建了 `DecorView` 

那么后面两个生命周期呢？

接下来我们去另外两个生命周期看一看，不过这时候问题来了。另外两个生命周期是怎么走到的？

看来，我们有必要先了解一下，在哪里我们会进入  `onStart` 和  `onResume`

## 生命周期

在上一篇，[Activity启动流程分析](http://oldben.gitee.io/flutter-blog/#/articlePage/Activity%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B%E5%88%86%E6%9E%90) 中，我们知道跳转到 `ActivityThread` 之前，是在 `ActivityStackSupervisor` 内的 `realStartActivityLocked(...)` 开启事务处理的：


```
    //ActivityStackSupervisor
    
    final boolean realStartActivityLocked(ActivityRecord r, ProcessRecord app,
            boolean andResume, boolean checkConfig) throws RemoteException {
                
                ...
                // Create activity launch transaction.
                final ClientTransaction clientTransaction = ClientTransaction.obtain(app.thread,
                        r.appToken);
                clientTransaction.addCallback(LaunchActivityItem.obtain(new Intent(r.intent),
                        System.identityHashCode(r), r.info,
                        // TODO: Have this take the merged configuration instead of separate global
                        // and override configs.
                        mergedConfiguration.getGlobalConfiguration(),
                        mergedConfiguration.getOverrideConfiguration(), r.compat,
                        r.launchedFromPackage, task.voiceInteractor, app.repProcState, r.icicle,
                        r.persistentState, results, newIntents, mService.isNextTransitionForward(),
                        profilerInfo));

                // Set desired final state.
                final ActivityLifecycleItem lifecycleItem;
                if (andResume) {
                    lifecycleItem = ResumeActivityItem.obtain(mService.isNextTransitionForward());
                } else {
                    lifecycleItem = PauseActivityItem.obtain();
                }
                clientTransaction.setLifecycleStateRequest(lifecycleItem);

                // Schedule transaction.
                mService.getLifecycleManager().scheduleTransaction(clientTransaction);
                ...
                
    }
```
这之间的逻辑会比较扩散，可以参考一下上一篇最后两种总结图的 `Activity流程总结图` 第14步到第15步。

`mService.getLifecycleManager()` 获取的 `ClientLifecycleManager` 对象，通过调用这个对象的 `scheduleTransaction(...)` 方法，就开始了接下来的内容


```
//1.scheduleTransaction(...)
class ClientLifecycleManager {
    ...
    void scheduleTransaction(ClientTransaction transaction) throws RemoteException {
        final IApplicationThread client = transaction.getClient();
        transaction.schedule();
        ...
    }
    ...
}

//2.schedule()
public class ClientTransaction implements Parcelable, ObjectPoolItem {
    ...
    private IApplicationThread mClient;
    ...
    public void schedule() throws RemoteException {
        mClient.scheduleTransaction(this);
    }
    ...
}

//3.scheduleTransaction(...)
public final class ActivityThread extends ClientTransactionHandler {
    ...
    private class ApplicationThread extends IApplicationThread.Stub {
        ...
        @Override
        public void scheduleTransaction(ClientTransaction transaction) throws RemoteException {
            ActivityThread.this.scheduleTransaction(transaction);
        }
        ...
    }
    ...
}

//4.scheduleTransaction(...)
public abstract class ClientTransactionHandler {
    ...
    void scheduleTransaction(ClientTransaction transaction) {
        transaction.preExecute(this);
        sendMessage(ActivityThread.H.EXECUTE_TRANSACTION, transaction);
    }
    ...
}

//5.EXECUTE_TRANSACTION
public final class ActivityThread extends ClientTransactionHandler {
    ...
    class H extends Handler {
        ...
        public void handleMessage(Message msg) {
            switch (msg.what) {
                ...
                case EXECUTE_TRANSACTION:
                    final ClientTransaction transaction = (ClientTransaction) msg.obj;
                    mTransactionExecutor.execute(transaction);
                    ...
                    break;
                ...
            }
        ...
    }
    ...
}

```
可以看到，上面走到第五步之后，会来到 `TransactionExecutor` 对象的 `execute` 方法。

而 `TransactionExecutor` 正是切换各个生命周期非常重要的一个对象

### TransactionExecutor

```
public class TransactionExecutor {
    ...
    public void execute(ClientTransaction transaction) {
        ...
        executeCallbacks(transaction);

        executeLifecycleState(transaction);
        ...
    }
    
    public void executeCallbacks(ClientTransaction transaction) {
        final List<ClientTransactionItem> callbacks = transaction.getCallbacks();
        ...
        final int size = callbacks.size();
        for (int i = 0; i < size; ++i) {
            ...
            item.execute(mTransactionHandler, token, mPendingActions);
            item.postExecute(mTransactionHandler, token, mPendingActions);
            ...
        }
        ...
    }
    
    private void executeLifecycleState(ClientTransaction transaction) {
        final ActivityLifecycleItem lifecycleItem = transaction.getLifecycleStateRequest();
        ...
        cycleToPath(r, lifecycleItem.getTargetState(), true /* excludeLastState */);
        lifecycleItem.execute(mTransactionHandler, token, mPendingActions);
        lifecycleItem.postExecute(mTransactionHandler, token, mPendingActions);
    }
    
    ...
    
}
```
上面的 `executeCallbacks(...)` 是处理我们之前传入的 `LaunchActivityItem` 对象，最后会执行到它的 `execute()` 方法，然后走到 `ActivityThread` 的 `handleLaunchActivity` 方法去初始化一个Activity。但在这里我们不关心这个，我们主要关心生命周期到底是如何执行到 `onStart` 和 `onResume` 的

所以，这里需要关注 `executeLifecycleState(...)` 方法，因为它才和生命周期有关。

上面的 `ActivityLifecycleItem` 对象，就是之前在 `realStartActivityLocked(...)`方法中传入的 `ResumeActivityItem` , 而每个Item都对应了一个生命周期：

- `onCreate` : 无对应Item
- `onStart` : 无对应Item
- `onResume` : 对应 `ResumeActivityItem`
- `onPause` : 对应 `PauseActivityItem`
- `onStop` : 对应 `StopActivityItem`
- `onDestory`: 对应  `DestroyActivityItem`
- `onRestart`: 无对应Item

我们可以先看一下 `ResumeActivityItem` 中的  `execute(...)` 方法


```
    //ResumeActivityItem
    
    @Override
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        ...
        client.handleResumeActivity(token, true /* finalStateRequest */, mIsForward,
                "RESUME_ACTIVITY");
        ...
    }
```
这里的 **client** 对象自然是继承了 `ClientTransactionHandler` 的 `ActivityThread`

如果看过其他 **Item** 代码的话，会发现每一个的 `execute(...)` 方法，都会调用到 `ActivityThread` 中对应的 `handle...Activity(...)` 方法，也会在那个方法执行到对应的生命周期

比如 `handleStopActivity(...)` 就执行 `onStop` 生命周期相关逻辑， `handleStartActivity(...)` 执行 `onStart` 生命周期相关逻辑。

但是到这里问题又来了。 `onStart` 到底是谁执行的？在哪里执行的？到现在也没看到。

这里，我们继续关注 `executeLifecycleState(...)` 方法，其中还有一个 `cycleToPath(...)`，它也是执行生命周期的组成部分。

因为上面的某些生命周期没有对应 **Item** 去执行 `handle...Activity(...)`方法，所以会通过其他方法调用 `handle...Activity(...)` ，这里就是其中之一


```
    private void cycleToPath(ActivityClientRecord r, int finish,
            boolean excludeLastState) {
        final int start = r.getLifecycleState();
        final IntArray path = mHelper.getLifecyclePath(start, finish, excludeLastState);
        performLifecycleSequence(r, path);
    }
    
    private void performLifecycleSequence(ActivityClientRecord r, IntArray path) {
        final int size = path.size();
        for (int i = 0, state; i < size; i++) {
            state = path.get(i);
            log("Transitioning to state: " + state);
            switch (state) {
                case ON_CREATE:
                    mTransactionHandler.handleLaunchActivity(r, mPendingActions,
                            null /* customIntent */);
                    break;
                case ON_START:
                    mTransactionHandler.handleStartActivity(r, mPendingActions);
                    break;
                case ON_RESUME:
                    mTransactionHandler.handleResumeActivity(r.token, false /* finalStateRequest */,
                            r.isForward, "LIFECYCLER_RESUME_ACTIVITY");
                    break;
                case ON_PAUSE:
                    mTransactionHandler.handlePauseActivity(r.token, false /* finished */,
                            false /* userLeaving */, 0 /* configChanges */, mPendingActions,
                            "LIFECYCLER_PAUSE_ACTIVITY");
                    break;
                case ON_STOP:
                    mTransactionHandler.handleStopActivity(r.token, false /* show */,
                            0 /* configChanges */, mPendingActions, false /* finalStateRequest */,
                            "LIFECYCLER_STOP_ACTIVITY");
                    break;
                case ON_DESTROY:
                    mTransactionHandler.handleDestroyActivity(r.token, false /* finishing */,
                            0 /* configChanges */, false /* getNonConfigInstance */,
                            "performLifecycleSequence. cycling to:" + path.get(size - 1));
                    break;
                case ON_RESTART:
                    mTransactionHandler.performRestartActivity(r.token, false /* start */);
                    break;
                default:
                    throw new IllegalArgumentException("Unexpected lifecycle state: " + state);
            }
        }
    }
```
在上面的方法可以看到，会在一个for循环中，根据传入的 `IntArray` 来执行对应方法。

从 **ON_CREATE** 到 **ON_RESTART** 的值分别是从1到7递增。而传递进入的 `IntArray` 会根据 `start`、`finish` 以及 `TransactionExecutorHelper` 的 `getLifecyclePath(...)` 方法来得出结果。

在这里，因为此前已经执行了 `onCreate` 周期，所以 `start` 是 **ON_CREATE**，也就是 **1** ，而 `finish` 是 **ON_RESUME**，也就是 **3** 。但是生产的 `IntArray` 并不是 **[1,2,3]** ，而是 **[2]** ，正好是 **[ON_START]**。至于原因嘛，我们看一下 `getLifecyclePath(...)` 方法


```
    //TransactionExecutorHelper
    public IntArray getLifecyclePath(int start, int finish, boolean excludeLastState) {
        ...
        if (finish >= start) {
            // just go there
            for (int i = start + 1; i <= finish; i++) {
                mLifecycleSequence.add(i);
            }
        } 
        ...
        // Remove last transition in case we want to perform it with some specific params.
        if (excludeLastState && mLifecycleSequence.size() != 0) {
            mLifecycleSequence.remove(mLifecycleSequence.size() - 1);
        }

        return mLifecycleSequence;
    }
```
传入的 `excludeLastState` 为 **ture**，相信你已经知道了为什么会产生上面的结果啦！

所以这里我们就知道了，生命周期是如何执行了：

- 首先通过 `cycleToPath(...)` 调用 `handleStartActivity(...)` 方法执行完 `onStart` 周期
- 然后通过 `ResumeActivityItem` 的 `execute(...)` 方法调用 `handleResumeActivity(...)` 执行 `onResume` 生命周期

由于  `handleStartActivity(...)` 中没有和 View绘制流程 相关的内容，所以我们直接来到 `handleResumeActivity(...)` 查看。


## 进入流程

### handleResumeActivity(...)

进入到 `ActivityThread` 的 `handleResumeActivity(...)` 方法


```
    public void handleResumeActivity(IBinder token, boolean finalStateRequest, boolean isForward,
            String reason) {
        ...
        final ActivityClientRecord r = performResumeActivity(token, finalStateRequest, reason);
        ...
        final Activity a = r.activity;
        ...
        boolean willBeVisible = !a.mStartedActivity;
        ...
        if (r.window == null && !a.mFinished && willBeVisible) {
            r.window = r.activity.getWindow();
            View decor = r.window.getDecorView();
            decor.setVisibility(View.INVISIBLE);
            ViewManager wm = a.getWindowManager();
            WindowManager.LayoutParams l = r.window.getAttributes();
            a.mDecor = decor;
            l.type = WindowManager.LayoutParams.TYPE_BASE_APPLICATION;
            l.softInputMode |= forwardBit;
            ...
            if (a.mVisibleFromClient) {
                if (!a.mWindowAdded) {
                    a.mWindowAdded = true;
                    wm.addView(decor, l);
                } 
                ...
            }
        }
        ...
    }
```
 `mStartedActivity` 是只有当这个 Activity 有返回结果时才为 **true**，而 `mFinished` 是只有当 Activity 结束后才为 **true**。并且，我们之前有提到过，在 Activity的 `attach(...)` 方法中创建了 `PhoneWindow` 对象，但是这里的 `ActivityClientRecord` 的 `Window` 对象还是没有的
 
 所以这里会进入这个 if 语句。通过 `PhoneWindow` 的 `getDecorView()` 来获取 `DecorView` 对象：

上面的 `WindowManager` 则是在 Activity的 `attach(...)` 中设置到 Activity中的， `WindowManager` 的实现类是 `WindowManagerImpl`

这里会通过 `addView(...)` 将 `DecorView` 添加进去。我们来看一下  `addView(...)` 方法

### addView(...)


```
public final class WindowManagerImpl implements WindowManager {
    private final WindowManagerGlobal mGlobal = WindowManagerGlobal.getInstance();
    ...
    public void addView(@NonNull View view, @NonNull ViewGroup.LayoutParams params) {
        applyDefaultToken(params);
        mGlobal.addView(view, params, mContext.getDisplay(), mParentWindow);
    }
    ...
}

```
加下来，进入 `WindowManagerGlobal`


```
public final class WindowManagerGlobal {
    private final ArrayList<View> mViews = new ArrayList<View>();
    private final ArrayList<ViewRootImpl> mRoots = new ArrayList<ViewRootImpl>();
    private final ArrayList<WindowManager.LayoutParams> mParams =
            new ArrayList<WindowManager.LayoutParams>();
    ...
    public void addView(View view, ViewGroup.LayoutParams params,
            Display display, Window parentWindow) {
        ...
        ViewRootImpl root;
        ...
        synchronized (mLock) {
            ...
            root = new ViewRootImpl(view.getContext(), display);

            view.setLayoutParams(wparams);

            mViews.add(view);
            mRoots.add(root);
            mParams.add(wparams);
            try {
                root.setView(view, wparams, panelParentView);
            }
            ...
        }
    }
    ...
}
```
可以看到，在这里初始化了 `ViewRootImpl` 对象，并对其添加了 `DecorView` ，来看一下 `setView(...)` 方法

### setView(...)


```
public final class ViewRootImpl implements ViewParent,
        View.AttachInfo.Callbacks, ThreadedRenderer.DrawCallbacks {
    ...
    View mView;
    final TraversalRunnable mTraversalRunnable = new TraversalRunnable();
    ...
    public void setView(View view, WindowManager.LayoutParams attrs, View panelParentView) {
        synchronized (this) {
            if (mView == null) {
                mView = view;
                ...
                requestLayout();
            }
        }
    }
    ...
    @Override
    public void requestLayout() {
        if (!mHandlingLayoutInLayoutRequest) {
            checkThread();
            mLayoutRequested = true;
            scheduleTraversals();
        }
    }
    ...
    void scheduleTraversals() {
        if (!mTraversalScheduled) {
            ...
            mChoreographer.postCallback(
                    Choreographer.CALLBACK_TRAVERSAL, mTraversalRunnable, null);
            ...
        }
    }
    ...
    final class TraversalRunnable implements Runnable {
        @Override
        public void run() {
            doTraversal();
        }
    }
    ...
}
```
在 `setView(...)` 方法中，会通过 `requestLayout()` 最后执行到 `TraversalRunnable` 的 `run()` 方法，其中 `mChoreographer.postCallback()` 实际上调用的是 `FrameHandler` 的 `sendMessage(msg)` ，也就是通过 `Handler` 机制完成的。

接着，我们看一下 `doTraversal()` 里面做了些什么


```
    void doTraversal() {
        if (mTraversalScheduled) {
            mTraversalScheduled = false;
            mHandler.getLooper().getQueue().removeSyncBarrier(mTraversalBarrier);
            ...
            performTraversals();
            ...
        }
    }
```
最后，走到了 `performTraversals()` 方法。这是View绘制流程中非常关键的一个方法，我们来看一看

### performTraversals()

这个方法体非常的长，而我们展示的内容将会非常的短

```
    private void performTraversals() {
        ...
        {
            {
                {
                    ...
                    int childWidthMeasureSpec = getRootMeasureSpec(mWidth, lp.width);
                    int childHeightMeasureSpec = getRootMeasureSpec(mHeight, lp.height);
                    ...
                    performMeasure(childWidthMeasureSpec, childHeightMeasureSpec);
                }
            }
                    
        }
        ...          
        {
            performLayout(lp, mWidth, mHeight);
        }
        ...
        {
            performDraw();
        }
        ...
    }
```

可以看到，我们熟悉的那三个流程，都在这里出现啦！

接下来，在开始介绍上面的三个方法之前，我们需要了解另外一个非常重要的对象 `MeasureSpec`


# View绘制流程

## MeasureSpec


```
    public static class MeasureSpec {
        private static final int MODE_SHIFT = 30;
        private static final int MODE_MASK  = 0x3 << MODE_SHIFT;
        
        public static final int UNSPECIFIED = 0 << MODE_SHIFT;
        
        public static final int EXACTLY     = 1 << MODE_SHIFT;
        
        public static final int AT_MOST     = 2 << MODE_SHIFT;
        
        public static int makeMeasureSpec(@IntRange(from = 0, to = (1 << MeasureSpec.MODE_SHIFT) - 1) int size,
                                          @MeasureSpecMode int mode) {
            if (sUseBrokenMakeMeasureSpec) {
                return size + mode;
            } else {
                return (size & ~MODE_MASK) | (mode & MODE_MASK);
            }
        }
        
        public static int getMode(int measureSpec) { return (measureSpec & MODE_MASK); }
        
        public static int getSize(int measureSpec) { return (measureSpec & ~MODE_MASK); }
    }
```
在 `MeasureSpec` 相关逻辑主要分为两个部分，分别是 **mode** 和 **size**。即通过一个 **32位的int** 数值来存储 **mode** 和 **size**

后30位，用于存储 **height** 或 **width**，前2位，用于表示 View 的绘制模式，这其中，就分了三种模式：

- **UNSPECIFIED** : 父布局对子布局的大小不做任何限制，子布局可以是任意大小。比如ScrollView这种
- **EXACTLY** : 父布局对子布局的大小有一个确定的尺寸，无论子布局想要多大的空间，都会被这个尺寸限制住
- **AT_MOST** : 在指定大小内，子布局要多大有多大

上面的 `makeMeasureSpec(size, mode)` 方法就是用于将传入的大小与模式转换在 **32位的int** 数值中

接下来，我们看一下之前的 `getRootMeasureSpec(...)` 方法


```
    private static int getRootMeasureSpec(int windowSize, int rootDimension) {
        int measureSpec;
        switch (rootDimension) {

        case ViewGroup.LayoutParams.MATCH_PARENT:
            measureSpec = MeasureSpec.makeMeasureSpec(windowSize, MeasureSpec.EXACTLY);
            break;
        case ViewGroup.LayoutParams.WRAP_CONTENT:
            measureSpec = MeasureSpec.makeMeasureSpec(windowSize, MeasureSpec.AT_MOST);
            break;
        default:
            measureSpec = MeasureSpec.makeMeasureSpec(rootDimension, MeasureSpec.EXACTLY);
            break;
        }
        return measureSpec;
    }
```
可以看到，结果的模式是根据 `LayoutParams` 的中的布局模式返回的。默认是 `EXACTLY`，另外两个则是一一对应的关系：

- **LayoutParams.MATCH_PARENT**: 对应 `EXACTLY` 模式
- **LayoutParams.WRAP_CONTENT**: 对应 `AT_MOST` 模式

`MeasureSpec` 相关内容介绍完了，那么要看一下 `performMeasure(...)` 方法了



```
    //ViewRootImpl
    
    private void performMeasure(int childWidthMeasureSpec, int childHeightMeasureSpec) {
        ...
        try {
            mView.measure(childWidthMeasureSpec, childHeightMeasureSpec);
        } 
        ...
    }
```
这里调用了 `mView` 的 `measure(...)` 方法，而这个 `mView` 就是我们之前传入的 `DecorView`，我们看一下它的 `measure(...)` 

## measure(...)

在 `DecorView` 中我们并没有发现 `measure(...)` 方法，我们可以看一下这个类的继承关系


```
public class DecorView extends FrameLayout implements RootViewSurfaceTaker, WindowCallbacks {
    ...
}
```
 `DecorView` 的继承关系如下：
 
> DecorView => FrameLayout => ViewGroup => View
 
除了在 `View` 中，你会发现其他地方都找不到 `measure(...)` ，这是为什么呢？我们看一下就知道了



### View


```
    public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
        ...
        {
            {
                onMeasure(widthMeasureSpec, heightMeasureSpec);
            }
        }
        ...
    }
    
```
可以看到， `measure(...)` 被关键词 **final** 修饰了，这说明子类是无法重写这个方法的。而它后面会调用 `onMeasure()` 方法，我们来看一下


```
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
                getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
    }
    
    protected int getSuggestedMinimumWidth() {
        return (mBackground == null) ? mMinWidth : max(mMinWidth, mBackground.getMinimumWidth());
    }
    
    protected int getSuggestedMinimumHeight() {
        return (mBackground == null) ? mMinHeight : max(mMinHeight, mBackground.getMinimumHeight());
    }
    
    public static int getDefaultSize(int size, int measureSpec) {
        int result = size;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        switch (specMode) {
        case MeasureSpec.UNSPECIFIED:
            result = size;
            break;
        case MeasureSpec.AT_MOST:
        case MeasureSpec.EXACTLY:
            result = specSize;
            break;
        }
        return result;
    }
    
    
```

可以先看一下 `getSuggestedMinimumWidth(...)` 和 `getSuggestedMinimumHeight(...)`

- *getSuggestedMinimumWidth(...)* : 返回 **background最小宽度** 与 **view最小宽度** 两者间更大的那个
- *getSuggestedMinimumHeight(...)* : 返回 **background最小高度** 与 **view最小高度** 两者间更大的那个

这里的 `background` 就是当前View的背景(比如在xml设置的那个)

然后看一下 `getDefaultSize(...)`，这里传入的 `size` 由 `getSuggestedMinimum...()` 得到。

只有当 `mode` 为 **MeasureSpec.EXACTLY** 时，返回的是给定的大小；为另外两种模式时，返回的就是 `background` 和 `view` 之间大小的最大值。

接下来就可以看一下 `setMeasuredDimension(...)` 方法了


```
    protected final void setMeasuredDimension(int measuredWidth, int measuredHeight) {
        boolean optical = isLayoutModeOptical(this);
        if (optical != isLayoutModeOptical(mParent)) {
            Insets insets = getOpticalInsets();
            int opticalWidth  = insets.left + insets.right;
            int opticalHeight = insets.top  + insets.bottom;

            measuredWidth  += optical ? opticalWidth  : -opticalWidth;
            measuredHeight += optical ? opticalHeight : -opticalHeight;
        }
        setMeasuredDimensionRaw(measuredWidth, measuredHeight);
    }
    
    private void setMeasuredDimensionRaw(int measuredWidth, int measuredHeight) {
        mMeasuredWidth = measuredWidth;
        mMeasuredHeight = measuredHeight;

        mPrivateFlags |= PFLAG_MEASURED_DIMENSION_SET;
    }
```
上面的 `isLayoutModeOptical(...)` 是用于判断是否为 `ViewGroup` 的一种 `LayoutMode`：是否有阴影边界。这里猜测可能是像 `Card` 这样的布局

`setMeasuredDimension(...)` 最终调用 `setMeasuredDimensionRaw(...)` 设置了 `View` 的测量高度与宽度

这里 `View` 的测量部分就结束了，我们要知道的是 `DecorView` 的测量流程，所以接下来还要看一下同为 `View` 子布局， `DecorView` 父布局的 `ViewGroup` 和 `FrameLayout` 重写的 `onMeasure(...)` 方法

看代码发现 `ViewGroup` 没有重写这个方法，所以直接来看 `FrameLayout` 的吧

### FrameLayout


```
public class FrameLayout extends ViewGroup {
    ...
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int count = getChildCount();

        final boolean measureMatchParentChildren =
                MeasureSpec.getMode(widthMeasureSpec) != MeasureSpec.EXACTLY ||
                MeasureSpec.getMode(heightMeasureSpec) != MeasureSpec.EXACTLY;
        ...
        for (int i = 0; i < count; i++) {
            final View child = getChildAt(i);
            if (mMeasureAllChildren || child.getVisibility() != GONE) {
                measureChildWithMargins(child, widthMeasureSpec, 0, heightMeasureSpec, 0);
                ...
                if (measureMatchParentChildren) {
                    if (lp.width == LayoutParams.MATCH_PARENT ||
                            lp.height == LayoutParams.MATCH_PARENT) {
                        mMatchParentChildren.add(child);
                    }
                }
            }
        }
        ...
        count = mMatchParentChildren.size();
        if (count > 1) {
            for (int i = 0; i < count; i++) {
                final View child = mMatchParentChildren.get(i);
                if (lp.width == LayoutParams.MATCH_PARENT) {
                    ...
                    childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(
                            width, MeasureSpec.EXACTLY);
                } else {
                    childWidthMeasureSpec = getChildMeasureSpec(...);
                }

                final int childHeightMeasureSpec;
                if (lp.height == LayoutParams.MATCH_PARENT) {
                    ...
                    childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(
                            height, MeasureSpec.EXACTLY);
                } else {
                    childHeightMeasureSpec = getChildMeasureSpec(...);
                }
                ...
                child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
            }
        }
    }
    ...
    //ViewGroup
    protected void measureChildWithMargins(View child,
            int parentWidthMeasureSpec, int widthUsed,
            int parentHeightMeasureSpec, int heightUsed) {
        final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
                mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin
                        + widthUsed, lp.width);
        final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
                mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin
                        + heightUsed, lp.height);
        child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
    }
}
```
可以看到，`onMeasure(...)` 中，遍历了所有 **子View** ，并通过 `measureChildWithMargins(...)` 调用 **子View** 的 `measure(...)` 方法。

同时也将 **LayoutParam** 的 **width** 或 **height** 为 `MATCH_PARENT`的 **子View** 添加到 `mMatchParentChildren` 中再进行一次遍历并且调用 `measure(...)` 方法进行测量

因为 `View` 的  `measure(...)` 方法不可重写，所以最终都会调用到其子布局的 `onmeasure(...)`

不过上面还有一个问题，那就是为什么要对 `mMatchParentChildren` 再测量一遍？从上面的逻辑看来，被添加到 `mMatchParentChildren` 中的 **子View**， 它的宽高一定有一条是 `LayoutParams.MATCH_PARENT` 而另一个是 `LayoutParams.WRAP_CONTENT`。如果是 `LayoutParams.MATCH_PARENT` ，则直接调用 `MeasureSpec.makeMeasureSpec(...)` 将测量模式设置为 `EXACTLY` ,否则就根据 `getChildMeasureSpec(...)` 返回测量模式。

在 `measureChildWithMargins(...)` 最后也调用了 `getChildMeasureSpec(...)` ，我们来看一看这个方法



```
    //ViewGroup
    
    public static int getChildMeasureSpec(int spec, int padding, int childDimension) {
        int specMode = MeasureSpec.getMode(spec);
        int specSize = MeasureSpec.getSize(spec);

        int size = Math.max(0, specSize - padding);

        int resultSize = 0;
        int resultMode = 0;

        switch (specMode) {
        // Parent has imposed an exact size on us
        case MeasureSpec.EXACTLY:
            if (childDimension >= 0) {
                resultSize = childDimension;
                resultMode = MeasureSpec.EXACTLY;
            } else if (childDimension == LayoutParams.MATCH_PARENT) {
                // Child wants to be our size. So be it.
                resultSize = size;
                resultMode = MeasureSpec.EXACTLY;
            } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                resultSize = size;
                resultMode = MeasureSpec.AT_MOST;
            }
            break;

        // Parent has imposed a maximum size on us
        case MeasureSpec.AT_MOST:
            if (childDimension >= 0) {
                // Child wants a specific size... so be it
                resultSize = childDimension;
                resultMode = MeasureSpec.EXACTLY;
            } else if (childDimension == LayoutParams.MATCH_PARENT) {
                // Child wants to be our size, but our size is not fixed.
                // Constrain child to not be bigger than us.
                resultSize = size;
                resultMode = MeasureSpec.AT_MOST;
            } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                // Child wants to determine its own size. It can't be
                // bigger than us.
                resultSize = size;
                resultMode = MeasureSpec.AT_MOST;
            }
            break;

        // Parent asked to see how big we want to be
        case MeasureSpec.UNSPECIFIED:
            if (childDimension >= 0) {
                // Child wants a specific size... let him have it
                resultSize = childDimension;
                resultMode = MeasureSpec.EXACTLY;
            } else if (childDimension == LayoutParams.MATCH_PARENT) {
                // Child wants to be our size... find out how big it should
                // be
                resultSize = View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
                resultMode = MeasureSpec.UNSPECIFIED;
            } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                // Child wants to determine its own size.... find out how
                // big it should be
                resultSize = View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
                resultMode = MeasureSpec.UNSPECIFIED;
            }
            break;
        }
        //noinspection ResourceType
        return MeasureSpec.makeMeasureSpec(resultSize, resultMode);
    }
```

返回的测量模式是根据 **父布局所提供的测量模式+LayoutParam参数** 结合来确定的。在之前 `ViewRootImpl` 的 `getRootMeasureSpec(...)` 方法中，`LayoutParams.MATCH_PARENT` 与 `EXACTLY` 对应，`LayoutParams.WRAP_CONTENT` 与 `AT_MOST` 对应。但是从这里看来，说明这个对应关系，只适用于根布局，这也和它的注释一致。

> 注意：当 childDimension >= 0 时，表示这个 child 自己有一个准确的尺寸，这个尺寸值就是 childDimension。

那么再看一下上面的方法：

- 当 `childDimension >= 0` 时: 无论父布局模式是什么，子布局的测量模式都是 `EXACTLY` ，且尺寸为 childDimension
- 父布局的mode为 `EXACTLY` 时: 对应关系与 `getRootMeasureSpec(...)` 提到的一致，也就是正常的情况
- 父布局的mode为 `AT_MOST` 时: 子布局模式都是 `AT_MOST`
- 父布局的mode为 `UNSPECIFIED` 时: 子布局模式都是 `UNSPECIFIED`

关于上面为什么会有第二次测量，以及这里的 `UNSPECIFIED` ，下面是使用场景及说明：

> 在日常定制View时，确实很少会专门针对 UNSPECIFIED 这个模式去做特殊处理，大多数情况下，都会把它当成MeasureSpec.AT_MOST一样看待，就比如最最常用的TextView，它在测量时也是不会区分UNSPECIFIED和AT_MOST的。
> 
> 不过，虽说这个模式比较少直接接触到，但很多场景下，我们已经在不知不觉中用上了，比如RecyclerView的Item，如果Item的宽/高是wrap_content且列表可滚动的话，那么Item的宽/高的测量模式就会是UNSPECIFIED。还有就是NestedScrollView和ScrollView，因为它们都是扩展自FrameLayout，所以它们的子View会测量两次，第一次测量时，子View的heightMeasureSpec的模式是写死为UNSPECIFIED的。 
>
> 我们在自定义ViewGroup过程中，如果允许子View的尺寸比ViewGroup大的话，在测量子View时就可以把Mode指定为UNSPECIFIED。


那么到这里， `measure` 就结束了，下面开始 `layout` 部分

## layout(...)

先来看一下 `ViewRootImpl` 的 `performLayout(...)`方法

### performLayout(...)


```
    private void performLayout(WindowManager.LayoutParams lp, int desiredWindowWidth,
            int desiredWindowHeight) {
        ...
        final View host = mView;
        ...
        try {
            host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());
            ...
            if (numViewsRequestingLayout > 0) {
                ...
                if (validLayoutRequesters != null) {
                    ...
                    host.layout(0, 0, host.getMeasuredWidth(), 
                    ...
                }
            }
        } 
        ...
    }
```
`mView` 就是 `DecorView` 对象，不过没有在其中找到 `layout(...)` 方法，`FrameLayout` 中也没有，而 `ViewGroup` 中存在，进去看一下吧


### layout(...)


```
    //ViewGroup
    
    @Override
    public final void layout(int l, int t, int r, int b) {
        if (!mSuppressLayout && (mTransition == null || !mTransition.isChangingLayout())) {
            if (mTransition != null) {
                mTransition.layoutChange(this);
            }
            super.layout(l, t, r, b);
        } else {
            // record the fact that we noop'd it; request layout when transition finishes
            mLayoutCalledWhileSuppressed = true;
        }
    }
```

这个方法被 `final` 修饰了，说明 `layout(...)` 方法最深也只能在 `ViewGroup` 中了，其中调用了 `super.layout(...)` ,接下来到 `View` 中


```
    //View
    
    public void layout(int l, int t, int r, int b) {
        ...
        boolean changed = isLayoutModeOptical(mParent) ?
                setOpticalFrame(l, t, r, b) : setFrame(l, t, r, b);
        if (changed || (mPrivateFlags & PFLAG_LAYOUT_REQUIRED) == PFLAG_LAYOUT_REQUIRED) {
            ...
            onLayout(changed, l, t, r, b);
            ...
        }
        ...
    }
    
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) { }
    
    private boolean setOpticalFrame(int left, int top, int right, int bottom) {
        ...
        return setFrame(...);
    }
    
    protected boolean setFrame(int left, int top, int right, int bottom) {
        boolean changed = false;
        ...
        if (mLeft != left || mRight != right || mTop != top || mBottom != bottom) {
            changed = true;
            ...

            int oldWidth = mRight - mLeft;
            int oldHeight = mBottom - mTop;
            int newWidth = right - left;
            int newHeight = bottom - top;
            boolean sizeChanged = (newWidth != oldWidth) || (newHeight != oldHeight);

            // Invalidate our old position
            invalidate(sizeChanged);

            mLeft = left;
            mTop = top;
            mRight = right;
            mBottom = bottom;
            mRenderNode.setLeftTopRightBottom(mLeft, mTop, mRight, mBottom);

            ...

            notifySubtreeAccessibilityStateChangedIfNeeded();
        }
        return changed;
    }
```
可以看到，在调用 `onLayout(...)` 之前，就通过 `setFrame(...)` 的方法设置完了 Layout 的布局，并且还做了参数对比判断布局是否发生变化。同时可以发现 `View` 的 `onLayout(...)` 并没有任何操作

再看看 `ViewGroup` 的 `onLayout(...)` 

``` 
    //ViewGroup
    
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    }
```
也没有做什么，并且这个方法是个抽象方法，说明子类 `FrameLayout` 一定实现了这个方法:


```
    ///FrameLayout
    
    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        layoutChildren(left, top, right, bottom, false /* no force left gravity */);
    }
    
    void layoutChildren(int left, int top, int right, int bottom, boolean forceLeftGravity) {
        final int count = getChildCount();
        ...
        for (int i = 0; i < count; i++) {
            final View child = getChildAt(i);
            if (child.getVisibility() != GONE) {
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                ...
                int gravity = lp.gravity;
                ...

                final int layoutDirection = getLayoutDirection();
                final int absoluteGravity = Gravity.getAbsoluteGravity(gravity, layoutDirection);
                final int verticalGravity = gravity & Gravity.VERTICAL_GRAVITY_MASK;

                switch (absoluteGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                    case Gravity.CENTER_HORIZONTAL:
                        childLeft = parentLeft + (parentRight - parentLeft - width) / 2 +
                        lp.leftMargin - lp.rightMargin;
                        break;
                    case Gravity.RIGHT:
                        if (!forceLeftGravity) {
                            childLeft = parentRight - width - lp.rightMargin;
                            break;
                        }
                    case Gravity.LEFT:
                    default:
                        childLeft = parentLeft + lp.leftMargin;
                }

                switch (verticalGravity) {
                    case Gravity.TOP:
                        childTop = parentTop + lp.topMargin;
                        break;
                    case Gravity.CENTER_VERTICAL:
                        childTop = parentTop + (parentBottom - parentTop - height) / 2 +
                        lp.topMargin - lp.bottomMargin;
                        break;
                    case Gravity.BOTTOM:
                        childTop = parentBottom - height - lp.bottomMargin;
                        break;
                    default:
                        childTop = parentTop + lp.topMargin;
                }

                child.layout(childLeft, childTop, childLeft + width, childTop + height);
            }
        }
    }
    
```
可以看到，`onLayout(...)` 通过调用 `layoutChildren(...)` 给每个 `child` 测量好了布局定位，然后调用了 `child` 的 `layout(...)` 方法。那么到这里 `layout` 流程就结束了，接下来是 `draw` 

## draw(...)

进入 `ViewRootImpl` 的 `performDraw()`方法

### performDraw()


```
    private void performDraw() {
        ...
        try {
            boolean canUseAsync = draw(fullRedrawNeeded);
            ...
        }
        ...
    }
    
    private boolean draw(boolean fullRedrawNeeded) {
        ...
        {
            {
                if (!drawSoftware(surface, mAttachInfo, xOffset, yOffset,
                        scalingRequired, dirty, surfaceInsets)) {
                    return false;
                }
            }
        }

        ...
    }
    
    private boolean drawSoftware(Surface surface, AttachInfo attachInfo, int xoff, int yoff,
            boolean scalingRequired, Rect dirty, Rect surfaceInsets) {
            ...
            try {
                ...
                mView.draw(canvas);
                ...
            }
            ...
    }

```
接下来，看一下 `DecorView` 的 `draw(...)` 方法

```
    //DecorView
    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);

        if (mMenuBackground != null) {
            mMenuBackground.draw(canvas);
        }
    }
```

`mMenuBackground.draw(canvas)` 自然就是绘制背景了，我们主要看这个 `super.draw(canvas)` ，它将进入 `View` 的 `draw(canvas)` 方法

### draw(canvas)


```
    //View
    public void draw(Canvas canvas) {
        ...
        /*
         * Draw traversal performs several drawing steps which must be executed
         * in the appropriate order:
         *
         *      1. Draw the background
         *      2. If necessary, save the canvas' layers to prepare for fading
         *      3. Draw view's content
         *      4. Draw children
         *      5. If necessary, draw the fading edges and restore layers
         *      6. Draw decorations (scrollbars for instance)
         */
        ...
        // Step 1, draw the background, if needed
        int saveCount;

        if (!dirtyOpaque) {
            drawBackground(canvas);
        }
        ...
        // Step 3, draw the content
        if (!dirtyOpaque) onDraw(canvas);

        // Step 4, draw the children
        dispatchDraw(canvas);
        ...
        // Step 6, draw decorations (foreground, scrollbars)
        onDrawForeground(canvas);
        ...
    }
    
    ...
    protected void onDraw(Canvas canvas) { }
    ...
    protected void dispatchDraw(Canvas canvas) { }
    ...
    
```
上面的注释对于 `draw` 的流程做了一个简要说明， 我们主要关注第三点 `onDraw(canvas)`和第四点 `dispatchDraw(canvas)`，先来看第三点

### onDraw(canvas)

只有 `DectorView` 重写了这个方法


```
    //DectorView
    @Override
    public void onDraw(Canvas c) {
        super.onDraw(c);

        mBackgroundFallback.draw(this, mContentRoot, c, mWindow.mContentParent,
                mStatusColorViewState.view, mNavigationColorViewState.view);
    }
```

因为 `super.onDraw(c)` 最终会调用到 `View` 的 `onDraw(canvas)`，是个空方法，啥也不会做。 而 `BackgroundFallback` 的 `draw(...)` 方法主要是绘制各个子布局的背景

接下来看一下之前的 `dispatchDraw(canvas)` 

### dispatchDraw(canvas)

 `dispatchDraw(canvas)` 也是一个空方法，只有 `ViewGroup` 对其进行了重写
 
 
```
    //ViewGroup
    @Override
    protected void dispatchDraw(Canvas canvas) {
        ...
        final int childrenCount = mChildrenCount;
        final View[] children = mChildren;
        ...
        for (int i = 0; i < childrenCount; i++) {
            while (transientIndex >= 0 && mTransientIndices.get(transientIndex) == i) {
                ...
                if ((transientChild.mViewFlags & VISIBILITY_MASK) == VISIBLE ||
                        transientChild.getAnimation() != null) {
                    more |= drawChild(canvas, transientChild, drawingTime);
                }
                ...
            }
            ...
        }
        ...
    }
    
    ...
    
    protected boolean drawChild(Canvas canvas, View child, long drawingTime) {
        return child.draw(canvas, this, drawingTime);
    }
```
上面其实有多处调用到了 `drawChild(...)` 方法，而它又会调用 `child.draw(...)` 方法，最后回到 `View` 的 `draw(...)` 来



# 总结

这次就通过文字总结View的绘制流程吧


1. 创建 `PhoneWindow` : `ActivityThread` 的 `performLaunchActivity(...)` 中,调用 `Activity` 的 `attach(...)` 方法,创建了 `PhoneWindow` 
2. 创建 `DecorView` :  在我们实现的 `Activity` 中,通过 `setContentView(...)` 走到 `AppCompatDelegateImpl` 的 `ensureSubDecor()` 方法,最后调用  `PhoneWindow` 的 `installDecor()` 创建  `DecorView` 
3. 绑定 `DecorView` : 进入 `ActivityThread` 的 `handleResumeActivity(...)`, 通过 `WindowManagerImpl` 的 `addView(...)` 方法, 将 `DecorView` 保存在 `WindowManagerGlobal` 维护的View列表中。 同时,会设置到 `ViewRootImpl` 中与之进行绑定
4. 开始绘制流程 : 通过 `ViewRootImpl` 的 `requestLayout()` 方法,最终调用到 `doTraversal()`, 至此开始绘制流程
5. `performMeasure(...)` : 
    1. 通过对 `DecorView` 调用 `measure(...)` 进入到 `View` 的 `measure(...)` 方法,然后调用 `View` 的 `onMeasure(...)`
    2. 然后走入到 `FrameLayout` 重写的 `onMeasure(...)`方法, 这里会便利 children ,走到 `ViewGroup` 的 `measureChildWithMargins(...)` 方法
    3. 在 `ViewGroup` 的 `measureChildWithMargins(...)` 中, 又会调用 `View` 的 `measure(...)` 方法, 从而形成递归调用
6. `performLayout(...)` : 
    1. 通过对 `DecorView` 调用 `layout(...)` 进入到 `ViewGroup` 的 `layout(...)` 方法, 然后又会进入到 `View` 的 `layout(...)` 
    2. 通过 `View` 的 `layout(...)`会调用它的 `onLayout(...)` 方法,而 `onLayout(...)` 没有任何逻辑操作, 因此会进入到子类 `FrameLayout` 的  `onLayout(...)` 
    3. 在 `FrameLayout` 的  `onLayout(...)` 中,会通过 `layoutChildren(...)` 来调用到 `View` 的 `layout(...)` 方法,从而形成了递归
7. `performDraw()` : 
    1. 通过对 `DecorView` 调用 `draw(...)` 进入到 `View` 的 `draw(...)` 方法, 然后会调用 `View` 的 `onDraw(...)` 进入到 `DectorView` 的 `onDraw(...)` 方法,不过这里只做了背景绘制
    2. 然后继续执行之前的 `dispatchDraw(...)` 方法, 遍历 children 对每一个子View 调用它的  `draw(...)` 方法,就这样形成了递归