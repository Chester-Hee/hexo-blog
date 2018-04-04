title: Laravel-Admin 用户与权限
author: helingfeng
tags:
  - roles
  - permission
categories:
  - Laravel
  - PHP
  - Admin
date: 2018-04-04 09:59:00
---
## Laravel-Admin 用户与权限

LA 不仅给我们提供快速构建`表单` `表格` `Tree` 工具，还提供一套完善的权限管理方案。

#### LA 权限数据库设计方案

我简单画了一张实体关系图


![upload successful](/images/pasted-30.png)

LA 权限设计中，使用三个实体`用户` `权限` `角色` ，它们之间都是多对多对应关系。
所以，对应的数据库表设计图


![upload successful](/images/pasted-31.png)

### LA 权限控制方式

对于权限的控制访问，LA 给出了多种方式

#### 路由控制

在laravel-admin 1.5中，权限和路由是绑定在一起的，在编辑权限页面里面设置当前权限能访问的路由，在HTTP方法select框中选择访问路由的方法，在HTTP路径textarea中填写能访问的路径。

比如要添加一个权限，该权限可以以GET方式访问路径/admin/users，那么HTTP方法选择GET，HTTP路径填写/users。

我们来分析一下源代码 Middleware\Permission.php

```php
class Permission
{
    public function handle(Request $request, \Closure $next)
    {
        // 如果用户未登录，直接跳过（跳过是让登录验证中间件进行处理）
        if (!Admin::user()) {
            return $next($request);
        }

        // 判断用户是否存在此权限，若存在允许访问，否则返回异常
        if (!Admin::user()->allPermissions()->first(function ($permission) use ($request) {
            return $permission->shouldPassThrough($request);
        })) {
            AuthPermission::error();
        }

        return $next($request);
    }
}
```

在这里要解释一下权限项是什么，LA中的一个权限项，包含三个部分`权限标识` `请求方式集合` `请求路径集合`

权限标识 = hello
请求方式集合 = ['GET', 'POST'] = 支持GET/POST
请求路径集合 = ['/admin/logs','/admin/users'] = 允许访问 logs/users 路径


![upload successful](/images/pasted-32.png)

Admin::user()->allPermissions() // 获取所有权限
具体实现

```php
public function allPermissions() : Collection
{
    // 这里实现思路是，获取 用户角色对应权限 并集 当前用户权限
    return $this->roles()->with('permissions')->get()->pluck('permissions')->flatten()->merge($this->permissions);
}
```

#### 页面控制


##### 场景1

比如现在有一个场景，对文章发布模块做权限管理，以创建文章为例

首先创建一项权限，进入/admin/auth/permissions，权限标识（slug）填写create-post，权限名称填写创建文章，这样权限就创建好了。 第二步可以把这个权限直接附加给个人或者角色，在用户编辑页面可以直接把上面创建好的权限附加给当前编辑用户，也可以在编辑角色页面附加给某个角色。 第三步，在创建文章控制器里面添加控制代码：

```php
use Encore\Admin\Auth\Permission;

class PostController extends Controller
{
    public function create()
    {
        // 检查权限，有create-post权限的用户或者角色可以访问创建文章页面
        Permission::check('create-post');
    }
}
```

##### 场景2

如果你要在表格中控制用户对元素的显示，那么需要先定义两个权限，比如权限标示delete-image、和view-title-column分别用来控制有删除图片的权限和显示某一列的权限，把这两个权限赋给你设置的角色，然后在grid中加入代码：

```php
$grid->actions(function ($actions) {

    // 没有`delete-image`权限的角色不显示删除按钮
    if (!Admin::user()->can('delete-image')) {
        $actions->disableDelete();
    }
});

// 只有具有`view-title-column`权限的用户才能显示`title`这一列
if (Admin::user()->can('view-title-column')) {
    $grid->column('title');
}
```

在blade模板中，可以这样使用

```php

@if(Admin::user()->can('set'))
    // 修改系统变量
@endif

```

##### 中间件控制

可以在路由配置上结合权限中间件来控制路由的权限

```php
// 允许administrator、editor两个角色访问group里面的路由
Route::group([
    'middleware' => 'admin.permission:allow,administrator,editor',
], function ($router) {

    $router->resource('users', UserController::class);
    ...

});
```

这篇博客部分摘要LA文档，如果你想了解更多，可以阅读源码！！！