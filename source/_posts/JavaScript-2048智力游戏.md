---
title: JavaScript 2048智力游戏
author: helingfeng
tags:
  - 游戏
categories:
  - JavaScript
translate_title: javascript-2048-puzzle-game
date: 2018-04-02 17:09:00
---
#### 编码流程

- 1.什么是2048？

- 2.玩2048技巧？

- 3.移动端开发注意事项？

- 4.游戏设计图？

- 5.HTML编写？

- 6.CSS编写

- 7.JavaScript游戏模型编写？

- 8.JavaScript游戏逻辑编写?

- 9.JavaScript游戏特效编写？

- 10.打包APP？

##### 什么是2048？

2048有16个格子，初始时会有两个格子上安放了两个数字2，每次可以选择上下左右其中一个方向去滑动，每滑动一次，所有的数字方块都会往滑动的方向靠拢外，系统也会在空白的地方随即出现一个数字方块，相同数字的方块在靠拢、相撞时会相加。

##### 玩2048技巧？

- 1、最大数尽可能放在角落。
- 2、数字按顺序紧邻排列。
- 3、首先满足最大数和次大数在的那一列/行是满的。
- 4、时刻注意活动较大数（32以上）旁边要有相近的数。
- 5、以大数所在的一行为主要移动方向
- 6、不要急于“清理桌面”。

移动端开发注意事项？
 
屏幕宽度：
开发移动端页面时，必须设置适应移动端显示代码：
```html
<meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width"> 
```
 
触屏事件：
基于移动端开发一定要支持触屏touch事件。

因为我开发选用JQ支持，所以引入了JQuery.touch.js

- JQuery.min.js下载：http://www.netcu.de/templates/netcu/js/jquery-1.4.2.min.js

- JQuery.touch.js 下载：http://www.netcu.de/templates/netcu/js/jquery.touchwipe.js

JQuery.touch.js 实现大概原理：

```html
(function($) { 
   $.fn.touchwipe = function(settings) {
     var config = {
            min_move_x: 20,
             wipeLeft: function() { alert("left"); },
             wipeRight: function() { alert("right"); },
            preventDefaultEvents: true
     };
     
     if (settings) $.extend(config, settings);
 
     this.each(function() {
         var startX;
         var isMoving = false;

         function cancelTouch() {
             this.removeEventListener('touchmove', onTouchMove);
             startX = null;
             isMoving = false;
         }    
         
         function onTouchMove(e) {
             if(config.preventDefaultEvents) {
                 e.preventDefault();
             }
             if(isMoving) {
                 var x = e.touches[0].pageX;
                 var dx = startX - x;
                 if(Math.abs(dx) >= config.min_move_x) {
                    cancelTouch();
                    if(dx > 0) {
                        config.wipeLeft();
                    }
                    else {
                        config.wipeRight();
                    }
                 }
             }
         }
         
         function onTouchStart(e)
         {
             if (e.touches.length == 1) {
                 startX = e.touches[0].pageX;
                 isMoving = true;
                 this.addEventListener('touchmove', onTouchMove, false);
             }
         }         
             
         this.addEventListener('touchstart', onTouchStart, false);
     });
 
     return this;
   };
 
 })(jQuery);
```


这样子，我们就可以支持wipeLeft、wipeRight、wipeDown、wipeUp事件了。

注意：在移动端click事件会延迟300ms

##### 游戏设计图？

看看我们2048设计图：


![upload successful](/images/pasted-21.png)

##### HTML编写？

页面编写过程：

最外层我使用一个div，里面的4*4一共使用16个div。

只要外层的div使用relative相对定位，然后内部的单元格div使用absolute绝对定位。然后使用js代码计算对应单元格的Left与Top值。

HTML代码如下：

