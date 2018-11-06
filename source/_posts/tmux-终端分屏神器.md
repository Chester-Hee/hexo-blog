---
title: tmux 终端分屏神器
author: helingfeng
tags:
  - Linux
categories:
  - Linux
translate_title: tmux-terminal-split-screen-artifact
date: 2018-05-19 10:56:00
---
## tmux 终端分屏神器

### 编译安装 tmux

- https://github.com/tmux/tmux/releases

linux用户选择下载tar.gz 
https://github.com/tmux/tmux/archive/2.7.tar.gz

```shell
# 安装依赖
sudo apt-get install libevent-dev
sudo apt-get install libncurses5-dev

# 生成 configure
sh autogen.sh

# 生成MakeFile 编译和安装
./configure && make
sudo make install
```

提示：如果你是ubuntu用户

```shell
sudo apt install tmux
```

### 快捷键设置与界面美化

- https://github.com/gpakosz/.tmux


![upload successful](/images/pasted-33.png)


tmux 自定义配置文件路径为 ～/.

所以可以下载配置文件进行覆盖

```shell
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```

Then proceed to customize your ~/.tmux.conf.local copy.

### 简单使用

终端输入tmux,启动tmux会话窗口

```
tmux
```
tmux为了不与终端快捷键发生冲突，使用了快捷键前缀方式

默认快捷键前缀为 `ctrl`+`b`

- 使用快捷键 `-` 进行横向分屏
- 使用快捷键 `shift` + `-` 进行纵向分屏
- 快捷键 `H` `J` `K` `L` 可以上下左右移动光标焦点


gpakosz/.tmux 采用vim操作风格，更便捷