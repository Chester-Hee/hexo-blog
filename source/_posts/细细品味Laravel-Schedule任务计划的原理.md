---
title: 细细品味 Laravel-Schedule 计划任务的原理
author: helingfeng
tags: []
categories:
  - Laravel
  - Crontab
  - Schedule
  - 源码阅读
translate_title: savour-the-principles-of-laravelschedule-planning-task
date: 2018-10-30 14:00:00
---

## Laravel-Schedule 原理剖析


介绍原理之前，先自省几句，很长一段事件没有码字啦，那种工作停不下来的习惯应该改一改。再忙都应该给自己留出一点空闲的时间，用来总结和提升技能。

到此为止

---

### 事情起因：

昨天，在工作过程中和同事讨论到`Laravel-Schedule`任务计划的问题。本来，对`Schedule`没有深入探索，并不理解任务的注册和执行过程，基于这个问题，我快速浏览了一遍这个模块的源代码。
并结合自己的理解来描述`Laravel-Schedule`的基本执行原理，可能有很多不正确的地方，勿喷，如果你有不同的看法，可以在下方留言并一起探索，感谢！

### 文章概述

`LS`计划任务，名称太长，本文使用`LS`代替`Laravel-Schedule`长命名。

`LS`流程分为两个步骤：

- 第一步，根据配置的Command命令、Cron表达式进行注册事件；
- 第二步，操作系统配置每分钟触发`LS`，由`LS`自主完成事件`是否符合执行时间过滤`，`重复性检查`，并可选`Background`或者`Foreground`进行执行任务。

### 事件注册

在命令行应用程序入口文件`artisan`首先引入`bootstrap/app.php`
```php
$app->singleton(
    Illuminate\Contracts\Console\Kernel::class,
    App\Console\Kernel::class
);
```

向容器中注册`Laravel-Kernel`，并使用`make`构建实例
```php
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
```

`App\Console\Kernel` 继承于 `Illuminate\Foundation\Console\Kernel`

所以在实例过程中会调用`Illuminate\Foundation\Console\Kernel`构造方法：

```php
public function __construct(Application $app, Dispatcher $events)
{
    if (! defined('ARTISAN_BINARY')) {
        define('ARTISAN_BINARY', 'artisan');
    }

    $this->app = $app;
    $this->events = $events;

    $this->app->booted(function () {
        $this->defineConsoleSchedule();
    });
}
```

这里又完成了一次事件注册，在应用启动`booted`完成后回调 `$this->defineConsoleSchedule()`

```php
protected function defineConsoleSchedule()
{
    $this->app->singleton(Schedule::class, function ($app) {
        return new Schedule;
    });

    $schedule = $this->app->make(Schedule::class);

    $this->schedule($schedule);
}
```

重点在于`defineConsoleSchedule`这个方法，容器中注册并实例化`Schedule`对象，并使用址传递对`Schedule`实例进行操作，**这里的操作就是计划任务的事件注册**。

`Illuminate\Foundation\Console\Kernel` 中的`schedule`方法

```php
/**
  * Define the application's command schedule.
  *
  * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
  * @return void
  */
protected function schedule(Schedule $schedule)
{
    //
}
```

当然，我们不需要在这里修改任何代码。上面，我们说过`Laravel-Kernel`对象的实例类是`App\Console\Kernel`，他继承了`Illuminate\Foundation\Console\Kernel`类。

所以我们在官方文档中也可以清楚看到，计划任务的配置是在`App\Console\Kernel`中的`schedule`方法中定义的，例如：

```php
/**
  * Define the application's command schedule.
  *
  * @param  \Illuminate\Console\Scheduling\Schedule $schedule
  * @return void
  */
protected function schedule(Schedule $schedule)
{
    $schedule->command('inspire')->hourly();
}
```

我们来看看**官方文档**的解读：

#### Closure 定义调度

使用`Closure`定义调度。例如，每天使用DB构造器方式来清空数据库一个表

```php
$schedule->call(function () {
    DB::table('recent_users')->delete();
})->daily();
```

#### Artisan 命令调度

除了计划 Closure 调用，你还能调度 Artisan 命令 和操作系统命令。举个例子，你可以给 command 方法传递命令名称或者类名称来调度一个 Artisan 命令：

```php
$schedule->command('emails:send --force')->daily();
```

#### 队列任务调度

`job`方法可以用来调度 队列任务。这个方法提供了一种快捷方式来调度任务，无需使用`call`方法手动创建闭包来调度任务：

```php
$schedule->job(new Heartbeat)->everyFiveMinutes();
```

#### Shell 命令调度

exec 方法可用于向操作系统发出命令：
```php
$schedule->exec('node /home/forge/script.js')->daily();
```

`LS` 提供很多提高我们开发效率的执行频率方法

| 方法 |	描述 |
|--|--|
|->cron('* * * * * *');	|在自定义的 Cron 时间表上执行该任务|
|->everyMinute();	|每分钟执行一次任务|
|->everyFiveMinutes();	|每五分钟执行一次任务|
|->everyTenMinutes();	|每十分钟执行一次任务|
|->everyFifteenMinutes();	|每十五分钟执行一次任务|
|->everyThirtyMinutes();	|每半小时执行一次任务|
|->hourly();	|每小时执行一次任务|
|->hourlyAt(17);	|每小时的第 17 分钟执行一次任务|
|->daily();	|每天午夜执行一次任务|
|->dailyAt('13:00');	|每天的 13:00 执行一次任务|
|->twiceDaily(1, 13);	|每天的 1:00 和 13:00 分别执行一次任务|
|->weekly();	|每周执行一次任务|
|->monthly();	|每月执行一次任务|
|->monthlyOn(4, '15:00');	|在每个月的第四天的 15:00 执行一次任务|
|->quarterly();	|每季度执行一次任务|
|->yearly();	|每年执行一次任务|
|->timezone('America/New_York');	|设置时区|

