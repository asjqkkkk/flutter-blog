---
title: Android事件分发流程
date: 2020-04-02 07:23:47
index_img: /img/touch_event.png
tags: 源码系列
---
# 序

这一篇，要开始准备分析Android的事件分发机制啦。

而上一篇，我们刚好了解了View的绘制流程，它对于这一篇的理解也是有一点小帮助的！


# 引子

这次分析的入口非常好找，我们可以在自己的Activity中重写 `onTouchEvent(event)` 方法。就以这个方法作为入口。


```
class MainActivity : AppCompatActivity() {
    ...
    override fun onTouchEvent(event: MotionEvent?): Boolean {
        return super.onTouchEvent(event)
    }
}
```

# Activity

## onTouchEvent(event)

可以从上面重写的方法，进入到 Activity 的 `onTouchEvent(event)`

```
public class Activity extends ..., Window.Callback, ... {
    ...
    public boolean onTouchEvent(MotionEvent event) {
        if (mWindow.shouldCloseOnTouch(this, event)) {
            finish();
            return true;
        }

        return false;
    }
    ...
}
```

`onTouchEvent(event)` 是接口 `Window.Callback` 中的方法。

第一个if中调用的 `shouldCloseOnTouch(...)` 方法，当它返回 ture 时，就结束当前Activity

可以看一下这个方法

```
    //Window
    public boolean shouldCloseOnTouch(Context context, MotionEvent event) {
        final boolean isOutside =
                event.getAction() == MotionEvent.ACTION_DOWN && isOutOfBounds(context, event)
                || event.getAction() == MotionEvent.ACTION_OUTSIDE;
        if (mCloseOnTouchOutside && peekDecorView() != null && isOutside) {
            return true;
        }
        return false;
    }

```
这种情况一般适用于触摸事件发生在window外，比如给Activity设置如下window属性：

```
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(FLAG_NOT_TOUCH_MODAL, FLAG_NOT_TOUCH_MODAL);
        window.setFlags(FLAG_WATCH_OUTSIDE_TOUCH, FLAG_WATCH_OUTSIDE_TOUCH);
        setContentView(R.layout.activity_main2)
    }
```
然后设置一个窗口Theme：

```
        <activity android:name=".xxxxxxActivity" android:theme="@style/Theme.AppCompat.Dialog"></activity>

```

就可以结合自定义的布局实现一个伪弹窗，具体效果可以参考AlertDoalog点击空白处消失。点击Activity的空白处就会触发 `MotionEvent.ACTION_OUTSIDE` 事件。不过因为 `MotionEvent.ACTION_OUTSIDE` 平时不常用，这里就不多讲了

接下来我们看一下，Activity的 `onTouchEvent(event)` 是被谁调用的

## dispatchTouchEvent(event)

可以找到被调用的地方


```
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            onUserInteraction();
        }
        if (getWindow().superDispatchTouchEvent(ev)) {
            return true;
        }
        return onTouchEvent(ev);
    }
```
就是这个方法，用于分发操作事件

其中 `onUserInteraction()` 表示用户与手机产生交互，不用详说。重点在于 `superDispatchTouchEvent(ev)` 方法。

可以从上一篇文章知道，这里的 `getWindow()` 其实获取的是 `PhoneWindow` 对象，我们去看一看它的 `superDispatchTouchEvent(ev)`

# PhoneWindow


```
    @Override
    public boolean superDispatchTouchEvent(MotionEvent event) {
        return mDecor.superDispatchTouchEvent(event);
    }
```
这里进入了 `DecorView` ，继续看

# DecorView


```
    public boolean superDispatchTouchEvent(MotionEvent event) {
        return super.dispatchTouchEvent(event);
    }
```
这里将会调用 `ViewGroup` 的 `dispatchTouchEvent(event)` 方法，到这里，我们就要开始我们常听说的事件分发流程啦！

接下来会进入 `GroupView` 

# GroupView


