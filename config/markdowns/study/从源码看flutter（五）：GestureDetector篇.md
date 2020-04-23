---
title: 从源码看flutter（五）：GestureDetector篇
date: 2020-04-23 10:43:35
index_img: /img/flutter_05.png
tags: Flutter系列
---
# 开篇

flutter的触摸事件涉及到的东西比较多，本篇文章将会从  `GestureDetector` 作为切入点，来对触摸事件的实现做一个全面的了解

# GestureDetector

```
class GestureDetector extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};
    ...
    return RawGestureDetector(
      gestures: gestures,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    );
  }
}
```
这里，会将所有在 `GestureDetector` 设置的各种点击事件，放在各个 `GestureRecognizer` 中，然后通过 `GestureRecognizerFactory` 对其进行封装，存入 `gestures` 中，这里 `GestureRecognizerFactory` 的实现还是蛮有意思的，感兴趣的小伙伴可以去看一下它的源码

这里，我们先简单了解一下 `GestureRecognizer`

## GestureRecognizer


```
abstract class GestureRecognizer extends GestureArenaMember with DiagnosticableTreeMixin {
  ...
  void addPointer(PointerDownEvent event) { 
    ...
    if (isPointerAllowed(event)) {
      addAllowedPointer(event);
    } else {
      handleNonAllowedPointer(event);
    }
  }
  
  @protected
  void addAllowedPointer(PointerDownEvent event) { }
  ...
}
```
`GestureRecognizer` 主要提供了`addPointer(downEvent)` 用于接收 `PointerDownEvent` 对象，它会调用 `addAllowedPointer(event)` 方法，由子类去具体实现

`GestureRecognizer` 继承于 `GestureArenaMember`，它只提供了两个方法

```
abstract class GestureArenaMember {
  void acceptGesture(int pointer);

  void rejectGesture(int pointer);
}
```
分别表示手势竞技场成员获胜与失败时会调用的方法，接下来我们来看一下 `RawGestureDetector`

# RawGestureDetector

```
class RawGestureDetector extends StatefulWidget {
    ...
}

class RawGestureDetectorState extends State<RawGestureDetector> {
  ...
  void _handlePointerDown(PointerDownEvent event) {
    assert(_recognizers != null);
    for (final GestureRecognizer recognizer in _recognizers.values)
      recognizer.addPointer(event);
  }
  。。。
  @override
  Widget build(BuildContext context) {
    Widget result = Listener(
      onPointerDown: _handlePointerDown,
      behavior: widget.behavior ?? _defaultBehavior,
      child: widget.child,
    );
    if (!widget.excludeFromSemantics)
      result = _GestureSemantics(...);
    return result;
  }
  ...
}
```
`RawGestureDetector` 是一个 `StatefulWidget` ，它默认返回的是 `Listener` 对象。其中还有一个 `_GestureSemantics` 它用于实现一些具有语义化的手势，比如长按展示 `tooltip`等，这里我们不用关注它。

这里将之前通过 `GestureDetector` 传入的 `gestures` 转换成了 `_recognizers`，并且将他们放在了 `_handlePointerDown(event)` 方法里通过 `onPointerDown` 传给了 `Listener` 对象

这里还需要注意， `_handlePointerDown(event)` 中对 `GestureRecognizer` 对象进行了遍历，并调用了他们的 `addPointer(event)` 方法

接下来我们看一下 `Listener` 

# Listener


```
class Listener extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    Widget result = _child;
    if (onPointerEnter != null ||
        onPointerExit != null ||
        onPointerHover != null) {
      result = MouseRegion(...);
    }
    result = _PointerListener(
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
      onPointerMove: onPointerMove,
      onPointerCancel: onPointerCancel,
      onPointerSignal: onPointerSignal,
      behavior: behavior,
      child: result,
    );
    return result;
  }
}
```
`Listener` 是一个 `StatelessWidget` ，当传入的部分事件不为 **null** 时，比如悬停事件 `onPointerHover`，返回的就是 `MouseRegion`，它用来处理鼠标的输入，默认返回 `_PointerListener`，这里我们只需要关注这个对象

