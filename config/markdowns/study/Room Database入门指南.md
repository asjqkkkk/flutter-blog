---
title: Room Database入门指南
date: 2018-10-30 21:49:47
index_img: /img/room_database.png
tags: Android
---

说到Android端有哪些可以使用的数据库，大家首先想到的自然是SQLite这种带有官方属性加持的轻型的数据库。

不过对于像我这种基本上没有接触过SQL数据库语言编写的人来说，要通过去写难以查错且又毫不熟悉的数据库代码才能操作数据库的话，那就太令人头大了。

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/001-001.jpg)

于是乎，便于Android开发者操作数据库的框架也就多了起来，其中人气较高的就有GreenDao、Realm，ObjectBox等，而Room则是谷歌官方十分推荐的，可以代替SQlite的不二之选。

本篇的主要介绍对象也是Room数据库，不过在此之前，还得简单介绍一下上面提到过的其他几位，同时做个小小的对比。

# 一、介绍与比较


由于我用过的数据库框架并不多，所以对于用过的可以说一下感受，没用过的就简单带过了。

## 介绍

### GreenDao 和 ObjectBox 

在这些数据库中， **GreenDao** 算是早闻其名，不过一直没有用过，后来它的作者又出了个 **ObjectBox** ，而且你可以在 [**GreenDao**的GitHub页面](https://github.com/greenrobot/greenDAO) 找到推荐使用 **ObjectBox** 的 [ObjectBox地址](https://objectbox.io/) .

### Realm

我真正使用过的还只有 **Realm** 数据库，这里要提一下，**Realm** 数据库对于中国的开发者非常的友好，就像大名鼎鼎的Glide一样， **Realm** 也有中文的介绍文档，文档地址在此：  
[开始使用Realm](https://realm.io/cn/docs/java/latest/)  
虽然这份文档对应的版本不是最新的. 不过对于初次接触 **Realm** 人来说，看这份文档就可以上手了

最开始使用Realm的时候也是碰过不少坑，不过最主要的是所有数据库对象需要继承 **RealmObject** 这个类(也可以通过接口实现)，这样对项目已有的数据结构不太友好，同时我还发现继承了 **RealmObject** 的对象并不能与 **Gson** 完美结合，如果需要转换的话，还是得费一番周折的。
种种原因，导致我最后从项目中抽去了Realm这个数据库.

### Room

与 Realm 分手后的日子里，我并没有放弃对新的数据库的寻找，后来在浏览 Google官方文档的时候才发现了 **Room** 这个新的数据库，经过我一番使用后，就决定是它了！
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/001-002.jpg)


## 比较

因为懒惰的原因，我并没有做过深入的测试，下面会给出从网上找到的关于这些数据库的对比，原文地址如下：

[**Realm, ObjectBox or Room. Which one is for you?**](https://notes.devlabs.bg/realm-objectbox-or-room-which-one-is-for-you-3a552234fd6e)

然后是数据量达到 **100k/10k** 的时候，进行增删改查等操作消耗的时间对比：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/001.jpeg)
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/002.jpeg)


![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/003.jpeg)
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/004.jpeg)

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/005.jpeg)
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/006.jpeg)

可以看到，在各个方面，统统都是 **ObjectBox** 傲视群雄。  
那这篇文章为什么还是要写介绍关于 **Room Database** 呢？

首先是官方Buff加持，和介绍文档里的一句话：  
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/007.png)  
[这里是Room的官方介绍文档地址](https://developer.android.google.cn/training/data-storage/room/)

大致意思就是：**我们强烈建议你用Roon去代替SQLite，不过如果你是个铁头娃非得用SQLite，那我们也没有办法。**

除了上面这段话，还有一点也可以作为选择Room的原因，就是对于Apk的“增量”是多少。据别人的测试

> ObjectBox和Realm分别占用1-1.5MB和3-4MB（大小取决于手机架构），而作为SQL封装的Room只占用大约50KB。在方法的增量上，Room只有300多个，ObjectBox和Realm则分别是1300和2000个


当然，如果你的数据量很大的话，我觉得还是 **ObjectBox** 更加适合你，因为就从上面的操作数据对比来看， **ObjectBox** 太牛逼了！我以后肯定也会花时间去对 **ObjectBox** 做一番研究，不过目前还是先来介绍介绍 **Room** 吧。


# 二、Room的结构

之前有说过，**Room** 是可以代替 **SQLite** 的，不过我觉得Google推出它更多的是为了搭配 **DataBinding** 使用，如果你对于 **DataBinding** 不太熟悉，可以看一看我前面的关于 **DataBinding** 的文章，这里就不再赘述了。下面就开始说说 **Room** 的结构。

Room主要分为三个部分，分别是 **Database**(数据库) 、**Entity**(实体) 、**DAO**(数据访问对象) 

## Database(数据库)

数据库指的就是一个数据库对象，它继承于 **RoomDataBase** 这个类，并且需要用 **@DataBase** 注解，获取这个数据库对象的方法是通过调用 **Room.databaseBuilder()** 或者 **Room.inMemoryDatabaseBuilder()** ，后者表示在内存中存储数据，如果程序结束了数据也就消失了，所以一般还是使用前者。

## Entity(实体)

实体的概念就比较简单了，就类似于MySQL数据库里面的表，一个实体类相当于一个表，而一个实体类有多个属性，就相当于表的多个字段，这个看一看接下来关于 **Entity** 的代码便一目了然。

## DAO

关于 **DAO** ，抽象的概念就表示**数据访问对象**，在这里简单的解释一下就是数据操作接口，可以通过编写 **DAO接口** 对数据库进行增删改查等一系列操作。  
> PS:这些接口可以支持RxJava的哦！

下面是图片说明：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/009.png)

