---
title: Android开发者编写自己的API接口：从零开始（一）
date: 2018-08-05 21:49:47
index_img: /img/api_1.png
tags: Android
---

## 序

作为一名Android开发人员，想要实现对一些数据的操作和展示，可以通过一些提供Api接口的网站去获取，虽然Api市场上种类繁多，不过别人提供的接口未必就是自己想要的，到最后，还是得自己去实现Api接口。

毕竟，最了解自己需求的人，还得是自己。

## 准备

很多小伙伴应该都会有着类似的需求，不过想去做的时候，常常无从下手。

所以这里做了一个整合，关于如何搭建开发环境，以及所需工具的下载等。


参考文章：

- [Android程序员搭建一个属于自己的服务器，不再求各种公共API](https://www.jianshu.com/p/4a0d40806ea2)
- [JAVA后台搭建(springboot+mybatis+mysql)项目搭建](https://www.jianshu.com/p/f91ca5814bcf)

## 步骤

一套开发环境下来，需要下面这些步骤：

- 1：搭建开发环境，IntelliJ + spring-boot + mybatis
- 2：搭建数据库，mysql + navicat
- 3：搭建运行环境，tomcat + 腾讯云（或者阿里云）


## 开始

### 一、搭建开发环境


#### 1.1 IntelliJ IDEA的安装

Android开发者所使用的Android studio是基于这个IDEA开发的，所以两者的界面非常非常相似。

而且现在比较流行的Android开发语言Kotlin也是由IntelliJ IDEA的开发公司JetBrains所开发的。

##### 下载 IntelliJ IDEA

首先，下载安装包——[【IntelliJ下载地址】](https://www.jetbrains.com/idea/download/#section=windows)

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001.png)

##### 安装 IntelliJ IDEA

下载完成后，就开始安装了

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-001.png)

Next到下面的界面，可以自行选择

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-002.png)


然后一直下一步，到可以运行IDEA，然后你应该会遇到需要购买的提示，破解的教程请看：

[Windows7下安装与破解IntelliJ IDEA2017](https://blog.csdn.net/yangying496875002/article/details/73603303)

win10也是适用的。


#### 1.2 MySQL的安装

##### 下载MySQL

这里使用的是mysql-5.7.17.msi，下载地址是：

[MYSQL下载地址](https://downloads.mysql.com/archives/installer/)


##### 安装MySQL

下载完成后进行安装：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-006.png)

这里只选择了Server

然后一直下一步

到了设置密码这里，我设置的密码是【oldchen】,后面项目配置的密码也是这个，这里你可以随便设置自己的密码，不过后面配置的时候要保证密码输入一致就是：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-007.png)


然后一直下一步，直到安装成功，接下来就是如何去操作数据库。


#### 1.3 Navicat的安装

Navicat用来对数据库进行操作，也是需要付费购买的，破解地址：
[Navicat for MySQL 安装和破解（完美）](https://blog.csdn.net/wypersist/article/details/79834490)


可以使用之后，来到如下界面：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-008.png)

然后创建MYSQL连接：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-009.png)

输入相关信息：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-010.png)

然后就可以看到创建的连接了，右键→新建数据库：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-011.png)


新建的数据库名字设置为oldchen,接下来双击这个数据库，新建一个user表,表中包含account,password,username以及自增主键id，具体操作如图所示：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/gif/001.gif)


创建这个表后，我们可以添加一条数据：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-012.png)


然后，开始配置IntelliJ IDEA

#### 1.4 IntelliJ IDEA的配置


##### 搭建SpringBoot项目

打开IntelliJ，左上角 File → New → Project，创建新项目：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-013.png)


然后

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-004.png)


接下来是选择依赖的界面，选中图中的全部依赖

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-005.png)

下一步
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-019.png)


开始项目构建，需要等待一定的时间，构建完成后的项目结构是这样的：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-015.png)


结合之前新建的数据库，在resources目录下的application.properties中进行配置：


```
#oldchen为创建的数据库名字
spring.datasource.url =jdbc:mysql://localhost:3306/oldchen
mybatis.type-aliases-package = com.example.demo
# 数据库用户名
spring.datasource.username = root
# 数据库密码
spring.datasource.password = oldchen

spring.datasource.driver-class-name=com.mysql.jdbc.Driver

#端口号
spring.session.store-type=none
spring.http.encoding.charset=UTF-8
```

接下来就开始写接口啦


#### 1.5 接口的编写


由于我们之前在操作名为【oldchen】的数据库时，还新建了一个【user】表，所以这里先创建一个User类：


```
public class User {
    private Integer id;
    private String account;
    private String password;
    private String userName;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
}
```


然后创建UserMapper，用于查询（根据字段account查询）


```
@Mapper
public interface UserMapper {

    @Select("select * from user where account = #{account}")
    User findByAccount(String account);

}
```


接着创建UserController，用于对数据的处理：


```
@RestController
@RequestMapping({"/user"})
public class UserController {

    @Autowired
    private UserMapper userMapper;

    @RequestMapping(value="/user")
    @ResponseBody
    public String getUserInfoByName(String account) {
        User user = userMapper.findByAccount(account);
        if (user == null){
            return "用户名保不存在";
        } else {
            return "用户名存在——" + user.getUserName();
        }
    }
}
```


最后项目结构如下：


![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-016.png)


### 二、测试接口

首先，运行项目

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-017.png)


当项目正常运行后，测试下面的地址：

http://localhost:8080/user/user?account=oldchen

结果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Android%E5%BC%80%E5%8F%91%E8%80%85%E7%BC%96%E5%86%99%E8%87%AA%E5%B7%B1%E7%9A%84API%E6%8E%A5%E5%8F%A3%EF%BC%9A%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%EF%BC%88%E4%B8%80%EF%BC%89/001-018.png)

测试成功啦！


## 后续


关于Api接口的学习，先到这里。

后面还会写关于如何将项目放在TomCat上，最后放在云服务器上，通过外网地址访问接口

那么，未完待续...



![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E8%A1%A8%E6%83%85%E5%8C%85/%E5%91%8A%E8%BE%9E.jpg)




