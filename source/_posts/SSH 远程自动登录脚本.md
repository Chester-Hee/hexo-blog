---
title: SSH 远程自动登录脚本
author: helingfeng
tags:
  - SSH
categories:
  - Linux
translate_title: ssh-remote-automatic-login-script
date: 2019-07-10 15:55:00
---

我们使用过 `SSH` 远程登录一台服务器，登录需要输入用户名和密码，并且服务器密码一般很难靠脑记住；`Windows` 用户可以使用 `XShell` 这种强大的工具，但是 Linux 或者 Mac 用户更倾向于命令行自动化脚本。

开源的 `autossh` 工具，就为解决这个问题，使用 expect 工具完成交互，自动根据配置用户名密码登录指定服务器。


### 安装 expect 工具
```
Linux:
$ yum install expect
$ apt-get install expect

Mac:
$ brew install expect
```

### 安装 autossh 命令

```
$ git clone https://github.com/FeeiCN/autossh.git
$ sudo cp autossh/autossh /usr/local/bin/
```

### 更新配置文件

```
$ vim ~/.autosshrc

添加服务器配置，如下格式：
server_name|192.168.1.110|root|password|port|is_bastion
```

### 远程登录服务器命令

输入 `autossh` 并选择需要登录的服务器编号
```
$ autossh
############################################################ 
#                     [AUTO SSH]                           # 
#                                                          # 
#                                                          # 
# [1] www.my-server.com - 192.168.192.110:root             # 
#                                                          # 
#                                                          # 
############################################################ 
Server Number: 1
```


### 如果自己也想写一个 SSH 自动登录脚本

可以直接使用 expect 工具，例如

```
#!/usr/bin/expect

spawn ssh root@192.168.192.110
expect "password:"

send "12345678.\r"
```

> 先推荐一款 `WEB` 流程图在线编辑工具：https://www.draw.io