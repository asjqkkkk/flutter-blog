---
title: 从源码看flutter（三）：RenderObject篇
date: 2020-04-20 10:03:39
index_img: /img/flutter_03.png
tags: Flutter系列
---

# 开篇

上一篇 [从源码看flutter（二）：Element篇](http://oldben.gitee.io/flutter-blog/#/articlePage/%E4%BB%8E%E6%BA%90%E7%A0%81%E7%9C%8Bflutter%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9AElement%E7%AF%87) 我们通过 `Element` 的生命周期对 `Element` 有了一个整体的了解，这次我们将来对 `RenderObject` 做深入的分析，进一步完善我们对于 flutter framework的了解

在[第一篇](http://oldben.gitee.io/flutter-blog/#/articlePage/%E4%BB%8E%E6%BA%90%E7%A0%81%E7%9C%8Bflutter%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9AWidget%E7%AF%87)，我们知道  `RenderObject` 的创建方法是由 `RenderObjectWidget` 提供的，而我们已经了解过了 `Element` 的生命周期，这里，我们将选择 `RenderObjectElement` 作为此篇文章的分析起点

# RenderObjectElement

`RenderObjectElement` 与之前我们分析的其他 `Element` 对象差别不是特别大，主要的不同点在下面的几个方法中

```
abstract class RenderObjectElement extends Element {
  ...
  @override
  void attachRenderObject(dynamic newSlot) { ... }
  
  @override
  void detachRenderObject() { ... }
  
  @protected
  void insertChildRenderObject(covariant RenderObject child, covariant dynamic slot);
  
  @protected
  void moveChildRenderObject(covariant RenderObject child, covariant dynamic slot);
  
  @protected
  void removeChildRenderObject(covariant RenderObject child);

}
```
分别是实现了 `Element` 提供的 `attachRenderObject(newSlot)` 与 `detachRenderObject()`，并提供给子类后面三个方法去对 `RenderObject` 对象进行相关操作。

这里可以看到，有的参数被关键字 `covariant` 所修饰，这个关键字是用于对重写方法的参数做限制的，像上面的 `removeChildRenderObject` 方法，如果有子类重写它，则重写方法中的参数类型需要为 `RenderObject` 或 `RenderObject` 的子类。具体的说明，可以看[这里](https://dart.dev/guides/language/sound-problems#the-covariant-keyword)


这里简单的对 `RenderObjectElement` 做了一个介绍，接下来，我们就来看一下它在初始化方法 `mount(...)` 中都做了写什么 

## mount(...)


```

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    ...
    _renderObject = widget.createRenderObject(this);
    ...
    assert(_slot == newSlot);
    attachRenderObject(newSlot);
    _dirty = false;
  }
```
可以看到，在 `mount(...)` 方法中，调用了 `RenderObjectWidget` 的 `createRenderObject(...)` 方法创建了 `RenderObject` 对象。

之后通过 `attachRenderObject(newSlot)` 对 `RenderObject` 进行了进一步的操作

## attachRenderObject(newSlot)


```
  @override
  void attachRenderObject(dynamic newSlot) {
    assert(_ancestorRenderObjectElement == null);
    _slot = newSlot;
    _ancestorRenderObjectElement = _findAncestorRenderObjectElement();
    _ancestorRenderObjectElement?.insertChildRenderObject(renderObject, newSlot);
    final ParentDataElement<ParentData> parentDataElement = _findAncestorParentDataElement();
    if (parentDataElement != null)
      _updateParentData(parentDataElement.widget);
  }
```
可以看到，在 `attachRenderObject(newSlot)` 中，首先是寻找到祖先 `RenderObjectElement` 结点，然后将当前 `RenderObject` 插入其中。

后面还会查找 `ParentDataElement`，关于这类 `Element` ，是当父节点想要把数据通过 `ParentData` 存储在子节点中时才会用到，比如 `Stack` 和 `Position`，其中 `Position` 对应的 `Element` 就是 `ParentDataElement`

可以简单看一下 `_findAncestorRenderObjectElement()` 逻辑


```
  RenderObjectElement _findAncestorRenderObjectElement() {
    Element ancestor = _parent;
    while (ancestor != null && ancestor is! RenderObjectElement)
      ancestor = ancestor._parent;
    return ancestor as RenderObjectElement;
  }
```
就是简单的遍历父节点，当结点为null或者是 `RenderObjectElement` 时就会退出遍历。所以这里找到的是最近的祖先结点

之后会调用 `RenderObjectElement` 的 `insertChildRenderObject(...)` 将child插入，这是一个抽象方法，具体的逻辑都交由子类去实现

我们知道，比较常用的两个 `RenderObjectElement` 的实现类，分别是 `SingleChildRenderObjectElement` 和 `MultiChildRenderObjectElement`。前者表示只有一个子节点，常见的对应 `Widget` 有 `Padding` 、 `Align`、`SizeBox` 等 ；后者表示有多个子节点，常见对应的 `Widget` 有 `Wrap`、`Stack`、`Viewport` 等

每个 `RenderObjectElement` 的实现类，其 `insertChildRenderObject(...)` 都有所不同，但最终都会调用到 `RenderObject` 的 `adoptChild(child)` 方法

接下来，我们进入到本篇文章主角 `RenderObject` 的相关信息

# RenderObject


```
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget {
    ...
}
```
可以看到， `RenderObject` 是 `AbstractNode` 的子类，并且实现了 `HitTestTarget` 接口， `HitTestTarget` 是用于处理点击事件的

我们来看一下 `AbstractNode`

## AbstractNode


```
class AbstractNode {
  int _depth = 0;
  
  @protected
  void redepthChild(AbstractNode child) { ... }
  
  @mustCallSuper
  void attach(covariant Object owner) { ... }
  
  ...
  
  AbstractNode _parent;
  
  @protected
  @mustCallSuper
  void adoptChild(covariant AbstractNode child) { ... }
  
  @protected
  @mustCallSuper
  void dropChild(covariant AbstractNode child) { ... }
}
```
在 `AbstractNode` 中，提供了许多方法供子类实现，其中比较核心的就是 `adoptChild(...)` 

可以先简单看一下它的 `adoptChild(...)`


```
  @protected
  @mustCallSuper
  void adoptChild(covariant AbstractNode child) {
    ...
    child._parent = this;
    if (attached)
      child.attach(_owner);
    redepthChild(child);
  }
```
接下来，来看一下 `RenderObject` 的实现

## adoptChild(...)


```
  @override
  void adoptChild(RenderObject child) {
    ...
    setupParentData(child);
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
    markNeedsSemanticsUpdate();
    super.adoptChild(child);
  }
```

这里，我们主要关注 `markNeedsLayout()`

## markNeedsLayout()


```
  RenderObject _relayoutBoundary;
  ...
  @override
  PipelineOwner get owner => super.owner as PipelineOwner;
  ...

  void markNeedsLayout() {
    ...
    if (_relayoutBoundary != this) {
      markParentNeedsLayout();
    } else {
      _needsLayout = true;
      if (owner != null) {
        ...
        owner._nodesNeedingLayout.add(this);
        owner.requestVisualUpdate();
      }
    }
  }
```
其中 `_relayoutBoundary` 表示重新布局的边界，如果当前 `RenderObject` 就是该边界，则只需要将当前的 `_needsLayout` 设为 **true**，同时将当前 `RenderObject` 添加到 `PipelineOwner` 中维护的 `_nodesNeedingLayout` 中；如果边界是父节点的话，则会调用父节点的 `markNeedsLayout()` 方法

那么下一步，我们应该走到哪里呢？

在上一篇中，我们知道 `Element` 的刷新流程，会走到 `WidgetsBinding ` 的 `drawFrame()` 方法


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
在 `buildScope(...)` 和 `finalizeTree()` 中间，调用了 `super.drawFrame()`，它会来到 `RendererBinding` 的 `drawFrame()` 方法中

## RendererBinding -> drawFrame()


```
  @protected
  void drawFrame() {
    assert(renderView != null);
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    if (sendFramesToEngine) {
      renderView.compositeFrame(); // this sends the bits to the GPU
      pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
      _firstFrameSent = true;
    }
  }
```
可以看到，这里主要是通过 `PipelineOwner` 去进行一些操作，其中，我们主要关注 `flushLayout()` 和 `flushPaint()`

## PipelineOwner

### flushLayout()


```
  List<RenderObject> _nodesNeedingLayout = <RenderObject>[];
  ...
  void flushLayout() {
    ...
    try {
      ...
      while (_nodesNeedingLayout.isNotEmpty) {
        final List<RenderObject> dirtyNodes = _nodesNeedingLayout;
        _nodesNeedingLayout = <RenderObject>[];
        for (final RenderObject node in dirtyNodes..sort((RenderObject a, RenderObject b) => a.depth - b.depth)) {
          if (node._needsLayout && node.owner == this)
            node._layoutWithoutResize();
        }
      }
    } finally {
      ...
        _debugDoingLayout = false;
      ...
    }
  }
```
`flushLayout()` 中，依旧是先根据深度，也就是父节点在前子节点在后的顺序进行排序，然后遍历调用 `RenderObject` 的 `_layoutWithoutResize()` 方法

可以简单看一下 `_layoutWithoutResize()` 方法

#### RenderObject -> _layoutWithoutResize()


```
  void _layoutWithoutResize() {
    ...
    RenderObject debugPreviousActiveLayout;
    ...
      performLayout();
    ...
    _needsLayout = false;
    markNeedsPaint();
  }
  ...
  @protected
  void performLayout();
```
在 `_layoutWithoutResize()` 中，会调用 `performLayout()` 方法，这个方法交由子类实现，一般实现它的子类中，会在这个方法内调用 `performLayout()` 的 `onLayout(...)` 方法

我们可以简单看一下 `onLayout(...)` 


```
  void layout(Constraints constraints, { bool parentUsesSize = false }) {
    ...
    if (!parentUsesSize || sizedByParent || constraints.isTight || parent is! RenderObject) {
      relayoutBoundary = this;
    } else {
      relayoutBoundary = (parent as RenderObject)._relayoutBoundary;
    }
    ...
    _relayoutBoundary = relayoutBoundary;
    ...
    if (sizedByParent) {
      ...
        performResize();
      ...
    }
    ...
      performLayout();
    ...
    _needsLayout = false;
    markNeedsPaint();
  }
```
基本上，执行 `performLayout()` 后就可以确定布局的大小了，之后，都会调用 `markNeedsPaint()` 

#### RenderObject -> markNeedsPaint()


```
  void markNeedsPaint() {
    ...
    _needsPaint = true;
    if (isRepaintBoundary) {
      ...
      if (owner != null) {
        owner._nodesNeedingPaint.add(this);
        owner.requestVisualUpdate();
      }
    } else if (parent is RenderObject) {
      final RenderObject parent = this.parent as RenderObject;
      parent.markNeedsPaint();
      ...
    } else {
      ...
      if (owner != null)
        owner.requestVisualUpdate();
    }
  }
  
  ...
  bool get isRepaintBoundary => false;
```
可以看到，通过对 `isRepaintBoundary` 进行判断做了不同的逻辑处理，如果 `RenderObject` 的  `isRepaintBoundary` 不为 **true** 则会一直找向父节点查找，直到找到 **true** 为止，然后将它们一起绘制，所以合理重写这个方法可以避免不必要的绘制。

当 `isRepaintBoundary` 为 **true** 时，就是将需要绘制的 `RenderObject` 放入 `PipelineOwner` 维护的另一个列表 `_nodesNeedingPaint` 中

`PipelineOwner` 的 `flushLayout()` 差不多就结束了，接下来看一下它的 `flushPaint()`

### flushPaint()


```
  void flushPaint() {
    ...
      _debugDoingPaint = true;
    ...
    try {
      final List<RenderObject> dirtyNodes = _nodesNeedingPaint;
      _nodesNeedingPaint = <RenderObject>[];
      ...
      for (final RenderObject node in dirtyNodes..sort((RenderObject a, RenderObject b) => b.depth - a.depth)) {
        assert(node._layer != null);
        if (node._needsPaint && node.owner == this) {
          if (node._layer.attached) {
            PaintingContext.repaintCompositedChild(node);
          } else {
            node._skippedPaintingOnLayer();
          }
        }
      }
      ...
    } finally {
      ...
        _debugDoingPaint = false;
      ...
    }
  }
```
依旧是排序后，进行遍历处理。这里又引入了一个新的概念 `Layer`。

当 `node._layer.attached` 为true 时表示该 `Layer` 对象被添加到了 `Layer` 树中。关于这个对象，我们会在下篇文章中进行更加详细的说明



这里只需要关注 ` PaintingContext.repaintCompositedChild(node)` 方法

在此之前，先简单的说明一下，`PaintingContext` 对象就是用于进行绘制的地方，它持有一个 `Canvas` 对象，你在flutter中看到的所有页面，基本上都是由 `Canvas` 来绘制的

####  PaintingContext -> repaintCompositedChild(node)


```
class PaintingContext extends ClipContext {
  ...
  static void repaintCompositedChild(RenderObject child, { bool debugAlsoPaintedParent = false }) {
    assert(child._needsPaint);
    _repaintCompositedChild(
      child,
      debugAlsoPaintedParent: debugAlsoPaintedParent,
    );
  }
  ...
}
```
它调用了 `_repaintCompositedChild(...)` 方法

####  PaintingContext -> _repaintCompositedChild(...)


```
  static void _repaintCompositedChild(
    RenderObject child, {
    bool debugAlsoPaintedParent = false,
    PaintingContext childContext,
  }) {
    assert(child.isRepaintBoundary);
    ...
    if (childLayer == null) {
      ...
      child._layer = childLayer = OffsetLayer();
    } else {
      ...
      childLayer.removeAllChildren();
    }
    ...
    childContext ??= PaintingContext(child._layer, child.paintBounds);
    child._paintWithContext(childContext, Offset.zero);
    ...
    assert(identical(childLayer, child._layer));
    childContext.stopRecordingIfNeeded();
  }
```



最后，主要的逻辑都在 `RenderObject` 的 `_paintWithContext(...)` 中

### RenderObject -> _paintWithContext(...)


```
  void _paintWithContext(PaintingContext context, Offset offset) {
    ...
    _needsPaint = false;
    try {
      paint(context, offset);
      ...
    }
    ...
  }
  
  void paint(PaintingContext context, Offset offset) { }
```
最后执行的 `paint(...)` 方法，显然交由子类去实现。

其实到这里，关于 `RenderObject` 的流程分析就差不多了。销毁的部分和我们之前看的 `Element` 销毁都是大同小异的，所以这里不介绍了

下面，我们可以用一个简单的例子来作为这次 `RenderObject` 的学习

# 例子


```
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyWidget());

class MyWidget extends SingleChildRenderObjectWidget{
  @override
  RenderObject createRenderObject(BuildContext context) => MyRenderObject();
}

class MyElement extends SingleChildRenderObjectElement{
  MyElement(SingleChildRenderObjectWidget widget) : super(widget);
}

class MyRenderObject extends RenderBox{

  @override
  BoxConstraints get constraints => BoxConstraints(minHeight: 100.0, minWidth: 100.0);

  @override
  void performLayout() => size = Size(constraints.minWidth + Random().nextInt(200), constraints.minHeight + Random().nextInt(200));

  @override
  void paint(PaintingContext context, Offset offset) {
    Paint paint = Paint()..color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    context.canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), paint);
  }
}
```

例子可以直接在这里进行测试：https://dartpad.dev/

我们重写了 `RenderBox` ，它是 `RenderObject` 一个主要的抽象实现类

`RenderBox` 中获取 `BoxConstraints` 的方法默认调用的是父节点的 `constraints` ，这里为了简化例子，我们将其重写了。这个对象主要是用于对 `RenderBox` 的大小进行限制，这个限制的逻辑你是可以自定义的



一般情况下，我们要自定义自己的 `RenderObject` ，都是重写 `RenderBox`。要自定义 `Element` 则是重写 `SingleChildRenderObjectElement` 或者 `MultiChildRenderObjectElement`

那么这篇关于 `RenderObject` 的文章就到这里结束了


# 总结

简单的总结一下 `RenderObject` 的一些特性吧

- `RenderObject` 的主要职责就是完成界面的布局、测量与绘制
- `RenderObject` 中有一个 `ParentData` 对象，如果有父节点需要将某些数据存储在子节点，会给子节点设置 `ParentData` 并将数据存入其中。比如 `RenderAligningShiftedBox` 在 `performLayout()` 时，就会给 child 设置 `BoxParentData`，在其中存储偏移量 `Offeset`，代表 `Widgett` 就是 `Center`
- `RenderObject` 在进行绘制时，会判断当前的 `isRepaintBoundary` 是否为 **true**，是则创建一个自己的 `Layer` 去进行进行绘制，默认为 `OffsetLayer`；不是则从父节点中获取 `Layer` ，与父节点一起绘制。关于 `Layer` 的更多信息，将在下一篇中详细说明