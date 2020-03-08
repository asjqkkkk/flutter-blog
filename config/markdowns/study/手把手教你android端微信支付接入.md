---
title: 手把手教你android端微信支付接入
date: 2018-10-08 21:49:47
index_img: /img/wechat_pay.png
tags: Android
---

## Android端接入微信支付，蛮简单的


### 一、添加gradle依赖：

在app module目录下的build.gralde中添加

```
dependencies {
    //微信SDK接入
    implementation 'com.tencent.mm.opensdk:wechat-sdk-android-with-mta:+'
}
```
gralde构建完成之后，再做下一步的操作。

### 二、在AndroidManifest.xml中添加相关权限：

```
    <!--微信支付权限-->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### 三、创建wxapi目录，并创建WXPayEntryActivity

在你的package目录下，创建**wxapi**目录，比如说我使用的demo项目，**wxapi**就在目录**net.sourceforge.simcpux**目录下

同时，在**wxapi**目录下创建**WXPayEntryActivity**

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-001.png)

**WXPayEntryActivity**实现**IWXAPIEventHandler**接口，这个Activity页面就是支付结果的回调页面，下面是它最简单地实现：
```
public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
	
	private static final String TAG = "MicroMsg.SDKSample.WXPayEntryActivity";
	
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.pay_result);
        
    	api = WXAPIFactory.createWXAPI(this, "你的appid");
        api.handleIntent(getIntent(), this);
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {
	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d(TAG, "onPayFinish, errCode = " + resp.errCode);

		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle("支付结果");
			builder.setMessage(getString(R.string.pay_result_callback_msg, String.valueOf(resp.errCode)));
			builder.show();
		}
	}
}
```
同时，别忘了在**AndroidManifest.xml**中声名**WXPayEntryActivity**


```
        <activity
            android:name=".wxapi.WXPayEntryActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <data android:scheme="你的appid"/>
            </intent-filter>

        </activity>
```

当这些准备工作都做好之后，就可以准备使用了。

### 四、使用

当你从服务端获取到订单的相关信息后，就可以调用支付接口了：
```
                IWXAPI api = WXAPIFactory.createWXAPI(context, null);
                api.registerApp(IntentKey.WX_APP_ID);
                PayReq req = new PayReq();
                req.appId			= "wx8888888888888888";//你的微信appid
                req.partnerId		= "1900000109";//商户号
                req.prepayId		= "WX1217752501201407033233368018";//预支付交易会话ID
                req.nonceStr		= "5K8264ILTKCH16CQ2502SI8ZNMTM67VS";//随机字符串
                req.timeStamp		= "1412000000";//时间戳
                req.packageValue	= "Sign=WXPay";扩展字段,这里固定填写Sign=WXPay
                req.sign			= "C380BEC2BFD727A4B6845133519F3AD6";//签名
//				req.extData			= "app data"; // optional
                // 在支付之前，如果应用没有注册到微信，应该先调用IWXMsg.registerApp将应用注册到微信
                api.sendReq(req);
```

这里需要注意的是，上面的这些信息，都应该从服务器去获取，比如说随机字符串之类的长短也不一定和上面例子中的一致。具体是什么，得看你们的后端给的是什么。

不出意外的话，通过上面接口的调用，你就可以正常使用微信提供的APP支付了。

是不是非常简单？！

***然鹅。。。***

事情哪儿有这么顺利，到了真正使用的时候，遇到的问题可不少，下面会列举出遇到过的问题，然后说明解决办法。


## Android端接入微信支付，坑蛮多的

**微信支付app的接入，要我来说，对初次尝试的人非常不友好**

一般情况下，开发者使用新的工具都需要先看一看它的说明文档，如果说明文档写的够好，直接用就是了；如果文档介绍的不够全面，还需要有Demo提供参考。微信的App支付就属于后者。
下面是它的接入文档页面：

[Android接入指南](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=1417751808&token=&lang=zh_CN)（还有其他相关信息也可以通过这个页面接入）

由于仅仅靠着文档的说明不足以让我掌握对微信支付的使用，所以自然而然的，Demo就成了初次接触微信支付者的学习教材啦！

[Demo下载](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=11_1)

当你接入Demo后，一系列的问题将会接踵而至，下面来看一看具体是什么问题

### 接入Demo

将下载后的Demo按照Import moudule的方式接入到某个项目中：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-002.png)

然后选中这个项目，进行编译：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-003.png)

接下来，编译器就开始报错了，找到报错的位置，发现是如下问题：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-004.png)

**到这里开始，我就要吐槽了**

这种问题一看就是找不到包了，于是我们看一下这个项目中的build.gralde中的依赖，如下
```
dependencies {
    compile files('libs/libammsdk.jar')
    compile files('libs/wechat-sdk-android-with-mta-1.0.2.jar')
}

```
很显然，是导入的本地jar包，为了方便起见，我们将这里的依赖修改成之前配置时的：

```
dependencies {
    //微信SDK接入
    implementation 'com.tencent.mm.opensdk:wechat-sdk-android-with-mta:+'
}
```
同时，我们还可以发现，重新构建完项目后，上面的问题并没有解决。

这时候我们在Android studio的中的**External Libraries**去看一看新构建的库:

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-005.png)

可以看到，正确的引用路径应该是把**sdk**换成**opensdk**

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-006.png)

当你将所有的路径都修改过来后，还会有如下问题：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-007.png)

将上面的 **imgObj.imageUrl = url** 修改为：

```
imgObj.setImagePath(url);
```
这个错误出现的地方有两处吧，当你把这些错误都解决后，再次进行编译，就可以正常运行啦！

Demo运行后的界面是这样的：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-008.png)

到了这里，基本上就可以进行测试了，剩下的东西无需再多说，过程差不多和上面直接接入的流程一样，不过要demo里面的更加详细，只需多多观摩即可。

那么，最后还是说一下需要注意的点吧。

### 注意事项

在微信开放平台上面设置app相关参数的时候，需要**应用包名**以及**应用签名**

![image](https://pay.weixin.qq.com/wiki/doc/api/img/chapter8_5_2.png)

获取应用签名的工具地址是：[签名工具下载地址](https://open.weixin.qq.com/zh_CN/htmledition/res/dev/download/sdk/Gen_Signature_Android.apk)

> 这里又要吐槽一下，签名工具就是一个apk，装到手机上后，输入包名，然后生成签名，最关键的是这个签名无法复制，使用下来就一个感受，不方便啊！！！！

签名工具里面输入的包名就是之前提到过的，可以直接在Androidmanifest.xml中复制。

**但是**

    尽管包名一样，release版的项目和debug版的项目最后生成的签名都是不一样的，这点很重要！
    
**所以如果你是用的debug进行测试，那么网站里面的签名一定要填写debug版下获取到的签名，正式发布的时候，要把它换成release版的！如果签名不一致，你是无法通过那个“-1”返回值获取到任何有效的错误信息的!切记！**


<font face="STCAIYUN">~~~~~~~~~~~~~~~~~~~~~~~~~~~~~那么</font>

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/%E5%BE%AE%E4%BF%A1%E6%94%AF%E4%BB%98%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B/wxpay-009.png)