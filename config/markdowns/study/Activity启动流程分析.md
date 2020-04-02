---
title: Activity启动流程分析
date: 2020-03-22 11:38:15
index_img: /img/activity_start.png
tags: 源码系列
---


# 序

前面已经写完了三篇android方面的学习文章啦，而这一篇关于 **Activity的启动流程**，它涉及的源码量非常大并且非常广。

在阅读源码之前，需要先做好准备工作。因为有的时候android sdk中的源码并不一定可以随心所欲的跳转，这时候你就需要替换一下sdk文件了，可以从这里下载：[android-hidden-api](https://github.com/anggrayudi/android-hidden-api)
> ps:替换之前记得备份哦

# 引子

对于 **Activity启动的流程**，这里我们很好去选择一个源码的阅读入口

那就是我们非常熟悉的：`startActivity(...)` 方法



# App内Activity启动流程

进入 `startActivity()` 康康吧

## Activity

### startActivity(...)

```
    public void startActivity(Intent intent) { this.startActivity(intent, null); }
    
    public void startActivity(Intent intent, @Nullable Bundle options) {
        if (options != null) {
            startActivityForResult(intent, -1, options);
        } else {
            startActivityForResult(intent, -1);
        }
    }
    
    public void startActivityForResult(@RequiresPermission Intent intent, int requestCode) {
        startActivityForResult(intent, requestCode, null);
    }
    
    public void startActivityForResult(@RequiresPermission Intent intent, int requestCode,
            @Nullable Bundle options) {...}
    
```

可以看到最终 `startActivity()` 方法会进入 `startActivityForResult(...)` 方法

### startActivityForResult(...)


```
    public void startActivityForResult(@RequiresPermission Intent intent, int requestCode,
            @Nullable Bundle options) {
        if (mParent == null) {
            options = transferSpringboardActivityOptions(options);
            Instrumentation.ActivityResult ar =
                mInstrumentation.execStartActivity(
                    this, mMainThread.getApplicationThread(), mToken, this,
                    intent, requestCode, options);
            if (ar != null) {
                mMainThread.sendActivityResult(
                    mToken, mEmbeddedID, requestCode, ar.getResultCode(),
                    ar.getResultData());
            }
            if (requestCode >= 0) {
                mStartedActivity = true;
            }

            cancelInputsAndStartExitTransition(options);
        } else {
            ...
        }
    }
```

上面的代码中根据 `mParent` 是否为 **null** 分了两种情况，关于 `mParent` 的来龙去脉，目前查阅资料得出的结果是由 `ActivityGroup` 遗留下来的代码

> 而我也通过在主Activity启动另一个Activity的方式测试得 getParent() 的方法打印为null， 也就是 ActivityGroup 已经被 Fragment + Activity 代替掉了

我们只需要注意 `execStartActivity(...)` 方法即可

## Instrumentation

关于 `Instrumentation` 这个类，它主要用于应用的自动化测试，可以看一下这里：[插桩测试](https://source.android.google.cn/compatibility/tests/development/instrumentation?hl=zh-cn)

我们直接看 `execStartActivity(...)` 方法

### execStartActivity(...)


```
    public ActivityResult execStartActivity(
        Context who, IBinder contextThread, IBinder token, String target,
        Intent intent, int requestCode, Bundle options) {
        IApplicationThread whoThread = (IApplicationThread) contextThread;
        ...//监视器相关
        try {
            intent.migrateExtraStreamToClipData();
            intent.prepareToLeaveProcess(who);
            int result = ActivityManager.getService()
                .startActivity(whoThread, who.getBasePackageName(), intent,
                        intent.resolveTypeIfNeeded(who.getContentResolver()),
                        token, target, requestCode, 0, null, options);
            checkStartActivityResult(result, intent);
        } catch (RemoteException e) {
            throw new RuntimeException("Failure from system", e);
        }
        return null;
    }
```
这里主要关注 `startActivity(...)` 方法，不过在此之前可以看一下 `ActivityManager.getService()` 返回的对象是什么


```
    public static IActivityManager getService() {
        return IActivityManagerSingleton.get();
    }
    
    private static final Singleton<IActivityManager> IActivityManagerSingleton =
            new Singleton<IActivityManager>() {
                @Override
                protected IActivityManager create() {
                    final IBinder b = ServiceManager.getService(Context.ACTIVITY_SERVICE);
                    final IActivityManager am = IActivityManager.Stub.asInterface(b);
                    return am;
                }
            };
```

上面的写法除了单例以外，是一个很典型的 **AIDL** 写法，返回的对象是通过 IBinder 对象提供的 **IActivityManager** 引用，而通过 `IActivityManager` 对象，就可以和 `ActivityManagerService` 通信了, 因为 `ActivityManagerService` 是服务端的实现：

```
public class ActivityManagerService extends IActivityManager.Stub
        implements Watchdog.Monitor, BatteryStatsImpl.BatteryCallback {...}
```
关于 **AIDL** 的使用与介绍，可以看这篇：[Android 接口定义语言 (AIDL)](https://developer.android.google.cn/guide/components/aidl?hl=zh_cn#Implement)

接下来，我们就进入 `ActivityManagerService` 去寻找 `startActivity(...)` 的实现吧：

## ActivityManagerService

`ActivityManagerService` 是 `Activity` 启动流程中非常关键的一个对象，大家经常能看到它的简称：**AMS**

那么 `Activity` 启动的流程中它都参与了哪些内容？我们继续往下看

下面就是一系列的方法调用了

### startActivity(...) -> startActivityAsUser(...)


```
    public final int startActivity(IApplicationThread caller, String callingPackage,
            Intent intent, String resolvedType, IBinder resultTo, String resultWho, int requestCode,
            int startFlags, ProfilerInfo profilerInfo, Bundle bOptions) {
        return startActivityAsUser(...);
    }
```
⬇

```
    public final int startActivityAsUser(IApplicationThread caller, String callingPackage,
            Intent intent, String resolvedType, IBinder resultTo, String resultWho, int requestCode,
            int startFlags, ProfilerInfo profilerInfo, Bundle bOptions, int userId) {
        return startActivityAsUser(...);
    }
```
⬇

```
    public final int startActivityAsUser(IApplicationThread caller, String callingPackage,
            Intent intent, String resolvedType, IBinder resultTo, String resultWho, int requestCode,
            int startFlags, ProfilerInfo profilerInfo, Bundle bOptions, int userId,
            boolean validateIncomingUser) {
        enforceNotIsolatedCaller("startActivity");

        userId = mActivityStartController.checkTargetUser(userId, validateIncomingUser,
                Binder.getCallingPid(), Binder.getCallingUid(), "startActivityAsUser");

        // TODO: Switch to user app stacks here.
        return mActivityStartController.obtainStarter(intent, "startActivityAsUser")
                ...//这里给ActivityStarter设置各种参数
                .setMayWait(userId)
                .execute();

    }
```
上面的 `checkTargetUser(...)` 用于检测调用方的权限等，这里就涉及到多用户和Linux的一些知识了，此处就不说了(如果以后会研究Linux的话，再做说明吧)

后面的 `obtainStarter(...)` 返回的是一个 `ActivityStarter` 对象，看这个类的名字，就知道它是干什么的了，我们进入它的 `execute()` 方法看看

## ActivityStarter

### execute()

```
    int execute() {
        try {
            if (mRequest.mayWait) {
                return startActivityMayWait(...);
            } else {
                return startActivity(...);
            }
        } finally {
            onExecutionComplete();
        }
    }
    
    
```

这里的 `mRequest.mayWait` 标志位是通过 `setMayWait(int userId)` 方法来更改的

```
    ActivityStarter setMayWait(int userId) {
        mRequest.mayWait = true;
        mRequest.userId = userId;

        return this;
    }
```
而我们在之前的 `startActivityAsUser(...)` 中，就调用过了 `setMayWait()` 方法，所以我们接下来会走到 `startActivityMayWait(...)` 中去

### startActivityMayWait(...)

这个方法的参数，以及方法体中的代码量非常大，我们只看最关键的流程部分


```
    private int startActivityMayWait(IApplicationThread caller, int callingUid,
            String callingPackage, Intent intent, String resolvedType,
            IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
            IBinder resultTo, String resultWho, int requestCode, int startFlags,
            ProfilerInfo profilerInfo, WaitResult outResult,
            Configuration globalConfig, SafeActivityOptions options, boolean ignoreTargetSecurity,
            int userId, TaskRecord inTask, String reason,
            boolean allowPendingRemoteAnimationRegistryLookup) {
                
            ...    
            int res = startActivity(caller, intent, ephemeralIntent, resolvedType, aInfo, rInfo,
                    voiceSession, voiceInteractor, resultTo, resultWho, requestCode, callingPid,
                    callingUid, callingPackage, realCallingPid, realCallingUid, startFlags, options,
                    ignoreTargetSecurity, componentSpecified, outRecord, inTask, reason,
                    allowPendingRemoteAnimationRegistryLookup);
            ...        
                
                
    }
```
进入 `startActivity(...)`

### startActivity(...) -> startActivity(...)


```
    private int startActivity(IApplicationThread caller, Intent intent, Intent ephemeralIntent,
            String resolvedType, ActivityInfo aInfo, ResolveInfo rInfo,
            IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
            IBinder resultTo, String resultWho, int requestCode, int callingPid, int callingUid,
            String callingPackage, int realCallingPid, int realCallingUid, int startFlags,
            SafeActivityOptions options, boolean ignoreTargetSecurity, boolean componentSpecified,
            ActivityRecord[] outActivity, TaskRecord inTask, String reason,
            boolean allowPendingRemoteAnimationRegistryLookup) {
            
            ...
        mLastStartActivityResult = startActivity(caller, intent, ephemeralIntent, resolvedType,
                aInfo, rInfo, voiceSession, voiceInteractor, resultTo, resultWho, requestCode,
                callingPid, callingUid, callingPackage, realCallingPid, realCallingUid, startFlags,
                options, ignoreTargetSecurity, componentSpecified, mLastStartActivityRecord,
                inTask, allowPendingRemoteAnimationRegistryLookup);
            ...
                
    }
```

进入下一个 `startActivity(...)`，依旧是一个行数非常多的方法体

```
    private int startActivity(IApplicationThread caller, Intent intent, Intent ephemeralIntent,
            String resolvedType, ActivityInfo aInfo, ResolveInfo rInfo,
            IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
            IBinder resultTo, String resultWho, int requestCode, int callingPid, int callingUid,
            String callingPackage, int realCallingPid, int realCallingUid, int startFlags,
            SafeActivityOptions options,
            boolean ignoreTargetSecurity, boolean componentSpecified, ActivityRecord[] outActivity,
            TaskRecord inTask, boolean allowPendingRemoteAnimationRegistryLookup) {
                
        ...        
        return startActivity(r, sourceRecord, voiceSession, voiceInteractor, startFlags,
                true /* doResume */, checkedOptions, inTask, outActivity);
    }
```
进入最后的 `startActivity(...)` 
```
    private int startActivity(final ActivityRecord r, ActivityRecord sourceRecord,
                IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
                int startFlags, boolean doResume, ActivityOptions options, TaskRecord inTask,
                ActivityRecord[] outActivity) {
        int result = START_CANCELED;
        try {
            ...
            result = startActivityUnchecked(r, sourceRecord, voiceSession, voiceInteractor,
                    startFlags, doResume, options, inTask, outActivity);
        } finally {
          ...
        }

        postStartActivityProcessing(r, result, mTargetStack);

        return result;
    }
```
这里调用了 `startActivityUnchecked(...)`方法，进去看一看



### startActivityUnchecked(...)


```
    private int startActivityUnchecked(final ActivityRecord r, ActivityRecord sourceRecord,
            IVoiceInteractionSession voiceSession, IVoiceInteractor voiceInteractor,
            int startFlags, boolean doResume, ActivityOptions options, TaskRecord inTask,
            ActivityRecord[] outActivity) {
        ...    
        //根据Activity的启动模式来决定如何启动Activity，比如LAUNCH_SINGLE_TOP或LAUNCH_SINGLE_TASK等    
        ...
        mTargetStack.startActivityLocked(mStartActivity, topFocused, newTask, mKeepCurTransition,
                mOptions);
        if (mDoResume) {
        ...
            mSupervisor.resumeFocusedStackTopActivityLocked(mTargetStack, mStartActivity,
                        mOptions);
        ...
        }
        ...
    }
```
上面的方法中有一个 `mTargetStack` 的 `startActivityLocked(...)` 方法，它是一个 `ActivityStack` 对象，这里的方法并不是去启动一个 `Activity`，而是将要启动的 `Activity` 放入 要展示的 `ActivityStack` 中，并且初始化 `WindowManager` ，而让顶层 `Activity` 获取焦点(也就是让用户看到的那个)的方法就是 `resumeFocusedStackTopActivityLocked(...)`

## ActivityStackSupervisor

**Supervisor** 有监管员的意思，所以 `ActivityStackSupervisor` 从名字上来看，是用于监控和管理 `ActivityStack` 的

### resumeFocusedStackTopActivityLocked(...)


```
    boolean resumeFocusedStackTopActivityLocked(
            ActivityStack targetStack, ActivityRecord target, ActivityOptions targetOptions) {

        if (!readyToResume()) {
            return false;
        }

        if (targetStack != null && isFocusedStack(targetStack)) {
            return targetStack.resumeTopActivityUncheckedLocked(target, targetOptions);
        }

        final ActivityRecord r = mFocusedStack.topRunningActivityLocked();
        if (r == null || !r.isState(RESUMED)) {
            mFocusedStack.resumeTopActivityUncheckedLocked(null, null);
        } else if (r.isState(RESUMED)) {
            // Kick off any lingering app transitions form the MoveTaskToFront operation.
            mFocusedStack.executeAppTransition(targetOptions);
        }

        return false;
    }
```

接下来，进入 `ActivityStack` 的 `resumeTopActivityUncheckedLocked(...)` 方法

## ActivityStack

### resumeTopActivityUncheckedLocked(...)

```
    boolean resumeTopActivityUncheckedLocked(ActivityRecord prev, ActivityOptions options) {
        if (mStackSupervisor.inResumeTopActivity) {
            return false;
        }

        boolean result = false;
        try {
            mStackSupervisor.inResumeTopActivity = true;
            result = resumeTopActivityInnerLocked(prev, options);
            ...
        } finally {
            mStackSupervisor.inResumeTopActivity = false;
        }

        return result;
    }
```

进入 `resumeTopActivityInnerLocked(...)` 方法


```
    private boolean resumeTopActivityInnerLocked(ActivityRecord prev, ActivityOptions options) {
        
        ...
        mStackSupervisor.startSpecificActivityLocked(next, true, true);
        ...
        
    }
```
这个方法体行数依旧非常多，主要是将之前正在运行的最顶层 `Activity` 给 **pause** 掉，然后又返回到 `ActivityStackSupervisor`，并调用其 `startSpecificActivityLocked(...)` 方法

## ActivityStackSupervisor

### startSpecificActivityLocked(...)


```
    void startSpecificActivityLocked(ActivityRecord r,
            boolean andResume, boolean checkConfig) {
        // Is this activity's application already running?
        ProcessRecord app = mService.getProcessRecordLocked(r.processName,
                r.info.applicationInfo.uid, true);

        getLaunchTimeTracker().setLaunchTime(r);

        if (app != null && app.thread != null) {
            try {
                ...
                realStartActivityLocked(r, app, andResume, checkConfig);
                return;
            } catch (RemoteException e) {
                ...
            }

        }

        mService.startProcessLocked(r.processName, r.info.applicationInfo, true, 0,
                "activity", r.intent.getComponent(), false, false, true);
    }
```
上面判断了两种情况：
- 如果app进程存在，则继续进入 `realStartActivityLocked(...)` 进行下一步操作
- 如果不存在，调用 `ActivityManagerService` 的 `startProcessLocked(...)` 方法去创建进程。这里将会是我们后面要分析的 **app启动流程** 中的一部分


所以我这里先看第一种情况


### realStartActivityLocked(...)


```
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
                ...

                // Schedule transaction.
                mService.getLifecycleManager().scheduleTransaction(clientTransaction);
                ...
                
    }
```
可以看到，这里主要是通过调用`ActivityManagerService` 中 `ClientLifecycleManager`对象 的 `scheduleTransaction(...)`方法去执行 **启动Activity** 的任务 

上面需要执行的 `transaction` 对象是 `LaunchActivityItem`，在去了解它的内部构造之前，我们可以看一下 `scheduleTransaction(...)`是如何执行这个对象的。

## ClientLifecycleManager

### scheduleTransaction(...)


```
    void scheduleTransaction(ClientTransaction transaction) throws RemoteException {
        final IApplicationThread client = transaction.getClient();
        transaction.schedule();
        if (!(client instanceof Binder)) {
            transaction.recycle();
        }
    }
    
    //ClientTransaction.java
    private IApplicationThread mClient;
    public void schedule() throws RemoteException {
        mClient.scheduleTransaction(this);
    }
```

可以看到 `schedule()` 方法就是调用 `IApplicationThread` 对象的 `scheduleTransaction(...)` 方法，显然，`IApplicationThread` 是 `ApplicationThread` 的客户端代理接口(又是AIDL),我们直接找到 `ApplicationThread` 看看它的实现方法

## ActivityThread.ApplicationThread

### scheduleTransaction(...)

```
        public void scheduleTransaction(ClientTransaction transaction) throws RemoteException {
            ActivityThread.this.scheduleTransaction(transaction);
        }
        
```
因为 `ActivityThread` 继承于 `ClientTransactionHandler`，所以会跳转到 `ClientTransactionHandler` 中。

## ClientTransactionHandler

### scheduleTransaction(...)


```
    void scheduleTransaction(ClientTransaction transaction) {
        transaction.preExecute(this);
        sendMessage(ActivityThread.H.EXECUTE_TRANSACTION, transaction);
    }
```

可以看到，这里调用了一个 `sendMessage(...)` 方法。因为 `ClientTransactionHandler` 中的 `sendMessage(...)` 是抽象方法，所以我们去子类 `ActivityThread` 找它的实现

## ActivityThread

### sendMessage(...)


```
    final H mH = new H();
    
    class H extends Handler {...}

    void sendMessage(int what, Object obj) {
        sendMessage(what, obj, 0, 0, false);
    }

    private void sendMessage(int what, Object obj, int arg1, int arg2, boolean async) {
        Message msg = Message.obtain();
        msg.what = what;
        msg.obj = obj;
        msg.arg1 = arg1;
        msg.arg2 = arg2;
        if (async) {
            msg.setAsynchronous(true);
        }
        mH.sendMessage(msg);
    }
```
可以看到，最终就是调用内部的一个名为 **H** 的 **Handler** 对象发送了 **Message**，接下来就需要寻找 `what` 值为 `ActivityThread.H.EXECUTE_TRANSACTION` 的处理逻辑了：

### case EXECUTE_TRANSACTION:


```

    private final TransactionExecutor mTransactionExecutor = new TransactionExecutor(this);
    
    
                case EXECUTE_TRANSACTION:
                    final ClientTransaction transaction = (ClientTransaction) msg.obj;
                    mTransactionExecutor.execute(transaction);
                    if (isSystem()) {
                        transaction.recycle();
                    }
                    break;
```
接下来，就看一下 `execute(...)` 方法

## TransactionExecutor

### execute(...)


```
    public void execute(ClientTransaction transaction) {
        final IBinder token = transaction.getActivityToken();

        executeCallbacks(transaction);

        executeLifecycleState(transaction);
        mPendingActions.clear();
    }
```
看一看 `executeCallbacks(...)` 方法


```
    public void executeCallbacks(ClientTransaction transaction) {
        final List<ClientTransactionItem> callbacks = transaction.getCallbacks();
        ...

        final int size = callbacks.size();
        for (int i = 0; i < size; ++i) {
            final ClientTransactionItem item = callbacks.get(i);
            ...

            item.execute(mTransactionHandler, token, mPendingActions);
            item.postExecute(mTransactionHandler, token, mPendingActions);
            ...
        }
    }
```
这么看来，是执行所有 `ClientTransactionItem` 对象的 `execute(...)` 和 `postExecute(...)` 方法。到这里，我们就可以看一下之前在 `realStartActivityLocked(...)` 方法中添加的 `LaunchActivityItem` 对象了。



## LaunchActivityItem

由于没有在 `LaunchActivityItem` 中找到 `postExecute(...)`，应该是没有重写这个方法。所以我们只用看 `execute(...)` 


### execute(...)

```
    public void execute(ClientTransactionHandler client, IBinder token,
            PendingTransactionActions pendingActions) {
        Trace.traceBegin(TRACE_TAG_ACTIVITY_MANAGER, "activityStart");
        ActivityClientRecord r = new ActivityClientRecord(token, mIntent, mIdent, mInfo,
                mOverrideConfig, mCompatInfo, mReferrer, mVoiceInteractor, mState, mPersistentState,
                mPendingResults, mPendingNewIntents, mIsForward,
                mProfilerInfo, client);
        client.handleLaunchActivity(r, pendingActions, null /* customIntent */);
        Trace.traceEnd(TRACE_TAG_ACTIVITY_MANAGER);
    }
```
可以看到这里新建了一个 `ActivityClientRecord` 对象，接着我们进入 `handleLaunchActivity(...)` 来看一看。很明显，这个方法在 `ClientTransactionHandler` 的子类 `ActivityThread` 中实现



## ActivityThread

### handleLaunchActivity(...)


```
    public Activity handleLaunchActivity(ActivityClientRecord r,
            PendingTransactionActions pendingActions, Intent customIntent) {
        ...    
        final Activity a = performLaunchActivity(r, customIntent);
        ...
        return a;
    }
```

进入 `performLaunchActivity(...)`

### performLaunchActivity...)

```
    private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
        ...
        Activity activity = null;
        try {
            java.lang.ClassLoader cl = appContext.getClassLoader();
            activity = mInstrumentation.newActivity(
                    cl, component.getClassName(), r.intent);
            ...
        } catch (Exception e) {
            ...
        }
        ...
        try {
            if (activity != null) {
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
        } catch (SuperNotCalledException e) {
            throw e;

        }
        ...
        return activity;

    }
```

可以看到，在这里通过 `Instrumentation.newActivity(...)` 创建了一个新的 **Activity** ，深入其中会发现是调用了 `Class.newInstance()`通过反射的方式来创建。之后就是 **Activity** 初始化时的一些其他初始化，包括生命周期的运行了。这里限于篇幅，我们就放在下一篇再讲吧！

那么，到这里，这一篇的关于 **Activity的启动流程** 分析就到此结束啦！

# App启动流程

来到之前 `ActivityStackSupervisor` 中 `startSpecificActivityLocked(...)` 的分叉点，其实**app启动流程**的前部分和**Activity启动流程**的前部分是重叠的。我们将从这里开始，来分析一下 **app启动流程的后半段** 。接下来我们看一下 `startProcessLocked(...)` 方法

## ActivityManagerService

### startProcessLocked(...)


```
    final ProcessRecord startProcessLocked(String processName,
            ApplicationInfo info, boolean knownToBeDead, int intentFlags,
            String hostingType, ComponentName hostingName, boolean allowWhileBooting,
            boolean isolated, boolean keepIfLarge) {
        return startProcessLocked(...);
    }
```
进入下一个 `startProcessLocked(...)` 方法


```
    final ProcessRecord startProcessLocked(String processName, ApplicationInfo info,
            boolean knownToBeDead, int intentFlags, String hostingType, ComponentName hostingName,
            boolean allowWhileBooting, boolean isolated, int isolatedUid, boolean keepIfLarge,
            String abiOverride, String entryPoint, String[] entryPointArgs, Runnable crashHandler) {
        
        if (app == null) {
            checkTime(startTime, "startProcess: creating new process record");
            app = newProcessRecordLocked(info, processName, isolated, isolatedUid);
            ...
        }
        ...
        final boolean success = startProcessLocked(app, hostingType, hostingNameStr, abiOverride);
        checkTime(startTime, "startProcess: done starting proc!");
        return success ? app : null;
    }
```
可以看到，当 **app** 进程为 **null** 时，会创建一个新的。最后调用了另外一个 `startProcessLocked(...)` 方法

我们看看另一个 `startProcessLocked(...)`

```
    private final boolean startProcessLocked(ProcessRecord app,
            String hostingType, String hostingNameStr, String abiOverride) {
        return startProcessLocked(app, hostingType, hostingNameStr,
                false /* disableHiddenApiChecks */, abiOverride);
    }
```
又一个


```
    private final boolean startProcessLocked(ProcessRecord app, String hostingType,
            String hostingNameStr, boolean disableHiddenApiChecks, String abiOverride) {
            ...
            final String entryPoint = "android.app.ActivityThread";
            
            return startProcessLocked(hostingType, hostingNameStr, entryPoint, app, uid, gids,
                    runtimeFlags, mountExternal, seInfo, requiredAbi, instructionSet, invokeWith,
                    startTime);
            ...        
    }
```
注意上面的 **entryPoint** ，它将会是后面程序的入口

然后继续进入下一个 `startProcessLocked(...)`

```
    private boolean startProcessLocked(String hostingType, String hostingNameStr, String entryPoint,
            ProcessRecord app, int uid, int[] gids, int runtimeFlags, int mountExternal,
            String seInfo, String requiredAbi, String instructionSet, String invokeWith,
            long startTime) {
            ...
                    final ProcessStartResult startResult = startProcess(app.hostingType, entryPoint,
                            app, app.startUid, gids, runtimeFlags, mountExternal, app.seInfo,
                            requiredAbi, instructionSet, invokeWith, app.startTime);
            ...
    }
```
现在，进入 `startProcess(...)` 方法

### startProcess(...)


```
    private ProcessStartResult startProcess(String hostingType, String entryPoint,
            ProcessRecord app, int uid, int[] gids, int runtimeFlags, int mountExternal,
            String seInfo, String requiredAbi, String instructionSet, String invokeWith,
            long startTime) {
        try {
            ...
            final ProcessStartResult startResult;
            if (hostingType.equals("webview_service")) {
                startResult = startWebView(...);
            } else {
                startResult = Process.start(...);
            }
            checkTime(startTime, "startProcess: returned from zygote!");
            return startResult;
        } finally {
            Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
        }
    }
```
上面分了两种进程启动，其中就有我们比较熟知的 `WebView` 的进程，这个就暂时不用管了。

而 **entryPoint** 就是之前所提到的进程入口 `android.app.ActivityThread`

在之前，我们分析 `Handler` 的时候，发现 **app主线程** 就是在 `ActivityThread` 的 `main()` 中初始化的。所以关于 `ActivityThread` 我们先放一边，解决了 `Process` 的流程再来看

接下来直接看 `Process.start(...)` 方法

## Process

### start(...)


```
    public static final ZygoteProcess zygoteProcess =
            new ZygoteProcess(ZYGOTE_SOCKET, SECONDARY_ZYGOTE_SOCKET);
            
    public static final ProcessStartResult start(final String processClass,
                                  final String niceName,
                                  int uid, int gid, int[] gids,
                                  int runtimeFlags, int mountExternal,
                                  int targetSdkVersion,
                                  String seInfo,
                                  String abi,
                                  String instructionSet,
                                  String appDataDir,
                                  String invokeWith,
                                  String[] zygoteArgs) {
        return zygoteProcess.start(processClass, niceName, uid, gid, gids,
                    runtimeFlags, mountExternal, targetSdkVersion, seInfo,
                    abi, instructionSet, appDataDir, invokeWith, zygoteArgs);
    }
```
这里出现了一个 `zygoteProcess` 对象，是不是听说过这个进程很多次了？我们接着往下看

## ZygoteProcess

### start(...)


```
    public final Process.ProcessStartResult start(final String processClass,
                                                  final String niceName,
                                                  int uid, int gid, int[] gids,
                                                  int runtimeFlags, int mountExternal,
                                                  int targetSdkVersion,
                                                  String seInfo,
                                                  String abi,
                                                  String instructionSet,
                                                  String appDataDir,
                                                  String invokeWith,
                                                  String[] zygoteArgs) {
        try {
            return startViaZygote(processClass, niceName, uid, gid, gids,
                    runtimeFlags, mountExternal, targetSdkVersion, seInfo,
                    abi, instructionSet, appDataDir, invokeWith, false /* startChildZygote */,
                    zygoteArgs);
        } catch (ZygoteStartFailedEx ex) {
            Log.e(LOG_TAG,
                    "Starting VM process through Zygote failed");
            throw new RuntimeException(
                    "Starting VM process through Zygote failed", ex);
        }
    }
```

进入 `startViaZygote(...)`

### `startViaZygote(...)`


```
    private Process.ProcessStartResult startViaZygote(final String processClass,
                                                      final String niceName,
                                                      final int uid, final int gid,
                                                      final int[] gids,
                                                      int runtimeFlags, int mountExternal,
                                                      int targetSdkVersion,
                                                      String seInfo,
                                                      String abi,
                                                      String instructionSet,
                                                      String appDataDir,
                                                      String invokeWith,
                                                      boolean startChildZygote,
                                                      String[] extraArgs)
                                                      throws ZygoteStartFailedEx {
                                          
        ...                                              
        argsForZygote.add(processClass);
        ...
        
        synchronized(mLock) {
            return zygoteSendArgsAndGetResult(openZygoteSocketIfNeeded(abi), argsForZygote);
        }                                              
    }
```

上面的 `processClass` 就是我们之前传入的 `entryPoint`，也就是 `android.app.ActivityThread`

而 `openZygoteSocketIfNeeded(abi)` 方法会尝试去开启一个 `LocalSocket` 进行通信

### openZygoteSocketIfNeeded(String abi)

```
    private ZygoteState openZygoteSocketIfNeeded(String abi) throws ZygoteStartFailedEx {
        Preconditions.checkState(Thread.holdsLock(mLock), "ZygoteProcess lock not held");
        ...
        secondaryZygoteState = ZygoteState.connect(mSecondarySocket);
        ...
    }
    
        public static ZygoteState connect(LocalSocketAddress address) throws IOException {
            DataInputStream zygoteInputStream = null;
            BufferedWriter zygoteWriter = null;
            final LocalSocket zygoteSocket = new LocalSocket();

            try {
                zygoteSocket.connect(address);

                zygoteInputStream = new DataInputStream(zygoteSocket.getInputStream());

                zygoteWriter = new BufferedWriter(new OutputStreamWriter(
                        zygoteSocket.getOutputStream()), 256);
            } catch (IOException ex) {
                try {
                    zygoteSocket.close();
                } catch (IOException ignore) {
                }

                throw ex;
            }

            String abiListString = getAbiList(zygoteWriter, zygoteInputStream);

            return new ZygoteState(zygoteSocket, zygoteInputStream, zygoteWriter,
                    Arrays.asList(abiListString.split(",")));
        }
```
可以看到，数据都被保存在了 `ZygoteState` 中了

上面关于 `Socket` 的部分就先放下，主要为下面的内容做铺垫。 接下来，进入之前的 `zygoteSendArgsAndGetResult(...)`

### zygoteSendArgsAndGetResult(...)


```
    private static Process.ProcessStartResult zygoteSendArgsAndGetResult(
            ZygoteState zygoteState, ArrayList<String> args)
            throws ZygoteStartFailedEx {
            
            ...
            /**
             * See com.android.internal.os.SystemZygoteInit.readArgumentList()
             * Presently the wire format to the zygote process is:
             * a) a count of arguments (argc, in essence)
             * b) a number of newline-separated argument strings equal to count
             *
             * After the zygote process reads these it will write the pid of
             * the child or -1 on failure, followed by boolean to
             * indicate whether a wrapper process was used.
             */
            final BufferedWriter writer = zygoteState.writer;
            final DataInputStream inputStream = zygoteState.inputStream;

            writer.write(Integer.toString(args.size()));
            writer.newLine();

            for (int i = 0; i < sz; i++) {
                String arg = args.get(i);
                writer.write(arg);
                writer.newLine();
            }

            writer.flush();

            // Should there be a timeout on this?
            Process.ProcessStartResult result = new Process.ProcessStartResult();

            result.pid = inputStream.readInt();
            result.usingWrapper = inputStream.readBoolean();

            if (result.pid < 0) {
                throw new ZygoteStartFailedEx("fork() failed");
            }
            return result;
            ...
    }
```
从上面的逻辑来看，`zygoteSendArgsAndGetResult(...)` 方法是通过 **Socket** 通信的方式将数据传到了接收方，那么这个接收方在哪里呢？

上面的注释中，提示是在 `com.android.internal.os.SystemZygoteInit` 中的 `readArgumentList()` 方法，但是一番寻找后，并没有发现这个类。不过倒是在同目录下找到了 `ZygoteInit` 类，想必这里是注释错误？（后来查阅相关资料，发现的确如此）

那么，我们就先进入 `ZygoteInit` 一探究竟吧，看看它到底在哪里

## ZygoteInit

先从 `main(...)` 方法开始看起

### main(...)

```
    public static void main(String argv[]) {
        ZygoteServer zygoteServer = new ZygoteServer();
        ...
        zygoteServer.registerServerSocketFromEnv(socketName);
        ...
        try {
            ...
            if (startSystemServer) {
                Runnable r = forkSystemServer(abiList, socketName, zygoteServer);
                if (r != null) {
                    r.run();
                    return;
                }
            }
            caller = zygoteServer.runSelectLoop(abiList);
        } catch (Throwable ex) {
    
            throw ex;
        }
        ...
    }
```
上面我们主要关注 `runSelectLoop(...)` 方法

## ZygoteServer

### runSelectLoop(String abiList)


```
    Runnable runSelectLoop(String abiList) {
        
        ...
        while (true) {
            ...
            for (int i = pollFds.length - 1; i >= 0; --i) {
                ...
                        ZygoteConnection connection = peers.get(i);
                        final Runnable command = connection.processOneCommand(this);
                ...
            }
            
        }
        ...
        
    }
```
我们看一下 `ZygoteConnection` 的 `processOneCommand(...)` 方法

## ZygoteConnection

### processOneCommand(ZygoteServer zygoteServer)


```
    Runnable processOneCommand(ZygoteServer zygoteServer) {
        String args[];
        ...
        try {
            args = readArgumentList();
            descriptors = mSocket.getAncillaryFileDescriptors();
        } catch (IOException ex) {
            throw new IllegalStateException("IOException on command socket", ex);
        }
        ...
        pid = Zygote.forkAndSpecialize(parsedArgs.uid, parsedArgs.gid, parsedArgs.gids,
                parsedArgs.runtimeFlags, rlimits, parsedArgs.mountExternal, parsedArgs.seInfo,
                parsedArgs.niceName, fdsToClose, fdsToIgnore, parsedArgs.startChildZygote,
                parsedArgs.instructionSet, parsedArgs.appDataDir);

        try {
            if (pid == 0) {
                ...
                return handleChildProc(parsedArgs, descriptors, childPipeFd,
                        parsedArgs.startChildZygote);
            } else {
                ...
                handleParentProc(pid, descriptors, serverPipeFd);
                return null;
            }
        } finally {
            ...
        }
        ...
    }
```
上面有一个 `readArgumentList()` 方法，和之前在 `zygoteSendArgsAndGetResult(...)` 中的注释一样，我们来看一看：


```
    private String[] readArgumentList()
            throws IOException {

        /**
         * See android.os.Process.zygoteSendArgsAndGetPid()
         * Presently the wire format to the zygote process is:
         * a) a count of arguments (argc, in essence)
         * b) a number of newline-separated argument strings equal to count
         *
         * After the zygote process reads these it will write the pid of
         * the child or -1 on failure.
         */

        int argc;

        try {
            String s = mSocketReader.readLine();

            if (s == null) {
                // EOF reached.
                return null;
            }
            argc = Integer.parseInt(s);
        } catch (NumberFormatException ex) {
            Log.e(TAG, "invalid Zygote wire format: non-int at argc");
            throw new IOException("invalid wire format");
        }
        ...

        String[] result = new String[argc];
        for (int i = 0; i < argc; i++) {
            result[i] = mSocketReader.readLine();
            if (result[i] == null) {
                // We got an unexpected EOF.
                throw new IOException("truncated request");
            }
        }

        return result;
    }
```
可以看到，上面明显也是一个 **Socket** 通信的方式，并且注释中的内容和之前的是对应的。所以可以确定这里对之前传递过来的信息进行了处理，其中就包含 `ActivityThread.main` 入口

接下来，继续看 `processOneCommand(...)` 剩下的内容：

当 `forkAndSpecialize(...)` 方法返回的pid为0时，表示是fork出来的子进程；如果是父进程，会返回-1或是报错

我们看一下 `handleChildProc(...)`

### handleChildProc(...)


```
    private Runnable handleChildProc(Arguments parsedArgs, FileDescriptor[] descriptors,
            FileDescriptor pipeFd, boolean isZygote) {
        ...
        if (parsedArgs.invokeWith != null) {
            WrapperInit.execApplication(parsedArgs.invokeWith,
                    parsedArgs.niceName, parsedArgs.targetSdkVersion,
                    VMRuntime.getCurrentInstructionSet(),
                    pipeFd, parsedArgs.remainingArgs);

            // Should not get here.
            throw new IllegalStateException("WrapperInit.execApplication unexpectedly returned");
        } else {
            if (!isZygote) {
                return ZygoteInit.zygoteInit(parsedArgs.targetSdkVersion, parsedArgs.remainingArgs,
                        null /* classLoader */);
            } else {
                return ZygoteInit.childZygoteInit(parsedArgs.targetSdkVersion,
                        parsedArgs.remainingArgs, null /* classLoader */);
            }
        }
    }
```
关于 `invokeWith` 这个参数，它是在 `ActivityManagerService` 的 `startProcessLocked(...)` 方法被赋值的：

```
            String invokeWith = null;
            if ((app.info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                // Debuggable apps may include a wrapper script with their library directory.
                String wrapperFileName = app.info.nativeLibraryDir + "/wrap.sh";
                StrictMode.ThreadPolicy oldPolicy = StrictMode.allowThreadDiskReads();
                try {
                    if (new File(wrapperFileName).exists()) {
                        invokeWith = "/system/bin/logwrapper " + wrapperFileName;
                    }
                } finally {
                    StrictMode.setThreadPolicy(oldPolicy);
                }
            }
```
也就是只有当调试的app目录中包含一个脚本程序时，才会给它赋值。所以我就不考虑这个情况了

还剩下 `isZygote` 参数，它是 `ZygoteConnection.Arguments` 中的 `startChildZygote` 变量，在 `ZygoteProcess` 的 `start(...)` 方法中被赋值


```
          return startViaZygote(processClass, niceName, uid, gid, gids,
                    runtimeFlags, mountExternal, targetSdkVersion, seInfo,
                    abi, instructionSet, appDataDir, invokeWith, false /* startChildZygote */,
                    zygoteArgs);
```
其中的 **false** 就是。所以 `handleChildProc(...)` 中，我们只关注 `ZygoteInit.zygoteInit(...)` 方法就行了

又来到 `ZygoteInit`

## ZygoteInit

### zygoteInit(...)


```
    public static final Runnable zygoteInit(int targetSdkVersion, String[] argv, ClassLoader classLoader) {
        ...
        ZygoteInit.nativeZygoteInit();
        return RuntimeInit.applicationInit(targetSdkVersion, argv, classLoader);
    }
```
看一下 `RuntimeInit.applicationInit(...)` 方法

## RuntimeInit

### applicationInit(...)


```
    protected static Runnable applicationInit(int targetSdkVersion, String[] argv,
            ClassLoader classLoader) {
        ...

        final Arguments args = new Arguments(argv);

        // The end of of the RuntimeInit event (see #zygoteInit).
        Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);

        // Remaining arguments are passed to the start class's static main
        return findStaticMain(args.startClass, args.startArgs, classLoader);
    }
```
看起来 `findStaticMain(...)` 就是 `main` 方法的入口了

### findStaticMain(...)

```
    protected static Runnable findStaticMain(String className, String[] argv,
            ClassLoader classLoader) {
        Class<?> cl;

        try {
            cl = Class.forName(className, true, classLoader);
        } catch (ClassNotFoundException ex) {
            ...
        }

        Method m;
        try {
            m = cl.getMethod("main", new Class[] { String[].class });
        } catch (NoSuchMethodException ex) {
            ...
        } catch (SecurityException ex) {
            ...
        }

        int modifiers = m.getModifiers();
        ...

        return new MethodAndArgsCaller(m, argv);
    }
    
    static class MethodAndArgsCaller implements Runnable {
        /** method to call */
        private final Method mMethod;

        /** argument array */
        private final String[] mArgs;

        public MethodAndArgsCaller(Method method, String[] args) {
            mMethod = method;
            mArgs = args;
        }

        public void run() {
            try {
                mMethod.invoke(null, new Object[] { mArgs });
            } catch (IllegalAccessException ex) {
                throw new RuntimeException(ex);
            } catch (InvocationTargetException ex) {
                ...
            }
        }
    }
```

显然，这里是通过反射的方式，来调用 `main()` 方法，从而启动 `ActivityThread` ，那么至此 **Zygote** 相关的内容就分析到这里了。

接下来，我们看一下 `ActivityThread` 中，是在哪里启动 **首个Activity** 的

## ActivityThread

### main(...)

```
    public static void main(String[] args) {
        ...
        Looper.prepareMainLooper();
        ...
        ActivityThread thread = new ActivityThread();
        thread.attach(false, startSeq);
        ...
        Looper.loop();
    }
```
`Looper` 相关的内容，之前已在 **Handler源码分析** 中已经分析过，这里就不再赘述了。我们进入 `attach(...)` 方法一探究竟

### attach(...)

```
    final ApplicationThread mAppThread = new ApplicationThread();

    private void attach(boolean system, long startSeq) {
        ...
        if (!system) {
            ...
            RuntimeInit.setApplicationObject(mAppThread.asBinder());
            final IActivityManager mgr = ActivityManager.getService();
            try {
                mgr.attachApplication(mAppThread, startSeq);
            } catch (RemoteException ex) {
                throw ex.rethrowFromSystemServer();
            }
            ...
        } else {
            ...
        }
        ...
    }
```
因为传过来的 `system` 为 **false**，所以这里只考虑第一个 **if** 逻辑

进入 `attachApplication(...)` 看一看，因为是 `ActivityManagerService` 的代理，所以直接 `ActivityManagerService` 找对应的方法

## ActivityManagerService

### attachApplication(...)


```
    @Override
    public final void attachApplication(IApplicationThread thread, long startSeq) {
        synchronized (this) {
            int callingPid = Binder.getCallingPid();
            final int callingUid = Binder.getCallingUid();
            final long origId = Binder.clearCallingIdentity();
            attachApplicationLocked(thread, callingPid, callingUid, startSeq);
            Binder.restoreCallingIdentity(origId);
        }
    }
```
然后看一下 `attachApplicationLocked(...)`

### attachApplicationLocked(...)

又是一个超长的方法体

```
    private final boolean attachApplicationLocked(IApplicationThread thread,
            int pid, int callingUid, long startSeq) {
        ...
                thread.bindApplication(processName, appInfo, providers,
                        app.instr.mClass,
                        profilerInfo, app.instr.mArguments,
                        app.instr.mWatcher,
                        app.instr.mUiAutomationConnection, testMode,
                        mBinderTransactionTrackingEnabled, enableTrackAllocation,
                        isRestrictedBackupMode || !normalMode, app.persistent,
                        new Configuration(getGlobalConfiguration()), app.compat,
                        getCommonServicesLocked(app.isolated),
                        mCoreSettingsObserver.getCoreSettingsLocked(),
                        buildSerial, isAutofillCompatEnabled);
        ...
       // See if the top visible activity is waiting to run in this process...
        if (normalMode) {
            try {
                if (mStackSupervisor.attachApplicationLocked(app)) {
                    didSomething = true;
                }
            } catch (Exception e) {
                Slog.wtf(TAG, "Exception thrown launching activities in " + app, e);
                badApp = true;
            }
        }
    }
```
上面的第一个部分是 `bindApplication(...)` 方法，显然和 **Application** 有关，因为 `IApplicationThread` 是 `ActivityThread` 中 `ApplicationThread` 的代理，所以我们直接在里面寻找相关方法

## ActivityThread.ApplicationThread

### bindApplication(...)


```
        public final void bindApplication(String processName, ApplicationInfo appInfo,
                List<ProviderInfo> providers, ComponentName instrumentationName,
                ProfilerInfo profilerInfo, Bundle instrumentationArgs,
                IInstrumentationWatcher instrumentationWatcher,
                IUiAutomationConnection instrumentationUiConnection, int debugMode,
                boolean enableBinderTracking, boolean trackAllocation,
                boolean isRestrictedBackupMode, boolean persistent, Configuration config,
                CompatibilityInfo compatInfo, Map services, Bundle coreSettings,
                String buildSerial, boolean autofillCompatibilityEnabled) {
            ...
            sendMessage(H.BIND_APPLICATION, data);
        }
```

根据这个 `BIND_APPLICATION` 继续下一步


```
                case BIND_APPLICATION:
                    Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "bindApplication");
                    AppBindData data = (AppBindData)msg.obj;
                    handleBindApplication(data);
                    Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
                    break;
```
得到 `handleBindApplication(...)` 方法

### handleBindApplication(...)


```
    private void handleBindApplication(AppBindData data) {
        ...
        final InstrumentationInfo ii;
        ...
        if (ii != null) {
            ...
                mInstrumentation = (Instrumentation)
                    cl.loadClass(data.instrumentationName.getClassName()).newInstance();
            ...
        } else {
            mInstrumentation = new Instrumentation();
            mInstrumentation.basicInit(this);
        }
        ...
        Application app;
        ...
            app = data.info.makeApplication(data.restrictedBackupMode, null);
        ...
                mInstrumentation.onCreate(data.instrumentationArgs);
        ...
                mInstrumentation.callApplicationOnCreate(app);
        ...
    }
```
上面创建了 `Application` 实例，以及 `Instrumentation` 实例。关于绑定 `Application` 就看到这里


接着我们来看一下之前 `attachApplicationLocked` 中的 `attachApplicationLocked(...)` 方法，显然这和 `Activity` 启动有关

## ActivityStackSupervisor

### attachApplicationLocked(...)


```
    boolean attachApplicationLocked(ProcessRecord app) throws RemoteException {
        ...
                final int size = mTmpActivityList.size();
                for (int i = 0; i < size; i++) {
                    final ActivityRecord activity = mTmpActivityList.get(i);
                    if (activity.app == null && app.uid == activity.info.applicationInfo.uid
                            && processName.equals(activity.processName)) {
                        try {
                            if (realStartActivityLocked(activity, app,
                                    top == activity /* andResume */, true /* checkConfig */)) {
                                didSomething = true;
                            }
                        } catch (RemoteException e) {
                            ...
                        }
                    }
                }
        ...
        return didSomething;
    }
```
显然， 这里调用了 `realStartActivityLocked(...)` 方法，也就是说从这里开始，又回到了前面分析 **Activity启动流程** 的环节中，我们所有的分析已经形成一个环了！

那么这篇文章的分析部分，就到这里结束啦！



# 总结

一开始只想了解一下 **Activity的启动流程**，可是看到中途又不知不觉进入了 **app启动流程** 的坑。看源码就是这样，千丝万缕的关系，最后汇成一个大的体系。

下面做个简单的总结吧：

- 流程中的几处跳转，都是通过AIDL来实现的。分别是 `IApplicationThread` 和 `IActivityManager`。
    - `IApplicationThread` 是AMS请求app进程的接口，它的实现是在 `ActivityThread` 中的 `ApplicationThread`
    - `IActivityManager` 是app进程请求AMS的接口，它的实现就是AMS：`ActivityManagerService` 啦
- 在app的启动流程中，通过 **Socket通信** 传递启动相关信息，来启动 `ActivityThread` 

文字总结大概就是这样，剩下的就看图片吧，方便多了

## Activity 启动流程

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/activity_start/activity_start.png)

## App启动流程

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/activity_start/app_start.png)