```
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        ...
        boolean handled = false;
        if (onFilterTouchEventForSecurity(ev)) {
            ...
            //第一部分
            final boolean intercepted;
            if (actionMasked == MotionEvent.ACTION_DOWN
                    || mFirstTouchTarget != null) {
                final boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;
                if (!disallowIntercept) {
                    intercepted = onInterceptTouchEvent(ev);
                    ...
                } else {
                    intercepted = false;
                }
            } else {
                intercepted = true;
            }
            ...
            //第二部分
            final boolean canceled = resetCancelNextUpFlag(this)
                    || actionMasked == MotionEvent.ACTION_CANCEL;
            ...
            if (!canceled && !intercepted) {
                ...
                if (actionMasked == MotionEvent.ACTION_DOWN
                        || (split && actionMasked == MotionEvent.ACTION_POINTER_DOWN)
                        || actionMasked == MotionEvent.ACTION_HOVER_MOVE) {
                    ...
                    final int childrenCount = mChildrenCount;
                    if (newTouchTarget == null && childrenCount != 0) {
                        ...
                        final ArrayList<View> preorderedList = buildTouchDispatchChildList();
                        ...
                        final View[] children = mChildren;
                        for (int i = childrenCount - 1; i >= 0; i--) {
                            final int childIndex = getAndVerifyPreorderedIndex(
                                    childrenCount, i, customOrder);
                            final View child = getAndVerifyPreorderedView(
                                    preorderedList, children, childIndex);
                            ...
                            if (dispatchTransformedTouchEvent(ev, false, child, idBitsToAssign)) {
                                ...
                                newTouchTarget = addTouchTarget(child, idBitsToAssign);
                                ...
                            }
                            ...
                        }
                        ...
                    }
                }
            }
            ...
            //第三部分
            if (mFirstTouchTarget == null) {
                ...
            } else {
                ...
            }
        }
        ...
        return handled;
    }
```
上面的逻辑主要分为三个部分，我们先从第一个部分开始看起

## 第一部分

当前 `ViewGroup` 允许拦截事件的时候，会调用 `onInterceptTouchEvent` 来决定是否需要对事件进行拦截。如果拦截的话，`intercepted` 会设置为 `true`


```
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        if (ev.isFromSource(InputDevice.SOURCE_MOUSE)
                && ev.getAction() == MotionEvent.ACTION_DOWN
                && ev.isButtonPressed(MotionEvent.BUTTON_PRIMARY)
                && isOnScrollbarThumb(ev.getX(), ev.getY())) {
            return true;
        }
        return false;
    }
```
这个方法可以被子类重写，多用于处理滑动冲突，这个后面再说

## 第二部分

当触摸事件没有取消，并且 `ViewGroup` 不拦截当前事件时。就会进入第二部分

可以看到，第二部分中有一个 `preorderedList` ，我们可以看一下这个列表是干什么的


```
    public ArrayList<View> buildTouchDispatchChildList() {
        return buildOrderedChildList();
    }
    ...
    ArrayList<View> buildOrderedChildList() {
        ...
        for (int i = 0; i < childrenCount; i++) {
            ...
            int insertIndex = i;
            while (insertIndex > 0 && mPreSortedChildren.get(insertIndex - 1).getZ() > currentZ) {
                insertIndex--;
            }
            mPreSortedChildren.add(insertIndex, nextChild);
        }
        return mPreSortedChildren;
    }
```
这里可以得知，该列表就是根据 `View` 在 **Z轴** 上的坐标，按照从高到底的顺序放入列表中。这里其实也可以得知，触摸事件是从外到里的

后面的逻辑会进入到一个判断语句

```
if (dispatchTransformedTouchEvent(ev, false, child, idBitsToAssign)) {
    ...
    newTouchTarget = addTouchTarget(child, idBitsToAssign);
    alreadyDispatchedToNewTouchTarget = true;
    break;
}
```
`dispatchTransformedTouchEvent(...)` 是一个非常重要的方法

在第三部分的逻辑中，主要也和它有关，我们直接来看一下它的逻辑


```
    private boolean dispatchTransformedTouchEvent(MotionEvent event, boolean cancel,
            View child, int desiredPointerIdBits) {
        final boolean handled;
        ...
        if (child == null) {
            handled = super.dispatchTouchEvent(transformedEvent);
        } else {
            final float offsetX = mScrollX - child.mLeft;
            final float offsetY = mScrollY - child.mTop;
            transformedEvent.offsetLocation(offsetX, offsetY);
            if (! child.hasIdentityMatrix()) {
                transformedEvent.transform(child.getInverseMatrix());
            }

            handled = child.dispatchTouchEvent(transformedEvent);
        }

        // Done.
        transformedEvent.recycle();
        return handled;
    }
```
`dispatchTransformedTouchEvent(...)` 中有三段类似的逻辑，上面为了控制篇幅只显示了其中一段

