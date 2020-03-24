---
title: 两数之和 II - 输入有序数组(简单)
date: 2020-03-08 06:14:30
---
## 题目描述

给定一个已按照 ***升序排列*** 的有序数组，找到两个数使得它们相加之和等于目标数。

函数应该返回这两个下标值 index1 和 index2，其中 index1 必须小于 index2。

**说明:**
- 返回的下标值（index1 和 index2）不是从零开始的。
- 你可以假设每个输入只对应唯一的答案，而且你不可以重复使用相同的元素

**示例:**


```
输入: numbers = [2, 7, 11, 15], target = 9
输出: [1,2]
解释: 2 与 7 之和等于目标数 9 。因此 index1 = 1, index2 = 2 。
```


## 解题思路

#### 思路一

常规思路，直接两个for循环，找到为止。


#### 思路二

根据本题的题干，输入的数组是一个 **升序数组** 所以我们完全可以同时进行首位一起查找


## 答案

#### 常规解法


```
    fun twoSum(numbers: IntArray, target: Int): IntArray {
        for (i in 0 until  numbers.size - 1){
            for (j in i+1 until numbers.size){
                if(numbers[i] + numbers[j] == target){
                    return intArrayOf(i+1,j+1)
                }
            }
        }
        return intArrayOf()
    }
```


#### 双指针解法


```
    fun twoSum(numbers: IntArray, target: Int): IntArray {
        var left = 0
        var right = numbers.size-1
        while (left < right){
            val sum = numbers[left] + numbers[right];
            if(sum == target){
                return intArrayOf(left+1,right+1)
            } else if(sum < target){
                left++
            } else{
                right--
            }
        }
        return intArrayOf()
    }
```
