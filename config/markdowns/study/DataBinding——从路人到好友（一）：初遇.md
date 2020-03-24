---
title: DataBinding——从路人到好友（一）：初遇
date: 2018-10-17 21:49:47
index_img: /img/data_binding.png
tags: Android
---

# 杂谈


> 在编程领域，对于一名初学者而言，最开始的进阶方式都是不断重复的练习，然后在练习中遇到各种困难，同时也在这个过程里积累了不少的经验。
>
> 一般情况下，我们获取的经验可以有效的减少我们的失误，也可以为我们预防掉许多“隐藏”的Bug。
> 
> 但是，随着我们能力的提升，我们逐渐的对于那些重复性非常高、而且意义并不大的代码产生了厌倦感。首当其冲的就是像 **findViewById** 这样的代码！

大量的 **findViewById** 与全局变量想必是许多初学者都会经历的阶段，不过学的东西越多，对于这类代码的接受力也就越低。所以许多人选择用了 **ButterKnife** 去解决这个问题。

然鹅当 **Kotlin** 出现后，**ButterKnife** 也可以随之抛弃了，这时候 **DataBinding** 的用处却和 **Kotlin** 并不冲突，相反二者结合使用，反而会让你有意想不到的、久违的、可圈可点的、眼前一亮的、拍手称赞的体验！


# 使用


使用 **Data-Binding** ，首先需要在 **app moudle** 下的 **build.gradle** 中添加：

```
android {
    ...
    dataBinding {
        enabled = true
    }
    ...
}
```

然后就可以正常使用了，不过需要注意，最低支持的Android版本是4.0（反正几乎没有比这更低的android设备了），gradle插件版本是1.5.0 （都2018年了，android开发者们肯定不能用比这更低的版本了吧！）


接下来，举个最简单的栗子，我们创建一个 **Cartoon** 类：

```
class Cartoon(var name:String = "JOJO的奇妙冒险" , var series :String = "黄金之风",
              var leader : String = "乔鲁诺·乔巴纳", var feature : String = "黄金体验") {
}
```
然后新建一个Activity，在这个Activity的xml中的根布局下，通过Alt+Enter快捷键创建databinding的布局，同时，导入 **Cartoon** 类：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/one/databinding-001.png)

这时候，编译器会自动根据这个布局生成相应的绑定类，这里会生成一个 **ActivityDataBindingBinding** 的类 ，暂时先不用管，我们继续在xml上工作，修改一下布局样式：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/one/databinding-002.png)

然后，在对应的Activity内对生成的 **ActivityDataBindingBinding** 类进行操作：

```
class DataBindingActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_data_binding)
        val bindingBinding : ActivityDataBindingBinding = DataBindingUtil.setContentView(this, R.layout.activity_data_binding)
        bindingBinding.cartoon = Cartoon()
    }
}
```

由于Kotlin创建的Cartoon实体类已经给每个字段都赋予了初始值，这里不用再进行赋值，然后看一下效果：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/one/databinding-003.png)

> 如果你使用的是 items 去进行的绑定，例如Fragment、RecyclerView的adapter，可以使用 inflate() 的方法去绑定或者 DataBindingUtil 类，就像下面这样

```
val listItemBinding = ListItemBinding.inflate(layoutInflater, viewGroup, false)
// or
val listItemBinding = DataBindingUtil.inflate(layoutInflater, R.layout.list_item, viewGroup, false)
```

如果这时候你想使用字符串拼接，可以在 **string.xml** 中创建，比如：

```
    <string name="cartoon_name">动漫名:%s</string>
    <string name="cartoon_series">系列:%s</string>
    <string name="cartoon_leader">主角:</string>
    <string name="cartoon_bodyDouble">替身:</string>
```
使用的时候可以是这样：

```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable name="cartoon" type="com.test.project.testdatabinding.DataBinding.Cartoon"/>
    </data>

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="match_parent">
        <TextView
            android:layout_gravity="center"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{@string/cartoon_name(cartoon.name)}"/>
        <TextView
            android:layout_gravity="center"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{@string/cartoon_series(cartoon.series)}"/>
        <TextView
            android:layout_gravity="center"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{@string/cartoon_leader + cartoon.leader}"/>
        <TextView
            android:layout_gravity="center"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{@string/cartoon_bodyDouble + cartoon.feature}"/>

    </LinearLayout>
</layout>
```
效果如下：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/one/databinding-004.png)

