---
title: Simple Factory 简单工厂模式（创建型）
author: helingfeng
tags: []
categories:
  - 设计模式
translate_title: simple-factory-mode-created
date: 2018-04-02 15:22:00
---
### 简介

简单工厂模式，是三种工厂模式中最简单且最容易理解的创建型模式。

### 实例应用（图表库）

假设有这样一个需求，使用PHP语言设计一个图表库

图表类型：饼图，条形图，折线图

使用简单工厂模式，我们得到一个关系图


![upload successful](/images/pasted-1.png)

工厂负责跟进客户端提供的参数，生产不同类型的图表。所以，简单的工厂模式，所有产品生产的初始化工作都会在工厂类这一个类进行。

### PHP实现源码

PHP语言实现

#### PieChart.php
```php
namespace SimpleFactory;
class PieChart
{
    public function init($data = [])
    {
        echo 'pie init data.'."\r\n";
    }
    public function display()
    {
        echo 'pie display.'."\r\n";
    }
}
```

#### LineChart.php
```php
namespace SimpleFactory;
class LineChart
{
    public function init($data = [])
    {
        echo 'line init data.'."\r\n";
    }
    public function display()
    {
        echo 'line display.'."\r\n";
    }
}
```

#### BarChart.php
```php
namespace SimpleFactory;
class BarChart
{
    public function init($data = [])
    {
        echo 'bar init data.'."\r\n";
    }
    public function display()
    {
        echo 'bar display.'."\r\n";
    }
}
```

#### Factory.php
```php
namespace SimpleFactory;
class Factory
{
    public static function getChartObject($type)
    {
        switch ($type) {

            case 'pie':
                $pie = new PieChart();
                return $pie;
                break;
            case 'line':
                $line = new LineChart();
                return $line;
                break;
            case 'bar':
                $bar = new BarChart();
                return $bar;
                break;
            default:
                throw new \Exception('无法创建该图');
        }
    }
}
```

#### index.php
```php

// 使用工厂创建图表产品
$pie = \SimpleFactory\Factory::getChartObject('pie');
$pie->init();
$pie->display();

$bar = \SimpleFactory\Factory::getChartObject('bar');
$bar->init();
$bar->display();

$line = \SimpleFactory\Factory::getChartObject('line');
$line->init();
$line->display();

output 输出信息

pie init data.
pie display.
bar init data.
bar display.
line init data.
line display.
```

### 简单工厂模式优点

- (1) 工厂类包含必要的判断逻辑，可以决定在什么时候创建哪一个产品类的实例，客户端可以免除直接创建产品对象的职责，而仅仅“消费”产品，简单工厂模式实现了对象创建和使用的分离。
- (2) 客户端无须知道所创建的具体产品类的类名，只需要知道具体产品类所对应的参数即可，对于一些复杂的类名，通过简单工厂模式可以在一定程度减少使用者的记忆量。
- (3) 通过引入配置文件，可以在不修改任何客户端代码的情况下更换和增加新的具体产品类，在一定程度上提高了系统的灵活性。
 

### 简单工厂模式缺点

- (1) 由于工厂类集中了所有产品的创建逻辑，职责过重，一旦不能正常工作，整个系统都要受到影响。
- (2) 使用简单工厂模式势必会增加系统中类的个数（引入了新的工厂类），增加了系统的复杂度和理解难度。
- (3) 系统扩展困难，一旦添加新产品就不得不修改工厂逻辑，在产品类型较多时，有可能造成工厂逻辑过于复杂，不利于系统的扩展和维护。
- (4) 简单工厂模式由于使用了静态工厂方法，造成工厂角色无法形成基于继承的等级结构。

### 应用场景

- (1) 工厂类负责创建的对象比较少，由于创建的对象较少，不会造成工厂方法中的业务逻辑太过复杂。
- (2) 客户端只知道传入工厂类的参数，对于如何创建对象并不关心。