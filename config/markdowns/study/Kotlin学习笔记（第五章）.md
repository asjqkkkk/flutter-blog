---
title: Kotlin笔记(四):基础篇most plus
date: 2018-10-03 21:49:47
index_img: /img/kotlin_4.png
tags: Kotlin
---


### 1.成员引用

Kotlin和Java8一样，如果把函数转换成一个值，你就可以传递它。  
> 使用:: 运算符来转换 ：

```
val getAge = Person::age 
```
这种表达式称为成员引用，它提供了简明语法，来创建一个调用单个方法或者 访问单个属性的函数值。双冒号把类名称与你要引用的成员（一个方法或者一个属性）名称隔开

### 2.集合的函数式API

**filter** 函数遍历集合并选出应用给定 **lambda** 后会返回 **true** 的那些元素：

```
>> val list= listOf(l, 2, 3, 4) 
>> println(list.filter{it % 2 == 0}) 
```

**filter** 函数可以从集合中移除你不想要的元素，但是它并不会改变这些元素。 元素的变换是 **map** 的用武之地。 

**map** 函数对集合中的每一个元素应用给定的函数并把结果收集到一个新集合。可以把数字列表变换成它们平方的列表，比如：

```
>> val list= listOf(l, 2, 3, 4) 
>> println(list.map { it * it }
{1, 4, 9, 16}
```

### 3."all""any""count"和"find"：对集合应用判断式

检查集合中的所有元素是否都符合某个条件（或者它的变种，是否存在符合的元素）。Kotlin中，它们是通过 **all** 和 **any** 函数表达的。 


```
val canBeinClub27 = { p: Person - > p.age <= 27 } 
```
> 如果你对是否所有元素都满足判断式感兴趣，应该使用 **all** 函数：

```
>> val people= listOf(Person ("Alice", 27), Person("Bob", 31))
>> println( people.all(canBeinClub27) ) 
false
```
> 如果你需要检查集合中是否至少存在一个匹配的元素，那就用 **any** :

```
>> println(people any(canBeinClub27)) 
true 
```
> 如果你想知道有多少个元素满足了判断式，使用 **count** : 

```
>> val people= listOf(Person("Alice", 27) , Person ("Bob", 31)) 
>> println(people.count(canBeinClub27))
1
```
> 要找到一个满足判断式的元素，使用 **find** 函数 ：

```
>> val people= listOf(Person("Alice"， 27) , Person("Bob", 31)) 
>> println(people.find(canBeinClub27)) 
Person(name=Alice, age=27) 
```
### 4.groupBy ：把列表转换成分组的 map

假设你需要把所有元素按照不同的特征划分成不同的分组。例如，你想把人按年龄分组，相同年龄的人放在一组。把这个特征直接当作参数传递十分方便。**groupBy** 函数可以帮你做到这一点：

```
>> val people= listOf(Person("Alice", 31), Person("Bob", 29), Person ("Carol", 31))
>> println(people.groupBy {it.age})
```
这次操作的结果是一个 **map**，是元素分组依据的键（这个例子中是age）和元素分组（persons）之间的映射

### 5.flatMap 和 flatten ：处理嵌套集合中的元素 

假设你有一堆藏书，使用 Book 类表示 ：

```
class Book (val title: String, val authors: List<String>) 
```
每本书都可能有一个或者多个作者，可以统计出图书馆中的所有作者的 set : 

```
books.flatMap { it.authors } toSet() 
```
**flatMap** 函数做了两件事情：首先根据作为实参给定的函数对集合中的每个元素做变换（或者说映射），然后把多个列表合并（或者说平铺）成一个列表。 

> **注意，如果你不需要做任何变换，只是需要平铺一个集合，可以使用flatten函数：listOfLists.flatten() 。**

Kotlin 标准库参考文档有说明，**filter** 和 **map** 都会返回一个列表。这意味着元素过多的时候，（链式）调用就会变得十分低效。为了提高效率，可以把操作变成使用序列，而不是直接使用集合，下面是对比的例子


```
people.map(Person: :name) .filter { it.startsWith("A")｝
```
转化为：
```
people.asSequence()
    .map (Person: : name)
    .filter{it.startsWith("A")}
    .tolist
```
Kotlin惰性集合操作的入口就是 **Sequence** 接口。这个接口表示的就是一个可以逐个列举元素的元素序列。 

可以调用扩展函数 **asSequence** 把任意集合转换成序列，调用  **toList** 来做反向的转换。 


### 6.使用Java函数式接口

 **OnClickListener** 接口只有一个抽象方法。这种接口被称为 **函数式接口**，或者 **SAM接口**，**SAM** 代表抽象方法。JavaAPI中随处可见像**Runnable**和**Callable**这样的函数式接口，以及支持它们
 的方法。 Kotlin 允许你在调用接收函数式接口作为参数的方法时使用 **lambda**，来保证你的 Kotlin代码既整洁又符合习惯。

可以把 **lambda** 传给任何期望函数式接口的方法。例如，下面这个方法，它有一个 **Runnable** 类型的参数：

```
/* Java */ 
void postponeComputation(int delay, Runnable computation); 
```
下面是显式地创建一个实现了 **Runnable** 的匿名对象的例子：

```
post postponeComputation(1OOO, object : Runnable { 
    override fun run() {
    println(42) 
    }
)}
```


在 Kotlin 中，可以调用它并把一个 **lambda** 作为实参传给它。编译器会自动把它转换成一个 **Runnable** 的实例：

```
postponeComputation(lOOO) { println(42) }
```
完全等价的实现应该是下面这段代码中的显式**object**声明，它把**Runnable**实例存储在一个变量中，并且每次调用的时候都使用这个变量：

```
val runnable = Runnable { println(42) } 
fun handleComputation(){ postponeComputation(1OOO, runnable)} 
```











