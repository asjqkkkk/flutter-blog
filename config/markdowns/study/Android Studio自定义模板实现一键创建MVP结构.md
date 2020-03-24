---
title: Android Studio自定义模板实现一键创建MVP结构
date: 2018-12-02 21:49:47
index_img: /img/create_mvp.png
tags: Android
---

# 前言

之前有写过关于如何使用 DataBinding 的两篇文章，不仅仅是为了消灭掉一部分重复代码，更是为了提高开发效率。详情可以点击下方的传送门  
[DataBinding——从路人到好友（一）：初遇](https://oldchen.top/2018/10/17/DataBinding%E2%80%94%E2%80%94%E4%BB%8E%E8%B7%AF%E4%BA%BA%E5%88%B0%E5%A5%BD%E5%8F%8B%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9A%E5%88%9D%E9%81%87/)  
[DataBinding——从相识到相知（二）：互酌](https://oldchen.top/2018/10/20/DataBinding%E2%80%94%E2%80%94%E4%BB%8E%E7%9B%B8%E8%AF%86%E5%88%B0%E7%9B%B8%E7%9F%A5%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9A%E4%BA%92%E9%85%8C/)

<!--more--> 

而这篇文章主要介绍的就是如何通过 Android Studio 提供的模版功能去自定义模版结构，从而实现类似于一键创建整个MVP代码的功能。可以说在提高效率的道路上，又向前走了一大步
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/001.jpg)

下面可以来看一看具体效果：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/002.gif)

# 介绍

在 Android Studio 中，创建一个 Activity 可以直接通过 **File -> New -> Activity** 来进行选择创建

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/003.png)

通过这种方式创建的 Activity 会自动在 AndroidManifest.xml 中完成注册，创建其他组件也可以通过这种方式。

不过，如果你正在使用某种开发模式，譬如 **MVP、MVVM** 等，你每创建一个 Activity 就意味着需要同时创建一系列其他相关的类。

为了避免这种毫无意义的重复性劳动，我们可以编写模板代码去实现一键创建重复代码。

# 开始

下面我们就来开始模版的编写吧。

首先，找到你的 **Android Studio** 的安装目录，然后根据这个目录找到 **...\templates** 目录：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/004.png)

然后进入 **activityes** 目录，我们将要编写的各种模版就在这个目录内：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/005.png)

要说如何去编写模版代码，一开始我也是一无所知的，不过好在 Android Studio 已经为我们提供了这些例子，我们直接参考例子去写。

就拿最简单的 **Empty Activity** 来开始吧

进入到 **EmptyActivity** 目录

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/006.png)

## globals.xml.ftl

打开 **globals.xml.ftl** 文件，下面是它的内容：

```
<?xml version="1.0"?>
<globals>
    <global id="hasNoActionBar" type="boolean" value="false" />
    <global id="parentActivityClass" value="" />
    <global id="simpleLayoutName" value="${layoutName}" />
    <global id="excludeMenu" type="boolean" value="true" />
    <global id="generateActivityTitle" type="boolean" value="false" />
    <#include "../common/common_globals.xml.ftl" />
</globals>

```

根据文件名来看， **globals.xml.ftl** 的作用是用来控制一些全局变量，比如是否显示 **ActionBar** 等，暂且先不用管它

## recipe.xml.ftl

 **recipe.xml.ftl** 文件内容如下：
 
```
<?xml version="1.0"?>
<#import "root://activities/common/kotlin_macros.ftl" as kt>
<recipe>
    <#include "../common/recipe_manifest.xml.ftl" />
    <@kt.addAllKotlinDependencies />

<#if generateLayout>
    <#include "../common/recipe_simple.xml.ftl" />
    <open file="${escapeXmlAttribute(resOut)}/layout/${layoutName}.xml" />
</#if>

    <instantiate from="root/src/app_package/SimpleActivity.${ktOrJavaExt}.ftl"
                   to="${escapeXmlAttribute(srcOut)}/${activityClass}.${ktOrJavaExt}" />
    <open file="${escapeXmlAttribute(srcOut)}/${activityClass}.${ktOrJavaExt}" />

</recipe>

```

第一段

        <#import "root://activities/common/kotlin_macros.ftl" as kt>

就是用于导入Kotlin的相关命令，同时它的别名为 **kt**

主要还是注意 **instantiate** 代码块中的相关信息， 其中 **${ktOrJavaExt}** 表示当你创建模版的时候，创建的 **.java** 文件还是 **.kt** 文件，而相对应的，你需要在编写模版例子的时候分别写上对应的两份 **Java** 与 **Kotlin** 代码

**open** 代码块就是创建模版后，默认打开的文件

# template.xml

**template.xml** 代码略长，这里只是贴出了大致代码

