title: explain 分析低效 SQL 的执行
author: helingfeng
tags: []
categories:
  - MySQL
date: 2018-04-10 16:47:00
---
本文为读书笔记

通过慢 SQL 日志查询到效率低的 SQL 后，我们可以通过 explain 或者 desc 获取 MySQL 如何执行 SELECT 语句的信息，包括 SELECT 语句执行过程表如何连接和连接的次序。

explain 可以知道什么时候必须为表加入索引以得到一个使用索引来寻找记录 的更快的SELECT。

- select_type： select 类型
- table： 输出结果集的表
- type： 表示表的连接类型
- 当表中仅有一行是type的值为system是最佳的连接类型；
- 当select操作中使用索引进行表连接时type的值为ref；
- 当select的表连接没有使用索引时，经常会看到type的值为ALL，表示对该表
- 进行了全表扫描，这时需要考虑通过创建索引来提高表连接的效率。
- possible_keys： 表示查询时,可以使用的索引列.
- key： 表示使用的索引
- key_len： 索引长度
- rows： 扫描范围
- Extra： 执行情况的说明和描述

```sql
EXPLAIN SELECT admin_users.username,admin_roles.name 
	FROM admin_users
  	LEFT JOIN admin_role_users 
    	ON admin_users.id = admin_role_users.user_id
  	INNER JOIN admin_roles 
    	ON admin_roles.id = admin_role_users.role_id
```


![upload successful](/images/pasted-35.png)