# 三、开始使用

在 **Room** 的使用过程中，也是遇到一些坑的，不过都已经解决掉了。如果你也遇到过某些问题，不妨对照一下我的接入流程，说不定就找到了问题所在。

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/008.png)

## 接入Gradle

为了避免之后的单元测试出现 <font color="#DC143C">java.lang.RuntimeException: Method e in android.util.Log not mocked. See http://g.co/androidstudio/not-mocked for details.</font> 的错误，除了 **Room** 相关的依赖需要添加外，这里还需要再引用一下 **robolectric单元测试库** 解决问题！

```
    //room数据库
    def room_version = "1.1.1"
    implementation "android.arch.persistence.room:runtime:$room_version"
    annotationProcessor "android.arch.persistence.room:compiler:$room_version"
    kapt "android.arch.persistence.room:compiler:$room_version"      // 由于要使用Kotlin,这里使用了kapt
    implementation "android.arch.persistence.room:rxjava2:$room_version"        //之后会用到rxjava，所以这里也可以有
//    implementation "android.arch.persistence.room:guava:$room_version"        //由于我们不用guava，这行注释掉
    testImplementation "android.arch.persistence.room:testing:$room_version" 
    
    //robolectric测试
    testImplementation 'org.robolectric:shadows-multidex:3.8'
    testImplementation "org.robolectric:robolectric:3.8"
    //这样就资瓷单元测试咯！
```

和我一样使用Kotlin的童鞋别忘了下面这行：

```
apply plugin: 'kotlin-kapt'
```
还有，需要做如下更改：

```
    androidTestImplementation 'com.android.support.test:runner:1.0.2'

    //更改为
    implementation 'com.android.support.test:runner:1.0.2'

```
这点一定要改哦！不然会出现一些莫名其妙的问题




相关库的依赖成功添加后就可以开始动手了！

## 创建 Entity、Dao 与 DataBase

### 创建Entity

首先，创建一个 **Entity** 对象，就把它命名为 **Book** 吧


```
@Entity
class Book(@field:ColumnInfo(name = "book_name")
           var bookName: String?, var author: String?, var type: String?) {

    @PrimaryKey(autoGenerate = true)
    var id: Int = 0
}
```
**Book** 有三个属性，分别表示书名、作者、类型。其中有三点需要注意：

- 每个 **Entity对象** 都需要使用 **@Entity** 注释声明
- **@PrimaryKey** 注释用于声明主键，这里还添加了 autoGenerate = true，表示它是自增的
- **@ColumnInfo** 注释用来给属性设置别名，如果 **bookName** 属性不设置别名的话，查询的时候可以通过 “**bookName**”进行查询，设置别名后就可以通过设置的“**book_name**” 进行查询了，看 **DAO接口** 便知



### 创建 DAO 

这里，通过 **DAO接口** 来对 **Book** 这个对象进行增删改查：

```
@Dao
interface BookDao {

    @get:Query("SELECT * FROM book")
    val all: List<Book>

    @Query("SELECT * FROM book WHERE author LIKE :author")
    fun getBookByAuthor(author: String): List<Book>

    @Query("SELECT * FROM book WHERE book_name LIKE :name")
    fun getBookByNamer(name: String): List<Book>

    @Insert
    fun insert(book: Book): Long?

    @Insert
    fun insert(vararg books: Book): List<Long>

    @Insert
    fun insert(books: List<Book>): List<Long>

    @Update
    fun update(book: Book): Int

    @Update
    fun update(vararg books: Book): Int

    @Update
    fun update(books: List<Book>): Int

    @Delete
    fun delete(book: Book): Int

    @Delete
    fun delete(vararg books: Book): Int

    @Delete
    fun delete(books: List<Book>): Int

}
```