至此，我们完成了与DataBinding的初次接触！

可以看到，相较于往常的通过findViewById去获取控件实例，然后给控件设置数据的方法，这样显然去掉了Activity内许多不必要的代码。

不过以上只是比较简单的DataBinding用法，下面将会介绍DataBinding的其他功能，这样才能应更复杂的需求。


## 集合的使用


```
<data>
    <import type="android.util.SparseArray"/>
    <import type="java.util.Map"/>
    <import type="java.util.List"/>
    <variable name="list" type="List<String>"/>
    <variable name="sparse" type="SparseArray<String>"/>
    <variable name="map" type="Map<String, String>"/>
    <variable name="index" type="int"/>
    <variable name="key" type="String"/>
</data>
…
android:text="@{list[index]}"
…
android:text="@{sparse[index]}"
…
android:text="@{map[key]}"  //这里也可以使用 @{map.key}代替
```

## 点击事件

点击事件也是可以在xml中绑定的，在 DataBindingActivity 中添加如下方法：

```
    fun doClick(view: View){
        Toast.makeText(this, "点击测试", Toast.LENGTH_SHORT).show()
    }
```
不要忘了在括号中传入View

然后再xml中写一个button的点击事件
```
 <Button
            android:text="DataBinding-点击测试"
            android:onClick="doClick"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content" />
```
如果想通过点击事件传入参数的话，可以通过下面这种方法：


```
<variable name="handler" type="com.test.project.testdatabinding.DataBinding.DataBindingActivity"/>


<Button
            android:text="DataBinding-点击测试"
            android:onClick="@{() -> handler.doClick(cartoon.name)}"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content" />
```
从xml中导入 DataBindingActivity 后，再修改代码：

```
class DataBindingActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_data_binding)
        val bindingBinding : ActivityDataBindingBinding = DataBindingUtil.setContentView(this, R.layout.activity_data_binding)
        bindingBinding.cartoon = Cartoon()
        bindingBinding.handler = this
    }

    fun doClick(message: String){
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}
```
点击效果如下：


![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/one/databinding-005.png)

如果有更加复杂的点击事件，可以参考官介绍中的，如带View参数的：
```
class Presenter {
    fun onSaveClick(view: View, task: Task){}
}


android:onClick="@{(theView) -> presenter.onSaveClick(theView, task)}"
```

## import 与 include

### import

在xml中，可以通过导入一些工具类进行简单地操作，比如说导入View类：

```
<data>
    <import type="android.view.View"/>
</data>
```
这样你就可以直接在xml中使用它的一些静态方法或者变量,官方的例子中简单地用法如下：

```
<TextView
   android:text="@{user.lastName}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"
   android:visibility="@{user.isAdult ? View.VISIBLE : View.GONE}"/>
```
不过我觉得xml中不适合做太多逻辑判断的操作，所以使用的时候应该考虑一下某些操作是否真的合适


### include

如果你有在xml中使用到 include ，通过下面例子中的方法就行绑定：
```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:bind="http://schemas.android.com/apk/res-auto">
    <data>
        <variable name="cartoon" type="com.test.project.testdatabinding.DataBinding.Cartoon"/>
    </data>

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="match_parent">
        
       <include layout="@layout/layout_test"
           bind:cartoon="@{cartoon}"/>

    </LinearLayout>
</layout>
```
layout_test 布局：

```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">

    <data>
        <variable name="cartoon" type="com.test.project.testdatabinding.DataBinding.Cartoon"/>
    </data>

    <android.support.constraint.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent">

        <TextView
            android:text="@{cartoon.name}"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content" />

    </android.support.constraint.ConstraintLayout>
</layout>
```
注意，要使用 bind 属性，可别忘了下面的这行代码：

```
xmlns:bind="http://schemas.android.com/apk/res-auto"
```

# 暂歇

出于篇幅考虑，关于 **DataBinding** 的使用，暂且就讲到这里，关于它更详尽的用法，后续再作介绍。



---

# 未完待续