从前面我们可以知道，我们只对 `Listener` 传入了 `onPointerDown` ，所以这里传递给 `_PointerListener` 的其他手势回调都是 `null`

# _PointerListener

```
class _PointerListener extends SingleChildRenderObjectWidget {
  ...
  @override
  RenderPointerListener createRenderObject(BuildContext context) {
    return RenderPointerListener(
      onPointerDown: onPointerDown,
      ...
    );
  }
  ...
}
```
`_PointerListener` 是一个 `SingleChildRenderObjectWidget` ，它对应的 `RenderObject` 是 `RenderPointerListener` ，我们来看一下这个对象

# RenderPointerListener


```
class RenderPointerListener extends RenderProxyBoxWithHitTestBehavior {
  ...
  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    ...
    if (onPointerDown != null && event is PointerDownEvent)
      return onPointerDown(event);
    ...
  }
}
```
之前我们分析 `RenderObject` 时就知道， `RenderObject` 对象有一个 `HitTestTarget` 接口


```
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget { ... }

abstract class HitTestTarget {
  factory HitTestTarget._() => null;

  void handleEvent(PointerEvent event, HitTestEntry entry);
}
```
这个接口提供了 `handleEvent(...)` 方法供 `RenderObject` 实现去处理各种手势事件，最终基本上都是交给子类去实现这个方法。这里的 `RenderPointerListener` 就是如此

这里对于 `GestureDetector` 的整体结构有了一个初步的了解，并且无法再往下深入了，接下来我们将从另外一个切入点来看手势事件。那就是手势分发的起点


# 手势分发流程

起点其实不难找，之前我们就知道过了，`runApp(...)` 方法作为flutter的入口，会对 `WidgetsFlutterBinding` 进行初始化，`WidgetsFlutterBinding` 混入了多个 `Binding` 对象，其中就有专门处理手势的 `GestureBinding`，我们看一下就知道了

## 手势分发起点: GestureBinding

在 `GestureBinding` 的 `initInstances()` 中可以看到如下内容


```
mixin GestureBinding on BindingBase implements HitTestable, HitTestDispatcher, HitTestTarget {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    window.onPointerDataPacket = _handlePointerDataPacket;
  }
  ...
}
```
这里的 `_handlePointerDataPacket` 就是触摸事件的起点，它会处理设备输入的信息，将其转换为flutter中的手势事件

### _handlePointerDataPacket(...)


```
  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();
  
  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    _pendingPointerEvents.addAll(PointerEventConverter.expand(packet.data, window.devicePixelRatio));
    if (!locked)
      _flushPointerEventQueue();
  }
```
手势事件都被存放在了一个队列中，之后会调用 `_flushPointerEventQueue()` 来进行手势分发

### _flushPointerEventQueue(...)

```
  void _flushPointerEventQueue() {
    assert(!locked);
    while (_pendingPointerEvents.isNotEmpty)
      _handlePointerEvent(_pendingPointerEvents.removeFirst());
  }
```
这里通过遍历队列，调用 `_handlePointerEvent(event)` 对各个event进行处理

### _handlePointerEvent(event)

```
  void _handlePointerEvent(PointerEvent event) {
    ...
    HitTestResult hitTestResult;
    if (event is PointerDownEvent || event is PointerSignalEvent) {
      ...
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      ...
    } else if (event.down) {
      ...
    }
    ...
    if (hitTestResult != null ||
        event is PointerHoverEvent ||
        event is PointerAddedEvent ||
        event is PointerRemovedEvent) {
      dispatchEvent(event, hitTestResult);
    }
  }
```
当你在在屏幕上点击一下，触发的事件流程如下:

> PointerHoverEvent -> PointerDownEvent -> PointerUpEvent

在屏幕上滑动时，流程如下

> PointerHoverEvent -> PointerDownEvent -> ...PointerMoveEvent... -> PointerUpEvent

