---
title: Kotlin笔记(一):基础篇
date: 2018-09-30 21:49:47
index_img: /img/kotlin_1.png
tags: Kotlin
---

>  在2017年的Google开发者大会上，Kotlin正式作为Android的官方开发语言闪亮登场。而现在已经到了2018年的下半年末，身为一名Android开发者，如果不会一点Kotlin，总感觉少了什么。  
>   
> 于是乎，我准备动手学一学这门“年轻”的新语言了。不过新学一些东西往往会因为知识的消化需要时间而导致知识接收的效率不高，所以这时候好记性不如烂笔头的优势才得以体现嘛！  
> 
> 所以，初学阶段，我还是准备记一记笔记，这样也许会对我学这门语言有所帮助吧？!


关于Kotlin的官方文档，地址如下：

[Kotlin学习](https://www.kotlincn.net/docs/reference/)
<!--more--> 

### 1.在 Kotlin 中，if是表达式，而不是语句。

 语句和表达式的区别在于，表达式有值，并且能作为另一个表达式的一部分使用；而语句总是包围着它的代码块中的顶层元素，并且没有自己的值。
- 在Java中，所有的控制结构都是语句。而在Kotlin中，除了循环（ for, do 和 do/while ）以外大多数控制结构都是 表达式。
这种结合控制结构和其他表达式的能力让你可以简明扼要地表示许多 常见的模式，稍后你会在本书中看到这些内容。
- 另一方面，Java中的赋值操作是表达式，在Kotlin中反而变成了语句。这有助于避免比较和赋值之间的混淆，而这种混淆是常见的错误来源。


### 2.声明变量的关键字有两个 ：

- val （来自 value） 一一不可变引用。使用 val 声明的变量不能在初始化之 后再次赋值。它对应的是 Java 的 final 变量。  
- var （来自 variable） 一一可变引用。这种变量的值可以被改变。这种声明对 应的是普通（非 final）的 Java 变量。


### 3.局部变量的引用

和许多脚本语言一样， Kotlin 让你可 以在字符串字面值中引用局部变量，只需要在变量名称前面加上字符$。

这等价于 Java 中的字符串连接（ "Hello,"+ name ＋"！"），效率一样但是更紧凑。

```
fun main(args: Array<String>) {
    val name = if(args.size > 0) args[0] else "Kotlin"
    println("Hello, $name !")
}
```


还可以引用更复杂的表达式，而不是仅限于简单的变量名称，只需要把表达式 用花括号括起来.

### 4.在Java中可以用switch语句完成的，而Kotlin 对应的结构是when

```
fun getMnemonic(color: Color) = 
when (color) { 
Color . RED ->”Richard" 
Color.ORANGE ->”Of” 
Color.YELLOW ->”York" 
Color .GREEN ->”Gave” 
Color.BLUE ->”Battle" 
Color ．工NDIGO ->”In” 
Color.VIOLET ->”Vain 
}
```

  在一个 when 分支上合并多个选项：
  
```
fun getWarmth(color: Color) = when(color) {
Color.RED, Color.ORANGE, Color.YELLOW - > ”warm”
Color.GREEN -> ”neutral”
Color.BLUE, Color.INDIGO, Color.VIOLET ->”cold”
}
```
上面的代码中，也可以导入枚举常量后不用限定词就可以访问。比如去掉花括号里的Color也是可以的。

> Kotlin中的when结构比Java中的switch强大得多。switch要求必须使用常量（枚举常量、字符串或者数字字面值）作为分支条件，和它不一样， when允许使用任何对象。



### 5.类型判断

在Kotlin中，你要使用is检查来判断一个变量是否是某种类型。is检查和Java中的instanceOf相似，不过在instanceOf检查之后还需要显式地加上类型转换。

在Kotlin中，编译器帮你完成了这些工作。如果你检查过一个变量是某种类型，后面就不再需要转换它，可以就把它当作你检查过的类型使用。

使用as关键字来表示到特定类型的显式转换；


### 6.循环中的"in"关键字

Kotlin里面关键字“in”有许多作用，比如检查区间的成员；作为when的分支；在for循环中使用等。关于in如何在list中使用，下章再介绍


### 7.关于"try"

Kotlin中的try关键字就像if和when一样,引入了一个表达式，可以把它的值赋给一个变量。不同于if，你总是需要用花括号把语句主体括起来。和其他语句一样，如果其主体包含多个表达式，那么整个 try 表达式的值就是最后一个表达式的值。