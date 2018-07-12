---
title: JavaScript兼容性解决方式
author: John Doe
translate_title: javascript-compatibility-solution
date: 2018-04-02 17:20:34
tags:
---
#### 前端兼容问题出现的原因

何为操作系统？**操作系统（Operating System）**是管理和控制计算机硬件与软件资源的计算机程序。是的，任何的应用软件必须在操作系统的支持下运行。

大家会疑问？为什么我要讲操作系统？你猜！

其实，我只想表述我自己的一个观点，“Web浏览器是Web应用的操作系统”。这句话来源于JavaScript权威指南。

正因为Web浏览器（IE、Mozilla、Apple、Google、360浏览器、QQ浏览器）的多样性，才出现了所谓的兼容性问题。

编写一个JavaScript程序并能正确运行在这么多平台之上，的确是一种挑战。


#### 前端兼容性主要有哪些问题

- **软件更新**；在web平台的发展中，一个标准规范会倡导一个新的特性或API。是的，浏览器开发商觉得某个特性很不错，那他可能在浏览器中实现它。如果某个特性有非常多的开发商实现，那么这个特性或API就会广泛使用，但是某个特性的实现会有一个先后的过程，导致一个结果“旧的浏览器不支持这个特性”。

- **设计差异**；浏览器开发商们同样实现一个特性或API，但他们的观点和编码风格差异，同样的一个功能在同的浏览器中也会有很大的差别。

- **软件BUG**；任何的软件都存在BUG，Web浏览器也是一个软件。并且没有按照规范准确实现客户端的JavaScriptAPI

#### 如何处理兼容性问题

如果你去面试一个前端工程师，面试官最常问的一个问题：如何解决浏览器的兼容性问题？


- 功能测试（capability testing）是解决不兼容问题的一种强大技术。

```
if(element.addEventListener){
    //W3C方法
    element.addEventListener("keydown",handler,false);
    element.addEventListener("keypress",handler,false);
}else if(element.attachEvent){
    //IE方法
    element.attachEvent("onkeydown",handler);
    element.attachEvent("onkeypress",handler);
}else{
    //选择广泛使用方式
    element.onkeydown = element.onkeypress = handler;
}
```

- 处理兼容性问题其中最简单的方法就是使用类库（JQuery、Zepto、Excanvas），前两者定义了新的客户端API并兼容所有浏览器。例如，JQuery处理事件程序注册通过Bind进行完成。
但是，有时候为了实现一个非常简单的功能，透明地实现整个标准并非真正可行。

例如，我的一个应用：只在页面实现一个Ajax请求！

**使用兼容性类库：**

```
<script src="./core/zepto.min.js"></script> 24k
<script>
    $.ajax({
            type: 'GET',
            url: './index.html',
            data: {}, //参数
            dataType: 'html', //返回类型
            success: function(data){
                //成功回调
            },
            error: function(xhr, type){
                alert('Ajax error!')
            }
      });
</script>
```

**使用原生JavaScript:**

```
var xml_http;
if (window.ActiveXObject) {
    xml_http = new ActiveXObject("Microsoft.XMLHTTP");
} else if (window.XMLHttpRequest) {
    xml_http = new XMLHttpRequest();
}
xml_http.open("GET", "./index");
xml_http.send(null);
xml_http.onreadystatechange = function () {
    if ((xml_http.readyState == 4) && (xml_http.status == 200)) {
        alert('success');
    } else {
        alert('fail');
    }
}
```

　　考虑兼容性问题时，要考虑适中的方法引用。

- 分级浏览器支持（graded browser support）是由Yahoo率先提出的一种测试技术。

从某种维度将浏览器版本/操作系统变体进行分级，使用不同的测试用例，从而解决兼容性问题。

- Internet Explorer是的条件注释

其实我们不难发现，客户端JavaScript编程中的很多不兼容性问题都是针对IE的，也就是说必须按照某种方式为IE编写代码，而按照另一种方式为其他浏览器编写代码。IE支持条件注释。

```
<!–[if lt IE 8]>
<script src=”http://ie7-js.googlecode.com/svn/version/2.0(beta)/IE8.js” type=”text/javascript”></script>
<![endif]–>
<!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
<!--[if lt IE 9]>
<script src="__STATIC__/bootstrap/js/html5shiv.js?v={:SITE_VERSION}"></script>
<![endif]-->
<block name="style"></block>
<!--[if lt IE 9]>
<script type="text/javascript" src="__STATIC__/jquery-1.10.2.min.js"></script>
<![endif]-->
<!--[if gte IE 9]><!-->
<script type="text/javascript" src="__STATIC__/jquery-2.0.3.min.js"></script>
<!--<![endif]-->
```

> 本文只是简单讲解了前端JavaScript脚本的兼容性问题原因及解决办法，当然，这些都只是一个基础的篇章。
