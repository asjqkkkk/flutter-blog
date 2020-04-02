---
title: HashMap源码分析
date: 2020-03-10 23:49:47
index_img: /img/hashmap.png
tags: 源码系列
---


# 序

我到底为什么要分析HashMap的源码呢？

这天是2020年3月9日，进行了一场视频面试，其中面试官问我HashMap结构是什么，因为没看过源码，所以确实不知道。

正好，最近断断续续也刷了不少leecode，对于数据结构方面精进了一些，看看源码好像感觉也还蛮舒服的。于是，就开始看啦！


# 引子

先进入 `HashMap` 的类康一康吧


```
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable{
        ...
    }
```

让我们一步步来

可以看到 `HashMap` 继承于一个抽象类 `AbstractMap<K,V>`

进去看一下 `AbstractMap<K,V>` 的内容吧


# 分析



### AbstractMap<K,V>

我将这个抽象类的代码简化一下：


```
public abstract class AbstractMap<K,V> implements Map<K,V>{
    public abstract Set<Entry<K,V>> entrySet();
    
    
    public boolean containsValue(Object value) {...}
    
    public boolean containsKey(Object value){...}
    
    public V get(Object key) {...}
    
    public V put(K key, V value) {
        throw new UnsupportedOperationException();
    }
    
    public boolean equals(Object o) {...}
    
    public int hashCode() {...}
    
}
```

上面的这些方法，就是我们日常使用中，最主要的一些方法。我们简单的看其中几个

#### containsValue(Object value)


```
    public boolean containsValue(Object value) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        if (value==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getValue()==null)
                    return true;
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (value.equals(e.getValue()))
                    return true;
            }
        }
        return false;
    }
```

`containsValue(Object value)` 用于判断是否包含这个对象，就是遍历 `Set<Entry<K,V>>` 去进行对比，其中也有对值为 `null` 的判断，这说明，`AbstractMap` 中，值是可以为  `null` 的

#### get(Object key)


```
    public V get(Object key) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        if (key==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null)
                    return e.getValue();
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    return e.getValue();
            }
        }
        return null;
    }
```
和 `containsValue(Object value)` 差不多，也是通过遍历。可以看出，`key` 也是可以为 `null` 的


看了上面两个，明显发现有点不对劲了？

因为 `HashMap` 的 `containsKey` 和 `get` 的时间复杂度不应该是 **O(1)** 吗？上面用到了遍历的话，时间复杂度就是 **O(n)** 了

显然，这样是8对的！因为这些方法都不是抽象方法，所以作为 `AbstractMap` 的子类， `HashMap` 一定是自己实现了这些方法。接下来，我们看一看 `HashMap`

不过，在此之前，我们需要看一下上面比较关键的 `Entry<K,V>` 究竟是个什么东西

### Entry<K,V>


```
    interface Entry<K, V> {
        K getKey();
        
        V getValue();
        
        V setValue(V value);
        
        boolean equals(Object o);
        
        int hashCode();
        
        public static <K extends Comparable<? super K>, V> Comparator<Map.Entry<K, V>> comparingByKey() {...}
        
        public static <K extends Comparable<? super K>, V> Comparator<Map.Entry<K, V>> comparingByValue() {...}
        ...
    }
    
```

可以看到  `Entry<K,V>` 是一个实现了一些基础操作的接口，而在 `HashMap` 中，由`Node` 对象实现了这个接口



### Node<K,V>

主要看其中的某些方法

```
static class Node<K,V> implements Map.Entry<K,V>{
        final int hash;
        final K key;
        V value;
        Node<K,V> next;
        
        ...
        public final int hashCode() {
            return Objects.hashCode(key) ^ Objects.hashCode(value);
        }


        public final boolean equals(Object o) {
            if (o == this)
                return true;
            if (o instanceof Map.Entry) {
                Map.Entry<?,?> e = (Map.Entry<?,?>)o;
                if (Objects.equals(key, e.getKey()) &&
                    Objects.equals(value, e.getValue()))
                    return true;
            }
            return false;
        }
}
```

因为每个 **Node** 还存储了一个 `Node<K,V> next` 对象，所以 **Node** 其实就是链表结构

`hashCode()` 这个方法，结合了 `key` 与 `value`，至于 `Objects.hashCode(key)` 的具体逻辑，主要是调用 `identityHashCode(Object obj)` 根据内存地址来得出 **hasCode** ，这里就不展示了


接下来把目光放到  `HashMap` 上来吧


### HashMap

简化代码入下：


```
public class HashMap<K,V> extends AbstractMap<K,V>implements Map<K,V>, Cloneable, Serializable{
    
    transient Node<K,V>[] table;
    
    transient Set<Map.Entry<K,V>> entrySet;
    
    transient int size;
    
    final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict){...}
    
    public V get(Object key) {...}
    
    final Node<K,V> getNode(int hash, Object key) {...}
    
    public boolean containsKey(Object key) { return getNode(hash(key), key) != null; }
    
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
    
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict) {...}
    
    public boolean containsValue(Object value) {...}
    
}
```


