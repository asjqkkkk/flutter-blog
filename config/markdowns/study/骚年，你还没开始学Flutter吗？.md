---
title: 骚年，你还没开始学Flutter吗？
date: 2019-05-04 21:49:47
index_img: /img/study_flutter.png
tags: Flutter
---

# 开场闲聊

在去年12月份的Flutter Live 2018上，谷歌的Flutter团队宣布**Flutter 1.0 release版**正式发布。

想必很多小伙伴和我一样，都是从那个时候开始了解到Flutter的，而我也是顺带从那个时候入了Flutter的坑。

不过应该还有一部分小伙伴对Flutter只是略有耳闻，甚至闻所未闻。为了把这部分小伙伴拉到这个 **“大坑”** 里面来，我不得不在这里向你们展示**Flutter的魅力**所在，同时为了保持客观公正，我也会介绍一些我遇到过的**Flutter的麻烦**之处。  
就像谈恋爱一样，因为优点才会在一起，也因为接受得了缺点才能使情感继续保持。

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/001.png)


话不多说，接下来就由我来为诸位展示Flutter所具备的这些的特性吧。
<!--more--> 


# Flutter的特性

在我看来，Flutter的特性主要分为两类，分别是**高效性**与**舒适性**，这两者都会是你在进行Flutter开发时最直观的感受，而下面的这些特性从侧面也会展示出这部分效果


### 一、热重载

热重载大家应该都耳熟能详了，和前端开发一样，对代码进行修改后，可以即时看到效果，这点相比于原生开发每次做了一点修改就要从头到尾编译一次不知道高到哪里去了！

下面是一点简单的演示效果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/002.gif)

可以看到，热重载带来的体验提升是巨大的！作为一名原生开发者，你心动了吗？

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/003.gif)

不过关于热重载还有一些需要说明的地方，在用到可以保存状态的控件时，热重载不能将状态重置，比如说一个动画控件，在动画结束后再进行热重载是无法再次播放动画的（除非你对动画做了循环处理），所以有的时候你看着觉得热重载没效果，这时候就要考虑是不是用到了 **StatefulWidget** 之类的控件。

Flutter将热重载作为一个亮点，不过由于Flutter的布局是用代码去写的，和Android中的xml不同，它无法进行实时预览，所以你无法想象没有热重载的话，要怎么面对Flutter进行编程，这么看来热重载既是亮点，也是要点。

### 二、万物基于Widget

Flutter中的页面都是由一个个的Widget组合而成，甚至连页面本身也是一个Widget，Widget与android中的组件类似，不过前者具有更好的组合性。  
同时Flutter已经封装了许多简单好用的Widget，使用起来非常方便。

比如在android中你想创建下面这样一个圆，你需要重新写一个xml，并在xml定义各种属性：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/004.png)

而在Flutter中实现是非常容易的：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/005.png)

不管是圆形，还是圆角矩形，又或者是不对称圆角矩形，Flutter都提供了很方便的实现方法。

关于Widget可以看到代码的结构是一层一层的，对于初次接触的人来说想必是很难接受这种代码格式。因为我当初看到Flutter这样的代码时，还产生过劝退的想法，不过写了一段时间后还是觉得蛮带感的。打个比方的话就像初见JoJo和再见JoJo的感觉。

在android中视图在xml中，代码则由java负责，在习惯了flutter后，我觉得用代码直接去创建视图也未尝不是一种好的解决方法，毕竟xml+java也算历史悠久了。而我也接触过一个前端框架——Vue，flutter的这种结构和vue的就非常类似。

孰好孰坏因人而异，想必等你使用过一段时间后的flutter后心中会有着一个自己的答案。


### 三、跨平台

跨平台其实是flutter最突出的一个特点了，与其他如React、Week这类跨平台框架不同，Flutter作为后起之秀能脱颖而出与其性能表现和稳点程度是有很大关系的。

在Flutter Live 2018上，官方已经放出了好几个纯Flutter的应用，并演示了他们在android和ios上的运行效果，其中最为惊艳的就是 **《The History Of Everything》** 了，下面给大家简单的展示一下真机运行效果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/007.gif)

想自行体验的话可以去Google Play或者App Store中下载

