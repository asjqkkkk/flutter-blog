---
title: Kotlin笔记(二):基础篇plus
date: 2018-10-01 21:49:47
index_img: /img/kotlin_2.png
tags: Kotlin
---

### 1.顶层函数和属性

在Kotlin中，可以把那些工具类里的函数直接放到代码文件的顶层，不用从属于任何的类。这些放在文件顶层的函数依然是包内的成员，如果你需要从包外访问它，则需要import，但不再需要额外包一层


### 2.给别人的类添加方法：扩展函数和属性

扩展函数非常简单，它就是一个类的成员函数，不过定义在类的外面。举个例子：

```
package strings 
fun String.lastChar(): Char = this.get(this.length - 1) //this可以省略
```
从某种意义上说，你已经为String类添加了自己的方法。即使字符串不是代码的一部分，也没有类的源代码，你仍然可以在自己的项目中根据需要去扩展方法。

> 注意，扩展函数并不允许你打破它的封装性。和在类内部定义的方法不同的是，扩展函数不能访私有的或者是受保护的成员。 
>    
> 对于你定义的一个扩展函数，它不会自动地在整个目范围内生效。相反，如果你要使用它，需要进行导入
>      
> 扩展函数并不存在重写，因为Kotiin会把它们当作静态函数对待


下面是声明一个扩展属性：

```
val String.lastChar: Char get() = get(length - 1) 
```

可以看到，和扩展函数一样，扩展属性也像接收者的一个普通的成员属性一样。这里，必须定义getter函数，因为没有支持字段，因此没有默认getter的实现。同理，初始化也不可以：因为没有地方存储初始值。

    注意，当你需要从Java中访问扩展属性的时候，应该显式地调用它的getter函数
    
    
### 3.可变参数：让函数支持任意数量的参数

当你在调用一个函数来创建列表的时候，可以传递任意个数的参数给它：

```
val list= list0f(2, 3, 5, 7, 11) 
```
Kotlin的可变参数与Java类似，但语法略有不同：Kotlin在该类型之后不会再使用三个点，而是在参数上使用vararg修饰符。

Kotlin和Java 之间的另一个区别是，当需要传递的参数己经包装在数组中时，调用该函数的语法。在Java中，可以按原样传递数组，而Kotlin 则要求你显式地解包数组，以便每个数组元素在函数中能作为单独的参数来调用。从技术的角度来讲，这个功能被称为展开运算符，而使用的时候，不过是在对应的参数前面放一个*：

```
fun main(args: Array<String>）{
val list = listOf("args:”,*args) 
println(list) 
}

```


### 4.键值对的处理：中缀调用和解构声明

可以使用 mapOf 函数来创建 map:

```
val map= mapOf(l to "one"， 7 to "seven"， 53 to "fifty-three")
```
这行代码中的单词to不是内置的结构，而是一种特殊的函数调用，被称为中缀调用。 

在中缀调用中，没有添加额外的分隔符，函数名称是直接放在目标对象名称和 参数之间的。以下两种调用方式是等价的：


```
1.to("one")
1 to "one"
```

中缀调用可以与只有一个参数的函数一起使用，无论是普通的函数还是扩展函 数。要允许使用中缀符号调用函数，需要使用 infix 修饰符来标记它。下面是一个 简单的 to 函数的声明：


```
infix fun Any.to(other: Any) = Pair(this, other)
```

to 函数是一个扩展函数，可以创建一对任何元素，这意味着它是泛型接收者的 扩展：可以使用 1 to "one" 、"one" to 1、list to list.size()等写法。 



### 5.让你的代码更整洁：局部函数和扩展

Kotlin可以在函数中嵌套类中提取的函数。这样，既可以获得所需的结构，也无须额外的语法开销。

举个栗子：

```
class User(val id: Int, val name: String, val address: String) 

fun saveUser(user : User){
    if(user.name.isEmpty()){
        ...
    }
    if(user.address.isEmpty()){
        ...
    }
    //保存...
}
```
如果将验证代码放到局部函数中，可以摆脱重复，并保持清晰的代码结构，可以这样做 ：


```
class User(val id: Int, val name: String, val address: String) 

fun saveUser(user : User){
    fun validate(user: User, value: String, fieldName: String){
        if(value.isEmpty()){
            ...
        }
    }
    
    validate (user, user.name, "Name")
    validate (user, user.address, "Address")
    //保存...
    
}
```

上面的代码看起来好多了，而且局部函数可以访问所在函数中的所有参数和变量。 我们可以利用这一点，去掉冗余的User参数，这里就不再演示了

我们可以继续改进，把验证逻辑放到 User 类的扩展函数中。

```
class User(val id: Int, val name: String, val address: String) 

fun User.validateBeforeSave(){
    fun validate(value: String, fieldName: String){
        if(value.isEmpty()){
            ...
        }
    }
    
    validate (user.name, "Name")
    validate (user.address, "Address")
}


fun saveUser(user : User){
    user.validateBeforeSave()
    //保存...
}
```

**小结：**

- Kotlin没有定义自己的集合类，而是在Java集合类的基础上提供了更丰富的API。

- Kotlin可以给函数参数定义默认值，这样大大降低了重载函数的必要性，而且命名参数让多参数函数的调用更加易读。

- Kotlin允许更灵活的代码结构：函数和属性都可以直接在文件中声明，而不仅仅是在类中作为成员。

- Kotlin可以用扩展函数和属性来扩展任何类的API，包括在外部库中定义的类，而不需要修改其源代码，也没有运行时开销。 

- 中缀调用提供了处理单个参数的，类似调用运算符方法的简明语法。

- Kotlin为普通字符串和正则表达式都提供了大量的方便字符串处理的函数。 

- 三重引号的字符串提供了一种简洁的方式，解决了原本在Java中需要进行大量啰嗦的转义和宇符串连接的问题。

- 局部函数帮助你保持代码整洁的同时，避免重复。