`PointerHoverEvent` 主要用于 flutter_web 中的鼠标悬停事件，这里我们不关注它，我们可以看一下，当触发 `PointerDownEvent` 时，做了些什么


```
  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};
  ...
    if (event is PointerDownEvent || event is PointerSignalEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      hitTestResult = HitTestResult();
      hitTest(hitTestResult, event.position);
      if (event is PointerDownEvent) {
        _hitTests[event.pointer] = hitTestResult;
      }
      ...
    }
  ...
  @override // from HitTestable
  void hitTest(HitTestResult result, Offset position) {
    result.add(HitTestEntry(this));
  }
```
这里的 `hitTest(...)` 由接口 `HitTestable` 提供，值得注意的是 `GestureBinding` 与 `RendererBinding` 都实现了这个接口，可以看一下在 `RendererBinding` 中的实现

```
  ///RendererBinding
  @override
  void hitTest(HitTestResult result, Offset position) {
    assert(renderView != null);
    renderView.hitTest(result, position: position);
    super.hitTest(result, position);
  }
```
这里调用了 `RenderView` 的 `hitTest(...)` 方法，我们已经知道过了，它是根 `RenderObject` 对象，进入它的 `hitTest(...)` 看一下

```
  ///RenderView
  bool hitTest(HitTestResult result, { Offset position }) {
    if (child != null)
      child.hitTest(BoxHitTestResult.wrap(result), position: position);
    result.add(HitTestEntry(this));
    return true;
  }
```
这里的 `child` 是 `RenderBox` 对象，在 `RenderBox` 中默认提供了 `hitTest(...)` 这个方法

```
  ///RenderBox
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    ...
    if (_size.contains(position)) {
      if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
```
所以看到这里你就能知道，当触发了 `PointerDownEvent ` 事件时，会调用所有 `RenderBox` 的 `hitTest(...)` 方法，将符合条件的对象放入到 `BoxHitTestEntry(...)` 中，再存入 `HitTestResult` 维护的 ` List<HitTestEntry> _path` 里

`HitTestEntry` 接受的对象是 `HitTestTarget` ，上面我们也提到过了，`RenderObject` 是实现了这个接口的。所以最后这些 `RenderBox` 会被存入 `BoxHitTestEntry` 先放入 `List<HitTestEntry>` 中，其次是存入了 `HitTestEntry` 的 `RenderView` ，最后才是 `GestureBinding` 对象

至于为什么要把这些对象收集起来放入 `HitTestResult` 呢？后面会逐步说明

当 `HitTestResult` 被创建后，会被存入`GestureBinding` 维护的 `Map<int, HitTestResult> _hitTests` 中，**key** 是 `event.pointer` ，每触发一次事件，`pointer` 的值都会+1，不会重复

接下来，会进入 `dispatchEvent(event, hitTestResult)` 方法，进行分发事件

### dispatchEvent(...)


```
  @override // from HitTestDispatcher
  void dispatchEvent(PointerEvent event, HitTestResult hitTestResult) {
    ...
    if (hitTestResult == null) {
      assert(event is PointerHoverEvent || event is PointerAddedEvent || event is PointerRemovedEvent);
      try {
        pointerRouter.route(event);
      } catch (exception, stack) {
        ...
      return;
    }
    for (final HitTestEntry entry in hitTestResult.path) {
      try {
        entry.target.handleEvent(event.transformed(entry.transform), entry);
      }
      ...
    }
  }
```
我们主要关注 `entry.target.handleEvent(...)` 方法，这里对之前在 `hitTest(...)` 中添加的各个实现了 `HitTestTarget` 接口的对象，调用其 `handleEvent(...)` 方法。而 `hitTestResult.path` 的顺序我们已经说过了，大致是下面这样：

> ... -> RenderPointerListener -> ... -> RenderView -> GestureBinding

这里会依次调用他们实现的 `handleEvent(...)` 。而事件的分发，就是通过这样实现的！

## 开始手势分发

我们再次进入 `RenderPointerListener` 的 `handleEvent(...)` 方法