```
<?xml version="1.0"?>
<template
    format="5"
    revision="5"
    name="Empty Activity"
    minApi="9"
    minBuildApi="14"
    description="Creates a new empty activity">

    <category value="Activity" />
    <formfactor value="Mobile" />

    <parameter
        id="activityClass"
        name="Activity Name"
        type="string"
        constraints="class|unique|nonempty"
        suggest="${layoutToActivity(layoutName)}"
        default="MainActivity"
        help="The name of the activity class to create" />
        
        
        ...

    <!-- 128x128 thumbnails relative to template.xml -->
    <thumbs>
        <!-- default thumbnail is required -->
        <thumb>template_blank_activity.png</thumb>
    </thumbs>

    <globals file="globals.xml.ftl" />
    <execute file="recipe.xml.ftl" />

</template>

```
我们挑出其中的重点来说

```
<category value="Activity" />
```
表示当前的这个模版的分类，当前的 **Value** 是 **Activity** ，就表示它会出现在 **File -> New -> Activity** 中，这个是可以自定义的.

```
        <thumbs>
        <!-- default thumbnail is required -->
        <thumb>template_blank_activity.png</thumb>
        </thumbs>
```
**thumbs** 用于指定创建模版时所展示出来的图片

而最重要的，还是 **parameter** 代码块的内容了，在这之中，我们只需要关注以下几个，其他的顾名思义即可。


```
    <parameter
        id="activityClass"
        name="Activity Name"
        type="string"
        constraints="class|unique|nonempty"
        suggest="${layoutToActivity(layoutName)}"
        default="MainActivity"
        help="The name of the activity class to create" />

```
**activityClass** 表示所要创建的 Activity ，其中 **default** 为默认名。


```
    <parameter
        id="generateLayout"
        name="Generate Layout File"
        type="boolean"
        default="true"
        help="If true, a layout file will be generated" />
```
上面的代码块表示是否同时自动创建一个Activity对应的布局


```
  <parameter
        id="layoutName"
        name="Layout Name"
        type="string"
        constraints="layout|unique|nonempty"
        suggest="${activityToLayout(activityClass)}"
        default="activity_main"
        visibility="generateLayout"
        help="The name of the layout to create for the activity" />
```
 **layoutName** 则表示布局的名字，这里的 **suggest** 属性所填写的内容即为布局名，**${activityToLayout(activityClass)}**则为跟随Activity的名字，其中 **activityClass** 是Activity名字的引用
 
 剩下的不用再作说明，基本上可以见名知意。
 
# 模版代码

接下来我们从 **EmptyActivity** 中的 **root** 目录一直进入，直到看到下面两个文件

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/007.png)

可以看到，一个后缀是 **java.ftl** 另外一个后缀是 **kt.ftl**，他们分别用于创建 Java模版与Kotlin模版，如果你暂时不使用Kotlin的话，可以不用去关心 Kotlin模版，当你完成了Java模版的编写，也可以使用 Android Studio自带的转换功能，还是蛮方便的。

下面来看一下Java的模版代码：

```
package ${packageName};

import ${superClassFqcn};
import android.os.Bundle;
<#if (includeCppSupport!false) && generateLayout>
import android.widget.TextView;
</#if>

public class ${activityClass} extends ${superClass} {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
<#if generateLayout>
        setContentView(R.layout.${layoutName});
       <#include "../../../../common/jni_code_usage.java.ftl">
<#elseif includeCppSupport!false>

        // Example of a call to a native method
        android.util.Log.d("${activityClass}", stringFromJNI());
</#if>
    }
<#include "../../../../common/jni_code_snippet.java.ftl">
}

```
- ${packageName}：表示当前包名
- ${activityClass}：表示当前的Activity名字
- ${superClass}：表示继承的Activity，同时为了让这个父类生效，需要在import中加入${superClassFqcn}
- ${layoutName}：当前Activity所对应的布局名

目前我们只需要关注上面这部分，接下来可以看一下我们实际想要创建的MVP结构：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/008.png)

编写模版代码前，最好的方式是先写一遍例子，然后对照例子去替换关键名部分，这样做是最轻松的。

下面就来看一看具体的实现吧：

# 样例代码


## 接口部分：TestActivityContact


```
package com.example.testcustomtemplates.contact;

public interface TestActivityContact {
    interface Presenter<T> {
        void succeed(T t);
        void failed(T t);
        void error(Throwable e);
        void subscribe();
        void unSubscribe();
    }

    interface View<T> {
        void setPresenter(Presenter presenter);
        void succeed(T t);
        void failed(T t);
        void error(Throwable e);
    }
    
    interface Model {
        void setPresenter(Presenter presenter);
    }
}
```
为了方便测试，这里并没有另外创建一些基类接口，可以看到上面代码中分别对应 MVP 结构中三个模块的接口，写的是最基本的需求方法，不过 MVP 也不都是完全一样的，这里你可以定义自己想写的方法。