大致逻辑分为两种情况：
- 当 `child` 为 **null** 时: 调用 `View` 的 `dispatchTouchEvent(event)` 方法分发事件
- 当 `child` 不为 **null** 时: 调用 `child` 的 `dispatchTouchEvent(event)` 方法，如果它没有重写这个分发，会来到 `View` 的 `dispatchTouchEvent(event)` 

那么我们先去看一下 `View` 的 `dispatchTouchEvent(event)` 方法，再了解 `ViewGroup` 后面的逻辑吧

# View

来看看 `View` 的事件分发

## dispatchTouchEvent(event)


```
    public boolean dispatchTouchEvent(MotionEvent event) {
        ...

        if (onFilterTouchEventForSecurity(event)) {
            ...
            ListenerInfo li = mListenerInfo;
            if (li != null && li.mOnTouchListener != null
                    && (mViewFlags & ENABLED_MASK) == ENABLED
                    && li.mOnTouchListener.onTouch(this, event)) {
                result = true;
            }

            if (!result && onTouchEvent(event)) {
                result = true;
            }
        }
        ...

        return result;
    }
```
可以看到， `mOnTouchListener`的 `onTouch(...)` 比 `onTouchEvent(event)` 的优先级要高

我们接下来我们还是主要关注 `onTouchEvent(event)` 方法

## onTouchEvent(event)


```
    public boolean onTouchEvent(MotionEvent event) {
        ...
        if (clickable || (viewFlags & TOOLTIP) == TOOLTIP) {
            switch (action) {
                case MotionEvent.ACTION_UP:
                    ...
                    break;
                case MotionEvent.ACTION_DOWN:
                    ...
                    break;
                case MotionEvent.ACTION_CANCEL:
                    ...
                    break;
                case MotionEvent.ACTION_MOVE:
                    ...
                    break;
            }
            return true;      
        }
        return false;
    }
```
在 `onTouchEvent(event)` 中，主要处理了四种情况，分别是 `ACTION_UP`、`ACTION_DOWN`、`ACTION_CANCEL` 以及 `ACTION_MOVE`

我们来分别看一下这四种情况


### ACTION_UP

```
case MotionEvent.ACTION_UP:
    ...
    boolean prepressed = (mPrivateFlags & PFLAG_PREPRESSED) != 0;
    if ((mPrivateFlags & PFLAG_PRESSED) != 0 || prepressed) {
        ...
        if (!mHasPerformedLongPress && !mIgnoreNextUpEvent) {
            // This is a tap, so remove the longpress check
            removeLongPressCallback();

            // Only perform take click actions if we were in the pressed state
            if (!focusTaken) {
                ...
                if (mPerformClick == null) {
                    mPerformClick = new PerformClick();
                }
                if (!post(mPerformClick)) {
                    performClickInternal();
                }
            }
        }
        ...
    }
    mIgnoreNextUpEvent = false;
    break;
```
在 `ACTION_UP` 中，主要处理的是 `PerformClick()` ,而它最后执行的是 `performClick()` 方法


```
    private final class PerformClick implements Runnable {
        @Override
        public void run() {
            performClickInternal();
        }
    }
    ...
    private boolean performClickInternal() {
        ...
        return performClick();
    }
    ...
    public boolean performClick() {
        ...
        final boolean result;
        final ListenerInfo li = mListenerInfo;
        if (li != null && li.mOnClickListener != null) {
            playSoundEffect(SoundEffectConstants.CLICK);
            li.mOnClickListener.onClick(this);
            result = true;
        } else {
            result = false;
        }
        ...
        return result;
    }
```
显然，在  `performClick()` 中，最后是执行的 `onClick(...)` 点击事件

 `ACTION_UP` 表示手指抬起，也就是说点击事件是在这个情况下触发的
 
 
### ACTION_DOWN


```
case MotionEvent.ACTION_DOWN:
    ...
    if (isInScrollingContainer) {
        mPrivateFlags |= PFLAG_PREPRESSED;
        if (mPendingCheckForTap == null) {
            mPendingCheckForTap = new CheckForTap();
        }
        mPendingCheckForTap.x = event.getX();
        mPendingCheckForTap.y = event.getY();
        postDelayed(mPendingCheckForTap, ViewConfiguration.getTapTimeout());
    } else {
        // Not inside a scrolling container, so show the feedback right away
        setPressed(true, x, y);
        checkForLongClick(0, x, y);
    }
    break;
```
`ACTION_DOWN` 主要做两件事，一是判断当前 `View` 是否在滚动的布局中，如果在的话将点击事件的反馈延迟 100ms 触发；如果不是则立即对点击事件进行反馈，同时判断是否有长按事件