### RenderPointerListener 


```
  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    ...
    if (onPointerDown != null && event is PointerDownEvent)
      return onPointerDown(event);
    ...
  }
```
这里会调用 `onPointerDown(event)` ，通过前面的的了解，我们知道这个方法就是 `RawGestureDetectorState ` 传入的 `_handlePointerDown(...)`，再来看一遍


```
  void _handlePointerDown(PointerDownEvent event) {
    for (final GestureRecognizer recognizer in _recognizers.values)
      recognizer.addPointer(event);
  }
```
`addPointer(event)` 的内容之前也说过了，最终都是调用 `GestureRecognizer` 提供的 `addAllowedPointer(...)` 方法。如果我们在 `GestureDetector` 中设置了 `onTapDown()` 或者其他点击事件，这里就会调用 `TapGestureRecognizer` 的 `addPointer(...)` 方法。我们就先以它为例，来看一下都做了些什么

#### TapGestureRecognizer

我们先简单的看一下 `TapGestureRecognizer` 的继承结构

> TapGestureRecognizer -> BaseTapGestureRecognizer -> PrimaryPointerGestureRecognizer -> OneSequenceGestureRecognizer -> GestureRecognizer

这些类中，只有 `GestureRecognizer` 实现了 `addPointer(...)` 方法，只有 `BaseTapGestureRecognizer` 和 `PrimaryPointerGestureRecognizer` 实现了 `addAllowedPointer(...)` 方法

可以先来看一下 `BaseTapGestureRecognizer` 的 `addAllowedPointer(...)` 

#### BaseTapGestureRecognizer


```
  PointerDownEvent _down;
  ...
  @override
  void addAllowedPointer(PointerDownEvent event) {
    assert(event != null);
    if (state == GestureRecognizerState.ready) {
      _down = event;
    }
    if (_down != null) {
      super.addAllowedPointer(event);
    }
  }
```
这里只是做了一个简单的赋值，保存传递的 `PointerDownEvent` ，它会在 `_reset()` 中被置空

接下来，进入 `PrimaryPointerGestureRecognizer` 的 `addAllowedPointer(...)` 

#### PrimaryPointerGestureRecognizer


```
  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    if (state == GestureRecognizerState.ready) {
      state = GestureRecognizerState.possible;
      primaryPointer = event.pointer;
      initialPosition = OffsetPair(local: event.localPosition, global: event.position);
      if (deadline != null)
        _timer = Timer(deadline, () => didExceedDeadlineWithEvent(event));
    }
  }
```
这里主要关注 `startTrackingPointer(...)` 方法，它在 `OneSequenceGestureRecognizer ` 中实现

#### OneSequenceGestureRecognizer 


```
  @protected
  void startTrackingPointer(int pointer, [Matrix4 transform]) {
    GestureBinding.instance.pointerRouter.addRoute(pointer, handleEvent, transform);
    _trackedPointers.add(pointer);
    assert(!_entries.containsValue(pointer));
    _entries[pointer] = _addPointerToArena(pointer);
  }
```
上面有两个比较关键的地方，先看第一个 `addRoute(...)`


```
  ///PointerRouter
  final Map<int, Map<PointerRoute, Matrix4>> _routeMap = <int, Map<PointerRoute, Matrix4>>{};
  ...
  void addRoute(int pointer, PointerRoute route, [Matrix4 transform]) {
    final Map<PointerRoute, Matrix4> routes = _routeMap.putIfAbsent(
      pointer,
      () => <PointerRoute, Matrix4>{},
    );
    assert(!routes.containsKey(route));
    routes[route] = transform;
  }
```
在这里把 `handleEvent(...)` 方法作为 `PointerRoute` 传入到了 `PointerRouter` 中，它的作用，我们后面就知道了。接下来看另一个非常关键的地方：`_entries[pointer] = _addPointerToArena(pointer)`


