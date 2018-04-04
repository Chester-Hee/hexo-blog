title: 终端神器 oh my zsh
author: helingfeng
tags: []
categories:
  - Linux
date: 2018-04-02 15:56:00
---
## 优化命令终端 oh my zsh

#### oh my zsh 配置 zsh 而生
```
# ubuntu 所有 shells
# /etc/shells: valid login shells
/bin/sh
/bin/dash
/bin/bash
/bin/rbash
/usr/bin/tmux
/bin/zsh
/usr/bin/zsh

```
- oh my zsh 配置0门槛
- 完全兼容 bash

#### 安装 oh my zsh

Github地址：https://github.com/robbyrussell/oh-my-zsh

安装命令：

- 通过curl自动安装，运行下面命令

```shell

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- 通过wget自动安装，运行下面命令

```shell

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

```

------

#### 定制化 .zshrc 配置

- 打开配置

```shell
cd 
vim .zshrc
```

- 配置主题

;# Set name of the theme to load. Optionally, if you set this to "random"
;# it'll load a random theme each time that oh-my-zsh is loaded.
;# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

```shell
ZSH_THEME="robbyrussell"
```

- 安装插件

;# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
;# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
;# Example format: plugins=(rails git textmate ruby lighthouse)
;# Add wisely, as too many plugins slow down shell startup.

```shell
plugins=(git)
plugins=(zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
```

#### 插件推荐

- zsh-syntax-highlighting 语法高亮
https://github.com/zsh-users/zsh-syntax-highlighting
- zsh-autosuggestions 命令提示
https://github.com/zsh-users/zsh-autosuggestions

#### 效果图


![upload successful](/images/pasted-15.png)
> 工具让开发变得更简单