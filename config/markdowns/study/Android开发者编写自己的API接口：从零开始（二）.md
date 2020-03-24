---
title: Android开发者编写自己的API接口：从零开始（二）
date: 2018-08-14 21:49:47
index_img: /img/api_2.png
tags: Android
---

## 前言



在上一篇[Android开发者编写自己的API接口（上）](https://oldchen.top/2018/08/05/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/)中，已经介绍了如何搭建一个基本的开发环境，以及接口的编写，最后是能够成功运行的。

这一篇将更进一步，主要解决下面两个问题：

- ①：如何让后台项目运行在TomCat上
- ②：如何在云服务器上部署自己的项目
    
## Start

#### 一、本地Tomcat的使用

##### 1.1、安装Tomcat
使用TomCat，自然是要TomCat的安装包咯

[安装包下载地址](https://tomcat.apache.org/download-90.cgi)

![image](
https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/001.png)

由于我们本地应该都是已经安装配置过JDK了的，所以安装Tomcat的时候一路Next就行了


##### 1.2、配置Gradle
首先，在项目的gradle所在的目录下创建gradle.properties，然后在里面添加：
```
# true就去打包War，否则不打包
BUILD_WAR=true
```
![image](
https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/002.png)

接着在build.gradle中添加：


```
if (BUILD_WAR.toBoolean()) {
    apply plugin: 'war'
}

dependencies {
    ...
    if (BUILD_WAR.toBoolean()) {
        providedRuntime('org.springframework.boot:spring-boot-starter-tomcat')
    }
}
```
![image](
https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/003.png)

同时，不要忘了创建一个ServletInitializer类，用于SpringBoot的初始化

```
public class ServletInitializer extends SpringBootServletInitializer {

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		return application.sources(TestForDemoApplication.class);
	}

}
```

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/008.png)


这些都完成后，在Terminal控制台输入：

```
gradlew assemble
```

等待结果，然后就可以看到一个war包了

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/004.png)

##### 1.3、配置Tomcat

找到demo-0.0.1-SNAPSHOT.war所在目录，然后将其更名为oldchen.war

    注意，这里修改后的名字将会与部署到Tomcat上的网络请求地址有关哦

![image](
https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/005.png)

然后找到Tomcat的安装目录下的webapps目录，将里面的其他文件和文件夹删除，把oldchen.war复制到该目录

接下来，在Tomcat目录下的bin目录中运行Tomcat9w.exe

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/006.png)

然后你会发现，webapps目录下多了一个文件

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/007.png)


##### 1.4、测试本地Tomcat

接下来，访问地址：

http://localhost:8080/oldchen/user/user?account=oldchen

结果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/009.png)

可以看到，本地的Tomcat已经部署成功，接下来就是云服务器上部署Tomcat了。


#### 二、云服务器上Tomcat的部署

##### 2.1、购买云服务器

想在云服务器上部署Tomcat，首先需要购买一个服务器，我买的是腾讯云的服务器，初次接触的同学建议去使用试用的云服务器，等操作成功后再买也不迟


出于对初学者的人文关怀（没错，Is me），这里我使用的是Windows版的服务器：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/010.png)


为了能够正常访问服务器的地址，需要给服务器配置一下安全组，安全组中需要添加这样一项规则：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/011.png)

然后，使用远程连接，连接到云服务器，具体操作是：
    
    一、win+R
    二、输入mstsc
    三、输入云服务器的Ip地址，用户名以及密码，连接

如果你使用的是windows2016版的服务器，同时遇到了"身份验证错误，要求的函数不支持"，而且你恰好是win10家庭版，那么下面有解决办法：
[windows10家庭版 远程桌面报错](https://jingyan.baidu.com/album/67508eb47ae5499ccb1ce410.html?picindex=3)


成功登录后，整个界面只有一个孤伶伶的回收站，到了这步，就准备开始配置吧。


##### 2.2、配置云服务器

云服务器上面运行项目只需要Tomcat+Mysql+Navicat+JDK，配置方法和之前在本地配置是一样的，不过这里不建议使用上传的方法，因为上传实际上和下载是一样的，有时候还会受限于你自己宽带的上行速度。



重新下载安装JDK是很头疼的，下面是详细教程：

[非常详细图文JDK和Tomcat安装和配置的图文教程](https://blog.csdn.net/qq_32519693/article/details/71330930)


全部需要准备的文件如下：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/012.png)

其中，**PatchNavicat** 用于Navicat的破解，在上一篇的链接中已经说明。

而**oldchen.sql**则是通过本地Navicat生成Mysql文件，具体操作是：右键你选中的数据库，选择【转储SQL文件】→【结构和数据】，然后就可以生成了。使用方法就是在云服务器上创建一个数据库后选择【运行SQL文件】即可。

这样，本地数据库的迁移就完成了。剩下的操作与之前介绍的基本一致，不过有一点需要注意，为了开启外网连接，需要在Tomcat安装目录下找到conf目录，修改其中的server.xml文件：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/013.png)

将port由8080修改为80

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/014.png)


当你完成全部的操作后，就可以测试接口了。

##### 2.3、测试云服务器接口


只要你的步骤是ok的，那么云服务器不会有什么问题。

由于在写这篇文章期间，我又多写了个登录接口，所以这里的测试例子用的是新的接口，仅供参考：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%BA%8C%EF%BC%89/015.png)


请求地址是：http://111.230.251.115/oldchen/user/login



## 后语

那么，编写接口的学习就到此为止了。

虽然有待完善的地方还不少，比如通过数据库指令对数据库进行增删改查、数据库之间相互关联等等，许多知识都需要慢慢学的。

此文章权当入门之径，剩下的还得靠大家自己多多钻研啦，毕竟作者本人需要学的地方也太多了，如有错误之处，还望指出，互相学习，岂不乐哉。

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%A1%A8%E6%83%85%E5%8C%85/%E5%91%8A%E8%BE%9E2.jpg)





