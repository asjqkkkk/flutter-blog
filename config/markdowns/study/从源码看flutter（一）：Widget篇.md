---
title: 从源码看flutter（一）：Widget篇
date: 2020-04-14 09:06:02
index_img: /img/flutter_01.png
tags: Flutter系列
---
# 开篇

我们知道，Flutter中我们做的一切几乎都是在和 `Widget` 打交道，那么它在flutter中扮演着怎样的角色，起到了什么样的作用呢？

我们将通过阅读源码的方式，去解答关于它的各种疑问。

而这也是flutter知识拼图中，我们选择的第一块。


# Widget

可以从我们常用的 `StatelessWidget` 和 `StatefulWidget` 看到，他们都拥有同一个父类 `Widget`，我们将 `Widget` 作为起点，先看看一看它的构造


```
@immutable
abstract class Widget extends DiagnosticableTree {

  const Widget({ this.key });
  
  final Key key;
  
  @protected
  Element createElement();
  ...
  static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType
        && oldWidget.key == newWidget.key;
  }
}
```
`Widget` 是继承于 `DiagnosticableTree` 的，关于 `DiagnosticableTree` 这个类，它主要用于在调试时获取子类的各种属性和children信息，在flutter各个对象中你经常能看到它，目前我们不需要去关心与之相关的内容

我们可以看到，`Widget` 是一个抽象类；同时它被 `immutable` 注解修饰，说明它的各个属性一定是不可变的，这就是为什么我们写各种 `Widget` 时，所写的各个属性要加 `final` 的原因，否则编译器就会发出警告

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/1.widget/001.png)

同时，我们看到了熟悉的 `createElement()` 方法，它交由子类去实现

还有 `canUpdate(...)` 方法, 如果返回 `true` 表示可以更新当前 `Element` 对象，并用新的 `widget` 更新 `Element` 的 `widget` ，在下一篇关于 `Element` 的介绍中，我们能看到它的具体使用

接下来，我们看一看几个飞车重要的 Widget 对象

## StatelessWidget


```
abstract class StatelessWidget extends Widget {
  
  const StatelessWidget({ Key key }) : super(key: key);
  
  @override
  StatelessElement createElement() => StatelessElement(this);
  
  @protected
  Widget build(BuildContext context);
}

```

`StatelessWidget` 也是一个抽象方法，提供了一个 `build(context)` 方法供子类实现，而这里重写的 `createElement()` 默认返回的是 `StatelessElement(...)` 对象，再来看看 `StatefulWidget`


## StatefulWidget


```
abstract class StatefulWidget extends Widget {

  const StatefulWidget({ Key key }) : super(key: key);

  @override
  StatefulElement createElement() => StatefulElement(this);

  @protected
  State createState();
}
```

`StatefulWidget` 同样是一个非常简单的抽象对象，这里默认提供的是创建 `StatefulElement` 的方法。同时，提供了我们非常熟悉的 `createState()` 方法，它返回一个 `State` 对象，我们经常使用的 `setState(...)` 就在其中，来看一下它的实现

### State


```
abstract class State<T extends StatefulWidget> extends Diagnosticable {
  T get widget => _widget;
  
  _StateLifecycle _debugLifecycleState = _StateLifecycle.created;
  
  BuildContext get context => _element;
  
  bool get mounted => _element != null;
  
  void initState() {
    assert(_debugLifecycleState == _StateLifecycle.created);
  }
  
  void didUpdateWidget(covariant T oldWidget) { }
  
  void reassemble() { }
  
  void setState(VoidCallback fn) {
    ...
    _element.markNeedsBuild();
  }

  void deactivate() { }
  
  void dispose() {
    ...
     _debugLifecycleState = _StateLifecycle.defunct;
    ...
  }
  
  Widget build(BuildContext context);
  
  void didChangeDependencies() { }
}

enum _StateLifecycle {

  created,

  initialized,

  ready,

  defunct,
}
```
为了方便阅读，上面省去了部分代码和所有注解，首先可以看到，`State` 是 `Diagnosticable` 的子类，而 `Diagnosticable` 对象就是之前 `DiagnosticableTree` 中内提供的结点，我们不需要关注它。

`State` 中持有了 `BuildContext` 对象和 `Widget` 对象， `BuildContext` 是 `Element` 实现的接口，下一篇会讲到它。同时，我们可以发现 `State` 是具备生命周期的，分别是四种情况：

