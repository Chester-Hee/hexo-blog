---
title: PHP 文件下载乱码
author: helingfeng
tags: []
categories:
  - PHP
translate_title: php-file-download-garbled
date: 2018-04-02 15:36:00
---
### download filename

经常在IE/Firefox浏览器遇到php下载文件名乱码问题，下面代码可以完美解决。

```php

$encoded_filename = urlencode($filename);
$encoded_filename = str_replace("+", "%20", $encoded_filename);

if (preg_match("/MSIE/", request()->userAgent())) {
	header('Content-Disposition: attachment; filename="' . $encoded_filename . '"');
} else if (preg_match("/Firefox/", request()->userAgent())) {
	header('Content-Disposition: attachment; filename*="utf8\'\'' . $filename . '"');
} else {
	header('Content-Disposition: attachment; filename="' . $filename . '"');
}

```