```
  GestureArenaTeam _team;
  ...
  GestureArenaEntry _addPointerToArena(int pointer) {
    ...
    return GestureBinding.instance.gestureArena.add(pointer, this);
  }
```
可以看到，这里将当前的 `OneSequenceGestureRecognizer` 作为 `GestureArenaMember` 对象，传入了 `GestureBinding` 中维护的 `GestureArenaManager` 内。也就是将需要竞技的手势成员，放入了手势竞技场内。

那么到这里，`RenderPointerListener` 的 `handleEvent(...)` 就执行完毕了，接下来会执行 `RenderView` 的 `handleEvent(...)`，不过由于它并没有重写这个方法，所以我们会直接来到 `GestureBinding` 的 `handleEvent(...)`

### GestureBinding


```
  final PointerRouter pointerRouter = PointerRouter();
  ...
  @override // from HitTestTarget
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    pointerRouter.route(event);
    if (event is PointerDownEvent) {
      gestureArena.close(event.pointer);
    } else if (event is PointerUpEvent) {
      gestureArena.sweep(event.pointer);
    } else if (event is PointerSignalEvent) {
      pointerSignalResolver.resolve(event);
    }
  }
```
这里就要进入这个非常重要的 `route(event)` 方法了

#### PointerRouter


```
  final Map<int, Map<PointerRoute, Matrix4>> _routeMap = <int, Map<PointerRoute, Matrix4>>{};
  final Map<PointerRoute, Matrix4> _globalRoutes = <PointerRoute, Matrix4>{};


  void route(PointerEvent event) {
    final Map<PointerRoute, Matrix4> routes = _routeMap[event.pointer];
    final Map<PointerRoute, Matrix4> copiedGlobalRoutes = Map<PointerRoute, Matrix4>.from(_globalRoutes);
    if (routes != null) {
      _dispatchEventToRoutes(
        event,
        routes,
        Map<PointerRoute, Matrix4>.from(routes),
      );
    }
    _dispatchEventToRoutes(event, _globalRoutes, copiedGlobalRoutes);
  }
```
这里有两个 `_dispatchEventToRoutes(...)` 方法，后者执行的是 `_globalRoutes` 中的 `PointerRoute`，而 `_globalRoutes` 中存放的是其他的全局手势，比如用于隐藏 `ToolTips` 的手势等，目前还不太了解它的其他具体作用。

不过前面的 `routes` 就是我们之前在 `OneSequenceGestureRecognizer` 的 `startTrackingPointer(...)` 中添加的各个 `handleEvent(...)` 方法

可以看一下 `_dispatchEventToRoutes(...)`

```
  void _dispatchEventToRoutes(
    PointerEvent event,
    Map<PointerRoute, Matrix4> referenceRoutes,
    Map<PointerRoute, Matrix4> copiedRoutes,
  ) {
    copiedRoutes.forEach((PointerRoute route, Matrix4 transform) {
      if (referenceRoutes.containsKey(route)) {
        _dispatch(event, route, transform);
      }
    });
  }
  ...
  void _dispatch(PointerEvent event, PointerRoute route, Matrix4 transform) {
    try {
      event = event.transformed(transform);
      route(event);
    }
    ...
  }
```
就是遍历然后执行所有的 `PointerRoute` 方法，这里的 `PointerRoute` 就是之前的各个 `OneSequenceGestureRecognizer` 中的 `handleEvent(...)` 

> 这里要注意不要把 `OneSequenceGestureRecognizer` 的 `handleEvent(...)` 和 `RenderPointerListener` 的 `handleEvent(...)` 混淆了

`OneSequenceGestureRecognizer` 提供了 `handleEvent(...)` ，交由子类去实现，我们接着之前的点击事件，实现它的点击子类是 `PrimaryPointerGestureRecognizer` ；如果是拖拽事件的话，实现的子类就是 `DragGestureRecognizer`

#### PrimaryPointerGestureRecognizer


