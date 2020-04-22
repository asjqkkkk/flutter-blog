---
title: 从源码看flutter（四）：Layer篇
date: 2020-04-21 03:46:55
index_img: /img/flutter_04.png
tags: Flutter系列
---

# 开篇

这一篇，我们将简单的了解一下 `Layer` 相关内容，因为其中大部分是与C++交互，所以只是从结构上做一个认识与分析

从上一篇中，我们了解到了，如果 `RenderObject` 的 `isRepaintBoundary` 为 **true** 会通过自己的 `Layer` 对象去渲染,如果没有为 `RenderObject` 手动指定 `Layer` 的话，默认会是 `OffestLayer`;为 **false** 则通过父节点的 `Layer` 对象渲染。

其中 **paint** 相关的 `Layer` 逻辑都在 `PaintingContext` 中，每次 **paint** 都会创建一个新的 `PaintingContext` 对象

同时通过 `PaintingContext` 获取 `Canvans` 时会创建一个 `PictureLayer` 被合成到 `PaintingContext` 的创建时所接收的 `Layer` 中

下面，我们简单的看一下 `Layer` 对象

# Layer


```
abstract class Layer extends AbstractNode with DiagnosticableTreeMixin {

  @override
  ContainerLayer get parent => super.parent as ContainerLayer;
  ...
  Layer get nextSibling => _nextSibling;
  ...
  Layer get previousSibling => _previousSibling;
  ...
  @protected
  void addToScene(ui.SceneBuilder builder, [ Offset layerOffset = Offset.zero ]);
  ...
}
```
`Layer` 和 `RenderObject` 一样，都是 `AbstractNode` 的子类，可以看到持有的 `parent` 对象都是 `ContainerLayer`，同时 `Layer` 还有两个对象 `nextSibling` 和 `previousSibling`，看起来像一个双向链表的结构

`addToScene(...)` 交由子类实现，就是将 `Layer` 对象交给 **engine** 去处理，传递给 **engine** 的逻辑都在 `SceneBuilder` 中

`Layer` 有多个子类，分别实现不同的渲染功能

![](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/4.layer/001.png)

其中 `PictureLayout` 是主要的图像绘制层；
`TextureLayer` 则用于外界纹理的实现，通过它可以实现诸如相机、视频播放、OpenGL等相关操作；
`ContainerLayout` 则是各个 `Layer` 组成的复合层

# Layer的刷新

上一篇中，我们自定义了 `RenderObject` 并且重写了它的 `paint(...)` 方法，通过对 `Canvans` 对象进行操作，我们绘制了自己想要的图像，而  `Canvans` 是从 `PaintingContext` 中获取的，在获取 `Canvans` 时，其实做了和 `Layer` 有关的一系列操作


```
class PaintingContext extends ClipContext {
  ...
  @override
  Canvas get canvas {
    if (_canvas == null)
      _startRecording();
    return _canvas;
  }

  void _startRecording() {
    assert(!_isRecording);
    _currentLayer = PictureLayer(estimatedBounds);
    _recorder = ui.PictureRecorder();
    _canvas = Canvas(_recorder);
    _containerLayer.append(_currentLayer);
  }
  ...
}
```
可以看到，在这里创建了一个新的 `PictureLayer` 被添加到了 `_containerLayer` 中，我们的 `Layer` 最终是如何被渲染的呢？

信息还是可以从上一篇获得，我们知道 `RendererBinding` 的 `drawFrame()` 中进行了布局与绘制操作


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
最终的渲染其实是通过 `compositeFrame()` 来进行的，而这里的 `renderView` 就是我们的根`RenderObject` 我们可以看一下 `compositeFrame()` 做了些什么


```
class RenderView extends RenderObject with RenderObjectWithChildMixin<RenderBox> {
  ...
  void compositeFrame() {
    ...
      final ui.SceneBuilder builder = ui.SceneBuilder();
      final ui.Scene scene = layer.buildScene(builder);
      if (automaticSystemUiAdjustment)
        _updateSystemChrome();
      _window.render(scene);
      scene.dispose();
    ...
  }
  ...
}
```
可以看到，这里通过 `buildScene(...)` 创建了 `Scene` 对象，根据注释来看，它相当于一颗 `Layer` 树

之后通过 `Window` 对象的 `render(...)` 方法来进行渲染

```
  void render(Scene scene) native 'Window_render';
```
它直接调用的是 **engine** 的方法，通过这个方法，就可以对图像进行渲染，后面我们会进行一个测试来展示它的作用

