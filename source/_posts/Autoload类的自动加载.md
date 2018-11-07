---
title: Autoload类的自动加载
author: Chester-He
tags:
  - PHP
  - Composer
categories:
  - PHP
date: 2018-11-05 14:00:00
---

## 类的自动加载

PHP面向对象程序设计过程中，必然需要定义很多类，也就是非常多的.PHP文件。在PHP5之前，我们如果在一个类中引用另一个类，需要在这个类的文件头部加上`require`或者`include`。
但是，如果我们的系统非常复杂，涉及极多的类时，这样的操作显得非常繁琐。

在PHP5中，已经不再需要这样了。 `spl_autoload_register()` 函数可以注册任意数量的自动加载器，当使用尚未被定义的类和接口时自动去加载。通过注册自动加载器，脚本引擎在PHP出错失败前有了最后一个机会加载所需的类。

---

尝试分别从 MyClass1.php 和 MyClass2.php 文件中加载 MyClass1 和 MyClass2 类

```php
<?php
spl_autoload_register(function ($class_name) {
    require_once $class_name . '.php';
});

$obj  = new MyClass1();
$obj2 = new MyClass2();
?>
```

将一个异常抛给不存在的自定义异常处理函数

```php
<?php
spl_autoload_register(function ($name) {
    echo "Want to load $name.\n";
    throw new MissingException("Unable to load $name.");
});

try {
    $obj = new NonLoadableClass();
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
?>
```

### Composer 自动加载

`composer` 提供了四种自动加载类型

- classmap
- psr-0
- psr-4
- files

这几种自动加载平常的框架都用到，通常来看，项目代码用`psr-4`自动加载， 如`Laravel`框架的函数库`helper`用`files`自动加载，`development`相关用`classmap`自动加载，而`psr-0`已经弃用，有事兼容古老的代码还会用到。

#### classmap

`composer`会扫描指定目录下以`.php` 或`.inc`结尾的文件中的`class`，生成`class`到指定`file-path`的映射(Key-Value)，并加入新生成的`vendor/composer/autoload_classmap.php`文件中

例如：

配置扫描路径
```php
{
  "autoload": {
    "classmap": ["src/"]
  }
}
```

生成结果文件
```php
<?php
return array(
    'BaseController' => $baseDir . '/src/BaseController.php'
);
?>
```

#### psr-4

#### files

###