```
  @override
  void handleEvent(PointerEvent event) {
    assert(state != GestureRecognizerState.ready);
    if (state == GestureRecognizerState.possible && event.pointer == primaryPointer) {
      final bool isPreAcceptSlopPastTolerance = ...;
      final bool isPostAcceptSlopPastTolerance = ...;

      if (event is PointerMoveEvent && (isPreAcceptSlopPastTolerance || isPostAcceptSlopPastTolerance)) {
        resolve(GestureDisposition.rejected);
        stopTrackingPointer(primaryPointer);
      } else {
        handlePrimaryPointer(event);
      }
    }
    stopTrackingIfPointerNoLongerDown(event);
  }
  
  @protected
  void handlePrimaryPointer(PointerEvent event);
```
当前事件是 `PointerMoveEvent` 时，会做一个判断，如果一定时间内滑动的距离超过 18px 那么就会进入第一个判断中，该手势会被拒绝掉，也就是从竞技场中会被移除，此时会触发 `onTapCancel`

我们主要关心手势有效时的方法 `handlePrimaryPointer(event)`，可以看到这个方法是交由子类去实现的，实现它的子类自然就是 `BaseTapGestureRecognizer` 了

#### BaseTapGestureRecognizer

```
  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerUpEvent) {
      _up = event;
      _checkUp();
    } else if (event is PointerCancelEvent) {
      resolve(GestureDisposition.rejected);
      ...
      _reset();
    } else if (event.buttons != _down.buttons) {
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(primaryPointer);
    }
  }
```
可以看到，在这里只对 `PointerUpEvent` 与 `PointerCancelEvent` 进行了处理，并没有处理 `PointerDownEvent` ，这里很自然的就可以知道， `PointerDownEvent` 肯定被放在了 `GestureBinding` 的 `handleEvent(...)` 的后面部分进行处理

不过我们这里还是可以先看一下 `PointerUpEvent` 是如何处理的，进入 `_checkUp()` 方法

```
  @protected
  void handleTapUp({ PointerDownEvent down, PointerUpEvent up });
  ...
  void _checkUp() {
    ...
    handleTapUp(down: _down, up: _up);
    _reset();
  }
```
`_checkUp()` 中调用了 `handleTapUp(...)` 方法，它是一个交由子类实现的方法，而 `BaseTapGestureRecognizer` 的子类就是 `TapGestureRecognizer` 了

#### TapGestureRecognizer


```
  @protected
  T invokeCallback<T>(String name, RecognizerCallback<T> callback, { String debugReport() }) {
    ...
      result = callback();
    ...
    return result;
  }

  @protected
  @override
  void handleTapUp({PointerDownEvent down, PointerUpEvent up}) {
    final TapUpDetails details = TapUpDetails(...);
    switch (down.buttons) {
      case kPrimaryButton:
        if (onTapUp != null)
          invokeCallback<void>('onTapUp', () => onTapUp(details));
        if (onTap != null)
          invokeCallback<void>('onTap', onTap);
        break;
        ...
      default:
    }
  }
```
可以看到，最终通过 `invokeCallback(...)` 方法执行了传入的方法，包括 `onTapUp` 和 `onTap` ，从这里我们就知道了，我们最最常用的点击事件，就是在 `TapGestureRecognizer` 的 `handleTapUp(...)` 中执行的。

而 `TapGestureRecognizer` 还有 `handleTapDown(...)` 用于执行 `onTapDown` ，它则是通过 `BaseTapGestureRecognizer` 的 `_checkDown()` 调用

接下来我们可以回到 `GestureBinding ` ，看看 `PointerDownEvent` 到底是如何处理的

```
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    pointerRouter.route(event);
    if (event is PointerDownEvent) {
      gestureArena.close(event.pointer);
    }
    ...
  }
```
#### GestureArenaManager -> close(...)