### ACTION_CANCEL


```
case MotionEvent.ACTION_CANCEL:
    if (clickable) {
        setPressed(false);
    }
    removeTapCallback();
    removeLongPressCallback();
    mInContextButtonPress = false;
    mHasPerformedLongPress = false;
    mIgnoreNextUpEvent = false;
    mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
    break;
```
`ACTION_CANCEL` 就是进行一些状态初始化的操作了

### ACTION_MOVE


```
case MotionEvent.ACTION_MOVE:
    if (clickable) {
        drawableHotspotChanged(x, y);
    }

    // Be lenient about moving outside of buttons
    if (!pointInView(x, y, mTouchSlop)) {
        // Outside button
        // Remove any future long press/tap checks
        removeTapCallback();
        removeLongPressCallback();
        if ((mPrivateFlags & PFLAG_PRESSED) != 0) {
            setPressed(false);
        }
        mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
    }
    break;
```
`ACTION_MOVE` 主要是用于更新触摸点在 `Drawable` 中的位置，同时判断如果触摸点在 `View` 外的话，做一些重置操作

到这里，关于 `View` 中的事件分发，其实就结束了。这时候我们回到 `ViewGroup` 的第二部分逻辑

# ViewGroup

## 第二部分

接着之前的来


```
if (dispatchTransformedTouchEvent(ev, false, child, idBitsToAssign)) {
    ...
    newTouchTarget = addTouchTarget(child, idBitsToAssign);
    alreadyDispatchedToNewTouchTarget = true;
    break;
}
```
当 `dispatchTransformedTouchEvent(...)` 返回 true 时，表示 `child` 消费了当前事件。我们看一下 `addTouchTarget(...)` 方法

### addTouchTarget(...)


```
    private TouchTarget addTouchTarget(@NonNull View child, int pointerIdBits) {
        final TouchTarget target = TouchTarget.obtain(child, pointerIdBits);
        target.next = mFirstTouchTarget;
        mFirstTouchTarget = target;
        return target;
    }
```
这里的操作其实比较类似 `MessageQuene` 里复用一个 `Message` 的场景。就是将这个 **子View** 放入 `TouchTarget` 对象中，`TouchTarget` 是一个链表，同时把 `mFirstTouchTarget` 放在链表头部

从这里可以看出， `TouchTarget` 是一个存放了要消耗触摸事件的 **子View** 链表

到这里就可以看第三部分的逻辑了

## 第三部分


```
if (mFirstTouchTarget == null) {
    // No touch targets so treat this as an ordinary view.
    handled = dispatchTransformedTouchEvent(ev, canceled, null,
            TouchTarget.ALL_POINTER_IDS);
} else {
    // Dispatch to touch targets, excluding the new touch target if we already
    // dispatched to it.  Cancel touch targets if necessary.
    TouchTarget predecessor = null;
    TouchTarget target = mFirstTouchTarget;
    while (target != null) {
        final TouchTarget next = target.next;
        if (alreadyDispatchedToNewTouchTarget && target == newTouchTarget) {
            handled = true;
        } else {
            final boolean cancelChild = resetCancelNextUpFlag(target.child)
                    || intercepted;
            if (dispatchTransformedTouchEvent(ev, cancelChild,
                    target.child, target.pointerIdBits)) {
                handled = true;
            }
            if (cancelChild) {
                if (predecessor == null) {
                    mFirstTouchTarget = next;
                } else {
                    predecessor.next = next;
                }
                target.recycle();
                target = next;
                continue;
            }
        }
        predecessor = target;
        target = next;
    }
}
```
当 `ViewGroup` 拦截了事件或者 `cancle` 为 **true** 时会直接跳过第二部分直接来到第三部分,而在没有经历过第二部分的时候, `mFirstTouchTarget` 的值会为 **null**



`ViewGroup` 的第三部分，判断 `mFirstTouchTarget` 是否为 **null**
- 如果  `mFirstTouchTarget` 为 **null** : 说明没有需要消耗事件的 **子View**， 调用 `dispatchTransformedTouchEvent(...)` 传入 `child` 为 null
- 如果  `mFirstTouchTarget` 不为 **null** : 则遍历 `mFirstTouchTarget` 看看有没有消耗触摸事件的 **子View**，有的话将返回结果设为 **true**

到这里，事件分发流程就分析结束啦！


# 总结

这次总结就用一张图片吧!

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/android_touch_event/touch_event.png)