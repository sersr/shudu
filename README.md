# shudu

## 介绍

    小说阅读项目app


## 使用到的包：
 - nop_db: 数据库工具包，代码生成，`Isolate`通信协议，动态传输
 - nop_db_sqlite: 使用 sqlite3 作为 nop_db 数据库底层实现
 - nop_db_sqflite: 使用 sqflite 作为 nop_db 数据库底层实现

- useful_tools: 指针采样，异步任务队列，图片缓存库

记得修改：package:flutter_sticky_header/src/rendering/sliver_sticky_header.dart:274-275  
作者好久没更新了。。。

```dart
    BoxValueConstraints<SliverStickyHeaderState>(
    value: state,
```

## 构建
- flutter channel: master
- 在项目的根目录下运行：

        dart run tools/sync.dart
 
保持最新状态：

    flutter pub upgrade

ps: 基于 flutter/master,没有做版本控制

## 免责声明

所有的api均来源于网络，请自行更改体验。  
本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。
