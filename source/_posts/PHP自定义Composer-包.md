---
title: PHP自定义Composer扩展包
author: helingfeng
tags: []
categories:
  - Composer
translate_title: php-custom-composer-extension-package
date: 2018-04-02 15:50:00
---
### 前言

Composer PHP扩展包依赖管理工具，类似java的maven，javascirpt的npm

Composer的出现让PHP发生了质的变化，头痛的代码库依赖问题，包版本问题得以解决

Composer是一个基于PHP的程序，所以安装Composer之前必须得安装PHP环境

### Install

##### Windows，Linux，Mac

Composer下载地址：[https://getcomposer.org/download/](https://getcomposer.org/download/ "https://getcomposer.org/download/")

##### 所有的环境都可以使用PHP命令行进行安装

###### 首先，下载composer-setup
```php
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```
###### 最后，开始安装

```php
php composer-setup.php --install-dir=bin
```
###### 安装选项

- --install-dir=bin   （安装路径）
- --filename=composer  （安装文件名称）
- --version=1.0.0-alpha8 （版本）

### 初始化自定义扩展包目录

```shell
mkdir my-composer
cd my-composer
composer init
```
init命令会提示你输入扩展包的一下基本信息和依赖信息

```shell

vim composer.json

{
    "name": "helingfeng/my-composer",
    "authors": [
        {
            "name": "helingfeng",
            "email": "857190327@qq.com"
        }
    ],
    "require": {}
}
```

### 实现扩展源码

假设，我们希望实现一个 Md5+salt 密码加密扩展。

#### mkdir目录结构

```shell
mkdir -p src/Md5salt
```

#### new Class

```shell
touch Auth.php
vim Auth.php
```

写入代码
```php
<?php

namespace Md5salt;

class Auth
{
    public function password2security($password)
    {
        $random_str = $this->createRandomStr();

        return ['password'=>md5($password.$random_str) , 'salt'=>$random_str];
    }

    protected function createRandomStr($len = 10){

        $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        $str = "";
        for ($i = 0; $i < $len; $i++) {
            $str .= substr($chars, mt_rand(0, strlen($chars) - 1), 1);
        }

        return $str;
    }

}
```

#### 初始化git，到GitHub创建一个代码库

```git
git init
git add .
git commit -m "first commit"
git remote add origin https://github.com/helingfeng/TestComposer.git
git push -u origin master

成功Push提示：

Delta compression using up to 4 threads.
压缩对象中: 100% (4/4), 完成.
写入对象中: 100% (6/6), 764 bytes | 0 bytes/s, 完成.
Total 6 (delta 0), reused 0 (delta 0)
To https://github.com/helingfeng/TestComposer.git
 * [new branch]      master -> master
分支 master 设置为跟踪来自 origin 的远程分支 master。
```

> 到这里，我们已经准备好了扩展程序。


### 编辑composer.json文件，配置自动加载 autoLoad

```shell
vim composer.json
```

配置扩展包源码路径

```composer
{
  "name": "helingfeng/my-composer",
  "authors": [
    {
      "name": "hechao",
      "email": "hechao-d@dfl.com"
    }
  ],
  "require": {},
  "autoload": {
    "psr-4": {
      "Md5salt\\": "src/Md5salt/"
    }
  },
  "repositories": {
    "packagist": {
      "type": "composer",
      "url": "https://packagist.phpcomposer.com"
    }
  }
}

```

### 在项目中使用扩展 helingfeng/my-composer

#### 首先，创建自定义扩展tag，如1.0

[https://github.com/helingfeng/TestComposer/tree/1.0](https://github.com/helingfeng/TestComposer/tree/1.0 "https://github.com/helingfeng/TestComposer/tree/1.0")

#### 在项目中配置Composer 来源
```
"repositories": [
    {
      "type": "composer",
      "url": "https://packagist.phpcomposer.com"
    },
    {
      "packagist": false
    },
    {
      "type": "git",
      "url": "https://github.com/helingfeng/TestComposer.git"
    }
  ]
```
require依赖自定义扩展

```composer
composer require helingfeng/my-composer 1.0

成功输出：

./composer.json has been updated
Loading composer repositories with package information                             Package operations: 1 install, 0 updates, 0 removals
  - Installing helingfeng/my-composer (1.0): Cloning e0b108628d from cache
Writing lock file
Generating autoload files

```

#### 使用扩展类

index.php

```php
<?php
require_once __DIR__ . '/../vendor/autoload.php';

use Md5salt\Auth;

$password = '123456';
$auth = new Auth();

$security = $auth->password2security($password);

var_dump($security);

```

#### 运行index.php输出

```shell
array(2) {
  'password' =>
  string(32) "79a9fb766f3e301751d248aa1a69194a"
  'salt' =>
  string(10) "XxYD9XBFMB"
}
```



