---
title: 前端使用 JavaScript 压缩图片
author: Chester-He
tags:
  - JavaScript
  - canvas
categories:
  - JavaScript
translate_title: use-javascript-compressed-pictures
date: 2019-06-26 20:00:00
---

## JavaScript 压缩图片

☘️WEB前端上传文件到远程时，我们都会遇到同样一个问题，请求长度超出限制，是的，**文件大小超出限制**该如何解决？

我这里有两种方案：

- 第一种，**前端压缩**后上传图片
- 第二种，**分块上传**，后台进行压缩存储
- 其实有第三种，不允许上传此文件 😅

如果只考虑第一种方案，前端压缩图片后上传，对于压缩图片的大小和质量无法把控，并且非图片类型的文件上传又要考虑非图片类型文件的压缩方法。
第二种方式，实现分块上传对编码要求更高，后端和前端都需要实现可靠的组件。

本篇文章，我们**只了解如何使用前端压缩图片**

我画了一张图，大致描述前端压缩图片整个流程调用

![demo11](/images/demo11.jpg)

使用 `JavaScript` 压缩图片，首先要学习三个`Web API`: `FileReader`，`Canvas`，`Blob`

### FileReader

FileReader 对象允许Web应用程序异步读取存储在用户计算机上的文件（或原始数据缓冲区）的内容，使用 File 或 Blob 对象指定要读取的文件或数据。

成员方法：

- `FileReader.abort()`中止读取操作。在返回时，`readyState`属性为`DONE`。
- `FileReader.readAsArrayBuffer()`开始读取指定的`Blob`中的内容, 一旦完成, `result` 属性中保存的将是被读取文件的 `ArrayBuffer` 数据对象.
- `FileReader.readAsBinaryString()`开始读取指定的Blob中的内容。一旦完成，result属性中将包含所读取文件的原始二进制数据。
- `FileReader.readAsDataURL()`开始读取指定的`Blob`中的内容。一旦完成，`result`属性中将包含一个`data: URL`格式的字符串以表示所读取文件的内容。
- `FileReader.readAsText()`开始读取指定的Blob中的内容。一旦完成，`result`属性中将包含一个字符串以表示所读取的文件内容。

事件处理：

- `FileReader.onabort`处理`abort`事件。该事件在读取操作被中断时触发。
- `FileReader.onerror`处理`error`事件。该事件在读取操作发生错误时触发。
- `FileReader.onload`处理`load`事件。该事件在读取操作完成时触发。
- `FileReader.onloadstart`处理`loadstart`事件。该事件在读取操作开始时触发。
- `FileReader.onloadend`处理`loadend`事件。该事件在读取操作结束时（要么成功，要么失败）触发。
- `FileReader.onprogress`处理`progress`事件。该事件在读取`Blob`时触发

图片压缩过程中，我们需要使用到`FileReader.readAsDataURL()`将文件转换为`DataURL`，并使用`FileReader.onload`事件接收转换结果。

代码实现：
```javascript
var ready = new FileReader();
ready.readAsDataURL(file);
ready.onload = function(){
    var re = this.result;
    // re 为 Base64 DataURL
}
```

### Canvas

HTML5 `<canvas>` 标签用于绘制图像（通过脚本，通常是 JavaScript）。不过，`<canvas>` 元素本身并没有绘制能力（它仅仅是图形的容器） - 您必须使用脚本来完成实际的绘图任务。
 - getContext() 方法可返回一个对象，该对象提供了用于在画布上绘图的方法和属性
 - getContext("2d") 对象属性和方法，可用于在画布上绘制文本、线条、矩形、圆形等等


**drawImage** drawImage() 方法在画布上绘制图像、画布或视频

三种重载方式：

1. context.drawImage(img,x,y); // 在画布上定位图像

2. context.drawImage(img,x,y,width,height); // 在画布上定位图像，并规定图像的宽度和高度

3. context.drawImage(img,sx,sy,swidth,sheight,x,y,width,height); // 剪切图像，并在画布上定位被剪切的部分

图片裁剪过程中，我们将会使用第二种方式，压缩修改图片的大小（实现等比例缩放）

