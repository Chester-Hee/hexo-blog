---
title: Laravel 实现页面静态缓存
author: helingfeng
tags:
  - PHP
  - Composer
  - Laravel
  - Cache
categories:
  - PHP
date: 2019-05-24 17:30:00
---

## 页面静态缓存

页面缓存就是在用户访问页面时，直接返回静态文件，减少了每次请求的业务处理和模板渲染，从而提高网站的`QPS`。在许多实时性要求不高的场景，或者纯查询和展示数据的页面，添加静态页面缓存并合理的配置缓存有效期可以有效的提升网站性能。

## Laravel 页面静态缓存

附上代码地址：https://github.com/freedoomcode/laravel-page-cache

我编码功底有限，建议不嫌多

### 实现思路

- 对于请求前后的处理，我们想到的是中间件（请求过滤器）

```php
public function handle($request, Closure $next, $guard = null)
{
    // 请求之前处理
    $response = $next($request);
    // 请求之后处理
    return $response;
}
```

- 请求直接，我们对请求`path`+`query`进行编码作为文件名

```php
$fileName = md5($uri);
```

- 并使用此文件名搜索是否存在文件，如果文件存在，若存在直接读取返回

```php
$fileName = $this->getRealFileNameByPath($request->getRequestUri());
if (is_file($fileName)) {
    return response(file_get_contents($fileName));
}
```

- 若不存在则将当期页面的响应内容写入文件，为了确保内容正确，判断响应状态码是否为`200`。并对正在写入的文件进行加锁。

```php
if ($response->getStatusCode() == 200) {
    $content = $response->getContent();
    if (!is_file($fileName)) {
        file_put_contents($fileName, $content, LOCK_EX);
    }
}
```

### 分布式支持

起初，我想将整个页面文档存入`Redis`中，但测试发现导致`Redis`网络占用非常高，因为单个页面大小为`100K+`，同时访问将会不断读取`Redis`。最后，我将页面保存在服务器文件中。

但是，如果存在多台服务器，那么如何统一更新页面缓存呢？所以还需要共享一个键值，我将这个键值存储在`Redis`中，这个键值相当于每个服务存储静态文件的所在路径。更新这个键值就相当于更新文件所在路径。

```php
$key = env('STATIC_HTML_CACHE_DIR_KEY', 'static_html_directory');
$expires = env('STATIC_HTML_CACHE_EXPIRE', 30);
if(Cache::has($key)) {
    $directory = Cache::get($key, date('YmdHis'));
} else {
    $directory = date('YmdHis');
    Cache::put($key, $directory, $expires);
}
// 完整的路径为 storage + directory
$fullPath = $prefix . DIRECTORY_SEPARATOR . $directory;
```

将文件存储在每台服务器中，均衡负载的压力，如果可以将静态文件存储在内存中，效果会更佳，使用`Swoole`应该可以实现。


### 更新缓存

刷新指定`Redis`键值即可
```php
 Cache::put($key, date('YmdHis'), $expires);
```

### 思考？

这种思路，只适合小产品，可能还会存在其他的问题，所以需要慎用。不过，敢于尝试才会懂得！