这里的 `layer` 就是根 `Layer` ，它其实是一个 `TransformLayer`，我们可以简单看一下它的创建流程

## 根Layer创建流程

在 `RendererBinding` 的 `initInstances()` 中通过 `initRenderView()` 进行了 `RenderView` 的创建


```
mixin RendererBinding on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, SemanticsBinding, HitTestable {
  ...
  @override
  void initInstances() {
    super.initInstances();
    ...
    initRenderView();
    ...
  }
  ...
}

```

### RendererBinding -> initRenderView()


```
  void initRenderView() {
    assert(renderView == null);
    renderView = RenderView(configuration: createViewConfiguration(), window: window);
    renderView.prepareInitialFrame();
  }
```
根 `Layer` 就是在 `prepareInitialFrame()` 中创建的

### RenderView -> prepareInitialFrame()


```
  void prepareInitialFrame() {
    ...
    scheduleInitialLayout();
    scheduleInitialPaint(_updateMatricesAndCreateNewRootLayer());
    ...
  }
```
创建的方法就是 `_updateMatricesAndCreateNewRootLayer()`


```
  TransformLayer _updateMatricesAndCreateNewRootLayer() {
    _rootTransform = configuration.toMatrix();
    final TransformLayer rootLayer = TransformLayer(transform: _rootTransform);
    rootLayer.attach(this);
    ...
    return rootLayer;
  }
```
这里我们只是简单的了解一下根 `Layer` 的创建流程，它就是一个 `TransformLayer` 对象。

创建流程我们知道了，而想要了解刷新流程，我们需要回到 `compositeFrame()` 方法中，执行刷新的方法就在 `buildScene(...)` 里

## buildScene(...)

从前面的关系图我们知道，`TransformLayer` 的父类是 `OffsetLayer`，而 `OffsetLayer` 的父类是 `ContainerLayer`，它们都没有重写 `buildScene(...)` 方法，所以最后会调用 `ContainerLayer` 的 `buildScene(...)`


```
  ui.Scene buildScene(ui.SceneBuilder builder) {
    ...
    updateSubtreeNeedsAddToScene();
    addToScene(builder);
    ...
    _needsAddToScene = false;
    ...
    return scene;
  }
```
可以先看一下 `updateSubtreeNeedsAddToScene()` 方法

## updateSubtreeNeedsAddToScene()


```
  ///ConstraintLayer
  @override
  void updateSubtreeNeedsAddToScene() {
    super.updateSubtreeNeedsAddToScene();
    Layer child = firstChild;
    while (child != null) {
      child.updateSubtreeNeedsAddToScene();
      _needsAddToScene = _needsAddToScene || child._needsAddToScene;
      child = child.nextSibling;
    }
  }

  ///Layer
  @protected
  @visibleForTesting
  void updateSubtreeNeedsAddToScene() {
    _needsAddToScene = _needsAddToScene || alwaysNeedsAddToScene;
  }
```
其实所有 `Layer` 类中，只有 `ConstraintLayer` 和 `Layer` 具备这两个方法，这里其实就是遍历所有子 `Layer` 对象，调用他们的 `updateSubtreeNeedsAddToScene()` 来设置 `_needsAddToScene` 的值

这个值顾名思义，就是表示是否需要将改 `Layer` 添加到 `Scene` 中，如果需要添加，则就是进行刷新了。它根据 `_needsAddToScene` 和 `alwaysNeedsAddToScene` 来设置，当调用 `markNeedsAddToScene()` 方法的时候， `_needsAddToScene` 就会被设置为 **true**

`updateSubtreeNeedsAddToScene()` 执行结束后，接下来会调用 `addToScene(builder)` 方法

## addToScene(...)

正好 `TransformLayer` 重写了这个方法，并且没有调用父类的方法


```
  @override
  void addToScene(ui.SceneBuilder builder, [ Offset layerOffset = Offset.zero ]) {
    ...
    engineLayer = builder.pushTransform(
      _lastEffectiveTransform.storage,
      oldLayer: _engineLayer as ui.TransformEngineLayer,
    );
    addChildrenToScene(builder);
    builder.pop();
  }
```
这里的 `engineLayer` 对象是用于进行复用的

可以看到这里调用了 `addChildrenToScene(builder)` 方法，这个方法只在 `ContainerLayer` 中，且没有被重写

## addChildrenToScene(...)


