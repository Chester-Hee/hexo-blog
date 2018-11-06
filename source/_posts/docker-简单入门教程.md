---
title: docker 简单入门教程
author: helingfeng
tags:
  - Docker
categories:
  - Docker
translate_title: docker-simple-tutorial
date: 2018-04-11 18:57:00
---
## docker 简单入门教程

### 简介

docker 是个划时代的开源项目，它彻底释放了计算虚拟化的威力，极大提高了应用的维护效率，降低了云计算应用开发的成本！使用 Docker，可以让应用的部署、测试和分发都变得前所未有的高效和轻松！

无论是应用开发者、运维人员、还是其他信息技术从业人员，都有必要认识和掌握 docker，节约有限的生命。

### 安装 docker

`docker` 分为两个程序`服务器`与`客户端`

- 服务端是一个服务进程，管理着所有的容器
- 客户端则扮演着 docker 服务端的远程控制器

安装 docker 有两个版本选择`Community Edition (CE)` 和 `Enterprise Edition (EE)`

- Enterprise Edition (EE) 是企业级付费版本
- Community Edition (CE) 这个是免费的

CE 下载安装文档路径：

- ubuntu：https://docs.docker.com/install/linux/docker-ce/ubuntu/
- Mac：https://docs.docker.com/docker-for-mac/install/
- Windows：https://docs.docker.com/docker-for-windows/install/

### docker image 基本命令

docker 镜像操作类似于 git 操作

#### 拉取镜像

```shell
docker pull ubuntu:16.04

输出：
16.04: Pulling from library/ubuntu
22dc81ace0ea: Downloading [=======>                                           ]  6.586MB/42.96MB
1a8b3c87dba3: Download complete 
91390a1c435a: Download complete 
07844b14977e: Download complete 
b78396653dae: Download complete 

获取镜像：docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]

```

#### 镜像列表

```shell
docker image ls

输出：
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              16.04               f975c5035748        5 weeks ago         112MB
```

#### 删除镜像

```shell
 docker image rm [选项] <镜像1> [<镜像2> ...]
```
通常要强制删除，添加参数 -f


#### 定制镜像

使用Dockerfile定制镜像

### docker container 基本命令

镜像都是在容器上运行的

#### 新建并启动容器

```shell
docker run -it ubuntu bash

输出：
 Unable to find image 'ubuntu:latest' locally
 latest: Pulling from library/ubuntu
 Digest: sha256:e348fbbea0e0a0e73ab0370de151e7800684445c509d46195aef73e090a49bd6
 Status: Downloaded newer image for ubuntu:latest
 root@fdfbf1ce305a:/# 
```

其中，-t 选项让Docker分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上， -i 则让容器的标准输入保持打开。

当利用 docker run 来创建容器时，Docker 在后台运行的标准操作包括：

- 检查本地是否存在指定的镜像，不存在就从公有仓库下载
- 利用镜像创建并启动一个容器
- 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
- 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
- 从地址池配置一个 ip 地址给容器
- 执行用户指定的应用程序
- 执行完毕后容器被终止


#### 获取容器列表

```shell
docker container ls -a
```

#### 终止容器

```shell
docker container stop
```

#### 进入已经启动容器

```shell
docker exec -it webserver bash
```

#### 删除容器

```shell
删除容器：
docker container rm trusting_newton

清理所有容器：
docker container prune
```

### docker 三剑客之 compose

`compose` 是定义和运行多容器 docker 应用程序的工具。使用compose，您可以使用 YAML 文件来配置应用程序的服务。compose 项目是 docker 官方的开源项目，负责实现对 docker 容器集群的快速编排。从功能上看，跟 OpenStack 中的 Heat 十分类似 compose 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理

重要两个概念：

- 服务 (service)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例
- 项目 (project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义

#### 安装

安装地址：https://docs.docker.com/compose/install/#install-compose

#### 命令

命令说明：https://yeasy.gitbooks.io/docker_practice/content/compose/commands.html

```shell
docker-compose up [options] [SERVICE...]

该命令十分强大，它将尝试自动完成包括构建镜像，（重新）创建服务，启动服务，并关联服务相关容器的一系列操作
```

```shell
docker-compose up -d

将会在后台启动并运行所有的容器。一般推荐生产环境下使用该选项
```