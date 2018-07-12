---
title: MacOs 动态地图桌面壁纸
author: helingfeng
tags:
  - 壁纸
categories:
  - Python
translate_title: macos-dynamic-map-desktop-wallpaper
date: 2018-05-09 15:12:00
---
## 炫酷动态地球壁纸配置

himawaripy 是基于 Python3 编写的脚本，用于实时获取 `向日葵 8 号 卫星 (ひまわり8号)` 拍摄的地球地图，并设置为你的桌面壁纸。

向日葵 8 号 卫星 (ひまわり8号)，搭载日本气象厅新型气象卫星“向日葵8号”的H2A火箭25号机于2014年10月7日14时16分从鹿儿岛县南种子町宇宙航空研究开发机构种子岛宇宙中心发射升空。“向日葵8号”搭载的传感器性能，观测频率高，有望在监测暴雨云团、台风动向以及持续对喷发活动的火山等防灾领域做出贡献

### 安装 himawaripy

#### 使用 git 下载源代码

```shell
cd ~
git clone https://github.com/boramalper/himawaripy.git
```
#### Python3 运行安装脚本

```shell
sudo python3 setup.py install
```

#### 运行测试

```shell
himawaripy --auto-offset

# 成功打印信息，并自动更替桌面壁纸

himawaripy 2.0.1
Updating...
Latest version: 2018/05/09 00:50:00 GMT.
Downloading tiles...
Downloading tiles: 1/16 completed...
Downloading tiles: 2/16 completed...
Downloading tiles: 3/16 completed...
Downloading tiles: 4/16 completed...
Downloading tiles: 5/16 completed...
Downloading tiles: 6/16 completed...
Downloading tiles: 7/16 completed...
Downloading tiles: 8/16 completed...
Downloading tiles: 9/16 completed...
Downloading tiles: 10/16 completed...
Downloading tiles: 11/16 completed...
Downloading tiles: 12/16 completed...
Downloading tiles: 13/16 completed...
Downloading tiles: 14/16 completed...
Downloading tiles: 15/16 completed...
Downloading tiles: completed.
Saving to '/Users/helingfeng/Library/Caches/himawaripy/himawari-20180509T005000.png'...

```

#### himawaripy 命令部分参数介绍

-l level 缩写，可选 4，8，16，20。表示下载图片的质量，也就是瓦片数，n 就代表有 2的 n 次方张瓦片组合成的图片。

其他参数，参考帮助文档
```shell
usage: himawaripy [-h] [--version] [--auto-offset | -o OFFSET]
                  [-l {4,8,16,20}] [-d DEADLINE] [--save-battery]
                  [--output-dir OUTPUT_DIR]

set (near-realtime) picture of Earth as your desktop background

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  --auto-offset         determine offset automatically
  -o OFFSET, --offset OFFSET
                        UTC time offset in hours, must be less than or equal
                        to +10
  -l {4,8,16,20}, --level {4,8,16,20}
                        increases the quality (and the size) of each tile.
                        possible values are 4, 8, 16, 20
  -d DEADLINE, --deadline DEADLINE
                        deadline in minutes to download all the tiles, set 0
                        to cancel
  --save-battery        stop refreshing on battery
  --output-dir OUTPUT_DIR
                        directory to save the temporary background image

http://labs.boramalper.org/himawaripy

```

### MacOS 已经放弃 crontab , 可以选择 launchd 服务管理工具。

配置定时任务 600s , 定时运行 himawaripy 生成新的地图壁纸。

从 git 下载源代码 osx 目录拷贝 plist 文件。
```shell
mkdir -p ~/Library/LaunchAgents/
cp osx/org.boramalper.himawaripy.plist ~/Library/LaunchAgents/
```

启动定时服务

```shell
launchctl load ~/Library/LaunchAgents/org.boramalper.himawaripy.plist
```

### 效果展示

![screen3](/images/screen_3.png)

完成，我们静静感受吧~

