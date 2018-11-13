---
title: Vue + Webpack 学习笔记
author: Chester-He
tags:
  - Vue
  - Webpack
categories:
  - Vue
translate_title: vue-webpack-learn-note
date: 2018-11-13 10:01:00
---

## Vue 安装

- CDN

这个一个很好的开始，直接在页面引入 script 标签，就可以开启 Vue 的世界！

```html
<script src="https://cdn.jsdelivr.net/npm/vue@2.5.17/dist/vue.js"></script>
```

当然如果你担心直接引入 script 标签会有一天失效，可以下载文件保存到自己的服务器中，然后引用自己的服务链接。我开发工作中也经常这么干，缺点就是如果访问流量较大，还是需要加 CDN 进行缓冲。

- Webpack

非常有意思的开发方式，前端现在最火的打包和构建工具，它的强大而我还只能远望，使用 Webpack 构建，Vue 官方文档也提供了支持：

```js
module.exports = {
  // ...
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js' // 用 webpack 1 时需用 'vue/dist/vue.common.js'
    }
  }
}
```

这个很重要，否则 `import Vue form 'vue';` 永远是一片空白的（ #app ）渲染结果！我刚开始使用的时候，就怎么也想不明白，只能说看文档很重要。

## Webpack 配置

最简单的一份配置文件，单一入口 main.js 文件，默认来自 src 目录 ；构建压缩输出 bundle.js 文件，默认输出到 dist 目录

```ecmascript 6
const path = require('path');

const config = {
    mode: 'development',
    entry: './src/main.js',
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'bundle.js'
    },
    resolve: {
        alias: {
            'vue$': 'vue/dist/vue.esm.js'
        }
    }
};
module.exports = config;
```

配置中 mode 来自 Webpack4 的特性！
源文件 main.js 引入 vue 并构建 vue 对象，定义数据 message 字符串，还定义 method reverseMessage 将字符串进行翻转操作

```ecmascript 6
import Vue from 'vue';

var app = new Vue({
    el: '#app',
    data: {
      message: 'Hello Vue.js!'
    },
    methods: {
      reverseMessage: function () {
        this.message = this.message.split('').reverse().join('')
      }
    }
});
```

入口页面 index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Vue - Learn</title>
  </head>
    <body>
      <h4> Vue - Learn </h4>
      <div id="app-5">
          <p>{{ message }}</p>
          <button v-on:click="reverseMessage">逆转消息</button>
      </div>
      <script src="../dist/bundle.js"></script>
    </body>
</html>
```

依赖包 package.json

```json
{
  "name": "vue-demo",
  "version": "1.0.0",
  "description": "",
  "main": "webpack.config.js",
  "author": "",
  "license": "ISC",
  "dependencies": {
    "vue": "^2.5.10"
  },
  "devDependencies": {
    "webpack": "^4.25.1",
    "webpack-cli": "^3.1.2"
  }
}
```

```shell
# 首选安装依赖扩展，建议使用国内源
npm install 

# 构建 bundle.js
webpack 
```

输入 webpack 时，你可能会发现命令找不到；是的，你全局没有这个命令，所以你可以选择选择安装方式 npm install g webpack，或者也可以使用 ./node_modules/webpack/bin/webpack 相对路径执行命令。还有一种是推荐的方法，在 package.json 中添加 scripts

```json
"scripts": {
    "build": "webpack"
}
```

那么，就可以执行使用 npm run build 命令，它代表的命令就是 ./node_modules/webpack/bin/webpack


done 运行结果：

![vue-demo](/images/demo.png)
