title: Laravel PHP 导出 csv 文件
author: helingfeng
tags:
  - csv
categories:
  - Laravel
  - csv
date: 2018-05-14 14:12:00
---
## 导出 csv 
通常一个实际的产品都会需要数据统计和分析，这时，就需要从当前产品业务数据库中导出数据，而导出数据格式中，最基本的就是 csv 格式

## 代码实现

### 设置头信息

设置响应头部信息；如下，设置 Content-Type:text/csv; Content-Disposition="attachment; filename=xxx.csv"
```php
$headers = [
    'Content-Encoding' => 'UTF-8',
    'Content-Type' => 'text/csv;charset=UTF-8',
    'Content-Disposition' => "attachment; filename=xxx.csv",
];
```
### 响应文件流

使用 PHP `fwrite` `fputcsv` `fclose` 进行操作 csv 文件
文件的开始需要写入 `chr(0xEF)` `chr(0xBB)` `chr(0xBF)` 字符，保证正常的编码（否则，可能出现乱码情况）

首先，打开文件 `fopen('php://output', 'w');`
第一步，写入编码描述 `fwrite($handle, chr(0xEF) . chr(0xBB) . chr(0xBF));`
第二步，写入第一行列描述 `fputcsv($handle, $titles);`
第三步，循环写入数据行，`fputcsv($handle, $item);`
第四步，关闭文件流 `fclose($handle);`

```php
response()->stream(function () {
    $handle = fopen('php://output', 'w');
    fwrite($handle, chr(0xEF) . chr(0xBB) . chr(0xBF));

    $titles = ['title1', 'title2', 'title3'];
    fputcsv($handle, $titles);

    $result = DB::connection(config('database.default'))->table('table')->get()->toArray();
    foreach ($result as $item) {
        fputcsv($handle, $item);
    }
    // Close the output stream
    fclose($handle);
}, 200, $headers)->send();
```

上述代码是在 Laravel 5.5 中编写
