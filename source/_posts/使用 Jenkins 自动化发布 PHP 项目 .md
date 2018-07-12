---
title: 使用 Jenkins 自动化发布 PHP 项目
author: helingfeng
tags:
  - Jenkins
categories:
  - Jenkins
  - PHP
translate_title: automatically-publish-php-projects-using-jenkins
date: 2018-05-10 11:12:00
---
## 什么是 Jenkins

Jenkins是一个开源软件项目，是基于Java开发的一种持续集成工具，用于监控持续重复的工作，旨在提供一个开放易用的软件平台，使软件的持续集成变成可能。

## 使用 Docker 安装 Jenkins

避免装环境的折腾, 直接使用 docker-compose 安装，具体如何安装在 `Docker 快速搭建 LNMP 环境` 已经描述了

docker-compose.yml

```yml
jenkins:
  image: jenkins:latest
  ports:
    - "8080:8080"
  volumes:
      - ./jenkins:/var/jenkins_home:rw
```
注意：volumes 配置 jenkins 目录映射到本地

```shell
docker-compose up -d 

# 等待下载镜像，创建容器
Creating dnmp_jenkins_1    ... done
# 安装就这么简单
```

## 访问 8080 端口，进入初始化页面

访问: http://localhost:8080/

首次打开，需要输入秘钥，根据提示，可以在对应的目录 /jenkins/secrets 找到该文件
设置登录用户名密码后，进入几分钟的初始化过程...

![screen](/images/screen_5.png)

## 配置自动化构建发布

### 配置远程服务器 SSH

菜单 -> 系统管理 -> 系统设置 ->  SSH Servers

![screen](/images/screen_7.png)

如图，是我配置的内容

![screen](/images/screen_8.png)

Remote Directory 这个配置很关键，表示构建时的相对目录。这里我配置 "/" 
配置完成后，最好 Test Configuration , 返回 Success 就表示成功！

### 新建发布项目

填写项目名称如, test
并选择项目类型，这里我选择"自由风格项目"
![screen](/images/screen_6.png)

#### General

选择对应项目路径，我使用 GitHub project 

![screen](/images/screen_9.png)

#### 源码管理

使用 git 源码仓库管理

![screen](/images/screen_10.png)

#### 构建

这里是最关键的，你可以打包源码发布到对应的服务器之上

![screen](/images/screen_11.png)

- Source files 表示打包好的源文件
- Remote directory 表示你需要将源文件上传的远程路径（这个路径相对于 SSH 配置目录）
- Exec command 上传完成后，执行的命令（ hexo g 这个是我发布博客时的构建命令）

### 立即构建

选择对应的项目，点击立即构建

![screen](/images/screen_12.png)

在构建执行状态中，可以点击 console output 看到构建的过程信息

![screen](/images/screen_13.png)


 









