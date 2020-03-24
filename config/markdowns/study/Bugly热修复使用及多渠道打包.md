---
title: Bugly热修复使用及多渠道打包
date: 2018-09-26 21:49:47
index_img: /img/bugly.png
tags: Android
---

## <font color="#7FFF00">头

不知道你是否遇到过这个情况，项目上线后或者开始给别人使用的时候，冷不丁的冒出个Bug，这时候首先要干嘛？

**先看崩溃日志啊**

看完崩溃日志你知道了造成崩溃的原因，然后干嘛？

**开始甩锅啊**

当查明了是谁造成的这个崩溃后，你发现不是你的问题，于是你心中一乐，长舒一口气，仰天大笑：码海沉浮又几载，我辈岂是蓬蒿人；笑完便准备躺床上睡觉去——秋豆麻袋，是不是忘了什么东西？

是的，即使你发现了问题，并且找到了问题的来源，这时候还差一步：解决问题的办法！如何解决？

**发布新版本？**

这样不觉得很麻烦吗？特别是如果一个项目处于初期阶段，Bug是想甩都甩不掉的，如果每发现一次崩溃，都需要靠发布一个新版本去解决的话，那未免就太麻烦了。不光是开发者麻烦，使用者也会因为频繁的升级而不耐烦（just like me），那问题又回来了，如何解决？

**热修复啊**

通过线上修复Bug，让用户在神不知鬼不觉的情况下就进行了一次应用更新，麻麻再也不用担心App崩溃啦！（不存在的）

热修复还有个隐藏的好处，那就是在测试人员不够（开发兼测试），测试机型不够的情况下可以显著改善App的崩溃率。好吧，准备开始使用吧。

## <font color="#000066">身

### 一、为什么要用Bugly

市面上关于热修复和崩溃日志监测的相关技术和SDK种类各不相同，为什么偏偏要用Bugly呢？

- 可以获取到App崩溃日志
- 可以集成Think热修复
- 界面好看，方便管理版本
- 免费
- （凑巧就用了这一款，其他的都没有用过）

基于以上原因，最后就使用了Bugly去解决上面提到过的问题；

### 二、Bugly热更新接入流程

其实关于Bugly热更新的详细接入流程，官方的文档介绍的非常详细，对新手比较友好，我第一次使用也是直接参照的文档，下面是官方文档的地址：

