---
title: 全排列 II(中等)
date: 2020-03-08 06:14:30
---
## 题目描述

给定一个可包含重复数字的序列，返回所有不重复的全排列。

**示例:**


```
输入: [1,1,2]
输出:
[
  [1,1,2],
  [1,2,1],
  [2,1,1]
]
```


## 解题思路

这题是 [全排列](https://leetcode-cn.com/problems/permutations/) 的进阶版，具体的改动就是，由不包含重复的输入序列变成了可包含重复的数字序列。

显然，出了需要使用回溯外，还需要进行剪枝才行。这题的难点就是如何去写剪枝的逻辑了。

先看看不减枝的常规解法：

#### 一般思路：

通过Set的特性，来完成去重操作，不过这样耗时会高很多。

#### 优化思路：

leecode上面有非常好的思路，下面将其放上：


<img width="500" alt="WeChatcf0b8272848f0486837568e93d4607e7" src="https://user-images.githubusercontent.com/30992818/71465127-aa404c00-27f6-11ea-9979-43c572364b7a.png">


<img width="500" alt="https://user-images.githubusercontent.com/30992818/71465153-c04e0c80-27f6-11ea-9427-acd5d30f7460.png">

<img width="500" alt="https://user-images.githubusercontent.com/30992818/71465188-dbb91780-27f6-11ea-9b8d-7e4003484fed.png">

<img width="500" alt="https://user-images.githubusercontent.com/30992818/71465247-ff7c5d80-27f6-11ea-9cee-c5dfb0d47f39.png">



## 答案

#### 一般答案


```
    fun permute(nums: IntArray): List<List<Int>> {
        val result = mutableListOf<List<Int>>()
        for (i in nums.indices) {
            val newNumbs = nums.toMutableList()
            newNumbs.removeAt(i)
            traceBackPermute(newNumbs, mutableListOf(nums[i]), result)
        }
        return result
    }

    private fun traceBackPermute(
        numbs: List<Int>,
        currentList: MutableList<Int>,
        result: MutableList<List<Int>>
    ) {
        if (numbs.isEmpty()) {
            val list = mutableListOf<Int>()
            list.addAll(currentList)
            if (!result.contains(list)) result.add(list)
            return
        }
        for (i in numbs.indices) {
            val newNumbs = numbs.toMutableList()
            newNumbs.removeAt(i)
            currentList.add(numbs[i])
            traceBackPermute(newNumbs, currentList, result)
            currentList.remove(currentList.last())
        }
    }
```

#### 优化答案


```
 fun permuteUnique(nums: IntArray): List<List<Int>> {
        val result = mutableListOf<List<Int>>()
        nums.sort()
        traceBackPermuteUnique(nums, MutableList(nums.size) {false},0, mutableListOf(),result)
        return result.toList()
    }

    private fun traceBackPermuteUnique(nums: IntArray,
                                        usedList: MutableList<Boolean>,
                                        currentIndex: Int,
                                        currentList: MutableList<Int>,
                                        result: MutableList<List<Int>>){
        if(currentIndex == nums.size) {
            val list = mutableListOf<Int>()
            list.addAll(currentList)
            result.add(list)
        }
        for (i in nums.indices) {
            if(usedList[i]) continue
            // 与上一个数相等,并且上一个数使用过，则数据重复,不加入集合（数据相同，只出一个排列结果）
            if (i > 0 && nums[i] == nums[i - 1] && usedList[i - 1]) continue
            usedList[i] = true
            currentList.add(nums[i])
            traceBackPermuteUnique(nums,usedList, currentIndex+1,currentList,result)
            currentList.removeAt(currentList.size - 1)
            usedList[i] = false
        }
    }
```