```
  void close(int pointer) {
    final _GestureArena state = _arenas[pointer];
    ...
    state.isOpen = false;
    ...
    _tryToResolveArena(pointer, state);
  }
  
  void _tryToResolveArena(int pointer, _GestureArena state) {
    assert(_arenas[pointer] == state);
    assert(!state.isOpen);
    if (state.members.length == 1) {
      scheduleMicrotask(() => _resolveByDefault(pointer, state));
    } else if (state.members.isEmpty) {
      _arenas.remove(pointer);
      assert(_debugLogDiagnostic(pointer, 'Arena empty.'));
    } else if (state.eagerWinner != null) {
      assert(_debugLogDiagnostic(pointer, 'Eager winner: ${state.eagerWinner}'));
      _resolveInFavorOf(pointer, state, state.eagerWinner);
    }
  }
```
`close(...)` 调用了 `_tryToResolveArena(...)` 方法，在这个方法中，处理了三种情况

- 如果竞技场成员只有一个
- 如果竞技场没有任何成员
- 如果存在竞技场的获胜者

如果成员只有一个，那么事件理所应当交给它处理；如果没有成员就不说了；如果存在胜利者，交给胜利者处理也是正常的。显然，`close(...)` 中并没有对竞技场的成员做一个竞争的处理，它只负责没有点击冲突的时候，也就是只有一个点击对象。这种情况最后会通过调用它的 `acceptGesture(...)` 来触发 `onTapDown`

我们继续看 `close(...)` 后面的方法


```
  @override // from HitTestTarget
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    pointerRouter.route(event);
    if (event is PointerDownEvent) {
      gestureArena.close(event.pointer);
    } else if (event is PointerUpEvent) {
      gestureArena.sweep(event.pointer);
    } 
    ...
  }
```


#### GestureArenaManager -> sweep(...)


```
  void sweep(int pointer) {
    ...
    if (state.members.isNotEmpty) {
      ...
      state.members.first.acceptGesture(pointer);
      ...
      for (int i = 1; i < state.members.length; i++)
        state.members[i].rejectGesture(pointer);
    }
  }
```
看看这个方法，多么简单粗暴，直接确定竞技场成员中的第一个为获胜者！根据前面我们说过的 `hintTest(...)` 的添加顺序，可以知道，`RenderBox`数最下层的对象是最先被添加到列表中的

所以这里的第一个成员，就是最下层的对象，在屏幕的显示中，它就是最里层的元素，所以如果像下面这样，为两个颜色块设置点击事件的话，只有红色的会生效

<img src="https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/5.gesture/001.jpg" width=400>

我们可以简单的看一下 `acceptGesture(...)` 做了些什么，这里会进入 `BaseTapGestureRecognizer` 的 `acceptGesture(...)`

```
  ///BaseTapGestureRecognizer
  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    if (pointer == primaryPointer) {
      _checkDown();
      _wonArenaForPrimaryPointer = true;
      _checkUp();
    }
  }
```
可以看到，这里的 `_checkDown()` 中就处理了 `onTapDown` 事件，后面跟着了一个 `_checkUp()` 用于对 `onTapUp` 和 `onTap` 的处理，如果竞技场成员只有一个，这里的 `_checkUp()` 不会生效

到这里，关于点击事件的整个流程我们都清楚了，可以分为下面两种情况

- 竞技场只有一个成员时：在 `GestureArenaManager` 的 `close(...)` 中完成 `onTapDown` 的调用，此时事件为 `PointDownEvent`; 在 `PointerRouter` 的 `route(...)` 方法完成对 `onTapUp` 和 `onTap` 的调用，此时事件为 `PointUpEvent`
- 竞技场有多个成员时：在 `GestureArenaManager` 的 `sweep(...)` 方法先完成对 `onTapDown` 的调用，后完成对 `onTapUp` 与 `onTap` 的调用，此时事件为 `PointUpEvent`


接下来可能你会产生疑问了，如果上面两个颜色块监听的是相同的滑动事件，在竞技场中他们又是如何处理的呢？

下面就来简单的看一下，以 `PanGestureRecognizer` 为例

### PanGestureRecognizer

简单的看一下它的结构

> PanGestureRecognizer -> DragGestureRecognizer -> OneSequenceGestureRecognizer -> GestureRecognizer

