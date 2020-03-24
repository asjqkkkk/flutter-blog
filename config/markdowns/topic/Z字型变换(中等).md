---
title: Z字型变换(中等)
date: 2020-03-08 06:14:30
---
## 题目描述

将一个给定字符串根据给定的行数，以从上往下、从左到右进行Z 字形排列。

比如输入字符串为 ``"LEETCODEISHIRING"`` 行数为 3 时，排列如下：


```
L   C   I   R
E T O E S I I G
E   D   H   N
```
之后，你的输出需要从左往右逐行读取，产生出一个新的字符串，比如：``"LCIRETOESIIGEDHN"``。

请你实现这个将字符串进行指定行数变换的函数：


```
string convert(string s, int numRows);
```


**示例1:**


```
输入: s = "LEETCODEISHIRING", numRows = 3
输出: "LCIRETOESIIGEDHN"
```


**示例2:**


```
输入: s = "LEETCODEISHIRING", numRows = 4
输出: "LDREOEIIECIHNTSG"
解释:

L     D     R
E   O E   I I
E C   I H   N
T     S     G
```


## 解题思路

说实话，这题没有什么特别的解体思路。因为思路上来说解决这道题目很简单。

那为什么我要将这题记录下来呢？

主要做完题目后对比答案，被答案的解法给惊艳到了。这种感觉于我而言就像直接吃掉第六个烧饼，然后肚子就饱了。

答案的解法可读性也不强，但是这种恰到好处的代码甚至让我怀疑出题者是先想到答案，再想到题目的。

## 答案


```
class Solution {
    public String convert(String s, int numRows) {

        if (numRows == 1) return s;

        List<StringBuilder> rows = new ArrayList<>();
        for (int i = 0; i < Math.min(numRows, s.length()); i++)
            rows.add(new StringBuilder());

        int curRow = 0;
        boolean goingDown = false;

        for (char c : s.toCharArray()) {
            rows.get(curRow).append(c);
            if (curRow == 0 || curRow == numRows - 1) goingDown = !goingDown;
            curRow += goingDown ? 1 : -1;
        }

        StringBuilder ret = new StringBuilder();
        for (StringBuilder row : rows) ret.append(row);
        return ret.toString();
    }
}

```
