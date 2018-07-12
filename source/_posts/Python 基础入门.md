---
title: Python 基础环境搭建
author: helingfeng
tags:
  - Python
categories:
  - Python IDE
translate_title: python-basic-environment-to-build
date: 2018-05-06 12:09:00
---

## Python 基础入门

### 环境搭建

#### 1. 首先安装 HomeBrew

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### 2. 其次安装 Python

```shell
brew install python
```

#### 3. 检查是否安装成功

```shell
$ python
           
Python 2.7.10 (default, Oct  6 2017, 22:29:07) 
[GCC 4.2.1 Compatible Apple LLVM 9.0.0 (clang-900.0.31)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> exit()
```
看到正确的输出版本信息，大功告成

#### 4. 选择开发工具 IDE

我个人觉得，虽然我们常说不要依赖工具，但是有一个好的 IDE 可以事半功倍，让你有更多的时间去了解运行原理和实物的本质。而不是把时间都花在调试构建运行代码之上。

因为我是从事 PHP Web 开发，所以非常青睐 jetbrains IDE , 并且 Python PyCharm 居然有免费开源版本

下载地址：https://www.jetbrains.com/pycharm/download/

Linux Mac Window 安装都非常简单

![ide](/images/screen_1.png)

感觉 UI 高端大气上档次有木有，瞬间激起对 Python 的兴趣。

Question 1 : PyCharm run 运行代码 报错 ！！！

需要配置 Interpreter options
 
打开菜单 Preferences | Project: python_test | Project Interpreter

点击添加 => 选择你需要的版本（这里我选择 Python 2.7），等待一会就安装完成

### Hello World

```python
print "Hello, Python!"
```