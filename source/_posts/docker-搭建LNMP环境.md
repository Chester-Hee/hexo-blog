---
title: docker 搭建LNMP环境
tags: docker
translate_title: docker-build-lnmp-environment
date: 2018-05-03 21:02:03
---

# DNMP 

Docker 快速搭建`Nginx` `MySQL` `PHP` 开发环境，并提供丰富的支持。 


### Feature

1. MIT 完全开源.
2. 多版本 PHP 环境支持，可以选择 `5.4` `5.6` `7.2`.
3. 一个环境可以配置多个项目.
4. 支持 HTTPS .
5. 可以配置不同主机服务的 PHP 源程序.
6. MySQL 数据目录映射本地.
7. 所有的环境配置文件都映射本地.
8. 所有的日志文件都映射本地.
9. 可以在构建 Dockerfile 修改命令安装 PHP 扩展依赖.
10. 适用于所有操作系统.

### Usage

1. 安装 `git`, `docker` and `docker-compose`;

2. git 克隆项目:
    ```
    $ git clone https://github.com/helingfeng/dnmp.git
    ```
    
4. 启动 docker containers:
    ```
    $ cd dnmp
    $ docker-compose up
    ```
5. 配置 hosts

    ```
    # sudo vim /etc/hosts
    
    127.0.0.1 www.demo.com  
    ```
  

6. 浏览器访问 https://www.demo.com 

可以看到下面成功页面 php_info

![demo](https://github.com/helingfeng/dnmp/raw/master/demo.png)

### 选择其他的 PHP version?

默认选择最新的 PHP 版本:
```
$ docker-compose up
```

可以通过启动选项选择 PHP5.4 or PHP5.6 :

```
$ docker-compose -f docker-compose54.yml up
$ docker-compose -f docker-compose56.yml up
```

5. Nginx 配置 HTTPS

运行自动脚本 gencert.sh，并输出参数 DOMAIN（可以为泛域 *.baidu.com）

配置 Nginx 即可
```
    ssl on;
    ssl_certificate /etc/nginx/conf.d/certs/*.baidu.com.crt;
    ssl_certificate_key /etc/nginx/conf.d/certs/*.baidu.com.key;
```
