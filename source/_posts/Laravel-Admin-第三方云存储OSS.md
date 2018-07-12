---
title: Laravel-Admin 第三方云存储OSS
author: helingfeng
tags:
  - 云存储
categories:
  - Laravel
  - OSS
translate_title: laraveladmin-thirdparty-cloud-storage-oss
date: 2018-04-04 10:35:00
---
## Laravel 

laravel 驱动模式设计filesystem. 本身就有`OSS`第三方云存储解决方案.

#### 安装扩展

https://github.com/jacobcyl/Aliyun-oss-storage

这个扩展借鉴了一些优秀的代码，综合各方，同时做了更多优化，将会添加更多完善的接口和插件，打造Laravel最好的OSS Storage扩展


##### composer require

```shell
composer require jacobcyl/ali-oss-storage:^2.1
```

##### add provider

```php
Jacobcyl\AliOSS\AliOssServiceProvider::class,
```

##### modify filesystems.php

```php
'disks'=>[
    ...
    'oss' => [
            'driver'        => 'oss',
            'access_id'     => '<Your Aliyun OSS AccessKeyId>',
            'access_key'    => '<Your Aliyun OSS AccessKeySecret>',
            'bucket'        => '<OSS bucket name>',
            'endpoint'      => '<the endpoint of OSS, E.g: oss-cn-hangzhou.aliyuncs.com | custom domain, E.g:img.abc.com>', // OSS 外网节点或自定义外部域名
            //'endpoint_internal' => '<internal endpoint [OSS内网节点] 如：oss-cn-shenzhen-internal.aliyuncs.com>', // v2.0.4 新增配置属性，如果为空，则默认使用 endpoint 配置(由于内网上传有点小问题未解决，请大家暂时不要使用内网节点上传，正在与阿里技术沟通中)
            'cdnDomain'     => '<CDN domain, cdn域名>', // 如果isCName为true, getUrl会判断cdnDomain是否设定来决定返回的url，如果cdnDomain未设置，则使用endpoint来生成url，否则使用cdn
            'ssl'           => <true|false> // true to use 'https://' and false to use 'http://'. default is false,
            'isCName'       => <true|false> // 是否使用自定义域名,true: 则Storage.url()会使用自定义的cdn或域名生成文件url， false: 则使用外部节点生成url
            'debug'         => <true|false>
    ],
    ...
]

```

如果你想默认使用OSS存储

```php
'default' => 'oss',
```

##### usage

```
use Illuminate\Support\Facades\Storage;

Storage::disk('oss'); // if default filesystems driver is oss, you can skip this step

Storage::get('path/to/file/file.jpg'); // get the file object by path
Storage::exists('path/to/file/file.jpg'); // determine if a given file exists on the storage(OSS)

Storage::delete('file.jpg');

Storage::put('path/to/file/file.jpg', $contents); //first parameter is the target file path, second paramter is file content


```


#### Laravel-Admin 配置OSS存储


##### modify config/admin.php

```php
[
	...
    'upload' => [
        'disk' => 'oss',
        'directory' => [
            'image' => 'admin/images',
            'file' => 'admin/files',
        ],
    ],
    ...
]
```

#### 私有OSS 使用

私有存储，只是对应的Bucket参数配置不同。

所以我们可以修改 bucket name

```php
'disks'=>[
    ...
    'oss' => [
            'bucket'        => '<OSS bucket name>',
    ],
    ...
]

```

对应私有的存储，我们是不可以直接通过云存储链接直接访问的，所以需要用到上面的get方法

```php
Storage::get('path/to/file/file.jpg'); // get the file object by path
```

通过返回一个文件，从而实现私有文件的读取，例如返回一张私有图片

```php
$result = Storage::get($path);

return response($result, 200, [
   'Content-Type' => 'image/jpeg',
]);
```

但是这个路由需求做权限控制，才能满足图片的`私有性`