上面应用中的动画大部分由 **Flare** 实现，具体可以参见 [2dimensions(需科学上网)](https://www.2dimensions.com/)，这样可以跑满60帧的矢量动画也只是Flutter性能展现的一面，在跨平台上，其最大的特点就是**接近原生效果**。

不过目前而言，flutter在跨平台上有一些问题还是需要完善的。比如视频的播放  
具体原因可以看这篇文章：[万万没想到——flutter这样外接纹理](https://www.yuque.com/xytech/flutter/pfpo68)

还有那些需要用到第三方sdk的时候，可能就需要做双端的channel通信了，但是也有比较积极的团队专门做了flutter的sdk，**声网**就是其中之一

### 四、年轻

年轻是flutter的一大优势，同时也是一大劣势。

就像上面说的，许多第三方sdk还没有开始为flutter做适配，所以flutter的开发生态自然比不了其他技术框架和平台，然而因其发展的势头非常迅猛，所以这其实也是一个机会。大量的开发者可以在这个领域再做建树，未来会是何种状况还是非常令人期待的。

如同 **Kotlin** 一样，现阶段如果去看国外的一些技术博客，如 **Medium** 里关于 Android 的，大部分语言都已经是kotlin的了，只是国内的博客可能普及度还没有那么高。但是良禽择木而栖，趋势一直都在，怎么选择就看个人了。

也正是因为flutter比较年轻，所以有些东西还没有一个既定的公认的解决方案。就比如flutter开发过程中都会遇到的 **状态管理**。

目前flutter中的状态管理框架有许多，最知名的比如从前端引鉴过来的 **Redux**，同时还有 **Bloc**， **Provide** 等。每个状态管理框架解决的范围都不一样，学习成本也各有差异，如何选择还是需要看项目需求与个人喜好。  
具体选择可以看这篇文章：[（译）让我来帮你理解和选择Flutter状态管理方案](https://juejin.im/post/5bac54c45188255c681589d3)


### 五、Dart语言

flutter的开发语言使用的是dart，对于刚接触kotlin的同学来说，再去使用dart想必是一件很苦恼的事情。

比如kotlin中用 **var表示变量(variable)**，**val表示常量(value)**，而到了dart中虽然可以用var表示变量，但是常量还是只能用final或者const去修饰。

从很多方面看来kotlin都算是算是采各家所长集于一身，而dart则像是修行还没结束就半路出山了。

不过因为对比对象是kotlin，所以dart显得不那么出色，其实dart还是有很多好用的点的。

比如
#### 调用前做对象判空：

```
//kotlin
a?.m()
//dart
a?.m()

```
不同之处在于kotlin如果对象为空则不做处理,同时要求你做对象为空时的赋值，dart如果对象为空则返回null,

#### 对象为空时赋值

```
//kotlin
var x = a?.b ?: c
//dart
var x = a?.b ?? c
```
两者区别不大.不过dart中还可以使用 ??= 代替?? ,区别是前者可以单独作为赋值语句

dart虽然在使用上不及kotlin那么舒适，但dart也一直在更新换代，优秀的语言发展到最后一定是有很多共同性的，所以不要过于纠结于语言的选择上，因为它终究只是一种工具。

# 结束闲聊

从去年12月flutter发布1.0 release版本到今天，flutter已经迭代了好多个版本了

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/008.png)

而我在使用过程中确实遇到过一些问题，或简单或麻烦，但大部分都有了解决方案。从稳定性上来讲，使用flutter的交互其实就是对数据进行操作，而正是因为这样，做到了视图与数据分离，所以出bug的情况要少得多。

为什么我要介绍flutter甚至是鼓励各位原生开发者们去学flutter，主要原因有两个：
- 一、学习flutter的成本很低，因为它难度不大
- 二、从flutter的性能表现上来看，它是可以代替原生应用的，只是现在火候不够

所以对于现阶段的初中级原生开发者而言，我建议你一定要抽出时间去了解了解flutter，因为大部分你能通过原生去实现的东西，用flutter一样也是可以的，并且还更加轻松，还可以跨平台。

写到这里，文章中也很少涉及到技术上的东西，主要还是以介绍为主

下面再介绍一点点我非常推荐的学习flutter的途径吧：



1、 **首先自然是Youtube上flutter官方的视频项目(科学上网)：
[Flutter](https://www.youtube.com/channel/UCwXdFgeE9KYzlDdR7TG9cMw)**

这里面有个超赞的系列，就是每周一更的 **Flutter Widget of the Week**


2、**然后你也可以关注B站的** **[Google中国账号](https://space.bilibili.com/64169458/)**

其中的视频都有中文翻译，可以找到关于flutter的学习视频，不过和youtube上相比更新要慢很多

3、**[《Flutter实战》](https://book.flutterchina.club/)**

万分感谢这位作者开源这本技术书！


剩下的学习途径还有许多，不过学习也是发散的，知道上面三个后，其他的途径于你也不在话下了。


最后再介绍一个学习途径

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/apk/apk.png)

没错，就是我用flutter写的一个小项目

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/introduce_flutter/009.jpg)

