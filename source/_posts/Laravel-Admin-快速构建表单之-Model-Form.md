---
title: Laravel Admin 快速构建表单之 Model-Form
author: helingfeng
tags: []
categories:
  - Laravel
  - PHP
  - Admin
translate_title: laravel-admin-quickly-build-forms-of-modelform
date: 2018-04-03 19:58:00
---
## Laravel Admin 快速构建表单之 Model-Form

上一篇博客中完成了对Model-Grid的源码阅读与分析。那么列表查询实现了，那如何新增和更新数据呢？LA给我们提供了什么快速构建表单的工具呢？
恩！！！没错，Model-Form 就是本文要去了解的内容。

我们先体验一下LA带给我们的快速构建表单的惊喜

举个例子，新增与编辑 用户角色

```php
public function edit($id)
{
    return Admin::content(function (Content $content) use ($id) {
        $content->header(__db_trans('admin.roles'));
        $content->description(__db_trans('admin.edit'));
        $content->body($this->form()->edit($id));
    });
}

public function create()
{
    return Admin::content(function (Content $content) {
        $content->header(__db_trans('admin.roles'));
        $content->description(__db_trans('admin.create'));
        $content->body($this->form());
    });
}

public function form()
{
    return Admin::form(Role::class, function (Form $form) {
        $form->display('id', 'ID');

        $form->text('slug', __db_trans('admin.slug'))->rules('required');
        $form->text('name', __db_trans('admin.name'))->rules('required');
        $form->listbox('permissions', __db_trans('admin.permissions'))->options(Permission::all()->pluck('name', 'id'));

        $form->display('created_at', __db_trans('admin.created_at'));
        $form->display('updated_at', __db_trans('admin.updated_at'));
    });
}

```

上面在LA中代码运行结果截图


![upload successful](/images/pasted-28.png)


#### Admin::content(function(){})


这个方法我们依旧不去关心，我们重点还是放在 $content->body($this->form()); 和 $content->body($this->form()->edit($id));

调用了一个自身的方法 $this->form()

````php
return Admin::form(Role::class, function (Form $form) {});
````


#### $this->form()

同样，LA的Model都必须继承一个基础类 或者 trait
也就是 AdminBuilder

AdminBuilder 中 form 做了两件事，注册字段类型，新建了Form对象

```php
public static function form(\Closure $callback)
{
    Form::registerBuiltinFields();
    return new Form(new static(), $callback);
}
```

#### Form 构造方法


```php
public function __construct($model, Closure $callback)
{
    $this->builder = new Builder($this);
    $callback($this);
}
```

$this->builder = new Builder($this);  完成变量初始化，并构建Tool（`返回` `列表` 按钮）工具。
$callback($this) 是form中数据类型的定义阶段，其中LA 1.5支持的数据类型非常丰富

```php
 * @method Field\Text           text($column, $label = '')
 * @method Field\Checkbox       checkbox($column, $label = '')
 * @method Field\Radio          radio($column, $label = '')
 * @method Field\Select         select($column, $label = '')
 * @method Field\MultipleSelect multipleSelect($column, $label = '')
 * @method Field\Textarea       textarea($column, $label = '')
 * @method Field\Hidden         hidden($column, $label = '')
 * @method Field\Id             id($column, $label = '')
 * @method Field\Ip             ip($column, $label = '')
 * @method Field\Url            url($column, $label = '')
 * @method Field\Color          color($column, $label = '')
 * @method Field\Email          email($column, $label = '')
 * @method Field\Mobile         mobile($column, $label = '')
 * @method Field\Slider         slider($column, $label = '')
 * @method Field\Map            map($latitude, $longitude, $label = '')
 * @method Field\Editor         editor($column, $label = '')
 * @method Field\File           file($column, $label = '')
 * @method Field\Image          image($column, $label = '')
 * @method Field\Date           date($column, $label = '')
 * @method Field\Datetime       datetime($column, $label = '')
 * @method Field\Time           time($column, $label = '')
 * @method Field\Year           year($column, $label = '')
 * @method Field\Month          month($column, $label = '')
 * @method Field\DateRange      dateRange($start, $end, $label = '')
 * @method Field\DateTimeRange  datetimeRange($start, $end, $label = '')
 * @method Field\TimeRange      timeRange($start, $end, $label = '')
 * @method Field\Number         number($column, $label = '')
 * @method Field\Currency       currency($column, $label = '')
 * @method Field\HasMany        hasMany($relationName, $callback)
 * @method Field\SwitchField    switch($column, $label = '')
 * @method Field\Display        display($column, $label = '')
 * @method Field\Rate           rate($column, $label = '')
 * @method Field\Divide         divider()
 * @method Field\Password       password($column, $label = '')
 * @method Field\Decimal        decimal($column, $label = '')
 * @method Field\Html           html($html, $label = '')
 * @method Field\Tags           tags($column, $label = '')
 * @method Field\Icon           icon($column, $label = '')
 * @method Field\Embeds         embeds($column, $label = '')
 * @method Field\MultipleImage  multipleImage($column, $label = '')
 * @method Field\MultipleFile   multipleFile($column, $label = '')
 * @method Field\Captcha        captcha($column, $label = '')
 * @method Field\Listbox        listbox($column, $label = '')
```


```php
public function __call($method, $arguments)
{
    if ($className = static::findFieldClass($method)) {
        $column = array_get($arguments, 0, ''); //[0];
        $element = new $className($column, array_slice($arguments, 1));
        $this->pushField($element);
        return $element;
    }
}
```

$element = new $className($column, array_slice($arguments, 1)); 
$this->pushField($element);

根据传入的有效字段类型（`$form->text` `$form->listbox`），进行对象创建，并放入队列 `$this->builder->fields()->push($field);`。


所有字段类型都继承于Field

#### Field

Field 中实现了很多功能（如，rules，readOnly，label等等），在这里就不详细讲述了。

```php
class Field implements Renderable
{
    const FILE_DELETE_FLAG = '_file_del_';

    protected $id;
    protected $value;
    protected $original;
    protected $default;
    protected $label = '';

    // ...  这个文件有一千行代码的实现
}
```

#### Form render() 实现

```php
public function render()
{
    $data = [
        'form' => $this,
        'width' => $this->width,
        'description' => $this->description,
    ];
    return view($this->view, $data)->render();
}
```
这个方法并没有做太多事情，
大部分调用都放到了view 进行处理

```php
<div class="box">
    {!! $form->renderHeaderTools() !!}
    
    <div class="box-body">
       @if($form->hasRows())
            @foreach($form->getRows() as $row)
                {!! $row->render() !!}
            @endforeach
       @else
            // 根据不同的字段类型，渲染对应的view
            @foreach($form->fields() as $field)
                {!! $field->render() !!}
            @endforeach
       @endif

        <div class="form-group">
            @if( ! $form->isMode(\App\Core\Form\Builder::MODE_VIEW)  || ! $form->option('enableSubmit'))
                <input type="hidden" name="_token" value="{{ csrf_token() }}">
            @endif

            <div class="col-sm-4 col-sm-offset-2">
                {!! $form->submitButton() !!}

                {!! $form->resetButton() !!}
            </div>
        </div>
        ...
    </div>
    
    @foreach($form->getHiddenFields() as $hiddenField)
        {!! $hiddenField->render() !!}
    @endforeach
    ...
</div>

```

如果你想更深入理解，可以仔细看一下各个基础类的实现`Field` `Builder`