```html
<!DOCTYPE html>
<html>
<head>
    <title>2048</title>
    <link type="text/css" rel="stylesheet" href="./lib/style.css" />
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width">

    <script src="./lib/jquery.min.js"></script>
    <script src="./lib/jquery.touchSwipe.min.js"></script>

    <script src="./lib/data.js"></script>
    <script src="./lib/function.js"></script>
    <script src="./lib/animation.js"></script>
    <script src="./lib/main.js"></script>
</head>
<body>
    <div class="main">
        <div class="header">
                <h4>2048</h4>
                <div class="score">Score&nbsp;:&nbsp;<span id="score">0</span></div>
                <div class="new_game" id="new_game">New Game</div>
        </div>
        <div class="msg"><span id="msg">GameOver.</span></div>
        <div class="game-panel">
            <div class="wall">
                <div class="cell" id="box-cell-0-0"></div>
                <div class="cell" id="box-cell-0-1"></div>
                <div class="cell" id="box-cell-0-2"></div>
                <div class="cell" id="box-cell-0-3"></div>
                <div class="cell" id="box-cell-1-0"></div>
                <div class="cell" id="box-cell-1-1"></div>
                <div class="cell" id="box-cell-1-2"></div>
                <div class="cell" id="box-cell-1-3"></div>
                <div class="cell" id="box-cell-2-0"></div>
                <div class="cell" id="box-cell-2-1"></div>
                <div class="cell" id="box-cell-2-2"></div>
                <div class="cell" id="box-cell-2-3"></div>
                <div class="cell" id="box-cell-3-0"></div>
                <div class="cell" id="box-cell-3-1"></div>
                <div class="cell" id="box-cell-3-2"></div>
                <div class="cell" id="box-cell-3-3"></div>
            </div>
        </div>
    </div>
    <div class="footer">Hatcher make.2016</div>
</body>
</html>
```

header这个div显示标题，然后得分，以及一个开始游戏的button。

wall这个div就是游戏的主体部分。

##### CSS编写？

对应的CSS如下：

```html
*{
    margin: 0px 0px;
    padding: 0px 0px;
}
.main{
    font-family: "微软雅黑";
    text-align: center;
}
.header{
    border: 5px solid #fff;
    height: 120px;
    border-radius: 2px;
    position: relative;
}
.header h4{
    width: 100px;
    height: 100px;
    color:#fff;
    font-size: 32px;
    line-height: 100px;
    margin: 10px;
    border-radius: 6px;
    background-color: #ffad2d;
}
.header .score{
    color: #ffad2d;
    font-size: 20px;
    font-weight: bold;
    position: absolute;
    top: 20px;
    left: 150px;
}
.header .new_game{
    color: #ffffff;
    background-color: #19B8C8;
    padding: 8px 10px;
    font-size: 22px;
    font-weight: bold;
    position: absolute;
    border-radius: 2px;

    top: 60px;
    left: 150px;
}
.header .new_game:active{
    background-color: #e15661;
}
.msg{
    font-size: 22px;
    font-weight: bold;
    line-height: 100px;
    color: #ff3d44;
}
.game-panel{
    height: 300px;
    width: 250px;
    margin: 20px auto;
}
.game-panel .wall{
    padding: 10px;
    width: 230px;
    height: 230px;
    background-color: #bbada0;
    border-radius: 6px;
    position: relative;
}

.game-panel .wall .cell{
    width: 50px;
    height: 50px;
    background-color: #ccc0b3;
    border-radius: 4px;
    position: absolute;
}

.game-panel .wall .number-cell{
    font-size: 25px;
    font-weight: bold;
    color: #fff;
    border-radius: 4px;
    line-height: 50px;
    width: 0px;
    height: 0px;
    position: absolute;
}
.footer {
    font-family: "微软雅黑";
    font-weight: bold;
    font-size: 15px;
    bottom: 0px;
    line-height: 30px;
    text-align: center;
    position: static;
}
```

嘿嘿，我觉得这个css写得有些牵强了。

好，我们先看看这个时候的效果：


![upload successful](/images/pasted-22.png)


##### JavaScript编写？

很明显，中间的格子都没有摆放整齐。

没事，我们接下来，就使用js将格子摆放整齐。

从设计图中，我们很容易看出。

单元格（0,0）对应的left与top值应该是：10px , 10px

单元格（0,1）对应的left与top值应该是：10+60px , 10px

单元格（0,2）对应的left与top值应该是：10+60px+60px , 10px

..............依次类推

可以得到两个函数：

```javascript
function getLeftPos(i,j){
    return 10+60*j;
}

function getTopPos(i,j){
    return 10+60*i;
}
```

那个，初始化内部16个单元的function怎么写呢？

```javascript
function init_grid() {
    for (var i = 0; i <= 3; i++) {
        for (var j = 0; j <= 3; j++) {
            $cell = $("#box-cell-" + i + "-" + j);
            $cell.css("left", getLeftPos(i, j));
            $cell.css("top", getTopPos(i, j));
        }
    }
}
```

ok，真的挺有意思的。

看看demo效果图


![upload successful](/images/pasted-23.png)