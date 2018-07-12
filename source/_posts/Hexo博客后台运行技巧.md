---
title: Hexo博客后台运行技巧
author: helingfeng
tags: []
categories:
  - Hexo
translate_title: hexo-blog-background-running-skills
date: 2018-04-02 17:54:00
---
安装并运行hexo博客后，一般教程都会告诉运行命令是:hexo s,但是关掉Terminal，进程也就结束了，对于一个希望永远运行的服务器来说是不可接受的。

查阅一些资料后找到一个后台运行的命令: hexo s &

这个命令确实可以实现后台运行，但是关掉Terminal，进程服务进程都会死掉，还找不到原因。


#### 解决办法

1. rc.local 

配置开机启动项，我正使用这种方式，暂时没有发现问题。


2. forever


转载，试了一下，有一些小问题


使用nodejs里很流行的forever，可以实现当进程死掉时候自动重启。Forever全局安装命令

```shell
npm install -g forever
```

安装完成，还不能直接用，需要在你的hexo根目录下新建一个js文件，比如app.js,代码如下：

```
require(‘hexo’).init({command: ‘server’});
```

之后使用命令forever start app.js 即可。

查看forever进程命令 forever list, 更多命令输入forever -h