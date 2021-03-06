---
title: 拒绝服务攻击防范-Nginx
author: helingfeng
tags:
  - Nginx
categories:
  - Nginx
translate_title: denial-of-service-attack-prevention-nginx
date: 2018-04-30 15:55:00
---
一个网站性能有限，如果有人恶意去频繁对页面进行刷新，其实对服务器影响是很大的，导致资源使用非常高，直接影响到其他用户的体验。
那么对于这样的一些频繁访问，我们该如何去拒绝它呢？
我总结了两种方法：第一种方式通过**Web服务器检查拒绝**，第二种方式通过**代码进行拦截过滤**。

### 通过Web服务器检查拒绝

第一种方式大致原理和思路是这样的，比如我们的Web服务器采用Nginx，那个Nginx可以记录用户访问记录，并通过查询分析这个日志可以得出频繁访问用户IP列表。

我们需要做的事情：
做一个定时任务，定时去分析日志文件，将得到的频繁访问用户的IP，并将IP设置到Nginx配置文件中的IP黑名单中，然后进行reload配置文件，当IP类表较大时，可以更新到iptables中去。

日志文件，查询IP的访问次数
```
grep '202.154.216.155' 2017-12-03.access.log|wc -l
289
#

curl ipinfo.io/202.154.216.155;echo''
{
  "ip": "202.154.216.155",
  "hostname": "fr.07.gs",
  "city": "",
  "region": "",
  "country": "ZH",
  "loc": "112.8600,3.3500",
  "org": "AS12876 ONLINE S.A.S."
}
```
在 Nginx 上，所以可以使用 Nginx 的 Deny 来拒绝攻击者的IP访问。

```
deny 195.154.211.220;
deny 195.154.188.28;
deny 195.154.188.186;
deny 180.97.106.161;
deny 180.97.106.162;
deny 180.97.106.36;
```


### 通过代码进行拦截过滤

具体做法是，在拦截器/过滤器中做一个计数器，如果单位时间内访问同一个资源或接口的次数超过安全阈值，则进行403拒绝访问返回。

> 实践更能检验代码