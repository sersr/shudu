# shudu

## 介绍

    小说阅读app

## 说明
一些自己写的库说明：

    nop_db: 拥抱 FFI，依赖 sqlite3 包和隔离间通信
    nop_db_gen: 数据库、隔离通信代码生成

隔离通信机制：

    以抽象类为事件类型，支持 implements 和 mixin 并且也生成一个事件类型，通过事件类型在隔离中通信；由 build_runner 生成两个基类，可以通过 mixin 的方式实现方法或处理复杂逻辑；支持的返回类型： Future, Stream;只需实现方法，不用处理通信逻辑；

返回类型:

    Future:与一般函数无二。
    Stream:如果调用的函数和参数都一致，并且Stream没有完成，会在本地自动生成一个Stream返回，而不用再与隔离通信创建另一个通道。两个Stream不是相等的，并且都不是广播，因此当调用`cancel`时，计数减一，如果没有订阅时会关闭通道，否则通道会一直存在。

数据库：  
不是DAO  
以链接的方式生成sql语句，如：
    
    

          
...

## 注意
修改：package:flutter_sticky_header/src/rendering/sliver_sticky_header.dart:274-275


```dart
    BoxValueConstraints<SliverStickyHeaderState>(
    value: state,
```
## 构建
Flutter.sdk >= 2.0

    flutter pub upgrade

## 免责声明

所有的api均来源于网络，请自行更改体验。  
本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。