了解`LS`给我们提供的多种任务定义和执行频率设置的方式后，我们回来思考其实现的原理是怎么样的？

**`schedule`方法里的每一句任务的定义，就是构造一个事件对象，并将这个事件对象放到数组里**

`Illuminate\Console\Scheduling\Schedule.php` command方法的核心实现代码如下:
```php
$this->events[] = $event = new Event($this->mutex, $command);
```
`mutex` 这个变量用来控制事件当前时间执行的不可重复性，在这里先不细究。

**`schedule`方法里的每一句调度频率设置，就是表达式的构建**

这个表达式 `expression` 就是与我们常用`crontab`表达式是同样的类型，`everyTenMinutes()` 每十分钟执行一次，其实对应的表达式就是`*/10 * * * * *`，具体`LS` 实现代码如下，应该不难看懂。

```php
public $expression = '* * * * * *';

public function everyTenMinutes()
{
    return $this->spliceIntoPosition(1, '*/10');
}
protected function spliceIntoPosition($position, $value)
{
    $segments = explode(' ', $this->expression);
    $segments[$position - 1] = $value;
    return $this->cron(implode(' ', $segments));
}
```

这个很重要，因为事件的过滤中，需要匹配执行时间是否等于当前时间。


### 运行事件

启动调度器，使用调度器时，只需将以下`Cron`项目添加到服务器:

```shell
* * * * * php /path-to-your-project/artisan schedule:run >> /dev/null 2>&1
```
上面这个`Cron`会每分钟调用一次`LS`命令调度器。执行`schedule:run`命令时， `LS`会根据你的调度运行预定任务。

让我们带着疑问继续理解`LS`运行事件原理。

#### schedule:run 是什么？

我们看 `Illuminate\Console\Scheduling\ScheduleRunCommand` 代码是怎么写的？和普通自定义`Artisan`命令一样，继承 `Command` 基类。然后具体任务内容在`handle`方法里实现。

```php
class ScheduleRunCommand extends Command
{
    //...
    public function handle()
    {
        foreach ($this->schedule->dueEvents($this->laravel) as $event) {
            // ...
            $event->run($this->laravel);
        }
        // ...
    }
}
```

`dueEvents` 完成过滤动作 `collect($this->events)->filter->isDue($app)` 使用 `isDue` 方法进行过滤。

```php
public function isDue($app)
{
    if (! $this->runsInMaintenanceMode() && $app->isDownForMaintenance()) {
        return false;
    }
    return $this->expressionPasses() &&
            $this->runsInEnvironment($app->environment());
}
protected function expressionPasses()
{
    $date = Carbon::now();

    if ($this->timezone) {
        $date->setTimezone($this->timezone);
    }

    return CronExpression::factory($this->expression)->isDue($date->toDateTimeString());
}
```

其实原理很简单，方法`expressionPasses`通过`Carbon`第三方扩展包获取当前时间，并与Event实例的`Expression`进行匹对。

```php
return $this->getNextRunDate($currentDate, 0, true)->getTimestamp() == $currentTime
```

如果返回`True`，那就表示`Event`需要执行。

```php
$event->run($this->laravel);


public function run(Container $container)
{
    if ($this->withoutOverlapping &&
        ! $this->mutex->create($this)) {
        return;
    }

    $this->runInBackground
                ? $this->runCommandInBackground($container)
                : $this->runCommandInForeground($container);
}
```

`withoutOverlapping` 和 `mutex` 就是在这里控制任务重复执行。

```php
(new Process(
    $this->buildCommand(), base_path(), null, null, null
))->run();
```

最后，由执行器执行命令任务...done


---


### 几点疑问？

1.假设每个五分钟执行，比如08:52定义命令调度`Command`到`Schedule`，会在08:57时刻执行？


不会，只会在08:55时刻执行，也就是满足时钟的固定周期。


2.任务调度的两种执行方式`runCommandInBackground` 与 `runCommandInForeground` 有什么区别？

`runCommandInBackground` 代码如下：

```php
protected function runCommandInBackground(Container $container)
{
    $this->callBeforeCallbacks($container);

    (new Process(
        $this->buildCommand(), base_path(), null, null, null
    ))->run();
}
```

`runCommandInForeground` 代码如下：

```php
 protected function runCommandInForeground(Container $container)
{
    $this->callBeforeCallbacks($container);

    (new Process(
        $this->buildCommand(), base_path(), null, null, null
    ))->run();

    $this->callAfterCallbacks($container);
}
```

差别在于 `$this->callAfterCallbacks($container)` ，是否等待当前任务执行完成，如果选择 `runCommandInBackground` 方式运行，任务命令直接传递给操作系统进行执行，然后直接返回，等待操作系统执行完成任务后，会执行另一条命令 `schedule:finish` 通过事件ID进行异步响应对应的任务事件。

3. Closure 定义调度，和命令其他方式定义调度是不相同的，`CallBackEvent` 同步方式执行。