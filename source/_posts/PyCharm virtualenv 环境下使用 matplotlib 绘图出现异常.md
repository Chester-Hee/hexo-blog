---
title: virtualenv 环境下使用 matplotlib 绘图出现异常
author: helingfeng
tags:
  - PyCharm
  - virtualenv
  - matplotlib
categories:
  - matplotlib
translate_title: drawing-with-matplotlib-in-virtualenv-environment
date: 2018-05-08 16:46:00
---
## 问题: MacOs PyCharm IDE virtualenv 下运行 matplotlib 绘图出现异常

```
Traceback (most recent call last):
File "<stdin>", line 1, in <module>
...
...
in <module>
from matplotlib.backends import _macosx
RuntimeError: Python is not installed as a framework. The Mac OS X backend will not be able to function correctly if Python is not installed as a framework. See the Python documentation for more information on installing Python as a framework on Mac OS X. Please either reinstall Python as a framework, or try one of the other backends. If you are Working with Matplotlib in a virtual enviroment see 'Working with Matplotlib in Virtual environments' in the Matplotlib FAQ

```

源代码：

```
#!/usr/bin/python
# -*-coding:utf-8-*-
import matplotlib.pyplot as plt

labels = 'frogs', 'hogs', 'dogs', 'logs'
sizes = 15, 20, 45, 10
colors = 'yellowgreen', 'gold', 'lightskyblue', 'lightcoral'
explode = 0, 0.1, 0, 0
plt.pie(sizes, explode=explode, labels=labels, colors=colors, autopct='%1.1f%%', shadow=True, startangle=50)
plt.axis('equal')
plt.show()

```

## 错误原因分析

Problem Cause In mac os image rendering back end of matplotlib (what-is-a-backend to render using the API of Cocoa by default). 
There is Qt4Agg and GTKAgg and as a back-end is not the default. 
Set the back end of macosx that is differ compare with other windows or linux os.

问题原因在 `MacOs` 图像渲染 `matplotlib` 的后端（默认情况下使用Cocoa的API呈现什么是后端）。
有`Qt4Agg`和`GTKAgg`，作为后端不是默认设置。
设置不同于其他`windows`或`linux`操作系统的`MacOsx`的后端。

## 解决方案

- 确认你使用 `pip` 安装 `matplotlib` , 安装完成后会自动在用户根目录生成这个文件夹 `~/.matplotlib`.
- 创建一个文件 ~/.matplotlib/matplotlibrc 并设置文件内容: backend: TkAgg

## 再次运行

![ide](/images/screen_2.png)


