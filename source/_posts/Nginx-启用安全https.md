---
title: Nginx 启用安全https
author: helingfeng
tags:
  - Nginx
categories:
  - Nginx
translate_title: nginx-enables-secure-https
date: 2018-04-25 15:51:00
---
## 安全https解决方案
[Let’s Encrypt](https://certbot.eff.org/all-instructions/#ubuntu-16-04-xenial-nginx "Let’s Encrypt")

## ubuntu apt 安装

On Ubuntu systems, the Certbot team maintains a PPA. Once you add it to your list of repositories all you'll need to do is apt-get the following packages.
```shell

$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx 

```

## 如何使用

运行脚本，将会自动生成PEM文件并配置您的Nginx.

```shell
$ sudo certbot --authenticator webroot --webroot-path <path to served directory> --installer nginx -d <domain>
```
命令运行成功后，输出两个文件，例如，www.helingfeng.com
```shell
ssl_certificate /etc/letsencrypt/live/www.helingfeng.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/www.helingfeng.com/privkey.pem;
```

## 如果你的Nginx没有配置成功？

可以手工进行修改
具体参考：[让你的Nginx支持HTTPS](https://www.helingfeng.com/2017/12/04/%E8%AE%A9%E4%BD%A0%E7%9A%84nginx%E6%94%AF%E6%8C%81https/ "让你的Nginx支持HTTPS")


## WordPress 配置支持https

- 修改站点地址 http => https
- 修改插件默认配置的资源地址
- 如果你上传了http地址资源，需要重新进行上传或配置


## 效果截图

请看上方访问地址


![upload successful](/images/pasted-14.png)



> 希望你也成功配置安全的https
