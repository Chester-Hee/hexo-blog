---
title: Git 选项 --no-ff
author: helingfeng
tags:
  - Git
categories:
  - Git
translate_title: git-option-noff
date: 2018-04-13 16:43:00
---
git merge 记得要加上 --no-ff

![upload successful](/images/pasted-34.png)

- git merge –no-ff 可以保存你之前的分支历史，能够更好的查看 merge 历史，以及 branch 状态。
- git merge 则不会显示 feature，只保留单条分支记录。