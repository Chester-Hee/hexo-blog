---
title: POST 请求 application/x-www-form-urlencoded 与 multipart/form-data
author: helingfeng
tags:
  - POST
categories:
  - HTTP
translate_title: form-content-types
date: 2019-07-10 15:55:00
---

如何正确选择 `Form` 的 `Content-type` 类型？

- 1. `application/x-www-form-urlencoded`，表单默认的 `Content-type` 类型，支持 `ASCII` 的 `text` 文本内容
- 2. `multipart/form-data`，允许提交表单包含： `files`，`non-ASCII`，`Binary`
- 3. `Row`，用于发送纯文本，或 `JSON` ，或其他类型字符串，客户端不会对数据做任何的修改
- 4. `Binary`，用于请求需要附带非文本的数据，比如 `video/audio` 或者 `images` 或者其他 `Binary` 数据文件

## application/x-www-form-urlencoded

当表单使用 `application/x-www-form-urlencoded` 时，需要对参数进行`urlencode 编码`和`序列化`

如，表单提交参数（key-value）为：
```
param1:website
param2:https://www.google.com
```

经过 `urlencode` 编码后：

```
param1:website
param2:https%3A%2F%2Fwww.google.com
```

再经过序列化，得到结果

```
param1=website&param2=https%3A%2F%2Fwww.google.com
```

## multipart/form-data

一个 ` multipart/form-data` 消息体，包含多个块组成，每个块代表一个有效的表单控件，并使用 `boundary` 的字符串分割：

- 1. 第一部分，`Content-Disposition: form-data` 参数名称，如，`name="my_control`
- 2. 第二部分，`Content-Type: text/plain`

例如表单：

```
<FORM action="http://server.com/cgi/handle"
       enctype="multipart/form-data"
       method="post">
   <P>
   What is your name? <INPUT type="text" name="submit-name"><BR>
   What files are you sending? <INPUT type="file" name="files"><BR>
   <INPUT type="submit" value="Send">
   <INPUT type="reset">
</FORM>
```

假设，`submit-name` 输入 `Larry` 文本，`files` 选择文件 `file1.txt`

```
Content-Type: multipart/form-data; boundary=AaB03x

--AaB03x
Content-Disposition: form-data; name="submit-name"

Larry
--AaB03x
Content-Disposition: form-data; name="files"; filename="file1.txt"
Content-Type: text/plain

... contents of file1.txt ...
--AaB03x--
```

参考文献：https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4