```
  void addChildrenToScene(ui.SceneBuilder builder, [ Offset childOffset = Offset.zero ]) {
    Layer child = firstChild;
    while (child != null) {
      if (childOffset == Offset.zero) {
        child._addToSceneWithRetainedRendering(builder);
      } else {
        child.addToScene(builder, childOffset);
      }
      child = child.nextSibling;
    }
  }
```
在这里就是遍历 **child** ，然后调用它们各自实现的 `addToScene(...)` 方法，而是否要将 `Layer` 添加到 `Scene` 的判断依据，已经在之前的 `updateSubtreeNeedsAddToScene()` 中完成了。

这里需要注意一下， `_addToSceneWithRetainedRendering(builder)` 就是用于对之前的 `_engineLayer` 进行复用，当 `childOffset` 为 `Offset.zero` 时

那么到这里 `Layer` 的刷新流程就结束了。而本篇文章差不多也快到头了，接下来我们完成上面提到过的，进行一个渲染测试

# 渲染测试

可以在这里进行测试：https://dartpad.dev/

```
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


void main(){
    final OffsetLayer rootLayer = new OffsetLayer();
    final PictureLayer pictureLayer = new PictureLayer(Rect.zero);
    rootLayer.append(pictureLayer);

    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);

    Paint paint = Paint();
    paint.color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

    canvas.drawRect(Rect.fromLTWH(0, 0, 300, 300), paint);
    pictureLayer.picture = recorder.endRecording();

    SceneBuilder sceneBuilder = SceneBuilder();
    rootLayer.addToScene(sceneBuilder);

    Scene scene = sceneBuilder.build();
    window.onDrawFrame = (){
      window.render(scene);
    };
    window.scheduleFrame();
}
```
效果如下

<img src="https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/4.layer/002.png" width=200>

可以看到，我们没有使用任何 `Widget` 就在设备上展示了一个图案。所以其实从这里就可以了解到为什么说 Flutter是通过skia引擎去绘制的了。

关于 `Layer` 的其他内容，这里也不再深入了，毕竟再深入就是C++了

本篇是我们讲过的四棵树中最后的一颗，而这里非常方便用于测试一个我们前三篇都遇到了但是都略过了的部分，那就是 **热重载**

# 额外部分：热重载

当你通过上面的用例进行测试的时候，点击一下热重载按钮，是不是发现会报错：

```
Error -32601 received from application: Method not found
```
并且图案的颜色并不会更改，这就涉及到我们之前提到过的一个方法了：`reassemble()` 了

在 `Element` 和 `RenderObject` 中你经常能看到与之相关的方法，它就是用于实现热重载的核心逻辑

在 `BindingBase` 中，我们可以看到找到这样一个方法：`reassembleApplication()` ，就是它来进行热重载控制的

它会调用 `performReassemble()` 方法


```
  @mustCallSuper
  @protected
  Future<void> performReassemble() {
    FlutterError.resetErrorCount();
    return Future<void>.value();
  }
```
在 `WidgetsBinding` 和 `RendererBinding` 都重写了这个方法，如果感兴趣的话，可以去看一下，他们分在其中调用了让 `Element` 和 `RenderObject` 进行热重载的方法

那么，我们想要实现实现热重载其实就很简单了，看代码：


```
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

void main() => TestBinding();

class TestBinding extends BindingBase{

  @override
  Future<void> performReassemble(){
    final OffsetLayer rootLayer = new OffsetLayer();
    final PictureLayer pictureLayer = new PictureLayer(Rect.zero);
    rootLayer.append(pictureLayer);

    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);

    Paint paint = Paint();
    paint.color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

    canvas.drawRect(Rect.fromLTWH(0, 0, 300, 300), paint);
    pictureLayer.picture = recorder.endRecording();

    SceneBuilder sceneBuilder = SceneBuilder();
    rootLayer.addToScene(sceneBuilder);

    Scene scene = sceneBuilder.build();
    window.onDrawFrame = (){
      window.render(scene);
    };
    window.scheduleFrame();
    super.performReassemble();
    return Future<void>.value();
  }
}
```
热重载效果如下，大家可以在设备上进行测试

<img src="https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/flutter/4.layer/003.gif" width=200>

当然，热重载的核心逻辑就是这个了。

不过此前会进行代码文件的变更检查等，详情可以看这一篇文章：[揭秘Flutter Hot Reload（原理篇）](https://juejin.im/post/5bc80ef7f265da0a857aa924)

本篇到这里就结束了，而【**从源码看flutter**】 尚未结束，敬请期待吧