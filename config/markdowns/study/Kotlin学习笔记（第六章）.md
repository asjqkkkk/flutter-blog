---
title: Kotlin笔记(五):基础篇latest
date: 2018-10-05 21:49:47
index_img: /img/kotlin_5.png
tags: Kotlin
---

### 1.可空类型

问号可以加在任何类型的后面来表示这个类型的变量可以存储 null 引用 ： String?、 Int?、 MyCustomType? ，等等

一旦你有一个可空类型的值，能对它进行的操作也会受到限制。例如，不能再调用它的方法 
```
>> fun strLenSafe(s: String?) = s.length() 
ERROR: only safe (?.) or non null asserted (!!.) calls are allowed on a nullable receiver of type kotlin.String?
```
也不能把它赋值给非空类型的变量 ：
```
>> val x: String? = null 
>> var y: String = x 
ERROR: Type mismatch: inferred type is String? but String was expected 
```
也不能把可空类型的值传给拥有非空类型参数的函数 ：
```
>> strLen(x) 
ERROR: Type mismatch: inferred type is String? but String was expected 
```
那么你可以对它做什么呢？最重要的操作就是和 null 进行比较。 而且一旦你 进行了比较操作，编译器就会记住，并且在这次比较发生的作用域内把这个值当作非空来对待


### 2.安全调用运算符："?."

> Kotlin的弹药库中最有效的一种工具就是安全调用运算符：?.，它允许你把一 次null检查和一次方法调用合并成一个操作。

例如，表达式 s?.toUpperCase() 等同于下面这种烦琐的写法：if(s!=null) s.toUpperCase() else null。 

### 3.Elvis运算符："?:" 

Kotlin 有方便的运算符来提供代替null的默认值。它被称作**Elvis运算符**（或者 null合并运算符，如果你喜欢听起来更严肃的名称）。下面展示了它是如何使用的：
```
fun foo(s: String?) {
    val t: String= s?:""
}
```
*Elvis 运算符接收两个运算数，如果第一个运算数不为null，运算结果就是第 一个运算数；如果第一个运算数为null，运算结果就是第二个运算数。*

### 4.安全转换："as?"

> as? 运算符尝试把值转换成指定的类型，如果值不是合适的类型就返回 null

一种常见的模式是把安全转换和 Elvis 运算符结合使用。例如，实现 equals 方法的时候这样的用法非常方便。


```
class Person(val firstNarne: String, val lastNarne: String){
    override fun equals(o: Any?): Boolean {
        val otherPerson = o as? Person?: return false
        return otherPerson.firstNarne == firstNarne && otherPerson.lastNarne == lastNarne 
    }
    
    override fun hashCode(): Int = firstNarne.hashCode() * 37 + lastNarne.hashCode() 
}


>> val pl = Person ( "Drnitry","Jernerov") 
>> val p2 = Person ( "Drnitry","Jernerov") 
>> println (pl == p2) 
true
>> println(pl.equals(42)) 
false 
```

### 5.非空断言："!!"

> 非空断言是 Kotlin 提供给你的最简单直率的处理可空类型值的工具。它使用双感叹号表示，可以把任何值转换成非空类型。如果对 null 值做非空断言，则会抛出异常。

某些问题适合用非空断言来解决。当你在一个函数中检查一个值是否为null，而在另一个函数中使用这个值时，这种情况下编译器无法识别这种用法是否安全。如果你确信这样的检查一定在其他某个函数中存在，你可能不想在使用这个值之前重复检查，这时你就可以使用非空断言。

 当你使用 !! 并且它的结果是异常时， 异常调用械的跟踪信息只表明异常发生在哪一行代码，而不会表明异常发生在哪一个表达 式。 为了让跟踪信息更清晰精确地表示哪个值为 null，最好避免在同一行中使用多个!!断言

### 6."let"函数

> let 函数让处理可空表达式变得更容易。 和安全调用运算符一起，它允许你对表达式求值，检查求值结果是否为 null，并把结果保存为一个变量。 所有这些动作都在同一个简洁的表达式中。 

下面举个栗子：

```
fun sendEmailTo(email: String) { /* ... */ } 
```
不能把可空类型的值传上面给这个函数：


```
>> val email: String? = ...
>> sendEmailTo(email) 
ERROR: Type mismatch: inferred type is String? but String was expected 
```
必须显式地检查这个值不为 null:

```
if (email != null) sendEmailTo(email)
```
如果使用了let函数，会是下面这样子的：

