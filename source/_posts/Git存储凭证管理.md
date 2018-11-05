---
title: Git-工具 存储凭证
author: helingfeng
tags: []
categories:
  - Git
  - Composer
  - 存储凭证
  - 源码阅读
translate_title: gittool-storage-credentials
date: 2018-11-05 14:00:00
---

## Git存储凭证管理

如果你使用的是 SSH 方式连接远端，并且设置了一个没有口令的密钥，这样就可以在不输入用户名和密码的情况下安全地传输数据。 然而，这对 HTTP 协议来说是不可能的，每一个连接都是需要用户名和密码的。 这在使用双重认证的情况下会更麻烦，因为你需要输入一个随机生成并且毫无规律的 token 作为密码。

---
幸运的是，Git 拥有一个凭证系统来处理这个事情。 下面有一些 Git 的选项：

- 默认所有都不缓存。 每一次连接都会询问你的用户名和密码。
- “cache” 模式会将凭证存放在内存中一段时间。 密码永远不会被存储在磁盘中，并且在15分钟后从内存中清除。
- “store” 模式会将凭证用明文的形式存放在磁盘中，并且永不过期。 这意味着除非你修改了你在 Git 服务器上的密码，否则你永远不需要再次输入你的凭证信息。 这种方式的缺点是你的密码是用明文的方式存放在你的 home 目录下。
- 如果你使用的是 Mac，Git 还有一种 “osxkeychain” 模式，它会将凭证缓存到你系统用户的钥匙串中。 这种方式将凭证存放在磁盘中，并且永不过期，但是是被加密的，这种加密方式与存放 HTTPS 凭证以及 Safari 的自动填写是相同的。
- 如果你使用的是 Windows，你可以安装一个叫做 “winstore” 的辅助工具。 这和上面说的 “osxkeychain” 十分类似，但是是使用 Windows Credential Store 来控制敏感信息。 可以在 https://gitcredentialstore.codeplex.com 下载。

> 更多的介绍：https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%87%AD%E8%AF%81%E5%AD%98%E5%82%A8

## Composer 使用Git私有库，404 Not Found 无法正常 `Composer Install` 问题

**我们团队遇到的问题**

- 团队有一开发人员`A`使用`mac`环境开发（Git存储凭证`osxkeychain`模式会永久缓存凭证）
- 我们现在有两个主项目`P1`和`P2`和一个私有扩展库`F3`
- `A`开发者拥有`P1`和`P2`访问权限，并通过`HTTP`协议`Clone`项目`P1`的源代码（经过了这一步操作，会存储凭证信息）
- `P2`项目使用PHP语言并通过`Composer`工具管理依赖，其中包含`F3`扩展包

`Composer.json`:
```json
{
  "type": "git",
  "url": "http://domain/f3.git"
}
```

`Auth.json`:
```json
{
  "http-basic": {
    "your-domain": {
      "username": "your-token",
      "password": "your-password"
    }
  }
}
```

**当`A`用户克隆`P2`项目，并使用`Composer Install`安装依赖会出现异`404 Not Found F3`，无法成功安装`P3`扩展**

我当时很疑惑？为什么不使用`Auth.json`进行验证？实际使用了缓存中凭证，可以说是Composer没有考虑到的极端情况。

**解决办法?**

### 1.清除Git存储凭证

```shell
# 全部 unset 一遍呗
$ git config --local --unset credential.helper
$ git config --global --unset credential.helper
# 这个要 sudo
$ sudo git config --system --unset credential.helper

# 这三个命令都没有显示任何东西了
$ git config --local credential.helper
$ git config --global credential.helper
$ git config --system credential.helper
```

如果还不生效 ？

```shell
# 还真的依然有 osxkeychain
$ git config -l
credential.helper=osxkeychain

# 跟回答一毛一样
$ git config --show-origin --get credential.helper
file:/Applications/Xcode.app/Contents/Developer/usr/share/git-core/gitconfig    osxkeychain

```

### 2.使用带用户名和密码的.git 

```shell
git clone https://yourusername:yourpassword@gitlab.domain.com/project.git
```










