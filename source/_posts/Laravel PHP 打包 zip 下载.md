title: Laravel PHP 打包 zip 下载
author: helingfeng
tags:
  - zip
categories:
  - Laravel
  - PHP
  - zip
date: 2018-05-14 15:12:00
---
## 打包文件夹 zip 

通常业务都需要下载一些用户上传的文件，假如系统需要下载文件数量级非常大，则需要批量下载文件来解决效率问题。
批量下载，代码现实方式就是将多个文件放到同一个目录文件夹中，并打包文件夹，得到 `zip` 文件，然后再下载 `zip` 文件
PHP 实现这样的功能非常的简单，大概不到 10 行代码即可

## ZipArchive 打包文件夹

`ZipArchive` 类使用官方文档：http://php.net/manual/zh/class.ziparchive.php

### 创建 ZipArchive 对象

```php
$zip = new \ZipArchive();
```

### 打开并创建 zip 文件

`$zip_filename` 存储 `zip` 文件的绝对路径

```php
$res = $zip->open($zip_filename, \ZipArchive::CREATE);
```
第二个，参数 `ZipArchive::CREATE` 表示文件不存在时，可以进行创建

参数常用选项（具体可以查看官方文档）：
  - ZipArchive::CREATE
  - ZipArchive::OVERWRITE

### 使用 `addFromString` `addFile` 向 zip 文件中添加文件

如，使用 addFromString 添加一个 `txt` readme 文件
```php
$zip->addFromString('readme.txt', '使用打包下载.');
```
### 关闭文件

```php
$zip->close();
```

### 响应下载

`$filename` 自定义下载文件名称
```php
return response()->download($zip_filename,$filename);
```