上面的 **DAO接口**，同样需要进行几点说明：

- **DAO接口** 需要使用 **@Dao** 注释进行声明
- **Insert** 操作可以使用 **Long** 作为返回值的类型，表示插入操作前的对象数量
- **Update** 和 **Delete** 操作可以使用 Int 作为返回值，表示更新或者删除的行数
- 返回类型还可以是 **void** ，如果结合 **Rxjava** 使用的话还可以是 **Completable、Single、 Maybe、Flowable**等，具体可以参见这篇文章：[Room 🔗 RxJava](https://medium.com/androiddevelopers/room-rxjava-acb0cd4f3757)(需要备好梯子，不过后续有时间的话我也会介绍一下Room搭配Rxjava的使用)

**Dao接口** 编写完成后，还剩下最重要的 **DataBase**

### 创建 DataBase

> 由于实例化一个 **RoomDatabase** 对象的开销是比较大的，所以 **DataBase** 的使用需要遵循单例模式，只在全局创建一个实例即可。

这里为了方便理解，还是使用java代码去创建一个 **BookDataBase类**，当然，转换成Kotlin只需要Shift + Alt + Ctrl + K 即可

如果你使用的是饿汉式的单例模式，在Kotlin中通过object修饰可达到同样效果
```
@Database(entities = {Book.class}, version = 1)
public abstract class BookDataBase extends RoomDatabase {
    public abstract BookDao bookDao();
    private static BookDataBase instance;

    public static BookDataBase getInstance(Context context){
        if (instance == null){
            synchronized (BookDataBase.class){
                if (instance == null){
                    instance = create(context);
                }
            }
        }
        return instance;
    }

    private static BookDataBase create(Context context) {
        return Room.databaseBuilder( context,BookDataBase.class,"book-db").allowMainThreadQueries().build();
    }
}
```

上面的例子中有一些需要特别注意：

- **@Database** 注释用于进行声明，同时还需要有相关的 **entity对象**，其中 **version** 是当前数据库的版本号，如果你对数据相关的**实体类结构**进行了更改，这里的 **version** 就需要**加一**
- **BookDataBase** 除了继承于 **RoomDatabase** ，还需要实例出相关的 **DAO接口**
- create()方法中的"**book-db**"是数据库的名字，这里随意，不过需要注意的是 **allowMainThreadQueries()** 方法，这里由于我们会用到单元测试，所以加上这行代码是为了防止 【*Cannot access database on the main thread since it may potentially lock the UI for a long period of time.*】 的报错。正式使用时，请务必去掉这行代码，因为它会让所有耗时操作运行在主线程！

到这里，我们就可以先愉快的进行测试了.



## 测试

### 初级测试

找到 **src** 下的 **test** 目录，然后可以像我这样创建一个 **RoomTest** 类进行测试

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/010.png)

说到这里，可能会有童鞋尚未了解过单元测试，这时候你可以先去看看相关博客，比如这篇

[Android 单元测试只看这一篇就够了](https://juejin.im/post/5b57e3fbf265da0f47352618)

不过这里使用的单元测试是 Android Studio 自带的，也没有用到太复杂的东西，同时我会做一些说明，不够了解的童鞋也可以继续往下看，看完你也就了解了


```
@RunWith(AndroidJUnit4::class)
class RoomTest {

    private var bookDao: BookDao? = null
    private var bookDataBase: BookDataBase? = null

    @Before
    @Throws(Exception::class)
    fun setUp() {
        ShadowLog.stream = System.out      //这样方便打印日志
        val context = InstrumentationRegistry.getTargetContext()
        bookDataBase = BookDataBase.getInstance(context)
        bookDao = bookDataBase?.bookDao()
    }


    @Test
    fun insert() {
        val book1 = Book("时间简史", "斯蒂芬·威廉·霍金", "科学")
        val book2 = Book("百年孤独", "西亚·马尔克斯", "文学")
        val list = bookDao?.insert(book1, book2)

        assert(list?.size == 2)
    }

    @Test
    fun query(){
        val books = bookDao?.all
        for (book in books?: emptyList()) {
            Log.e(javaClass.name, "获取的书籍数据: ${Gson().toJson(book)}")
        }
    }

    @After
    @Throws(Exception::class)
    fun cloaseDb() {
        bookDataBase?.close()
    }
}
```

可以看到，这里的单元测试使用的是 **AndroidJUnit4**，通过 **@Before** 注释的方法，表示用于**相关资源的初始化**，类似于Activity的onCreate()方法；而通过 **@After** 注释的方法，则是用于**相关资源的销毁**，类似于Activity的onDestroy()方法。

剩下的，通过 **@Test** 注释的方法就表示用于测试的单元，每个测试类里面可以有多个测试单元，这里目前只写了插入和查询两个单元，在 **RoomTest** 类上通过右键运行，然后看一下结果：
![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/011.png)

在测试代码中的 **insert()单元 ** 里，有这样一行代码：

```
assert(list.size == 2)
```
而测试的结果是一片绿色，就表示这个断言是正确的，list列表长度刚好为2，这里为了验证返回的list是整个数据库长度还是仅仅表示此次进行插入操作的长度，我们修改一下 insert()测试单元：

```
   @Test
    fun insert() {
        val book1 = Book("时间简史", "斯蒂芬·威廉·霍金", "科学")
        val book2 = Book("百年孤独", "西亚·马尔克斯", "文学")
        val list = bookDao?.insert(book1, book2)
        assert(list?.size == 2)

        val list2 = bookDao?.insert(book1, book2)
        assert(list2?.size == 4)
    }
```

这时候在 **insert()单元测试区域** 右键运行，就只测试这一个单元，然后结果如下：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/012.png)