有了上面的一些铺垫，我们直接从 `put(...)` 方法开看

可以看到 `put` 调用的是 `putVal`

#### putVal(...)

看一看 `putVal` 的详细内容


```

    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

先看第一段

```
if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
```

这里表示当 **tab** 为 **null** 或者没有内容的时候，对 **tab** 进行初始化

初始化的关键代码就是 `resize()` 方法了，看一下 `resize()` 

##### resize()

```
    final Node<K,V>[] resize() {
    ...
    //判断数组是否初始化过，没有初始化就初始化，否则扩容
    ...
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        if (oldTab != null) {
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
                    else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { // preserve order
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            ...
                        } while ((e = next) != null);
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```
resize()的作用有两个，分别是 **初始化table** 或者 **给table扩容**

上面的逻辑主要分为两段：

- 前面省略号中的逻辑如下:

     >具体就是：如果数组为空，用默认值16去初始化。  
     否则，数组扩容一倍。这里还涉及到另一个参数：threshold，它表示数组扩容的阙值。每当数组元素到达阙值时，就说明数组需要扩容了，threshold每次也扩大一倍，初始的threshold数值为 16*0.75
    

- 后一段代码逻辑如下:
    > 如果旧的table数组不为空，则需要遍历它，并放入新的table中去，也就是进行扩容。其中，元素在数组中存放的索引，是根据哈希算法来生成的

哈希算法看起来比较奇幻：`newTab[e.hash & (newCap - 1)] = e`

因为新数组的长度就是 **newCap** ，每次数组都扩容一倍，所以**newCap**一定是2的次幂数 。不过上面这个代码到底是如何运作的呢？我还不是太清楚原理，但是我作了一个实验


```
    @Test
    public void test() {
        int newCap = 1 << 4;//16
        int[] newTab = (int[])new int[newCap];
        for(int i = 0; i < 8; i++){
            Object o = i;
            newTab[o.hashCode() & (newCap - 1)] = i;
        }
        System.out.println(Arrays.toString(newTab));
    }
```

上面这段代码打印内容如下：

```
[0, 1, 2, 3, 4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0]
```
看起来非常的神奇。不过这里就暂时先不去管这个算法的原理了。

我们还注意到一段代码：

```
else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
```

这里又引入了一个新的概念： **TreeNode** ，不过暂时我们还不需要管它，继续看 `putVal(...)` 方法后面的内容吧

大概逻辑如下：

> 如果 put 时，数组对应index的Node为null，则创建一个新的放进去  
如果Node不为null，则通过 hash 值、key来进行对比  
如果对比值相同的话，用新Node替换旧Node  
不相同的话(哈希冲突)，遍历旧Node，将新Node存放在旧Node的尾部  
如果Node节点数量超过8个了的话，通过treeifyBin()将Node转换为TreeNode

上面看到的 `TreeNode` 对象，其实就是 **红黑树**

关于 `putValue` 的分析就到这里，接下来是 `get(Object key)` 方法


```
    public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }
```

直接来看 `getNode(...)` 吧

#### getNode(...)


```
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
```

上面的逻辑很清晰，先是通过 `(n - 1) & hash` 来获得 `key` 在 `table` 数组中对应的 **index**   
如果该 `index` 对应的 **Node** 为空，则说明不存在该元素，返回null  
如果不为空，且 `hash` 值与 `key` 值都相同则返回该 **Node** 的值，hash不同的话，遍历链表找到相同的返回，否则返回null



到这里 **HashMap** 的源码就分析完成啦，关于 **TreeNode** ，后面有机会再介绍吧！


# 总结

关于 `HashMap` 的总结，大致如下

- 数据结构：由 **数组** + **链表** 组成，链表就是 `Node<K,V>` 对象，通过 **哈希算法** 将 `Node<K,V>` 在数组中的索引与 `Key` 相关联，因为这个算法，在数组中 **put** 和 **get** 的耗时都是 **O(1)**
- 数组扩容：因为是通过数组存储的 `Node<K,V>` 对象，我们知道，数组的长度是无法改变的，所以这里会因为 **put** 到了一定数量后就需要创建更大的新数组。
- 扩容规则：初始的数组长度为 **16**, 扩容**阙值**为 `16 * 0.75` = **12**, 之后每当数组中元素数量到达**阙值**时，就会对数组进行扩容。数组长度每次增加一倍，**阙值**也增加一倍
- 哈希冲突：其实可以很明显的想到，如果只需要存键值对的话，为什么还需要将 `Node<K,V>` 链表放在数组里，直接放一个普通的对象不就可以了吗，比如 `class Obj<K,V>{var key: K, var value: V}` ，那为什么不这样呢？还是因为 **哈希算法** 可能导致的 **哈希冲突** 问题。也就是说可能存在 **hash(Key1) == hash(Key2)** 的情况，这时候就需要用到链表了，将有冲突的对象添加到链表里。看过源码也知道，当这个链表的长度超过 **8** 时，链表会转换成 **红黑树**，即 **Node<K,V>** 变成 **TreeNode<K,V>**


那么 `HashMap` 的源码就分析就暂时结束啦！


