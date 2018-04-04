title: Laravel-Admin Model-Grid 快速构建数据表格
author: helingfeng
tags: []
categories:
  - Laravel
  - PHP
  - Admin
date: 2018-04-03 18:50:00
---
## Laravel Admin 快速构建数据表格之 Model-Grid

使用LA过程中，我们是不是感觉代码变得更整洁，冗余更低，维护更简单，这都要归于LA优雅设计理念。

通常，一个后台管理系统最基本的操作是CRDU，对于`查询`特别是列表的查询，在传统的框架中代码的冗余非常严重。
对于一个列表查询其实是比较复杂的，因为它包含几个部分，`操作-actions` `查询条件-filters` `数据格式-display`


对于LA来说，这些都变得简单起来，来看一段代码

```php
public function index()
{
    return Admin::content(function (Content $content) {
        $content->header(__db_trans('admin.administrator'));
        $content->description();
        $content->body($this->grid()->render());
    });
}

protected function grid()
{
    return Administrator::grid(function (Grid $grid) {
        $grid->id('编号')->sortable();
        $grid->username(__db_trans('admin.username'));
        $grid->avatar(__db_trans('admin.avatar'))->image('',45);
        $grid->roles(__db_trans('admin.roles'))->pluck('name')->label('info');
        $grid->created_at(__db_trans('admin.created_at'));
        $grid->updated_at(__db_trans('admin.updated_at'));

        $grid->disableExport();

        $grid->actions(function (Grid\Displayers\Actions $actions) {
            if ($actions->getKey() == 1) {
                $actions->disableDelete();
            }
        });

        $grid->filter(function($filter){
            $filter->like('username', '账号名称');
        });

    });
}
```

上面运行的结果截图

![upload successful](/images/pasted-27.png)



### Admin::content(...)

接下来，我们来尝试解读上文代码的含义

```php
return Admin::content(function (Content $content) {
    $content->header(__db_trans('admin.administrator'));
    $content->description();
    $content->body($this->grid()->render());
});
```

从语义和表面意思，我们很容易理解这段代码：给客户端返回一个内容块，其中包含头部，描述，内容体

是的，但是本文不对这个做过多的解释，本文重点是 `$content->body($this->grid()->render());` 部分

### Model-Grid

```php
$this->grid()->render()
```

很显然，grid()返回的是一个对象，并调用render()转化为html

接下来，我们就进入正题，来剖析 `Model-Grid`

#### return Administrator::grid($callback)

容易看出，Model 继承了LA基础类库。

#### use AdminBuilder

```php
class Menu extends Model
{
    use AdminBuilder;
}
```

我们可以打开 AdminBuilder 源码实现

```php
public static function grid(\Closure $callback)
{
    return new Grid(new static(), $callback);
}
```

new static() 很关键，创建一个静态模型

#### Grid 构造函数

```php
public function __construct(Eloquent $model, Closure $builder)
{
    $this->keyName = $model->getKeyName();
    $this->model = new Model($model);
    $this->builder = $builder;
    // ...

    $this->setupTools();
    $this->setupFilter();
}
```

构造函数中，完成了一些初始化工作，具体看代码也不难理解。

还记得 上文代码中 $this->grid()->render() 方法render()是我们的入口

#### grid->render()

```php
public function render()
{
    try {
        $this->build();
    } catch (\Exception $e) {
        return Handler::renderException($e);
    }
    return view($this->view, $this->variables())->render();
}
```

$this->view 默认值等于 table.blade


#### grid->build()  

如何快速构建数据表，核心方法就是它

```php
public function build()
{
    $data = $this->processFilter();

    // ...
    Column::setOriginalGridData($data);

    $this->columns->map(function (Column $column) use (&$data) {
        $data = $column->fill($data);
        // ...
    });

    $this->buildRows($data);
}
```

代码分析：

- $this->processFilter(); 这里通过Model分页条件查询并返回一个Collect集合
- $data = $column->fill($data); 这里使用地址传递，完成数据格式化display动作
- $this->buildRows($data); 构建一个Rows集合，提供给View渲染



#### $this->processFilter()

Grid($callback) $callback 在 $this->processFilter() 进行了调用 

```php
public function processFilter()
{
    call_user_func($this->builder, $this);
    return $this->filter->execute();
}
```

