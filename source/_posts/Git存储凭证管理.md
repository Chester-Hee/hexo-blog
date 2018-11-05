---
title: Git-工具 存储凭证
author: helingfeng
tags: []
categories:
  - Git
  - Composer
  - 存储凭证
  - 源码阅读
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

更多的介绍：https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%87%AD%E8%AF%81%E5%AD%98%E5%82%A8

## Composer 使用Git私有库，404 Not Found 无法正常 `Composer Install` 问题

**问题出现描述**

假设：

- 团队有两个开发人员，`A`和`B`都是使用`mac`环境（osxkeychain 模式会记录验证信息）进行开发

- 我们现在有两个项目`P1`和`P2`和`P3`

- `A`开发者仅拥有`P1`访问权限，并通过 HTTP协议拉取了`P1`项目代码

- `B`开发者在`P2`项目使用 `Composer` 依赖扩展 `P3` 包 Composer.json（使用 git+http）, 并添加Auth.json文件
`Composer.json`
```json
{
  "type": "git",
  "url": "http://domain/project.git"
}
```

当 `A` 用户得到 `P2` 项目时，并使用 `Composer Install`安装依赖会出现 404 Not Found 无法拉取 `P3` 扩展包问题（可以说是Composer没有考虑到的极端情况）

**解决办法**

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