- created: 默认的生命周期
- initialized:  `initState()` 被调用后的生命周期
- ready: `didChangeDependencies()` 被调用后的生命周期， 当生命周期为这个时就准备调用 `build()` 方法了
- defunct: `dispose()` 被调用后的生命周期

其中第二个第三个都是在 `StatefulElement` 中被改变的，可以简单的看一看


```
class StatefulElement extends ComponentElement {
    ...
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
  }
  ...
  @override
  void unmount() {
    super.unmount();
    _state.dispose();
    ...
  }
}
```
至于哪里调用了 `_firstBuild()` 我们放到第二篇讲

还有一些方法，我们简单介绍一下：

- didUpdateWidget(...): 当 Widget 更新时，会调用它。可以重写这个方法做一些数据修改的操作，比如更新数据，但是不要在这个方法中调用 `setState` 因为这样就重复刷新了
- reassemble(): 这个方法是debug时热重载会触发的，我们一般不需要去管它
- deactivate(): 当前 `Widget` 从树中移除的时候，会调用这个方法，它会比 `dispose()` 先调用


还有 `setState(...)` 是我们最常用的一个方法，这个方法中并没有触发传入的 `VoidCallback` ，而是调用了 `Element` 的 `markNeedsBuild()` ，这也是为什么我们把修改数据的逻辑放到 `setState(...)` 前、中、后，数据都能刷新的原因，而真正导致数据刷新的逻辑，等第二篇就知道啦。

关于 `State` 的部分就差不多了。不知道这时候你是否会产生一个疑问，因为我们常常听说 `Widget`、`Elmenet`、`RenderObject` 这三个对象的关系是十分紧密的。不过到上面只看到了 `Widget` 与 `Element` ，完全没有 `RenderObject` 的身影，那么它是在 `Elmenet` 中创建的吗？

这里我先提前说明一下，并不是。因为 `Elment` 中并没有相关的 `RenderObject` 创建方法，到这里问题来了，`RenderObject` 的创建方法，在哪里呢？

下面将介绍另一个非常重要，但是我们很少使用的 `Widget` 对象

## RenderObjectWidget


```
abstract class RenderObjectWidget extends Widget {
    
  const RenderObjectWidget({ Key key }) : super(key: key);
  
  @override
  RenderObjectElement createElement();
  
  @protected
  RenderObject createRenderObject(BuildContext context);
  
  @protected
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) { }
  
  @protected
  void didUnmountRenderObject(covariant RenderObject renderObject) { }
}
```
可以看到，`RenderObject` 的创建方法其实是由 `RenderObjectWidget` 提供的，同时还提供了对应的 `RenderObjectElement` 创建方法。关于这个 `Widget` 以及 `RenderObject` 相关信息，留到第三篇。本篇就结束了。


# 总结

通过上面一番源码阅读，我们可以发现 `Widget` 具备下面的一些特性：

- `Widget` 中所持有的对象都是不可修改的，也就是说它不具备数据的存储功能，而只能够对数据进行传递；即便是 `StatefulWidget`，数据的存储也是放在 `State` 中，它只是提供了 `State` 的创建方法
- 每个 `Widget` 都提供了 `Element` 的创建方法，但只有部分 `Widget` 具备 `RenderObject` 的创建方法。从这里我们可以断定， `Element` 与 `RenderObject` 不是一一对应的关系，很可能是一对一或者多对一的关系；同时我们猜想， `Element` 与 `Widget` 是一一对应的关系。

仅仅根据上面这些特性，并不能给 `Widget` 下一个准确的定义，那是因为我们还没深入了解主要的 `RenderObject` 。不过这里为了结束这篇文章，还是先提前做个定义吧：

-  `RenderObject` 用于布局绘制等操作，那么  `RenderObjectWidget` 则是向 `RenderObject` 提供绘制所需要的配置参数
-  `State` 用于进行数据的保存与修改， 那么 `StatefulWidget` 则是用于向 `State` 传递配置参数
-  `StatelessWidget` 用于向其他 `Widget` 传递配置参数。

而 `Widget` 之间又可以相互组合，最后得出结论：**Widget 用于描述描当前的配置和状态下视图所应该呈现的样子**

