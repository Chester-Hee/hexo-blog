---
title: Facade外观设计模式（结构型）
author: helingfeng
tags: []
categories:
  - 设计模式
translate_title: facade-design-pattern-structural
date: 2018-04-02 15:39:00
---
### 目录

[toc]

### 结构型设计模式

外观模式是一种**使用频率非常高**的**结构型**设计模式，为子系统中的一组接口提供一个一致的界面，Facade模式定义了一个**高层接口**，这个接口使得这一子系统更加容易使用。

通过引入一个外观角色来简化客户端与子系统之间的交互，为复杂的子系统调用提供统一的接口。降低子系统与客户端的耦合度，并且简化客户端调用的复杂度。

- 不使用外观模式下客户端系统与子系统的关系依赖图


![upload successful](/images/pasted-4.png)

- 使用外观模式下，子系统与客户端关系依赖图


![upload successful](/images/pasted-5.png)

### 外观模式无处不在

- 我们家里的电视机的遥控器，或者电风扇的档位与开关

通过外观模式，使得用户不需要了解电视机的启动原理，也可以轻松打开电视并使用电视观看节目。相反，如果一个电视机开机与关闭都需要用户输入（service tv start/service tv stop）复杂的命令的话，那么会有很多的普通人愿意买？

- 例如一个门户网站的首页与导航


![upload successful](/images/pasted-6.png)

通过导航条，客户可以很简易使用一项服务，并不需要关心一项服务后面关联了多少子系统或调用了多少子系统。也就是我们常说的“低耦合”。

### 应用实例（文件加密模块）

使用外观模式设计文件加密模块

具体流程包含三个部分，读取源文件，加密，存储

- 文件读取，使用文件流实现
- 数据加密，采用MD5加密
- 文件存储，使用文件流实现

具体代码结构图（PHP）


![upload successful](/images/pasted-7.png)

- FileReader.php

```php
namespace FileEncrypt;
class FileReader
{
    /**
     * 读取源文件内容并返回
     * @param $file_name
     * @return bool|string
     */
    public function read($file_name)
    {
        return file_get_contents($file_name);
    }
}
```

- FileWriter.php

```php
namespace FileEncrypt;
class FileWriter
{
    /**
     * 写入加密文件
     * @param $content
     * @param $new_file_name
     * @return bool|int
     */
    public function write($content,$new_file_name)
    {
        return file_put_contents($new_file_name,$content);
    }
}
```

- CipherMachine.php

```php
namespace FileEncrypt;
class CipherMachine
{
    /**
     * 对明文进行加密
     * @param $content
     * @return string
     */
    public function encrypt($content)
    {
        return md5($content);
    }
}
```

- EncryptFacade.php

```php
namespace FileEncrypt;
class EncryptFacade
{
    private $cipher = null;
    private $reader = null;
    private $writer = null;

    public function __construct()
    {
        $this->cipher = new CipherMachine();
        $this->reader = new FileReader();
        $this->writer = new FileWriter();
    }

    public function encryptFile($src, $tar)
    {
        $content = $this->reader->read($src);
        echo '读取明文:'.$content."\r\n";
        $encryptContent = $this->cipher->encrypt($content);
        echo '加密明文:'.$encryptContent."\r\n";
        $this->writer->write($encryptContent,$tar);
        echo '成功写入文件.'."\r\n";
    }
}
```

- index.php

```
require_once './vendor/autoload.php';
$encrypt = new \FileEncrypt\EncryptFacade();
$encrypt->encryptFile('a.txt','b.data');

# output

读取明文:i am helingfeng.
加密明文:7cc3074b4821ae64fb0c1ec52feb005e
成功写入文件.

```

### Facade优点

- 它对客户端屏蔽了子系统组件，减少了客户端所需处理的对象数目，并使得子系统使用起来更加容易。通过引入外观模式，客户端代码将变得很简单，与之关联的对象也很少。
- 它实现了子系统与客户端之间的松耦合关系，这使得子系统的变化不会影响到调用它的客户端，只需要调整外观类即可。
- 一个子系统的修改对其他子系统没有任何影响，而且子系统内部变化也不会影响到外观对象。

### Facade缺点

- 不能很好地限制客户端直接使用子系统类，如果对客户端访问子系统类做太多的限制则减少了可变性和灵活性。
- 如果设计不当，增加新的子系统可能需要修改外观类的源代码，违背了**开闭原则**。

### 抽象Facade

上文实例中，如果加密方式或者文件读取和存储方式发生变化，那么我们依旧需要更新Facade和客户端源代码，这违背了**开闭原则**，并不是我们想要的。所以抽象的Facade解决了这个问题。
基于抽象Facade设计模式，新的需要，我们需要添加新的Facade类，通过修改配置文件来达到不修改任何的客户端和外观类源代码的目的。

例如：laravel app.php配置文件

```
'Cache' => Illuminate\Support\Facades\Cache::class,
'Config' => Illuminate\Support\Facades\Config::class,
'Cookie' => Illuminate\Support\Facades\Cookie::class,
'Crypt' => Illuminate\Support\Facades\Crypt::class,
'DB' => Illuminate\Support\Facades\DB::class,

```

### 适用场景

- 当要为访问一系列复杂的子系统提供一个简单入口时可以使用外观模式。
- 客户端程序与多个子系统之间存在很大的依赖性。引入外观类可以将子系统与客户端解耦，从而提高子系统的独立性和可移植性。
- 在层次化结构中，可以使用外观模式定义系统中每一层的入口，层与层之间不直接产生联系，而通过外观类建立联系，降低层之间的耦合度。

### Thanks

> 书籍是人类进步的阶梯