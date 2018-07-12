---
title: PHP-JavaScript-Transformer
author: helingfeng
tags: []
categories:
  - PHP
  - Transfer
translate_title: phpjavascripttransformer
date: 2018-04-04 13:44:00
---
## PHP-JavaScript-Transformer

https://github.com/helingfeng/PHP-JavaScript-Transformer

将PHP变量转换成JavaScript变量扩展包，避免直接echo带来的JavaScript语法问题。

### Installation

配置追加composer.json文件

```
 "repositories": [
    {
      "type": "git",
      "url": "https://github.com/helingfeng/PHP-JavaScript-Transformer.git"
    }
  ]
```

执行 require

```
composer require helingfeng/php-java-script-transformer 1.0

## 成功输出
./composer.json has been updated
Loading composer repositories with package information
 - Installing helingfeng/php-java-script-transformer (1.0): Cloning c88a2cc375 from cache
Writing lock file
Generating autoload files

```

### Usage


#### PHP变量转换JavaScript

- 字符串 String

```
$transfer = new JavaScriptTransformer();

$script = $transfer->put(['username'=>'helingfeng']);

echo $script;



# output

window.username = 'helingfeng';


```

- 数组 Array

```
$transfer = new JavaScriptTransformer();

$script = $transfer->put(['person'=>['name'=>'helingfeng','age'=>18]]);

echo $script;


# output 

window.person = {"name":"helingfeng","age":18};

```

#### 使用不同的作用域，默认window

```
$transfer = new JavaScriptTransformer('home');

$script = $transfer->put(['person'=>['name'=>'helingfeng','age'=>18]]);

echo $script;

# output 

window.home = window.home || {};home.person = {"name":"helingfeng","age":18};

```