我们在 insert()单元 中进行了两次插入操作，所以数据库的总长度应该为 4 ，而这里第39行的代码：

```
assert(list2?.size == 4)
```
返回的cede 是 -1，就表示实际上每次插入操作返回的列表长度应该为插入的数量，而非数据库总量。其他操作亦是如此。

在单元测试中，我们的测试并不能直接用于正式的项目中，因为数据库操作属于耗时操作，所以一定不能把这些操作放在主线程里，而最方便的线程切换，莫过于 **Rxjava** 啦！

现在开始使用 **Rxjava** 进行测试吧

### 结合Rxjava的测试

首先，要在项目中添加 **Rxjava** 的依赖：

```
    //rxJava2+rxAndroid
    implementation "io.reactivex.rxjava2:rxjava:2.x.y"
    implementation 'io.reactivex.rxjava2:rxandroid:2.1.0'
```

在单元测试中，RxJava 如果做 **IO线程** 到 **UI线程** 的切换操作，结果是无法获取的，所以需要将这些线程进行合并，方法如下：

```
    @Before
    @Throws(Exception::class)
    fun setUp() {
        val context = InstrumentationRegistry.getTargetContext()
        bookDataBase = BookDataBase.getInstance(context)
        bookDao = bookDataBase?.bookDao()
        ShadowLog.stream = System.out

        initRxJava2()
    }
    
    private fun initRxJava2() {
        RxJavaPlugins.reset()
        RxJavaPlugins.setIoSchedulerHandler { Schedulers.trampoline() }
        RxAndroidPlugins.reset()
        RxAndroidPlugins.setMainThreadSchedulerHandler { Schedulers.trampoline() }
    }
```

在 **@Before注解** 下的 **setUp()** 方法中进行RxJava的配置，然后我们可以把RxJava常用的线程切换写在一个方法里，方便复用：

```
    private fun<T> doWithRxJava(t: T): Observable<T>{
        return Observable.create<T>{it.onNext(t)}
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
    }
```

接着，对 **insert单元** 和 **query单元** 进行修改：

```
    @Test
    fun insert() {
        val book1 = Book("时间简史", "斯蒂芬·威廉·霍金", "科学")
        val book2 = Book("百年孤独", "西亚·马尔克斯", "文学")
        doWithRxJava(bookDao?.insert(book1, book2))
                .subscribe ({
                    Log.e("insert长度：" , "${it?.size}")
                    assert(it?.size == 2)
                },{
                    Log.e("insert出错：" , "${it.stackTrace}-${it.message}")
                })
    }

    @Test
    fun query(){
        doWithRxJava(bookDao?.all)
                .subscribe({
                    for(book in it?: emptyList()){
                        Log.e(javaClass.name, "获取的书籍数据: ${Gson().toJson(book)}")
                        assert(it?.size == 2)
                    }
                },{
                    Log.e("query出错：" , "${it.stackTrace}-${it.message}")
                })
    }
```

然后看一下测试的结果：

![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/013.png)


那么， **Room DataBase** 的入门指南，就写到这里啦！

后续我可能会再写一篇进阶版的文章，涵盖了真实使用的场景，然后看能不能写一个简单的Demo出来，这样更方便学习吧！

~~*不过我发现我现在的懒癌是越来越严重了，也不知道下一篇是什么时候*~~


![image](https://blog-pic-1256696029.cos.ap-guangzhou.myqcloud.com/Room-Database/014.png)










