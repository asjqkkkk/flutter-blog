---
title: 不同路径 II(中等)
date: 2020-03-08 06:14:30
---
## 题目描述

一个机器人位于一个 *m x n* 网格的左上角 （起始点在下图中标记为“Start” ）。

机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为“Finish”）。

现在考虑网格中有障碍物。那么从左上角到右下角将会有多少条不同的路径？

![image](https://user-images.githubusercontent.com/30992818/72131874-76e5eb80-33b8-11ea-8cb9-a6cc28b18d9a.png)

网格中的障碍物和空位置分别用 1 和 0 来表示。

**说明**：m 和 n 的值均不超过 100。

**示例 1:**


```
输入:
[
  [0,0,0],
  [0,1,0],
  [0,0,0]
]
输出: 2
解释:
3x3 网格的正中间有一个障碍物。
从左上角到右下角一共有 2 条不同的路径：
1. 向右 -> 向右 -> 向下 -> 向下
2. 向下 -> 向下 -> 向右 -> 向右
```


## 解题思路

这题相较于它的上一个版本来说，多了 **障碍物** 的设置。

如果某个格子上有障碍物，那么我们不考虑包含这个格子的任何路径。也就是说**这个格子提供的路径值为0**。而没有障碍物的格子，提供的路径值为1。

接下来我们还是将上边界和左边界全部设置为1(这里的1和用于表示障碍物的1，虽然数值一样，但是概念不同)，不过这里需要注意几点：
- 如果第一个点就存在障碍物，那后面的点就都为0了
- 如果第一个点没有障碍物，将第一个点的值由0设置为1，表示提供一个路径值
- 遍历第一行，如果存在障碍物，将改点的数值由1设置为0，表示不提供路径值
- 遍历第一列，与上面一样
- 从第[1][1]点开始进行遍历，如果发现某个点有障碍物，将其值由1设为0，否则该点的值为左边的点和上边的点的值相加


根据以上几点，我们就可以使用**动态规划**来解决问题了


## 答案


```
    fun uniquePathsWithObstacles(obstacleGrid: Array<IntArray>): Int {
        val column = obstacleGrid.size
        val row = obstacleGrid[0].size
        if(obstacleGrid[0][0] == 1) return 0
        obstacleGrid[0][0] = 1
        for (i in 1 until column) {
            obstacleGrid[i][0] = if(obstacleGrid[i-1][0] == 1 && obstacleGrid[i][0] == 0) 1 else 0
        }
        for(i in 1 until row){
            obstacleGrid[0][i] = if(obstacleGrid[0][i-1] == 1 && obstacleGrid[0][i] == 0) 1 else 0
        }
        for(i in 1 until column){
            for(j in 1 until row){
                if(obstacleGrid[i][j] == 1){
                    obstacleGrid[i][j] = 0
                } else {
                    obstacleGrid[i][j] = obstacleGrid[i-1][j] + obstacleGrid[i][j-1]
                }
            }
        }
        return obstacleGrid[column-1][row-1]
    }
```
