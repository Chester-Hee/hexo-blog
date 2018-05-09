title: UEditor 百度编辑器使用 PHP 上传图片
author: helingfeng
tags:
  - UEditor
categories:
  - UEditor
  - PHP
date: 2018-05-09 15:12:00
---
## 什么是 UEditor

UEditor 是由百度 web 前端研发部开发所见即所得富文本 web 编辑器，具有轻量，可定制，注重用户体验等特点，开源基于MIT协议，允许自由使用和修改代码...

## UEditor 下载安装

下载：
http://ueditor.baidu.com/website/

演示：
http://ueditor.baidu.com/website/onlinedemo.html

## 如何使用 UEditor

### HTML 容器
```html
<script id="content" type="text/plain">
    {!! $content !!}
</script>
```

### JavaScript 脚本
```JavaScript

// 这个是开启组件
var ueditorConfig = [[
    'source', 'fullscreen','bold', 'link', 'simpleupload', 'inserttable', 'undo', 'redo',
    'forecolor', 'backcolor','paragraph', 'fontfamily', 'fontsize',
    'justifyleft', 'justifycenter', 'justifyright', 'justifyjustify',
]];

// 初始化编辑器
var ue = UE.getEditor('content',{
    serverUrl: 'your_server',
    toolbars: ueditorConfig,
    catchRemoteImageEnable: false,   // 关闭 catchRemoteImage
    autoHeightEnabled: false
});
```

### 上传图片 your_server 服务配置

百度编辑器图片上传原理： 

- 首先，会提交一个请求 action=config 去获取服务器配置信息，我们可以根据需求返回对应的上传配置信息
- 其次，用户提交上传图片时，编辑器会根据 config 配置上传地址，创建 form 对象异步上传文件
- 最后，服务器根据文档，返回上传的结果 json 数据

时序图：

!(screen)[/images/screen_4.png]

### PHP 后端代码

以 Laravel 为例：

```php
public function editUploadServer()
{
    $action = request()->input('action');
    $result = ['state' => 'callback参数不合法'];
    switch ($action) {
    
        case 'config':
            $config = [
                "imageActionName" => 'upload_image',
                "imageFieldName" => "upfile",
                "imageMaxSize" => 2048000,
                "imageUrlPrefix" => "",
                "imageAllowFiles" => [".png", ".jpg", ".jpeg", ".gif"]
            ];
            $result = $config;
            break;

        case 'upload_image':
            $files = request()->file('upfile');
            if ($file->isValid()) {
                $ext = $file->getClientOriginalExtension();
                $realPath = $file->getRealPath();
                $size = $file->getSize();

                $filename = config('admin.upload.directory.image') . '/' . date('Y-m-d-H-i-s') . '-' . uniqid() . '.' . $ext;
                $result = array(
                    "state" => "SUCCESS",                           //上传状态，上传成功时必须返回"SUCCESS"
                    "url" => 'https://xxx.xxx.com/' . $filename,    //返回的地址
                    "title" => $filename,                           //新文件名
                    "original" => $file->getClientOriginalName(),   //原始文件名
                    "type" => $file->getClientMimeType(),           //文件类型
                    "size" => $size,
                );
                $result = Storage::put($filename, file_get_contents($realPath));
                if (!$result) {
                    $result['state'] = "ERROR";
                }
            }
            break;
    }
    return response()->json($result, 200, [], JSON_UNESCAPED_UNICODE);
}
```