[【Bugly Android热更新使用指南】](https://bugly.qq.com/docs/user-guide/instruction-manual-android-hotfix/?v=20180709165613)

虽然官方有例子，这里还是写了一个简化版，也方便以后哪天自己忘记了依旧能快速使用：

#### 第一步：添加依赖插件

在你的项目更目录下的“build.gradle”中添加：

```
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        // tinkersupport插件, 其中lastest.release指拉取最新版本，也可以指定明确版本号，例如1.0.4
        classpath "com.tencent.bugly:tinker-support:1.1.2"
    }
}
```
在写这篇文章的时候，最新的版本就是1.1.2

#### 第二步：配置依赖插件

##### gradle配置

在app module的“build.gradle”文件中添加（示例配置）：


```
...
// 依赖插件脚本
apply from: 'tinker-support.gradle'

android {
        defaultConfig {
          ndk {
            //设置支持的SO库架构
            abiFilters 'armeabi' //, 'x86', 'armeabi-v7a', 'x86_64', 'arm64-v8a'
          }
        }
      }
      dependencies {
         implementation 'com.android.support:multidex:1.0.1'
        // 多dex配置
        //注释掉原有bugly的仓库
        //compile 'com.tencent.bugly:crashreport:latest.release'//其中latest.release指代最新版本号，也可以指定明确的版本号，例如1.3.4
        implementation 'com.tencent.bugly:crashreport_upgrade:1.3.5'
        // 指定tinker依赖版本（注：应用升级1.3.5版本起，不再内置tinker）
        implementation 'com.tencent.tinker:tinker-android-lib:1.9.6'
        implementation 'com.tencent.bugly:nativecrashreport:latest.release'
        //其中latest.release指代最新版本号，也可以指定明确的版本号，例如2.2.0
      }
```
在这个版本的SDK里面，已经集成了崩溃日志上传的功能哦！

##### tinker-support.gradle的配置

接下来，你要在app module目录下创建另外一个gradle文件，命名为“tinker-support.gradle”，然后对它进行配置：

```
apply plugin: 'com.tencent.bugly.tinker-support'

def bakPath = file("${buildDir}/bakApk/")

/**
 * 此处填写每次构建生成的基准包目录
 */
def baseApkDir = "app-0921-14-52-06"

/**
 * 对于插件各参数的详细解析请参考
 */
tinkerSupport {

    // 开启tinker-support插件，默认值true
    enable = true

    // 指定归档目录，默认值当前module的子目录tinker
    autoBackupApkDir = "${bakPath}"

    // 是否启用覆盖tinkerPatch配置功能，默认值false
    // 开启后tinkerPatch配置不生效，即无需添加tinkerPatch
    overrideTinkerPatchConfiguration = true

    // 编译补丁包时，必需指定基线版本的apk，默认值为空
    // 如果为空，则表示不是进行补丁包的编译
    // @{link tinkerPatch.oldApk }
    baseApk = "${bakPath}/${baseApkDir}/app-release.apk"

    // 对应tinker插件applyMapping
    baseApkProguardMapping = "${bakPath}/${baseApkDir}/app-release-mapping.txt"

    // 对应tinker插件applyResourceMapping
    baseApkResourceMapping = "${bakPath}/${baseApkDir}/app-release-R.txt"

    // 构建基准包和补丁包都要指定不同的tinkerId，并且必须保证唯一性
    tinkerId = "1.0.1-patch"                //tinkerId = "1.0.1-patch"            tinkerId = "1.0.1-base"

    // 构建多渠道补丁时使用
    // buildAllFlavorsDir = "${bakPath}/${baseApkDir}"

    // 是否启用加固模式，默认为false.(tinker-spport 1.0.7起支持）
    // isProtectedApp = true

    // 是否开启反射Application模式
    enableProxyApplication = false

    // 是否支持新增非export的Activity（注意：设置为true才能修改AndroidManifest文件）
    supportHotplugComponent = true

}

/**
 * 一般来说,我们无需对下面的参数做任何的修改
 * 对于各参数的详细介绍请参考:
 * https://github.com/Tencent/tinker/wiki/Tinker-%E6%8E%A5%E5%85%A5%E6%8C%87%E5%8D%97
 */
tinkerPatch {
    //oldApk ="${bakPath}/${appName}/app-release.apk"
    ignoreWarning = false
    useSign = true
    dex {
        dexMode = "jar"
        pattern = ["classes*.dex"]
        loader = []
    }
    lib {
        pattern = ["lib/*/*.so"]
    }

    res {
        pattern = ["res/*", "r/*", "assets/*", "resources.arsc", "AndroidManifest.xml"]
        ignoreChange = []
        largeModSize = 100
    }

    packageConfig {
    }
    sevenZip {
        zipArtifact = "com.tencent.mm:SevenZip:1.1.10"
//        path = "/usr/local/bin/7za"
    }
    buildConfig {
        keepDexApply = false
        //tinkerId = "1.0.1-base"
        //applyMapping = "${bakPath}/${appName}/app-release-mapping.txt" //  可选，设置mapping文件，建议保持旧apk的proguard混淆方式
        //applyResourceMapping = "${bakPath}/${appName}/app-release-R.txt" // 可选，设置R.txt文件，通过旧apk文件保持ResId的分配
    }
}

```
这里面的配置比较多，一开始看还是有点儿眼花缭乱的，所以得慢慢来；

这里对其中的几点进行说明：

 - *baseApkDir* ： 这里填写每次构建生成的基准包目录，每次打包的时候，都会有新的目录和新的基准包生成，但是只有你打算发布的那一个的目录才是有效的。
 - *tinkerId* ： 构建基准包和补丁包都要指定不同的tinkerId，并且必须保证唯一性。比如你的第一个基准包打包的时候可以把这个id设置为“1.0.0-base”，当你想打包热修复补丁包的时候，需要把这个id换成1.0.0-patch。


更详细的配置项参考：[tinker-support配置说明](https://bugly.qq.com/docs/utility-tools/plugin-gradle-hotfix/)

#### 第三步：初始化SDK


上面的“tinker-support.gradle”中的enableProxyApplication属性设置的是false，是Tinker推荐的接入方式。

##### 自定义Application，当enableProxyApplication为false的情况

```
public class SampleApplication extends TinkerApplication {
    public SampleApplication() {
        super(ShareConstants.TINKER_ENABLE_ALL, "xxx.xxx.SampleApplicationLike",
                "com.tencent.tinker.loader.TinkerLoader", false);
    }
}
```
**SampleApplicationLike**需要是自定义的继承**DefaultApplicationLike**的类，不要忘了在**AndroidManifest.xml**中声名上面的这个Application哦。


```
public class SampleApplicationLike extends DefaultApplicationLike {


    public static final String TAG = "Tinker.SampleApplicationLike";

    public SampleApplicationLike(Application application, int tinkerFlags,
                                 boolean tinkerLoadVerifyFlag, long applicationStartElapsedTime,
                                 long applicationStartMillisTime, Intent tinkerResultIntent) {
        super(application, tinkerFlags, tinkerLoadVerifyFlag, applicationStartElapsedTime, applicationStartMillisTime, tinkerResultIntent);
    }


    @Override
    public void onCreate() {
        super.onCreate();
        // 这里实现SDK初始化，appId替换成你的在Bugly平台申请的appId
        // 调试时，将第三个参数改为true
        Bugly.init(getApplication(), "900029763", false);
    }


    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    @Override
    public void onBaseContextAttached(Context base) {
        super.onBaseContextAttached(base);
        // you must install multiDex whatever tinker is installed!
        MultiDex.install(base);

        // 安装tinker
        // TinkerManager.installTinker(this); 替换成下面Bugly提供的方法
        Beta.installTinker(this);
    }

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    public void registerActivityLifecycleCallback(Application.ActivityLifecycleCallbacks callbacks) {
        getApplication().registerActivityLifecycleCallbacks(callbacks);
    }
}
```

上面需要注意的是在“onCreate()”方法中进行初始化的时候，填入的appId是你在Bugly创建的项目的Appid，其他地方基本上不用改了


##### 自定义Application，当enableProxyApplication为true的情况

这种的接入方式要简单许多，无须你改造Application

```
public class MyApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        // 这里实现SDK初始化，appId替换成你的在Bugly平台申请的appId
        // 调试时，将第三个参数改为true
        Bugly.init(this, "900029763", false);
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // you must install multiDex whatever tinker is installed!
        MultiDex.install(base);


        // 安装tinker
        Beta.installTinker();
    }

}
```

#### 第四步：AndroidManifest.xml配置

##### 1.权限配置：

```
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.READ_LOGS" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
##### 2.Activity配置：

```
<activity
    android:name="com.tencent.bugly.beta.ui.BetaActivity"
    android:configChanges="keyboardHidden|orientation|screenSize|locale"
    android:theme="@android:style/Theme.Translucent" />
```
##### 3.配置FileProvider

    注意：如果您想兼容Android N或者以上的设备，必须要在AndroidManifest.xml文件中配置FileProvider来访问共享路径的文件。


```
        <!--热更新需要的Provider-->
        <provider
            android:name="android.support.v4.content.FileProvider"
            android:authorities="${applicationId}.fileProvider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths"/>
        </provider>
```
在res目录新建xml文件夹，创建provider_paths.xml文件如下：
```
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- /storage/emulated/0/Download/${applicationId}/.beta/apk-->
    <external-path name="beta_external_path" path="Download/"/>
    <!--/storage/emulated/0/Android/data/${applicationId}/files/apk/-->
    <external-path name="beta_external_files_path" path="Android/data/"/>
</paths>
```
#### 第五步：混淆配置

为了避免混淆SDK，在Proguard混淆文件中增加以下配置：
```
-dontwarn com.tencent.bugly.**
-keep public class com.tencent.bugly.**{*;}
# tinker混淆规则
-dontwarn com.tencent.tinker.**
-keep class com.tencent.tinker.** { *; }
```

### 三、打包

当上面的环境配置都没有问题之后，就可以进行打包了。

打包之前，你还得配置一下编译正式版apk所需要的**keystore.jks**文件，这个文件怎么创建的就不介绍了，这里主要介绍一下如何配置：

在app moudle目录下的“build.gradle”中配置：

```
android {
    signingConfigs {
        release {
            keyAlias 'xxxxxxxx'
            keyPassword 'xxxxxxxx'
            storeFile file('../keystore.jks')
            storePassword 'xxxxxxxx'
        }
    }
    ...
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
}
```
其中的各项参数就不必做说明了



然后就是打包过程![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Bugly%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/bugly-001.png)

**打包过程中需要注意之前提到过的tinkerId的配置，以及目录的配置，很重要哦！**

生成的基准包会在这个目录

![image](https://bugly.qq.com/docs/img/hotfix/android/Snip20170209_2.png?v=20180709165613)

生成的补丁包会在这个目录

![image](https://bugly.qq.com/docs/img/hotfix/android/1479216059696.png?v=20180709165613)

然后就准备开始使用吧

### 四、使用

找到你创建的产品，然后进入到下面的界面

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Bugly%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/bugly-002.png)

接着，发布新补丁吧，看一看效果
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Bugly%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/bugly-003.png)

具体的效果可以自行尝试一下，不过有时候你会遇到上传不成功的情况，一般下发后要过5到10分钟才会生效（可能是我的网络问题），如果太久没效果，应该是哪里出问题了

## <font color="#660066">尾

前面的所有操作都尝试过后，接下来你可能就会面临新的需求了。比如说，多渠道打包的实现，比较旧的办法是通过productFlavors去实现分别打包，不过这样会有一个弊端，即有多少渠道打包流程就执行多少次，这样效率显然是不够的；

于是乎，新的打包方案出来了：

### 使用Walle进行多渠道打包

下面是Walle的github地址：

[Walle（瓦力）：Android Signature V2 Scheme签名下的新一代渠道包打包神器](https://github.com/Meituan-Dianping/walle)

它的接入文档写的也十分友好，接下来实际操作一遍：


#### Walle的Gradle接入

在项目根目录的 **build.gradle** 中添加依赖：

```
buildscript {
    dependencies {
        classpath 'com.meituan.android.walle:plugin:1.1.6'
    }
}
```
然后在app module中的 **build.gradle** 添加：

```
apply plugin: 'walle'

dependencies {
    compile 'com.meituan.android.walle:library:1.1.6'
}
```
并进行插件配置

```
walle {
    // 指定渠道包的输出路径
    apkOutputFolder = new File("${project.buildDir}/outputs/channels");
    // 定制渠道包的APK的文件名称
    apkFileNameFormat = '${appName}-${packageName}-${channel}-${buildType}-v${versionName}-${versionCode}-${buildTime}.apk';
    // 渠道配置文件
    channelFile = new File("${project.getProjectDir()}/channel")
}
```
接着在app module目录下创建一个文件，和上面配置中要保持一致，就叫 **channel**
```
360
yingyongbao
baidu
wandoujia
xiaomi
oppo
lenovo
huawei
default_channel
# 打包命令 gradlew clean assembleReleaseChannels  或者 gradlew assembleReleaseChannels
```
最后，在你的Application中的**onCreate**方法里添加：

```
        String channel = WalleChannelReader.getChannel(getApplication());
        Bugly.setAppChannel(getApplication(), channel);
```
如果你实现的是**SampleApplicationLike**，也是在它的**onCreate**方法里添加即可。

接下来通过运行上面的打包命令或者通过图中的手动操作，都是可以打包的

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Bugly%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/bugly-004.png)


## <font color="#dddd00">末

至此，基本上整个配置流程就到此结束!!!

不过有一个问题我一直不知道如何解决，就是打包基准包的命名，在 **tinker-support.gradle** 进行配置是不起效果的，试了好久都没效果，看来还得交给其他小伙伴们解决了



*那么*

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Bugly%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/zaihui.png)
