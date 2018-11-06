---
title: Laravel Blade 模板
author: helingfeng
translate_title: laravel-blade-template
date: 2018-05-01 18:20:49
tags:
  - Laravel
categories:
  - Laravel
---
## Laravel-Blade 模板引擎

### 简介

Blade 是Laravel所提供的一个简单并且强大的模板引擎，视图文件以`.blade` 做为扩展名，通常保存在views文件夹中

### Blade-Engine原理

Laravel是基于服务容器的，模板引擎也不例外，在上一篇Laravel源码分析文章中，初始化`注册核心容器的别名访问`

```php
$this->registerCoreContainerAliases();

'view'  => ['Illuminate\View\Factory', 'Illuminate\Contracts\View\Factory'],
```

我们首先了解一下源码结构，可以简单得出类的依赖关系，`View`依赖于`Engines`，`Engines`依赖于`Compilers`

```php
├── Compilers
│   ├── BladeCompiler.php
│   ├── CompilerInterface.php
│   └── Compiler.php
├── composer.json
├── Engines
│   ├── CompilerEngine.php
│   ├── EngineInterface.php
│   ├── Engine.php
│   ├── EngineResolver.php
│   └── PhpEngine.php
├── Expression.php
├── Factory.php
├── FileViewFinder.php
├── Middleware
│   └── ShareErrorsFromSession.php
├── ViewFinderInterface.php
├── View.php
└── ViewServiceProvider.php
```

#### 代码执行流程

执行流程分解`return view('index');`


##### $view->render()

这里将engine当做`黑盒`，传入文件以及参数，得到contents内容.

```php
return $this->engine->get($this->path, $this->gatherData());
```

##### $engine->get()

这里会根据view文件名称生成对应的MD5缓存文件，如果文件发生更新，对应缓存文件也会刷新
```php
public function get($path, array $data = [])
{
    if ($this->compiler->isExpired($path)) {
        $this->compiler->compile($path);
    }

    $compiled = $this->compiler->getCompiledPath($path);
    ...
}
```

##### token_get_all()

模板引擎核心是使用`token_get_all()`语法分析器，这个函数返回语法分析结果数组，遍历返回数组，得到类型为`T_INLINE_HTML`数据，并对其进行Blade编译。

```php
protected $compilers = [
    'Extensions',
    'Statements',
    'Comments',
    'Echos',
];
```

```php
- Extensions对应的是的自定义Blade扩展标签，最后会用到。
- Statements是最重点的一个，包括所有@开头的标签，如`@include`,`@extends`,`@foreach`
- Comments是编译注解的
- Echos是编译`{{`,`{!!`,`{{{`这几种输出方式的，下午也会介绍如何使用
```

```php
public function compileString($value)
{
    $this->footer = [];

    foreach (token_get_all($value) as $token) {
        $result .= is_array($token) ? $this->parseToken($token) : $token;
    }
    
    $result. = array_reverse($this->footer);
    ...
}
```

#### 模板继承与区块

源代码实现继承原理其实并不复杂，使用用户级别的输出缓冲区`ob_start`

Blade 的两个最大优点就是`模板继承`与`区块`

```php
`@section` 命令定义一个内容区块，而 `@yield` 命令被用来 “显示指定区块” 的内容

<html>
    <head>
        <title>应用程序名称 - @yield('title')</title>
    </head>
    <body>
        @section('sidebar')
            这是主要的侧边栏。
        @show

        <div class="container">
            @yield('content')
        </div>
    </body>
</html>
```

继承页面布局

```php
@extends('layouts.master')

@section('title', '页面标题')

@section('sidebar')
    @parent

    <p>这边会附加在主要的侧边栏。</p>
@endsection

@section('content')
    <p>这是我的主要内容。</p>
@endsection



在这个例子中，sidebar 区块利用了 @parent 命令增加（而不是覆盖）内容至布局的侧边栏。@parent 命令会在视图输出时被置换成布局的内容
```


#### 显示数据

你可以像这样显示 name 变量的内容：

```php
Hello, {{ $name }}.

注意：`Blade` 的 `{{ }}` 语法会自动调用 `PHP htmlentites` 函数来防御 XSS 攻击。

由于许多 JavaScript 框架也使用「大括号」在浏览器中显示指定的表达式，因此可以使用 @ 符号来告知 Blade 渲染引擎该表达式应该维持原样。举个例子：

<h1>Laravel</h1>

Hello, @{{ name }}.

```


#### 控制结构

判断

你可以使用 `@if`、`@elseif`、`@else` 及 `@endif` 命令建构 if 表达式。这些命令的功能等同于在 PHP 中的语法：

```php
@if (count($records) === 1)
    我有一条记录！
@elseif (count($records) > 1)
    我有多条记录！
@else
    我没有任何记录！
@endif
```

循环

```php
@for ($i = 0; $i < 10; $i++)
    目前的值为 {{ $i }}
@endfor

@foreach ($users as $user)
    <p>此用户为 {{ $user->id }}</p>
@endforeach

@forelse ($users as $user)
    <li>{{ $user->name }}</li>
@empty
    <p>没有用户</p>
@endforelse
```


### 子视图
Blade 的 `@include` 命令用来引入已存在的视图，所有在父视图的可用变量在被引入的视图中都是可用的

```php
@include('view.name', ['some' => 'data'])
```


### 扩充 Blade

Blade 甚至允许你自定义命令，你可以使用 `directive` 方法注册命令。当 Blade 编译器遇到该命令时，它将会带参数调用提供的回调函数。

以下例子会创建一个把指定的 `$var` 格式化的 `@datetime($var)` 命令：

```php
class AppServiceProvider extends ServiceProvider
{
    /**
     * 运行服务注册后的启动进程。
     *
     * @return void
     */
    public function boot()
    {
        Blade::directive('datetime', function($expression) {
            return "<?php echo with{$expression}->format('m/d/Y H:i'); ?>";
        });
    }
}
```

如你所见，Laravel 的 with 辅助函数被用在这个命令中。with 辅助函数会简单地返回指定的对象或值，并允许使用便利的链式调用。最后此命令生成的 PHP 会是：

```php
<?php echo with($var)->format('m/d/Y H:i'); ?>
```