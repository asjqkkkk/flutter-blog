---
title: DataBinding——从相识到相知（二）：互酌
date: 2018-10-20 21:49:47
index_img: /img/data_binding.png
tags: Android
---

# 前言

上一篇里，主要讲了关于Databinding的以下几点：

- 接入与使用
- 简单的数据绑定
- 点击事件的绑定

这一篇将会继续上一篇的步伐，对DataBinding的使用更深几分.首先依旧是从数据绑定开始
<!--more--> 

> 之前所介绍的，虽然UI与数据进行了绑定，但是修改数据对象的时候并不会同时更新 **UI** .  
现在有三种不同类型的 **observable** 类：**objects**, **fields**, 还有 **collections**.  
当其中某个 **observable** 数据对象绑定到 **UI** 并且数据对象的属性发生更改时， UI 将自动更新，下面开始介绍.


# Observable数据

如果你的数据类只有几个属性，那么没必要去实现 **Observable** 接口来监听数据的改变，可以使用下面这些字段：

- [**ObservableBoolean**](https://developer.android.google.cn/reference/android/databinding/ObservableBoolean.html)
- [**ObservableByte**](https://developer.android.google.cn/reference/android/databinding/ObservableByte.html)
- [**ObservableChar**](https://developer.android.google.cn/reference/android/databinding/ObservableChar.html)
- [**ObservableShort**](https://developer.android.google.cn/reference/android/databinding/ObservableShort.html)
- [**ObservableInt**](https://developer.android.google.cn/reference/android/databinding/ObservableInt.html)
- [**ObservableLong**](https://developer.android.google.cn/reference/android/databinding/ObservableLong.html)
- [**ObservableFloat**](https://developer.android.google.cn/reference/android/databinding/ObservableFloat.html)
- [**ObservableDouble**](https://developer.android.google.cn/reference/android/databinding/ObservableDouble.html)
- [**ObservableParcelable**](https://developer.android.google.cn/reference/android/databinding/ObservableParcelable.html)

现在，我们再创建一个类
```
class ObservableBean {
    val text = ObservableField<String>()
}
```
布局文件改为：

```
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable name="model" type="com.test.project.testdatabinding.MVP.DataBinding.Bean.ObservableBean"/>
    </data>

    <LinearLayout
        android:orientation="vertical"
        android:layout_width="match_parent"
        android:layout_height="match_parent">

        <EditText
            android:id="@+id/et_test"
            android:text="@={model.text}"
            android:layout_width="match_parent"
            android:layout_height="wrap_content" />

        <TextView
            android:id="@+id/tv_test"
            android:text="@{model.text}"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"/>
        
    </LinearLayout>
</layout>
```
需要注意的是，上面的 **EditText** 的 **text** 属性使用的是 **@={}** 而 **TextView** 使用的是 **@{}** 。当你想要使用双向绑定的时候，可别忘了这个 **=** 号



Activity的代码只改变了绑定对象：

```
class DataBindingActivity<T> : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_data_binding)
        val bindingBinding : ActivityDataBindingBinding = DataBindingUtil.setContentView(this, R.layout.activity_data_binding)
        bindingBinding.model = ObservableBean()
    }
}
```
效果如下：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/DataBinding/two/databinding-001.gif)

可以看到，直接使用 **Observable** 字段去实现双向数据绑定是很轻松的，不过实际项目里面需求各不相同，要将数据都换成 **Observable** 字段还是很麻烦的，所以自定义双向数据绑定非常有必要！

这时对 **ObservableBean** 进行修改：

```
class ObservableBean : BaseObservable() {
    @get:Bindable
    var text: String = ""
    set(value) {
        field = value
        notifyPropertyChanged(BR.text)
    }
}

//相较于Kotlin写法，这里我觉得Java写法更有助于理解：
public  class ObservableBean extends BaseObservable {
    private String text;

    @Bindable
    public String getText() {
        return text;
    }

    public ObservableBean setText(String text) {
        this.text = text;
        notifyPropertyChanged(BR.text);
        return this;
    }
}

```
修改过后的效果与之前使用 **Observable** 字段的效果一样，上面需要注意的两点：

-  使用了 **@Bindable** 注解，进行绑定声明
-  使用了 **notifyPropertyChanged()** 方法为数据刷新做准备

不过在我看来，通过这种继承的方法对于我们原有的数据结构并不过友好，尤其是继承了 **BaseObservable** 类的数据类不能通过  **Gson** 去与 **Json** 相互转换。

所以使用的时候，我们可以考虑通过某个中介类的方式去进行转换.


# 布局的绑定

第第一篇中，有写到Activity中如何获取自动生成的布局绑定类——xxxBinding，这种类的命名与使用数据绑定的布局文件xml有关，比如说 **activity_main.xml** 就会生成 **ActivityMainBinding** 

这里再详细说明一下，不同类型的布局，应该怎么获取生成的 **Binding绑定类** 

> 事先并不知道绑定类型的对象可以使用 **DataBindingUtil** 去创建绑定

```
val rootView = LayoutInflater.from(this).inflate(layoutId, parent, attachToParent)
val binding: ViewDataBinding? = DataBindingUtil.bind(viewRoot)
```

## 获取带 ID 的 View对象

如果使用的是Kotlin，可以直接在Activity里很方便的使用id获取View对象，不过使用DataBinding后，就有另外一种获取View对象的方式了

布局里面的 Id 如下：

```
    ...
        <EditText
            android:id="@+id/et_test"
            android:text="@={model.text}"
            android:layout_width="match_parent"
            android:layout_height="wrap_content" />

    ...
```

通过 Id 获取 EditText 的方法如下：

```
        ...
        super.onCreate(savedInstanceState)
        val bindingBinding : ActivityDataBindingBinding = DataBindingUtil.setContentView(this, R.layout.activity_data_binding)
        bindingBinding.model = ObservableBean()
        val editText = bindingBinding.root.rootView.findViewById<EditText>(R.id.et_test)
```


> **立即绑定**  
>
> 当变量或可观察对象发生更改时，绑定会在下一帧之前更改。 不过有的时候需要立刻执行绑定.  
>
> 若要强制执行，可以使用 **executePendingBindings()** 方法。

## 高级绑定

有时候，特定的绑定类是未知的.  

例如，针对任意布局操作的 **RecyclerView.Adapter** 不知道特定的绑定类.它仍然必须在调用 **onBindViewHolder()** 方法时分配绑定值.

在 **RecyclerView** 的  **onBindViewHolder()** 方法里，可以这样写：

```
override fun onBindViewHolder(holder: BindingHolder, position: Int) {
    item: T = mItems.get(position)
    holder.binding.setVariable(BR.item, item);
    holder.binding.executePendingBindings();
}
```

## 使用@BindingAdapter自定义绑定逻辑

DataBinding为我们提供了一种可以对绑定逻辑进行自定义的方法，比如说我想在xml中对一个ImageView控件加载图片，并且是使用的Glide加载框架，这时候可以这样：

```
//随便创建一个类，然后在类中定义如下方法
@BindingAdapter("imageUrl")
fun loadImage(view: ImageView, url: String) {
    GlideApp.with(view.getContext())
   .load(url)
   .fitCenter()
   .into(view);
}
```
使用的时候编译器会自动生成对应属性：

```
<ImageView 
app:imageUrl="@{model.imageUrl}"  />
```
使用 **@BindAdapter** 几乎可以完成你想要的各种逻辑，不过我觉得，只有那种使用率特别高的代码，才最适合这个属性.

## 使用@BindingConversion完成转换功能

在某些情况下，特定类型之间需要自定义转换。 例如，视图的android:background属性需要Drawable，但指定的颜色值是整数。 

官方例子中，转换功能的具体用法如下：

```
@BindingConversion
fun convertColorToDrawable(color: Int) = ColorDrawable(color)
```
使用的时候可以这样：

```
<View
   android:background="@{isError ? @drawable/error : @color/white}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```



# 暂歇

本篇关于DataBindin的介绍也就到此结束，不过DataBinding的使用还没有到头，下一篇将会侧重实际上的操作以及DataBinding还可以为我们带来哪些便捷.



---

# 未完待续


