代码实现
```javascript
var img = new Image();
img.src = path;
img.onload = function(){
    var that = this;
    // 等比例缩放
    var w = that.width,
        h = that.height,
        scale = w / h;
    w = obj.width || w;
    h = obj.height || (w / scale);
    var quality = 0.7;
    var canvas = document.createElement('canvas');
    var ctx = canvas.getContext('2d');
    var anw = document.createAttribute("width");
    anw.nodeValue = w;
    var anh = document.createAttribute("height");
    anh.nodeValue = h;
    canvas.setAttributeNode(anw);
    canvas.setAttributeNode(anh);
    ctx.drawImage(that, 0, 0, w, h);
    if(obj.quality && obj.quality <= 1 && obj.quality > 0){
        quality = obj.quality;
    }
    var base64 = canvas.toDataURL('image/jpeg', quality);
}
```

### Blob

`Blob`对象表示一个不可变、原始数据的类文件对象。`Blob`表示的不一定是`JavaScript`原生格式的数据。`File`接口基于`Blob`，继承了`blob`的功能并将其扩展使其支持用户系统上的文件。

要从其他非`blob`对象和数据构造一个`Blob`，请使用`Blob()`构造函数。要创建包含另一个`blob`数据的子集`blob`，请使用`slice()`方法。

此处 `slice()` 也是用于分块上传的调用方法

本文前端压缩图片流程，我们只需要用到`Blob()`构造函数

下面代码实现：DataURL 创建 Blob 对象，提供上传表单`form-data`使用：

```javascript
function dataURLtoFile(dataurl, filename) {
  var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1],
    bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
  while(n--){
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new File([u8arr], filename, {type:mime});
}
```

### 图片拍摄角度问题

首先来了解一个概念 `EXIF` 是什么?

简单来说，`Exif`信息就是由数码相机在拍摄过程中采集一系列的信息，然后把信息放置在我们熟知的`JPEG/TIFF`文件的头部，也就是说`Exif`信息是镶嵌在 `JPEG/TIFF`图像文件格式内的一组拍摄参数。主要包含了以下几类信息：

- 拍摄日期
- 摄器材（机身、镜头、闪光灯等
- 拍摄参数（快门速度、光圈F值、ISO速度、焦距、测光模式等
- 图像处理参数（锐化、对比度、饱和度、白平衡等）
- 图像描述及版权信息
- GPS定位数据
- 缩略图

其中`orientation`记录着拍摄后图片旋转的角度信息

| orientation | 旋转角度 |
|:----:|:----:|
| 1	| 0° |
| 3	| 180°|
| 6	| 顺时针90°|
| 8	| 逆时针90°|

所以，上传图片时，需要将图片进行反向旋转，才能得到一致的展示效果。

开始旋转图片之前，我们需要获取图片旋转信息，需要引入扩展：https://github.com/exif-js/exif-js

然后，就可以编写代码实现：（所有的旋转都是以原点为中心的）
```javascript
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');
const anw = document.createAttribute('width');
const anh = document.createAttribute('height');
anw.nodeValue = w;
anh.nodeValue = h;
switch (orientation) {
  case 6: // 90度，所以进行-90度旋转
    anw.nodeValue = h;
    anh.nodeValue = w;
    canvas.setAttributeNode(anh);
    canvas.setAttributeNode(anw);
    ctx.rotate(Math.PI / 2);
    ctx.drawImage(this, 0, -h, w, h);
    break;
  case 3: // 180度，所以进行-180度旋转
    canvas.setAttributeNode(anh);
    canvas.setAttributeNode(anw);
    ctx.rotate(Math.PI);
    ctx.drawImage(this, -w, -h, w, h);
    break;
  case 8: // -90度，所以进行90度旋转
    anw.nodeValue = h;
    anh.nodeValue = w;
    canvas.setAttributeNode(anh);
    canvas.setAttributeNode(anw);
    ctx.rotate(3 * Math.PI / 2);
    ctx.drawImage(this, -w, 0, w, h);
    break;
  default: // 0度，不进行旋转
    canvas.setAttributeNode(anh);
    canvas.setAttributeNode(anw);
    ctx.drawImage(this, 0, 0, w, h);
}
```