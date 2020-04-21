---
title: 从源码看flutter（二）：Element篇
date: 2020-04-17 03:39:25
index_img: /img/flutter_02.png
tags: Flutter系列
---
# 开篇

上一篇 [从源码看flutter（一）：Widget篇](http://oldben.gitee.io/flutter-blog/#/articlePage/%E4%BB%8E%E6%BA%90%E7%A0%81%E7%9C%8Bflutter%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9AWidget%E7%AF%87) 我们了解到了关于 `Widget` 的相关知识， 知道了 `Element` 都是通过 `Widget` 的 `createElement()` 方法来创建的。

那么，是谁调用了 `createElement()` 方法？通过查找， 发现只有两处调用了这个方法。分别是：

- `Element` 的 `inflateWidget(...)` 方法
- `RenderObjectToWidgetAdapter` 的 `attachToRenderTree(...)` 方法

第一个方法在 `Element` 内部，并且不是 **static** 方法，显然 `Element` 不可能凭空调用自己的方法创建自己， 所以它是用来生成其他 `Element` 对象的。而第一个 `Element` 就是在第二个方法被创建出来的。

在我们介绍 `Element` 对象之前，我们可以先简单了解一下第一个 `Element` 的创建过程

## RenderObjectToWidgetElement

我们知道，flutter的入口在 `runApp(widget)` 方法里，我们可以看一下:

### runApp(app)

```
void runApp(Widget app) {
  WidgetsFlutterBinding.ensureInitialized()
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}
```
在这里进行了所有的初始化操作，而我们通过 `runApp(app)` 传入的根 `Widget` 被第二个方法 `scheduleAttachRootWidget(app)` 所调用，从这个方法进入

### scheduleAttachRootWidget(app)


```
mixin WidgetsBinding on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, RendererBinding, SemanticsBinding {
  ...
  @protected
  void scheduleAttachRootWidget(Widget rootWidget) {
    Timer.run(() {
      attachRootWidget(rootWidget);
    });
  }
  ...
  void attachRootWidget(Widget rootWidget) {
    _renderViewElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: renderView,
      debugShortDescription: '[root]',
      child: rootWidget,
    ).attachToRenderTree(buildOwner, renderViewElement as RenderObjectToWidgetElement<RenderBox>);
  }
  ...
}
```
可以看到，最终通过创建 `RenderObjectToWidgetAdapter` 对象，并调用其 `attachToRenderTree(...)` 方法创建了 `RenderObjectToWidgetElement`，我们简单了解一下

### attachToRenderTree(...)


```
class RenderObjectToWidgetAdapter<T extends RenderObject> extends RenderObjectWidget {
  ...
  RenderObjectToWidgetElement<T> attachToRenderTree(BuildOwner owner, [ RenderObjectToWidgetElement<T> element ]) {
    ...
        element = createElement();
    ...
    return element;
  }
  ...
}
```

这里的 `createElement()` 也就是我们之前提到过的，第二个调用的地方。之后所有的 `Element` 都是通过其 **父Element** 调用 `inflateWidget(...)` 方法所创建了

接下来，我们开始正式介绍 `Element` 对象

# Element


我们常用的 `StatefulWidget` 、`StatelessWidget` 所对应的 `Element` 对象，继承关系如下:

> xxxElement -> ComponentElement -> Element

许多其他的 `Element` 对象也都是直接或者间接继承于 `ComponentElement` ，不过 `RenderObjectWidget` 的 `Element` 继承关系如下：

> RenderObjectElement -> Element

下面，我们从 `Element` 的构造函数开始

## Element(widget)

```
  Element(Widget widget)
    : assert(widget != null),
      _widget = widget;
```
在构造函数里面，进行了 `Element` 所对应的 `Widget` 对象的赋值。接下来看一看 `Element` 的结构


```
abstract class Element extends DiagnosticableTree implements BuildContext {
    ...
}
```

`DiagnosticableTree` 在第一篇已经介绍过，这里不再赘述。可以看到这里有个我们熟悉的对象 `BuildContext` , 经常可以在 `Widget` 或 `State` 的 `build(...)` 方法中看到它，我们先来简单的了解一下它

## BuildContext


```
abstract class BuildContext {
    
  Widget get widget;
  
  BuildOwner get owner;
  ...
  RenderObject findRenderObject();
  ...
  InheritedElement getElementForInheritedWidgetOfExactType<T extends InheritedWidget>();

  T findAncestorWidgetOfExactType<T extends Widget>();
  ...
  void visitChildElements(ElementVisitor visitor);
  ...
}
```
上面列出了比较典型的一些方法。`BuildContext` 是一个抽象类，因为 dart 中没有 **Interface** ，而这里的 `BuildContext` 本质上只提供各种调用方法，所以完全可以把它当成 java 中的接口

其中 `BuildOwner` 对象只在 `WidgetsBinding` 的 `initInstances()` 中初始化过一次，也就是说全局只有唯一的实例。他是 **widget framework** 的管理类，实际上的的作用有很多，比如在 `Element` 中，就负责管理它的生命周期

其他的一些方法：

- findRenderObject(): 用于返回当前 `Widget` 对应的 `RenderObject` ，如果当前 `Widget` 不是 `RenderObjectWidget` 则从children中寻找
- getElementForInheritedWidgetOfExactType(): 在维护的 `Map<Type, InheritedElement>` 中查找 `InheritedElement`，在我们熟知的 `Provider` 中的 `Provider.of<T>(context)` 就是通过这种方法获取数据类的
- findAncestorWidgetOfExactType(): 通过遍历 `Element` 的 **parent** 来找到指定类型Widget
- visitChildElements(): 用于遍历 **子Element**

`BuildContext` 大致就介绍这些，接下来我们来看 `Element` 中的一些成员变量

## Element的成员变量


```
abstract class Element extends DiagnosticableTree implements BuildContext {
  ...
  Element _parent;
  ...
  dynamic _slot;
  ...
  int _depth;
  ...
  Widget _widget;
  ...
  BuildOwner _owner;
  ...
  bool _active = false;
  ...
  _ElementLifecycle _debugLifecycleState = _ElementLifecycle.initial;
  ...
  Map<Type, InheritedElement> _inheritedWidgets;
  ...
  bool _dirty = true;
  ...
  bool _inDirtyList = false;
}
```

上面列举出了主要的一些成员变量

`Element` 中默认持有 `parent` 对象，而 `slot` 用于表示它在  `parent` 中 **child列表** 的位置，如果 `parent` 只有一个 **child** ， `slot` 应该为 null ，再来看看剩下的一些变量

- depth : 当前 `Element` 节点在树中的深度，深度是递增的，且必须大于0
- _active: 默认为 **false**， 当 `Element` 被添加到树后，变为 **true**
- _inheritedWidgets: 从 `parent` 一直传递下来，维护了所有 `InheritedElement` ，不过很好奇为什么这里不直接用 **static** 修饰，是为了方便垃圾回收吗？
- dirty: 如果为 **true** 就表示需要 **reBuild** 了， 在 `markNeedsBuild()` 中会被设为 **true**
- _inDirtyList: 当 `Element` 被标记为 `dirty` 后，随之会将 `Element` 放入 `BuildOwner` 中的 `_dirtyElements` ，并设置为 **true** ，等待 **reBuild**


还有一个 生命周期对象 `_debugLifecycleState`

```
enum _ElementLifecycle {
  initial,
  active,
  inactive,
  defunct,
}
```
它对外部是隐藏的，这个生命周期和 `State` 的有点类似，不过其中的 `active` 和 `inactive` 是可以来回切换的，这里就涉及到 `Element` 的复用了，后面会说

然后是 `Element` 的一些主要方法，我们简单的看一下

## Element的方法


```
  RenderObject get renderObject { ... }
  
  void visitChildren(ElementVisitor visitor) { }
  
  @override
  void visitChildElements(ElementVisitor visitor) {
    ...
    visitChildren(visitor);
  }
  
  @protected
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) { ... }
  
  @mustCallSuper
  void mount(Element parent, dynamic newSlot) { ... }
  
  @mustCallSuper
  void update(covariant Widget newWidget) {
    ...
    _widget = newWidget;
  }
  
  Element _retakeInactiveElement(GlobalKey key, Widget newWidget) { ... }
  
  @protected
  Element inflateWidget(Widget newWidget, dynamic newSlot) { ... }
  
  @protected
  void deactivateChild(Element child) { ... }
  
  @mustCallSuper
  void activate() { ... }
  
  @mustCallSuper
  void deactivate() { ... }
  
  @mustCallSuper
  void unmount() { ... }
  
  @mustCallSuper
  void didChangeDependencies() {
    ...
    markNeedsBuild();
  }
  
  void markNeedsBuild(){ ... }
  
  void rebuild() { ... }
  
  @protected
  void performRebuild();
```
上面的主要方法中，最核心的是 `mount()` 、`unmount()` 、`inflateWidget(...)` 、`updateChild(...)` 、`rebuild()` 这些

这里我们不去直接介绍这些方法的作用，因为脱离上下文单独看的话可能阅读体验不会太好，后面会走一遍 `Element` 的创建流程，在这个过程中去阐述各个方法的作用。

不过我们可以先看其中一个方法 `renderObject` 了解一下 `Element` 与 `RenderObject` 的对应关系


```
  RenderObject get renderObject {
    RenderObject result;
    void visit(Element element) {
      assert(result == null); // this verifies that there's only one child
      if (element is RenderObjectElement)
        result = element.renderObject;
      else
        element.visitChildren(visit);
    }
    visit(this);
    return result;
  }
```
解释一下就是，如果当前 `element` 是 `RenderObjectElement` 的话，直接返回它持有的 `renderObject` ，否则遍历 children 去获取最近的 `renderObject` 对象

从这里也可以知道 `RenderObject` 只与 `RenderObjectElement` 是一一对应的，与其他 `Element` 则是一对多的关系，也验证了我们上一篇中的判定

> 不过这里有一点需要吐槽的是，在方法里面直接定义方法，阅读体验不是特别好，而后面这样的情况还会很多

接下来，我们准备进入 `Element` 的创建流程入口

## Element 创建流程入口

既然要走创建流程，自然是要找个起点的。在上一篇中，我们知道通过 `createElement()` 创建 `Element` 的方法只在两个地方被调用：

- 其一是作为根节点 `Element` 的 `RenderObjectToWidgetElement` 在 `RenderObjectToWidgetAdapter` 的 `attachToRenderTree(...)` 中被创建
- 另一个是其他所有 `Element` 在 `inflateWidget(...)` 方法中被创建

我们以第二个方法为入口，进入 `Element` 的创建流程，先简单的看一下第二个方法


```
abstract class Element extends DiagnosticableTree implements BuildContext {
  ...
  @protected
  Element inflateWidget(Widget newWidget, dynamic newSlot) {
    ...
    final Element newChild = newWidget.createElement();
    ...
    newChild.mount(this, newSlot);
    assert(newChild._debugLifecycleState == _ElementLifecycle.active);
    return newChild;
  }
  ...
}
```
可以看到，上面最后调用了 `Element` 的 `mount(...)` 方法，所以这个方法算是各个 `Element` 的入口了。

上一篇我们提到过，不同 `Widget` 对应 `Element` 的实现都不一样，其中最广泛的两种实现分别是 `ComponentElement` 和 `RenderObjectElement`。

我们可以从第一个开始了解

## ComponentElement 的创建流程

进入它的 `mount(...)` 方法

### mount(...)

```
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    ...
    _firstBuild();
    ...
  }
```
调用了父类，也就是 `Element` 的 `mount(...)`

### Element -> mount(...)


```
  @mustCallSuper
  void mount(Element parent, dynamic newSlot) {
    ...
    _parent = parent;
    _slot = newSlot;
    _depth = _parent != null ? _parent.depth + 1 : 1;
    _active = true;
    if (parent != null) // Only assign ownership if the parent is non-null
      _owner = parent.owner;
    final Key key = widget.key;
    if (key is GlobalKey) {
      key._register(this);
    }
    _updateInheritance();
    assert(() {
      _debugLifecycleState = _ElementLifecycle.active;
      return true;
    }());
  }
```
可以看到，在 `mount(...)` 中，进行了一些列的初始化操作。

其中如果传入的 `key` 是 `GlobalKey` ，会将当前 `Element` 存入 `GlobalKey` 中维护的 `Map<GlobalKey, Element>` 对象。

最后会将生命周期设置为 `_ElementLifecycle.active`

接下来，可以看一下 `ComponentElement` 的 `_firstBuild()`

### _firstBuild()


```
  void _firstBuild() {
    rebuild();
  }
```
调用了 `rebuild()` ，它是在 `Element` 中实现的


### Element -> rebuild()


```
  void rebuild() {
    ...
    performRebuild();
    ...
  }
  
  @protected
  void performRebuild();
```
最后调用到 `performRebuild()` 方法，`Element` 中这个方法什么都没做，就是交由子类去实现的，接下来回到 `ComponentElement` 

### performRebuild()


```
  @override
  void performRebuild() {
    if (!kReleaseMode && debugProfileBuildsEnabled)
      Timeline.startSync('${widget.runtimeType}',  arguments: timelineWhitelistArguments);

    ...
    Widget built;
    try {
      built = build();
      ...
    } catch (e, stack) {
      built = ErrorWidget.builder(...);
    } finally {
      ...
      _dirty = false;
      ...
    }
    try {
      _child = updateChild(_child, built, slot);
      assert(_child != null);
    } catch (e, stack) {
      built = ErrorWidget.builder(...);
      _child = updateChild(null, built, slot);
    }

    if (!kReleaseMode && debugProfileBuildsEnabled)
      Timeline.finishSync();
  }
```
可以看到，开头和结尾都做了debug模式的判断，并使用了 `Timeline` 这个对象，它的作用其实就是我们之前介绍过的，用于在 **DevTool** 中检测性能表现

可以看到，上面通过调用我们最熟悉的 `build()` 方法来创建 `Widget` ，如果发生异常的话，就会在 `catch` 语句中创建一个 `ErrorWidget`， 也就是我们常常遇见的那个红色的错误界面啦！

后面会通过 `updateChild(...)` 来给当前 `Element` 的 `_child` 赋值

而  `updateChild(...)` 位于 `Element` 中

### Element -> updateChild(...)

```
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    ...
    if (newWidget == null) {
      if (child != null)
        deactivateChild(child);
      return null;
    }
    if (child != null) {
      if (child.widget == newWidget) {
        if (child.slot != newSlot)
          updateSlotForChild(child, newSlot);
        return child;
      }
      if (Widget.canUpdate(child.widget, newWidget)) {
        if (child.slot != newSlot)
          updateSlotForChild(child, newSlot);
        child.update(newWidget);
        assert(child.widget == newWidget);
        assert(() {
          child.owner._debugElementWasRebuilt(child);
          return true;
        }());
        return child;
      }
      deactivateChild(child);
      assert(child._parent == null);
    }
    return inflateWidget(newWidget, newSlot);
  }
```

`updateChild(...)` 是非常重要的一个方法，它接受三个参数，分别是 `Element child` 、`Widget newWidget` 以及 `dynamic newSlot`，传入的参数不同，这个方法的作用也不一样，主要分为下面几种情况：

|                     | newWidget为null  | newWidget不为null   |
| --- | --- | --- |
|  child为null  |  ①.返回null         |  ②.返回新的Elment |
|  child不为null  | ③.移除传入child,返回null | ④.根据 canUpdate(...) 决定返回更新后的child或者新Element |

其中的 `deactivateChild(child)` 就是将传入 `Element` 移除掉

而我们在 `performRebuild()` 中创来的值是: **child为null** 并且 **newWidget不为null**，属于第二种情况。直接进入 `inflateWidget(...)` 方法

### Element -> inflateWidget(...)

又回到最初的起点

```
  @protected
  Element inflateWidget(Widget newWidget, dynamic newSlot) {
    assert(newWidget != null);
    final Key key = newWidget.key;
    if (key is GlobalKey) {
      final Element newChild = _retakeInactiveElement(key, newWidget);
      if (newChild != null) {
        assert(newChild._parent == null);
        assert(() {
          _debugCheckForCycles(newChild);
          return true;
        }());
        newChild._activateWithParent(this, newSlot);
        final Element updatedChild = updateChild(newChild, newWidget, newSlot);
        assert(newChild == updatedChild);
        return updatedChild;
      }
    }
    //创建新的Element，开始下一轮循环
    return newChild;
  }
```

方法后部分的逻辑之前已经说过，这里可以看一下前部分关于 `GlobalKey` 的部分。如果获取到 `widget` 的 `key` 是 `GlobalKey`， 并且之前 `Widget` 已经在 `Element` 的 `mount(...)` 中注册到了 `GlobalKey`的话，就会在这里取出并且复用。这部分是在 `_retakeInactiveElement(...)` 完成的，可以简单看一下：


```
  Element _retakeInactiveElement(GlobalKey key, Widget newWidget) {
    final Element element = key._currentElement;
    if (element == null)
      return null;
    if (!Widget.canUpdate(element.widget, newWidget))
      return null;
    ...
    return element;
  }
```
当`Element`不存在或者无法更新时，则不会进行复用，返回 null

如果结果不为null，后面再调用 `updateChild(...)` 方法，这里传入的参数都不为null，所以会进入之前所说的第四种情况：


```
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    ...
      //这里一定是true的
      if (Widget.canUpdate(child.widget, newWidget)) {
        if (child.slot != newSlot)
          updateSlotForChild(child, newSlot);
        child.update(newWidget);
        assert(child.widget == newWidget);
        assert(() {
          child.owner._debugElementWasRebuilt(child);
          return true;
        }());
        return child;
      }
    ...
    return inflateWidget(newWidget, newSlot);
  }
```
注意到上面的部分，调用 `child` 的 `update(newWidget)` 方法，这个方法除了更新当前 `Element` 持有的 `Widget` 外，剩下的逻辑都交给子类去实现了

那么 `ComponentElement` 的创建流程大致就讲到这里

下面，我们可以看一下 `ComponentElement` 的两个子类 `StatelessElement` 与 `StatefulElement`

### StatelessElement 


```
class StatelessElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  StatelessElement(StatelessWidget widget) : super(widget);

  @override
  StatelessWidget get widget => super.widget as StatelessWidget;

  @override
  Widget build() => widget.build(this);

  @override
  void update(StatelessWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _dirty = true;
    rebuild();
  }
}
```
`StatelessElement` 非常简单，重写的 `update(...)` 也只是调用了 `rebuild()`，感觉没有什么可说的。

接下来看看 `StatefulElement`

### StatefulElement


```
class StatefulElement extends ComponentElement {

  StatefulElement(StatefulWidget widget)
      : _state = widget.createState(),
        super(widget) {
    ...
    _state._element = this;
    ...
    _state._widget = widget;
    ...
   }
   
  
  @override
  void _firstBuild() { ... }
  
  @override
  void update(StatefulWidget newWidget) { ... }
  
  @override
  void unmount() { ... }
}
```
这里展示了 `StatefulElement` 一些主要的方法，可以看到在构造函数中把 `Element` 和 `Widget` 对象放入了 `State` 中

接下来看一下剩下三个方法都做了什么

#### _firstBuild()


```
  @override
  void _firstBuild() {
      ...
      final dynamic debugCheckForReturnedFuture = _state.initState() as dynamic;
      ...
      _state._debugLifecycleState = _StateLifecycle.initialized;
    ...
    _state.didChangeDependencies();
      ...
      _state._debugLifecycleState = _StateLifecycle.ready;
      ...
    super._firstBuild();
  }
```
`ComponentElement` 中是在 `mount(...)`里调用 `_firstBuild()` 的，这里重写了这个方法，并且在里面进行了一些初始化的操作，并且调用了 `State` 的 `initState()` 方法

### update(...)


```
  @override
  void update(StatefulWidget newWidget) {
    super.update(newWidget);
    ...
    final StatefulWidget oldWidget = _state._widget;
    ...
    _dirty = true;
    _state._widget = widget as StatefulWidget;
      ...
      final dynamic debugCheckForReturnedFuture = _state.didUpdateWidget(oldWidget) as dynamic;
      ...
    rebuild();
  }
```
在这里主要是调用了 `State` 的 `didUpdateWidget(...)` 方法，其他内容和 `StatelessElement` 差不多

那么到了这里，关于 `StatefulWidget`中我们常用的 `setState()` 方法，它具体会走过 `StatelessElement` 的哪些过程呢，下面我们就来看一下

## StatefulElement的刷新流程

我们知道 `State` 的 `setState()` 方法会调用 `Element` 的 `markNeedsBuild()`

### Element -> markNeedsBuild()


```
  BuildOwner get owner => _owner;

  void markNeedsBuild() {
    ...
    if (dirty)
      return;
    _dirty = true;
    owner.scheduleBuildFor(this);
  }
```
下面进入 `BuildOwner` 看看 `scheduleBuildFor(element)` 做了些什么

### BuildOwner -> scheduleBuildFor(element)


```
  final List<Element> _dirtyElements = <Element>[];

  void scheduleBuildFor(Element element) {
    ...
    if (element._inDirtyList) {
      ...
      _dirtyElementsNeedsResorting = true;
      return;
    }
    ...
    if (!_scheduledFlushDirtyElements && onBuildScheduled != null) {
      _scheduledFlushDirtyElements = true;
      onBuildScheduled();
    }
    _dirtyElements.add(element);
    element._inDirtyList = true;
    ...
  }
```
可以看到，`scheduleBuildFor(element)` 后面会将需要刷新的 `Element` 添加到 `_dirtyElements` 中，并将该 `Element` 的 `_inDirtyList` 标记为 **true**

但之后并没有做其他的操作，那刷新到底是如何进行的呢？这就要看前面调用的一个方法 `onBuildScheduled()` 了

### BuildOwner -> onBuildScheduled()

这个方法是在 `BuildOwner` 被创建时设置的


```
mixin WidgetsBinding on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, RendererBinding, SemanticsBinding {
  ...
  @override
  void initInstances() {
    ...
    _buildOwner = BuildOwner();
    buildOwner.onBuildScheduled = _handleBuildScheduled;
    ...
  }
  ...
}

```
来看一下 `_handleBuildScheduled`


#### WidgetsBinding  -> _handleBuildScheduled


```
  void _handleBuildScheduled() {
    ...
    ensureVisualUpdate();
  }
```
`ensureVisualUpdate()` 在 `SchedulerBinding` 中被定义


```
mixin SchedulerBinding on BindingBase, ServicesBinding {
  ...
  void ensureVisualUpdate() {
    switch (schedulerPhase) {
      ...
      case SchedulerPhase.postFrameCallbacks:
        scheduleFrame();
        return;
      ...
    }
  }
  ...
}
```
后面会进入 `scheduleFrame()` 方法

#### SchedulerBinding -> scheduleFrame()


```
  @protected
  void ensureFrameCallbacksRegistered() {
    window.onBeginFrame ??= _handleBeginFrame;
    window.onDrawFrame ??= _handleDrawFrame;
  }
  
  void scheduleFrame() {
    ...
    ensureFrameCallbacksRegistered();
    window.scheduleFrame();
    _hasScheduledFrame = true;
  }
  
```
这里会调用 `window.scheduleFrame()` 


#### Window -> scheduleFrame()


```
class Window {
  ...
  /// Requests that, at the next appropriate opportunity, the [onBeginFrame]
  /// and [onDrawFrame] callbacks be invoked.
  ///
  /// See also:
  ///
  ///  * [SchedulerBinding], the Flutter framework class which manages the
  ///    scheduling of frames.
  void scheduleFrame() native 'Window_scheduleFrame';
}
```
到了这里，就是对 engine 的相关操作了。其中，经过各种各样的操作之后，会回调到 dart 层的 `_drawFrame()` 方法

> sky_engine -> ui -> hooks.dart -> _drawFrame()

如果你对 engine 中的**这一部分操作**感兴趣的话，可以看一下这一篇文章 [Flutter渲染机制—UI线程](http://gityuan.com/2019/06/15/flutter_ui_draw/)， 因为都是C++的内容，超越了我的能力范畴，所以这里直接去看大神的吧

`_drawFrame()` 方法内容如下：

```
void _drawFrame() {
  _invoke(window.onDrawFrame, window._onDrawFrameZone);
}
```
最后，会调用到之前在 `SchedulerBinding` 中 `onDrawFrame` 所注册的 `_handleDrawFrame` 方法, 它会调用 `handleDrawFrame()`

####  SchedulerBinding -> handleDrawFrame()


```
  void handleDrawFrame() {
    ...
    try {
      // PERSISTENT FRAME CALLBACKS
      _schedulerPhase = SchedulerPhase.persistentCallbacks;
      for (FrameCallback callback in _persistentCallbacks)
        _invokeFrameCallback(callback, _currentFrameTimeStamp);
      ...
    }
    ...
  }
```
在这里会遍历 `_persistentCallbacks` 来执行对应方法，它是通过 `RendererBinding` 的 `addPersistentFrameCallback` 添加，并且之后的每一次 frame 回调都会遍历执行一次

这里将要执行的方法，是在 `RendererBinding` 的 `initInstances()` 中添加的 `_handlePersistentFrameCallback`


```
  void _handlePersistentFrameCallback(Duration timeStamp) {
    drawFrame();
    _mouseTracker.schedulePostFrameCheck();
  }
```
最后，会调用到 `WidgetBinding` 的 `drawFrame()`

#### WidgetBinding -> drawFrame()

```
  @override
  void drawFrame() {
    ...
    try {
      if (renderViewElement != null)
        buildOwner.buildScope(renderViewElement);
      super.drawFrame();
      buildOwner.finalizeTree();
    }
    ...
  }
```
`renderViewElement` 就是我们之前看 `runApp()` 流程中所创建的 **根Element**

最后调又回到了 `BuildOwner` 对象，并调用它的 `buildScope(...)` 方法

### BuildOwner -> buildScope(...)

 `buildScope(...)` 用于对 **Element Tree** 进行局部更新

```
  void buildScope(Element context, [ VoidCallback callback ]) {
    ...
      _debugBuilding = true;
    ...
      _scheduledFlushDirtyElements = true;
    ...
      _dirtyElements.sort(Element._sort);
      _dirtyElementsNeedsResorting = false;
      int dirtyCount = _dirtyElements.length;
      int index = 0;
      while (index < dirtyCount) {
        ...
          _dirtyElements[index].rebuild();
        ...
        index += 1;
        ...
        //如果在局部更新的过程中，_dirtyElements发生了变化
        //比如可能有新的对象插入了_dirtyElements，就在这里进行处理
      }
    ...
      for (Element element in _dirtyElements) {
        assert(element._inDirtyList);
        element._inDirtyList = false;
      }
      _dirtyElements.clear();
      _scheduledFlushDirtyElements = false;
      _dirtyElementsNeedsResorting = null;
    ...
        _debugBuilding = false;
    ...
  }
```
所以其实从上面我们就能知道，局部更新的原理就是把需要更新的对象存入了 `_dirtyElements` 中，然后在需要更新的时候，遍历它们，进行 `reBuild()`

遍历之前，会调用 `sort(...)` 方法进行排序，判断条件是 `Element` 的深度，按照从小到大排列，也就是对于 `Element` 是从上往下更新的。

更新结束后，`_dirtyElements` 会被清空，各个标志位也会被重置

到这里，`StatefulElement` 的刷新流程我们已经了解到了，接下来我们了解一下它的销毁流程，同时顺便也可以知道 `Element` 的销毁流程

## StatefulElement的销毁流程

其实在 `drawFrame()` 的 `buildScope(...)` 方法后紧跟着的 `buildOwner.finalizeTree()` 就是用于进行 `Element` 的销毁的

不过这里不将它作为入口，记得我们之前 `Element` 的 `updateChild(...)` 方法里面，有两处会对 `Element` 进行销毁，而调用销毁的方法就是 `deactivateChild(child)` 

下面就从这里作为入口

### Element -> deactivateChild(child)


```
  @protected
  void deactivateChild(Element child) {
    ...
    child._parent = null;
    child.detachRenderObject();
    owner._inactiveElements.add(child);
    ...
  }
```
在这里会清除掉 `child` 对于 `parent` 的引用，同时也调用 `detachRenderObject()` 去销毁 `RenderObject`，关于它的细节下一片蘸再说。

最主要的还是向 `BuildOwner` 的 `_inactiveElements` 中添加了当前要销毁的 `child`

我们可以先了解一下 `_inactiveElements`

### _InactiveElements


```
class _InactiveElements {
  bool _locked = false;
  final Set<Element> _elements = HashSet<Element>();
  
  static void _deactivateRecursively(Element element) {
    ...
    element.deactivate();
    ...
    element.visitChildren(_deactivateRecursively);
    ...
  }
  
  void add(Element element) {
    ...
    if (element._active)
      _deactivateRecursively(element);
    _elements.add(element);
  }
}
```
可以看到，`_InactiveElements ` 中使用 `Set` 存放了所有需要销毁的对象

在 `add(element)` 方法中，如果当前要销毁的对象还处于活跃状态，则通过递归的方式，遍历它的 `children` ，对每个 `child Element` 调用 `deactivate()` 来设为销毁状态，可以看一下 `deactivate()` 方法

```
  ///Element
  @mustCallSuper
  void deactivate() {
    ...
    _inheritedWidgets = null;
    _active = false;
    ...
      _debugLifecycleState = _ElementLifecycle.inactive;
    ...
  }
```
将要被销毁的 `Element` 生命周期会变为 `inactive`

这里我们收集完要销毁的 `Element` 之后呢，就会在`WidgetsBinding` 的 `drawFrame()` 被触发时调用 `finalizeTree()` 来进行真正的销毁了

### BuildOwner -> finalizeTree()


```
  void finalizeTree() {
    ...
      lockState(() {
        _inactiveElements._unmountAll(); // this unregisters the GlobalKeys
      });
    ...
  }
```
这里调用了 `_InactiveElements` 的 `_unmountAll()` 来进行销毁

### _InactiveElements -> _unmountAll()


```
  void _unmountAll() {
    _locked = true;
    final List<Element> elements = _elements.toList()..sort(Element._sort);
    _elements.clear();
    try {
      elements.reversed.forEach(_unmount);
    } finally {
      assert(_elements.isEmpty);
      _locked = false;
    }
  }
```
这里的销毁也是由上到下的，调用了 `_unmount(element)` 方法

```
  void _unmount(Element element) {
    ...
    element.visitChildren((Element child) {
      assert(child._parent == element);
      _unmount(child);
    });
    element.unmount();
    ...
  }
```
> 不得不说，dart 将方法作为参数传递，并且在某些情况下可以省略输入方法的参数真是好用，不过可能就牺牲了一点可读性

`_unmount(element)` 也是遍历 children ，然后调用 `child Element` 的 `unmount()` 来进行销毁

在 `_InactiveElements` 中还有一个 `remove` 方法，介绍 `unmount()` 前我们先把这个给看了

### _InactiveElements -> remove()

```
  void remove(Element element) {
    ...
    _elements.remove(element);
    ...
  }
```
这里就是从 `Set` 中移除传入的 `Element` 对象，在之前的 `_unmountAll()` 中会通过 `clear()` 清楚 `Set` 内所有的元素，那为什么这里会有这样一种情况呢？之前我们在 `Element` 的 `inflateWidget(...)` 中提到过，`GlobalKey` 是可以用于复用 `Element` 的，被复用的 `Element` 对象无需重新创建。我们再来看一下

#### Element -> _retakeInactiveElement(...)


```
  @protected
  Element inflateWidget(Widget newWidget, dynamic newSlot) {
    ...
    final Key key = newWidget.key;
    if (key is GlobalKey) {
      final Element newChild = _retakeInactiveElement(key, newWidget);
      if (newChild != null) {
        ...
        newChild._activateWithParent(this, newSlot);
        final Element updatedChild = updateChild(newChild, newWidget, newSlot);
        assert(newChild == updatedChild);
        return updatedChild;
      }
    }
    ...
  }

  Element _retakeInactiveElement(GlobalKey key, Widget newWidget) {
    ...
    final Element element = key._currentElement;
    if (element == null)
      return null;
    if (!Widget.canUpdate(element.widget, newWidget))
      return null;
    ...
    final Element parent = element._parent;
    if (parent != null) {
      ...
      parent.forgetChild(element);
      parent.deactivateChild(element);
    }
    ...
    owner._inactiveElements.remove(element);
    return element;
  }
```
可以看到，在 `_retakeInactiveElement(...)` 末尾处，会将被复用了的 `Element` 从 `_inactiveElements` 中移除掉。获取到这个 `Element` 后，会调用 `_activateWithParent(...)` 方法再次将 `Element` 激活

#### Element -> _activateWithParent(...)


```
  void _activateWithParent(Element parent, dynamic newSlot) {
    ...
    _parent = parent;
    ...
    _updateDepth(_parent.depth);
    _activateRecursively(this);
    attachRenderObject(newSlot);
    ...
  }
  
  static void _activateRecursively(Element element) {
    ...
    element.activate();
    ...
    element.visitChildren(_activateRecursively);
  }
```
这里会通过递归调用，激活 `Element` 和它的 `children` ，来看一下 `active()` 方法

#### Element -> activate()


```
  @mustCallSuper
  void activate() {
    ...
    final bool hadDependencies = (_dependencies != null && _dependencies.isNotEmpty) || _hadUnsatisfiedDependencies;
    _active = true;
    ...
    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    ...
      _debugLifecycleState = _ElementLifecycle.active;
    ...
    if (_dirty)
      owner.scheduleBuildFor(this);
    if (hadDependencies)
      didChangeDependencies();
  }
  
  
  ///StatefulElement
  @override
  void activate() {
    super.activate();
    ...
    markNeedsBuild();
  }
```
在 `activate()` 中，`Element` 的生命周期再次变为了 `active`, 这也就是我们之前所说过的， `Element` 的四个生命周期中可能会出现 `active` 和 `inactive` 切换的情况。

那么在哪种情况下会触发这种复用呢？其实很简单：**当处于不同深度的同一类型 `Widget` 使用了同一个 `GlobalKey` 就可以**， 比如下面这样：


```
Center(
          child: changed
              ? Container(
                  child: Text('aaaa', key: globalKey),
                  padding: EdgeInsets.all(20))
              : Text('bbb', key: globalKey),
        )
```
当通过 `setState` 修改 `changed` 时，就可以触发复用

插曲就说到这里，我们继续之前的 `unmount()` 方法

### Element -> unmount()


```
  @mustCallSuper
  void unmount() {
    ...
    final Key key = widget.key;
    if (key is GlobalKey) {
      key._unregister(this);
    }
    assert(() {
      _debugLifecycleState = _ElementLifecycle.defunct;
      return true;
    }());
  }
```

可以看到，`unmount()` 中，如果当前 `Element` 注册了 `Globalkey` 就会被清空掉，同时生命周期会被设置为 `defunct`，在 `StatefulElement` 中会重写这个方法

### StatefulElement -> unmount()


```
  @override
  void unmount() {
    super.unmount();
    _state.dispose();
    ...
    _state._element = null;
    _state = null;
  }
```
在这里调用了 `State` 的 `dispose()` 方法，并且在之后清理了 `State` 中持有的 `Element` 引用，最后将 `State` 置空

到了这里，`StatefulElement` 的销毁流程也结束了，本篇文章也接近尾声

当然，还有 `RenderObjectElement` 都还没有做过分析，因为所有和 `RenderObject` 有关的内容都将放到第三篇来讲，这里就先跳过吧



# 总结

- `Element` 是真正的数据持有者，而 `State` 也是在它的构造函数里被创建，它的生命周期比 `State` 略长。
- 每次刷新时，`Widget` 都会被重新创建，而在 `Element` 的创建流程结束后， `Element` 只有在 `canUpdate(...)` 返回 **false** 时才会重新创建，不然一般都是调用它的 `update(...)` 进行更新。`StatelessElement` 也是这样的。
- `GlobalKey` 除了可以跨 `Widget` 传递数据外，还可以对 `Element` 进行复用

剩下的总结，就看图片吧

> 注:以上源码分析基于flutter stable 1.13.6  
新的版本可能存在代码不一致的地方，比如updateChild(...)，但是逻辑都是一样的，可以放心食用

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/2.element/element.png)





