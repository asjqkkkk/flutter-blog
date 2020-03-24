---
title: Kotlin笔记(三):基础篇more plus
date: 2018-10-02 21:49:47
index_img: /img/kotlin_3.png
tags: Kotlin
---

### 1.接口的默认实现

接口的方法可以有一个默认实现。与Java8不同的是，Java8中需要你在这样的实现上标注default关键字，对于这样的方法，Kotlin没有特殊的注解 ：只需要提供一个方法体

```
interface Clickable{
    fun click()
    fun showOff = println("I'm clickable")
}
```
在实现接口的地方如果要显式地实现方法，在Kotlin中需要把 基类的名字放在尖括号中 ：
```
super<Clickable>.showOff() 
```
<!--more--> 
### 2.定义类的继承结构

    Java的类和方法默认是open的，而Kotlin中默认都是final的。 

如果你想允许创建一个类的子类，需要使用 **open** 修饰符来标示这个类。此外，需要给每一个可以被重写的属性或方法添加open修饰符。

> *注意，如果你重写了一个基类或者接口的成员，重写了的成员同样默认是 open的。如果你想改变这一行为，阻止你的类的子类重写你的实现，可以显式地将重写的成员标注为 **final** 。*



### 3.嵌套类与内部类

Kotlin中没有显式修饰符的嵌套类与Java中的static嵌套类是一样的。要把它变成一个内部类来持有一个外部类的引用的话需要使用 **inner** 修饰符。

在Kotlin中引用外部类实例的语法也与Java不同。需要使用 **this@Outer** 从 **Inner** 类去访问 **Outer** 类：


```
class Outer{
    inner class Inner{
        fun getOuterReference() : Outer = this@Outer
    }
}
```


### 4.密封类：定义受限的类继承结构

为父类添加一个 **sealed** 修饰符，对可能创建的子类做出严格的限制。

如果你在 when 表达式中处理所有 **sealed** 类的子类，你就不再需要提供默认分支。注意， **sealed** 修饰符隐含的这个类是一个 **open** 类， 你不再需要显式地添加 **open** 修饰符。


### 5.声明一个带非默认构造方法或属性的类

举个栗子：

```
class User constructor(_nickname: String) {
    val nickname : String
    
    init{
        nickname = _nickname
    }
}
```
在这个例子中，可以看到两个新的Kotlin关键宇：**constructor** 和 **init** 。 **constructor** 关键字用来开始一个主构造方法或从构造方法的声明。 **init** 关键字用来引入一个初始化语句块。这种语句块包含了在类被创建时执行的代码， 并会与主构造方法一起使用。

> 如果你想要确保你的类不被其他代码实例化，必须把构造方法标记为 private：

```
class Secretive private constructor() {}
//一般这么做表示这个类是一个静态实用工具成员的容器或者是单例的
```

### 6.通过 getter 或 setter 访问支持字段

假设你想在任何对存储在属性中的数据进行修改时输出日志，你声明了一个可变属性并且在每次 setter 访问时执行额外的代码。

```
class ·user (val name: String) { 
    var address: String ="unspecified" 
        set(value: String) { 
            println (””“ A Address was changed for $name:
            "$field" -> "value"."""".trimIndent())
            field = value
        }
    }
```
可以像平常一样通过使用 user.address ＝ "new value"， 来修改一个属性的值，这其实在底层调用了 setter。


在 setter 的函数体中，使用了特殊的标识符 **field** 来访问支持字段的值。

如果你想修改访问器的可见性，可以像下面这样：

```
class LengthCounter {
    var counter: Int = 0 
    private set     //这下就不能在类外部修改这个属性了
    
    fun addWord(word: String){
        counter += word.length
    }
}
```

### 7.数据类：自动生成通用方法的实现 

如果想要你的类是一个方便的数据容器，你需要重写这些方法 ： **toString**、 **equals** 和 **hashCode** 。在Kotlin中你不必再去生成这些方法了 。如果为你的类添加 **data** 修饰符，必要的方法将会自动生成好。

比如：
```
data class Client(val name: String, val postalCode: Int)
```

### 8.数据类和不可变性： copy()方法

为了让使用不可变对象的数据类变得更容易，Kotlin编译器为它们多生成了一个方法：一个允许 **copy** 类的实例的方法，并在 **copy** 的同时修改某些属性的值:


```
class Client (val name: String, val postalCode: Int) {
    fun copy(name: String = this.name, postalCode: Int = 
    this.postalCode) = Client(name, postalCode)
}


//使用
>>> val bob = Client("Bob”, 973293) 
>>> println(bob.copy(postalCode = 382555)) 
```

### 9.类委托：使用“by”关键字
(装饰模式我还不是太了解，了解以后再记录)

### 10.对象声明：创建单例易如反掌

在面向对象系统设计中一个相当常见的情形就是只需要一个实例的类。在Java中，这通常通过单例模式来实现 

Kotlin 通过使用对象声明功能为这一切提供了最高级的语言支持。对象声明将类声明与该类的单一实例声明结合到了一起。 


```
object Payroll { 
    val allErnployees = arrayListOf<Person>()

    fun calculateSalary() { 
        for {person in allErnployees) { 
        ...
        }
    }
}
```
> 对象声明通过object关键宇引入。一个对象声明可以非常高效地以一句话来定义一个类和一个该类的变量。 

### 11.伴生对象：工厂方法和静态成员的地盘

在类中定义的对象之一可以使用一个特殊的关键字来标记：**companion**。如果这样做，就获得了直接通过容器类名称来访问这个对象的方法和属性的能力，不再需要显式地指明对象的名称。最终的语法看起来非常像 Java 中的静态方法调用。

```
class A { 
    companion object { 
        fun bar() { 
        println ("Companion object called") 
        }
    }
}



>> A.bar() 
Companion object called
```


伴生对象可以访问类中的所有private成员，包括private构造方法，它是实现工厂模式的理想选择。 

```
class User private constructor(val nickname: String) {
    companion object {
        fun newSubscribingUser(email: String) =
        User(email.substringBefore ('@')) 
        
        fun newFacebookUser(accountld: Int) = 
        User(getFacebookName(accountld)) 
    }
}


>> val subscribingUser = User.newSubscribingUser ("bob@gmail.com") 
>> val facebookUser = User.newFacebookUser(4) 
>> println(subscribingUser.nickname)
bob
```

### 小结：


- Kotlin 的接口与 Java 的相似，但是可以包含默认实现 (Java 从第8版才开始支持)和属性。
- 所有的声明默认都是 final 和 public 的。
- 要想使声明不是 final 的，将其标记为 open。
- internal 声明在同一模块中可见。
- 嵌套类默认不是内部类。使用inner关键字来存储外部类的引用。
- sealed 类的子类只能嵌套在自身的声明中（Kotlin 1.1 允许将子类放置在同一文件的任意地方）。
- 初始化语句块和从构造方法为初始化类实例提供了灵活性。 
- 使用 field 标识符在访问器方法体中引用属性的支持字段。
- 数据类提供了编译器生成的 equals、 hashCode、 toString、 copy 和其他方法。 
- 类委托帮助避免在代码中出现许多相似的委托方法。 
- 对象声明是 Kotlin 中定义单例类的方法。
- 伴生对象（与包级别函数和属性一起）替代了Java静态方法和字段定义。 
- 伴生对象与其他对象一样，可以实现接口，也可以拥有有扩展函数和属性。
- 对象表达式是 Kotlin中针对Java匿名内部类的替代品，并增加了诸如实现多个接口的能力和修改在创建对象的作用域中定义的变量的能力等功能。