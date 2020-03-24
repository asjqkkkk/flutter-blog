---
title: Flutter图文混排原生实现方案
date: 2019-04-19 21:49:47
index_img: /img/pic_text.png
tags: Flutter
---

# 开头

图文混排在移动端的实现方案主要有两大种，比如通过HTML去做一个WebView的富文本，或者通过原生的方式去实现。

使用WebView在性能上自然不及原生实现，同时开发者需要具备一定的前端知识，它最大的优势是跨平台;

出于性能的考虑，以及我对前端知识的了解程度，这里我只是介绍一下如何通过原生的方式去实现图文混排。
<!--more--> 

# 介绍

在手机上，你经常能看到这样的图文实现方式，比如贴吧的这种：

<img src="https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Flutter%E5%9B%BE%E6%96%87%E6%B7%B7%E6%8E%92%E5%8E%9F%E7%94%9F%E5%AE%9E%E7%8E%B0%E6%96%B9%E6%A1%88/001.png" width = "600" height = "300" div align=center />

点进去后是这样的展示：


<img src="https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Flutter%E5%9B%BE%E6%96%87%E6%B7%B7%E6%8E%92%E5%8E%9F%E7%94%9F%E5%AE%9E%E7%8E%B0%E6%96%B9%E6%A1%88/002.png" width = "400" height = "720" div align=center />


这种实现方式比较简单，算是文字与图片分开展示。不过既然我们要实现的是图文混排，那一定会稍稍复杂一点。

# 示例

下面是demo的效果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Flutter%E5%9B%BE%E6%96%87%E6%B7%B7%E6%8E%92%E5%8E%9F%E7%94%9F%E5%AE%9E%E7%8E%B0%E6%96%B9%E6%A1%88/003.gif)


从上面的demo可以看到，通过原生的图文混排实现了下面这些效果：

    1.单个图片的插入
    2.多个图片的插入
    3.插入图片时对文字进行切割
    4.删除图片时对文字进行合并


其实看到这里，你应该能够看得出来一个大致的实现方法了，接下来我来介绍一下整个图文混排的结构。

由于是用Flutter实现，所以图文混排用的ListView，如果是android的话则可以使用RecyclerView(ios的话我不太了解所以就不说了)，因为实现图文混排主要是对数据的处理，所以平台的限制不大。

**既然是ListView，可以看得出来，ListView的内容全部是由Image与TextField组成，每当你插入一个Image的时候，同时会新増一个TextField，而这个TextField的内容则是上个TextField光标后的文字。**

既然知道了结构，那么下面来看一下是如何实现的吧。


# 实现

图文混排的主要逻辑在于两个：

    1.插入
    2.删除

在进行操作之前，先定义一个抽象的结构，用于存储字符串数据，其实只是对MapEntry的一个简单修改：


```
class TextEntry<K, V> {
  K key;
  V value;
  factory TextEntry(K key, V value) = TextEntry<K, V>._;
  TextEntry._(this.key, this.value);
  String toString() => "TextEntry($key: $value)";
}
```


然后来看一下插入的实现：

## 插入

```
class RichTextList<T>{

  List<TextEntry<T, String>> _list = [];

  void insertOne(int currentPosition, String beforeText, String selectText,
      String afterText, T t) {
    _list[currentPosition].value = beforeText;
    _list.insert(currentPosition + 1, TextEntry(t, ""));
    _list.insert(currentPosition + 2, new TextEntry(null, afterText));
  }

}
```
传递的参数中各个的意义如下：

- currentPosition：当前TextField所在的位置
- beforeText：当前TextField中光标前的文字
- selectText：当前TextField中选中的文字，在这里没有进行处理
- afterText：当前TextField中光标后的文字
- t：你传入的泛型参数

可以看到，每插入一个数据，还会自动插入一个value为null的TextEntry，而这个Entry则是文字的内容：

```
_list.insert(currentPosition + 2, new TextEntry(null, afterText));
```

所以图文混排的关键在于有一个统一的数据结构，后续如果想对这个数据结构进行转换也可以依据这个来，value为空的TextEntry表示文字，其他的则是你传入的泛型参数。

下面是插入多条的代码：


```
  void insert(int currentPosition, String beforeText, String selectText, String afterText, List<T> list){
    _list[currentPosition].value = beforeText;
    for(int i = 0; i < list.length; i++){
      _list.insert(currentPosition + 2*i + 1, TextEntry(list[i], ""));
      _list.insert(currentPosition + 2*i + 2, new TextEntry(null, i == list.length - 1?afterText:""));
    }
  }
```

当然，你可以用插入多个的替代上面插入单个的。

然后就是删除的逻辑了：

## 删除

删除也非常简单：


```
  void remove(int currentPosition) {
      String afterText = _list[currentPosition + 1].value;
      _list[currentPosition - 1].value += afterText;
      _list.removeAt(currentPosition + 1);
      _list.removeAt(currentPosition);
  }
```

删除的主要逻辑在于把下一个TextField中的内容补在上一个TextField中


核心的逻辑大概就是这样。


其中有点不方便的就是可能会与你的数据结构不太相同，所以转换的工作需要自己另外实现，当然如果你不想使用抽象的结构也可以自己自定义一种，比如说下面这种：


```
class CustomTypeList{
  TypeFlag flag;//默认为文字——0：文字，1：图片，2：视频，3：音乐
  var imageUrl;
  CustomTypeList({this.flag = TypeFlag.text, this.imageUrl = ""});
}

enum TypeFlag{
  text,
  image,
  video,
  music
}
```
实际使用中可以把枚举类型替换成int值，这样配合后端更佳。

**通过ListView实现图文混排最大的一个优势在于你可以将文字与任何类型的布局混合在一起，可以是图片，可以是视频，也可以是音乐！**


# 结尾

这篇文章没有把全部的代码贴出来，我已经把demo放在仓库里了，小伙伴们有意向可以去下载查看。

[**项目地址**](https://github.com/asjqkkkk/TextPicList)

最后的最后，为我用纯Flutter写的一个测试项目打个小广告：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/apk/apk.png)

如果你对于上面图文混排最后的效果不是特别满意，也可以到上面的app(android版)里面瞧一下,有做过特殊处理哦！