```
email?.let { email -> sendEmailTo(email) } 
```
**let** 函数只在 email 的值非空时才被调用，所以你就能在 lambda 中把 email 当作非空的实参使用。
使用自动生成的名字 it 这种简明语法之后，上面的代码就更短了 ： 
```
 email?.let{ sendEmailTo(it) ｝ 
```

### 7.延迟初始化的属性

Kotlin 通常要求你在构造方法中初始化所有属性，如果某个属性是 非空类型，你就必须提供非空的初始化值。否则，你就必须使用可空类型。否则， 你就必须使用可空类型。如果你这样做，该属性的每一次访问都需要 null 检查或者 !! 运算符。
```
class MyService {
    fun performAction() : String = "foo"
}

class MyTest{
    private var myService: MyService? = null 
    
    @Before fun setUp(){
        myService = MyService() 
    }
    
    
    @Test fun testAction(){
        //必须注意可空性：要么 用!!， 要么用?.
        Assert.assertEquals( "foo" ， myService!!.performAction() ) 
    }
}
```
这段代码很难看，尤其是你要反复使用这个属性的时候。 
为了解决这个问题， 使用 **lateinit** 修饰符来完成这样的声明。
```
class MyService {
    fun performAction() : String = "foo"
}

class MyTest{
    //声明一个不需要初始化 器的非空类型的属性
    private lateinit var myService: MyService
    
    @Before fun setUp(){
        myService = MyService() 
    }
    
    @Test fun testAction(){
        //不需要 null 检查直接访问属性
        Assert.assertEquals( "foo" ， myService!!.performAction() ) 
    }
}
```
*注意， 延迟初始化的属性都是 var，因为需要在构造方法外修改它的值*

### 8."Any"和"Any?"：根类型

> 和 Object 作为 Java 类层级结构的根差不多， **Any** 类型是 Kotlin 所有非空类型的超类型（非空类型的根）。
>
> 但是在 Java 中， Object 只是所有引用类型的超类 型（引用类型的根），而基本数据类型并不是类层级结构的一部分。
>
> 这意味着当你 需要 Object 的时候，不得不使用像 java.lang.Integer 这样的包装类型来表示基本数据类型的值。 **而在 Kotlin 中， Any 是所有类型的超类型（所有类型的根）**， 包括像 Int 这样的基本数据类型。 

和 Java 一样，把基本数据类型的值赋给 **Any** 类型的变量时会自动装箱：

```
val answer: Any = 42 
```
*注意 **Any** 是非空类型，所以 **Any** 类型的变量不可以持有 null 值*

### 9.Unit 类型 ： Kotlin 的"void"

Kotlin 中的 **Unit** 类型完成了 Java 中的 void 一样的功能。当函数没什么有意思的结果要返回时，它可以用作函数的返回类型：
```
fun f () : Unit { . . . } 
```
语法上，这和写一个带有代码块体但不带类型声明的函数没有什么不同：

```
fun f () { .. }         //缩写版
```
> Unit 是一个完备的类型，可以作为类型参数，而 void 却不行。

在函数式编程语言中， Unit 这个名字习惯上被用来表示“只有一个实例”，这正是 Kotlin 的 Unit 和 Java 的 void 的区别。

### 10.Nothing类型：“这个函数永不返回”

对某些 Kotlin 函数来说，"返回类型"的概念没有任何意义，因为它们从来不会成功地结束
,Kotlin 使用一种特殊的返回类型 Nothing 来表示：

```
fun fail(message: String): Nothing { 
    throw IllegalStateException (message)
}

>> fail ("Error occurred")
java.lang.IllegalStateException: Error occurred 
```
Nothing 类型没有任何值， 只有被当作函数返回值使用，或者被当作泛型函数 返回值的类型参数使用才会有意义。在其他所有情况下，声明一个不能存储任何值 的变量没有任何意义。 


### 11.可空性和集合

遍历一个包含可空值的集合并过滤掉 null 是一个非常常见的操作，因此 Kotlin 提供了一个标准库函数 **filterNotNull** 来完成它。 

### 12.只读集合与可变集合 

Kotlin 的集合设计和 Java 不同的另一项重要特质是，它把访问集合数据的接口和修改集合数据的接口分开了。这种区别存在于最基础的使用集合的接口之中:kotlin.collections.Collection。

使用 kotlin.collections.MutableCollection 接口可以修改集合中的数据。它继承了普通的 kotlin.collections.Collection 接口,还提供了方法来添加和移除元素、清空集合等。 

一般的规则是在代码的任何地方都应该使用只读接口，只在代码需要修改集合的地方使用可变接口的变体
