## Model层：TestActivityModel


```
package com.example.testcustomtemplates.model;

import android.content.Context;
import com.example.testcustomtemplates.contact.TestActivityContact;

public class TestActivityModel implements TestActivityContact.Model {

    private Context context;
    private TestActivityContact.Presenter mPresenter;

    public TestActivityModel(Context context) {
        this.context = context;
    }

    @Override
    public void setPresenter(TestActivityContact.Presenter presenter) {
        this.mPresenter = presenter;
    }
}
```
Model层主要就是做一些网络请求，存储之类的数据相关操作，不可以持有对View的引用，他是通过Presenter去和View进行交互的。

## Presenter层：TestActivityPresenter


```
package com.example.testcustomtemplates.presenter;

import android.content.Context;
import com.example.testcustomtemplates.contact.TestActivityContact;
import com.example.testcustomtemplates.model.TestActivityModel;

public class TestActivityPresenter<T> implements TestActivityContact.Presenter<T> {

    private TestActivityContact.View mView;
    private TestActivityModel mModel;
    private Context context;

    public TestActivityPresenter(TestActivityContact.View mView, Context context) {
        this.mView = mView;
        this.context = context;
        mModel = new TestActivityModel(context);

    }
    @Override
    public void succeed(T t) {

    }
    @Override
    public void failed(T t) {

    }
    @Override
    public void error(Throwable e) {

    }
    @Override
    public void subscribe() {

    }
    @Override
    public void unSubscribe() {

    }
}
```
Presenter层自然不必多说，他最好是不要持有View控件的引用，大部分的逻辑操作需要他来完成，不过不可避免的，如果业务逻辑复杂了，Presenter层也会变得臃肿，这也是MVP结构的一个短处。

## View层：TestActivity

```
package com.example.testcustomtemplates.activity;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import com.example.testcustomtemplates.R;
import com.example.testcustomtemplates.contact.TestActivityContact;
import com.example.testcustomtemplates.presenter.TestActivityPresenter;

public class TestActivity<T> extends AppCompatActivity implements TestActivityContact.View<T> {

    private TestActivityContact.Presenter mPresenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_test);
        new TestActivityPresenter<T>(this, this);
    }

    @Override
    public void setPresenter(TestActivityContact.Presenter presenter) {
        this.mPresenter = presenter;
    }

    @Override
    public void succeed(T t) {

    }

    @Override
    public void failed(T t) {

    }

    @Override
    public void error(Throwable e) {

    }
}

```
Activity或者Fragment都可以用作View层，这层主要是对一些视图控件的状态进行切换，不做复杂的逻辑操作。

看完上面的这些代码后，其实就可以开始直接编写我们的模版代码了。

# 模版编写

首先，可以Copy一份 **EmptyActivity** 整个模版的文件，然后改一下名字，随便什么都可以，这里我将其改成 **MvpDemoActivity**

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/009.png)

然后我们首先对 **template.xml** 文件进行修改，主要修改下面这个部分：


```
<category value="Activity" />
```
然后是对 **recipe.xml.ftl** 文件进行修改，修改后如下：


```
<?xml version="1.0"?>
<#import "root://activities/common/kotlin_macros.ftl" as kt>
<recipe>
    <#include "../common/recipe_manifest.xml.ftl" />
    <@kt.addAllKotlinDependencies />

<#if generateLayout>
    <#include "../common/recipe_simple.xml.ftl" />
    <open file="${escapeXmlAttribute(resOut)}/layout/${layoutName}.xml" />
</#if>

	<!--View-activity-->
    <instantiate from="root/src/app_package/MvpActivity.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/activity/${activityClass}.java" />
	<!--Model-->
	<instantiate from="root/src/app_package/MvpModel.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/model/${activityClass}Model.java" />	
	<!--Contact-->
	<instantiate from="root/src/app_package/MvpContact.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/contact/${activityClass}Contact.java" />
	<!--Presenter-->
	<instantiate from="root/src/app_package/MvpPresenter.java.ftl"
                   to="${escapeXmlAttribute(srcOut)}/presenter/${activityClass}Presenter.java" />	   
    <open file="${escapeXmlAttribute(srcOut)}/activity/${activityClass}.java" />

</recipe>

```

上面的代码表示只编写了Java版，当然你在修改这个文件之前还是需要创建相对应的几个类的模版代码的。这里出于篇幅考虑暂时就不贴出实际的模版代码了，下面会给出github地址，编写了Java版和Kotlin版的，大家可以拿去参考

[Github项目链接](https://github.com/asjqkkkk/TemplatesTest)

当然，有好的模版也可以一起分享一下

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%A8%A1%E6%9D%BF%E5%AE%9E%E7%8E%B0%E4%B8%80%E9%94%AE%E5%88%9B%E5%BB%BAMVP%E7%BB%93%E6%9E%84/010.png)



