基本上和拖拽相关的核心逻辑都在 `DragGestureRecognizer` 中了

从之前我们的流程就知道，会先走 `addAllowedPointer(...)` 方法，之后通过在 `GestureBinding` 的 `handleEvent(...)` 中执行 `PointerRouter` 的 `route(...)` 来走 `GestureRecognizer` 的  `handleEvent(...)` 方法

所以我们先看 `DragGestureRecognizer` 的 `addAllowedPointer(...)`

```
  @override
  void addAllowedPointer(PointerEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _velocityTrackers[event.pointer] = VelocityTracker();
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      ...
      _checkDown();
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }
```
还是会先在 `startTrackingPointer(...)` 将 `handleEvent(...)` 加入 `PointerRouter` ，然后把当前对象加入竞技场。

接着通过 `_checkDown()` 执行了 `onDown` 方法，对于 `DragGestureRecognizer` 它就是 `onPanDown`

以上是收到 `onPointDownEvent` 时的事件，因为是拖拽，接下来会收到 `onPointMoveEvent` 事件

再看它的 `handleEvent(...)`

```
  @override
  void handleEvent(PointerEvent event) {
    ...

    if (event is PointerMoveEvent) {
      ...
      if (_state == _DragState.accepted) {
        ...
      } else {
        ...
        if (_hasSufficientGlobalDistanceToAccept)
          resolve(GestureDisposition.accepted);
      }
    }
    ...
  }
```
其中 `_hasSufficientGlobalDistanceToAccept` 是交由子类去实现的方法，用于判断滑动距离是否有效，默认大于36个像素就有效；如果有效，就会进入 `resolve(...)` 方法，它最终会调用到 `GestureArenaManager` 的 `_resolveInFavorOf(...)` 

而这个方法，对于传入的 `GestureArenaMember` 对象，直接判定其为胜出者，并将其他竞技场成员清除掉。而这里传入的对象和我们之前再点击事件中的一样，都是树结构中最下层的对象，也就是屏幕上最里层的元素

所以这里的滑动事件在竞技场中的处理就是这样了。而我们本篇的内容也即将结束


# 总结

手势的分发流程大致如下：

- **触发手势**: flutter接受到由底层传来的触摸事件通知，它会触发 `GestureBinding` 的 `_handlePointerDataPacket(...)` 方法，flutter再这个方法中对传来的数据进行转换，变成flutter中适用的格式
- **HitTestTarget对象收集**: 通过 `hitTest(...)` 方法，将 `RenderObject`树中符合条件的 `RenderBox` 对象添加到 `HitTestResult` 中，添加顺序是由底至上的，最上层的两个对象分别是 `GestureBinding` 与 `RenderView` ，这些对象都实现了 `HitTestTarget` 接口，也就是说他们都具备 `handlerEvent(...)` 方法
- **事件分发**: 在 `dispatchEvent(...)` 中，通过遍历之前添加的对象，调用他们的 `handlerEvent(...)` 方法来进行事件的分发
- **GestureRecognizer对象收集**: 我们的 `GestureDetector` 对应的 `RenderPointerListener` 会进行事件处理，在收到 `PointDownEvent` 事件时，会将所有 `GestureDetector` 中注册的 `GestureRecognizer` 对象的 `handlerEvent` 方法作为 `PointerRoute` 传入 `PointerRouter` ，并将该对象放入 `GestureArenaManager` 维护的竞技场
- **事件处理**: 执行到最外层，也就是 `GestureBinding` 的 `handleEvent` 中，在这里从竞技场选出最终处理手势的 `GestureRecognizer` 对象，然后进行手势处理

> ps:以上分析都是基于单点触摸事件，尚未对多点触摸事件进行分析

最后，说明一下，单点触摸事件的核心并不是所谓的手势竞技场，因为根本就没有一个真正的竞技过程。最终都是直接选择最下层的 `GestureDetector` 作为手势的处理者，单点触摸事件的核心其实是这些竞技场成员被添加到竞技场中的顺序，**是由底至上的顺序**