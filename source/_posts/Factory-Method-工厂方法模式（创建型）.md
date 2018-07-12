---
title: Factory Method 工厂方法模式（创建型）
author: helingfeng
tags: []
categories:
  - 设计模式
translate_title: factory-method-pattern-created
date: 2018-04-02 16:41:00
---
### 简介

简单工厂模式中有一个很致命的缺陷，如果一个工厂生产产品数量非常大，那么大量的代码就会堆积在一个工厂类中，违背了“单一职责”。并且如果出现新的产品，需要修改工厂类源码，也违背了“开闭原则”。那么为了解决这些问题，对工厂模式进一步优化，提出了工厂方法模式。

### 工厂方法有四个角色

- 抽象工厂 （factory）
- 具体工厂 （concreteFactory）
- 抽象产品 （chart）
- 具体产品 （pie/line/bar）

### 模式应用（图表库）

Factory.php 抽象工厂
```
namespace FactoryMethod;
abstract class Factory
{
    abstract function getChartObject();
}
```

Chart.php 抽象图表
```
namespace FactoryMethod;
abstract class Chart
{
    abstract public function init($data = []);
    abstract public function display();
}
```

PieChart.php 具体图表
```
namespace FactoryMethod;
class PieChart extends Chart
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

PieFactory.php 具体工厂
```
namespace FactoryMethod;
class PieFactory
{
    public static function getChartObject()
    {
        $pie = new PieChart();
        return $pie;
    }
}
```

LineChart.php 具体图表
```
namespace FactoryMethod;
class LineChart extends Chart
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

LineFactory.php 具体工厂
```
namespace FactoryMethod;
class LineFactory
{
    public static function getChartObject()
    {
        $line = new LineChart();
        return $line;
    }
}
```

index.php 客户端
```
require_once './vendor/autoload.php';

$pie = \FactoryMethod\PieFactory::getChartObject();
$pie->init();
$pie->display();

$line = \FactoryMethod\LineFactory::getChartObject();
$line->init();
$line->display();

# output 输出结果

pie init data.
pie display.
line init data.
line display.


```

### 优点

- 在工厂方法模式中，工厂方法用来创建客户所需要的产品，同时还向客户隐藏了哪种具体产品类将被实例化这一细节，用户只需要关心所需产品对应的工厂，无须关心创建细节，甚至无须知道具体产品类的类名。

- 基于工厂角色和产品角色的多态性设计是工厂方法模式的关键。它能够让工厂可以自主确定创建何种产品对象，而如何创建这个对象的细节则完全封装在具体工厂内部。工厂方法模式之所以又被称为多态工厂模式，就正是因为所有的具体工厂类都具有同一抽象父类。

- 使用工厂方法模式的另一个优点是在系统中加入新产品时，无须修改抽象工厂和抽象产品提供的接口，无须修改客户端，也无须修改其他的具体工厂和具体产品，而只要添加一个具体工厂和具体产品就可以了，这样，系统的可扩展性也就变得非常好，完全符合“开闭原则”。

### 缺点

- 在添加新产品时，需要编写新的具体产品类，而且还要提供与之对应的具体工厂类，系统中类的个数将成对增加，在一定程度上增加了系统的复杂度，有更多的类需要编译和运行，会给系统带来一些额外的开销。

- 由于考虑到系统的可扩展性，需要引入抽象层，在客户端代码中均使用抽象层进行定义，增加了系统的抽象性和理解难度，且在实现时可能需要用到DOM、反射等技术，增加了系统的实现难度。

### 应用场景

- 客户端不知道它所需要的对象的类。在工厂方法模式中，客户端不需要知道具体产品类的类名，只需要知道所对应的工厂即可，具体的产品对象由具体工厂类创建，可将具体工厂类的类名存储在配置文件或数据库中。

- 抽象工厂类通过其子类来指定创建哪个对象。在工厂方法模式中，对于抽象工厂类只需要提供一个创建产品的接口，而由其子类来确定具体要创建的对象，利用面向对象的多态性和里氏代换原则，在程序运行时，子类对象将覆盖父类对象，从而使得系统更容易扩展。