回顾上面代码

```php
 return Administrator::grid(function (Grid $grid) {
    $grid->id('编号')->sortable();
    $grid->username(__db_trans('admin.username'));
    $grid->avatar(__db_trans('admin.avatar'))->image('',45);
    // ...
 });
```

$grid->id , $grid->username , $grid->avatar 都会统一调用到 $grid __call() 方法


```php
public function __call($method, $arguments)
{
    $label = isset($arguments[0]) ? $arguments[0] : ucfirst($method);

    //...
    if ($column = $this->handleRelationColumn($method, $label)) {
        return $column;
    }

    if ($column = $this->handleTableColumn($method, $label)) {
        return $column;
    }
    return $this->addColumn($method, $label);
}
```

实现工作就是 $this->columns[] = $column;

接下来，就是

$this->filter->execute(); 
```php

public function buildData($toArray = true)
{
    $collection = $this->get();

    $this->data = $collection->toArray();
    return $this->data;
}
```

**这里巧妙实现了第三方接口快速生成数据表格的支持**

$this->get() 

方式会调用Model的paginate()方法来获取数据列表，所以通过实现此方法可以很好解决数据源问题。

如，

```php
public function paginate()
{
    $page_size = request()->input('per_page', 20);
    $cur_page = request()->input('page', 1);

    $data = $this->service->statisticList($cur_page, $page_size);
    $total = intval($data);
    
    $paginator = new LengthAwarePaginator($data, $total, $page_size, $cur_page);
    $paginator->setPath(url()->current());

    return $paginator;
}
```



#### $column->fill($data)
 
$column->fill($data) 就是对数据进行格式化，并使用display方法

```php
public function fill(array $data)
{
    foreach ($data as $key => &$row) {
        $this->original = $value = array_get($row, $this->name);

        $value = $this->htmlEntityEncode($value);

        array_set($row, $this->name, $value);

        if ($this->hasDisplayCallbacks()) {
            $value = $this->callDisplayCallbacks($this->original, $key);
            array_set($row, $this->name, $value);
        }
    }
    return $data;
}

```

对于display 方法，其实LA提供了扩展。

Bootstrap.php Middleware文件

```php
$map = [
    'editable' => \App\Core\Grid\Displayers\Editable::class,
    'switch' => \App\Core\Grid\Displayers\SwitchDisplay::class,
    'switchGroup' => \App\Core\Grid\Displayers\SwitchGroup::class,
    'select' => \App\Core\Grid\Displayers\Select::class,
    'image' => \App\Core\Grid\Displayers\Image::class,
    'label' => \App\Core\Grid\Displayers\Label::class,
    'button' => \App\Core\Grid\Displayers\Button::class,
    'link' => \App\Core\Grid\Displayers\Link::class,
    'badge' => \App\Core\Grid\Displayers\Badge::class,
    'progressBar' => \App\Core\Grid\Displayers\ProgressBar::class,
    'radio' => \App\Core\Grid\Displayers\Radio::class,
    'checkbox' => \App\Core\Grid\Displayers\Checkbox::class,
    'orderable' => \App\Core\Grid\Displayers\Orderable::class,
];

foreach ($map as $abstract => $class) {
    Column::extend($abstract, $class);
}
```

让你的列表元素更丰富。


#### $this->buildRows($data)

```php
$this->rows = collect($data)->map(function ($model, $number) {
    return new Row($number, $model);
});
```

构建一个Rows集合，用于前端模板渲染。

#### view($this->view, $this->variables())->render()

好，最后我们来看一下table.blade这个文件

```php
<table class="table table-hover table-border table-striped">
    <tr class="text-center">
    @foreach($grid->columns() as $column)
         <th>{{$column->getLabel()}}{!! $column->sorter() !!}</th>
    @endforeach
    </tr>

    @foreach($grid->rows() as $row)
    <tr {!! $row->getRowAttributes() !!}>
          @foreach($grid->columnNames as $name)
          <td {!! $row->getColumnAttributes($name) !!}>
                {!! $row->column($name) !!}
          </td>
          @endforeach
    </tr>
    @endforeach
    
</table>
```

简单分析一下Model-Grid源代码实现流程与原理，希望对你会有一点帮助。