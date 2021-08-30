# shudu

## 介绍

    编写一个小说阅读app，开发有趣的工具


## 其中使用到的包：
 - nop_db: 数据库工具包，代码生成，`Isolate`通信协议，动态传输
 - nop_db_sqlite: 使用 sqlite3 作为 nop_db 数据库底层实现
 - nop_db_sqflite: 使用 sqflite 作为 nop_db 数据库底层实现

nop_db实现为：以编程的方式编写sql语句，并提供监听查询数据，以`Stream`的方式实现，配合`Isolate`通信协议，只需实现数据库操作方法，就可以把所有耗时的任务放到`Isolate`中，支持动态`TransferableTypedData`传输(暂未支持内嵌，因为`materialize`只能调用一次，而同一个方法调用是有可能接收到同一个对象的，所以在内部调用`materialize`存储引用，接受方只会接收到`ByteBuffer`，在未来可能提供一个转换器)

- useful_tools: 其他有趣的工具，包括指针采样，异步任务队列，图片缓存库

记得修改：package:flutter_sticky_header/src/rendering/sliver_sticky_header.dart:274-275  
作者好久没更新了。。。

```dart
    BoxValueConstraints<SliverStickyHeaderState>(
    value: state,
```
## 构建
- Flutter.sdk >= 2.0
- 将`pubspec.yaml`本地package替换成github版本
- 或者在项目的同级目录创建`packages`目录，并克隆所有包到其中
- 必要时：

        flutter pub upgrade

- 到目前为止并没有做好版本控制，所以最好都更新到最新版本

研究方向：动态化(DeferredComponent)  
目前 flutter 官方只支持 aab 的构建方式，不过 apk 也是可能通过一些方式支持。
不过不同版本的单元(unit)是不能共用的，不过对于大项目来说是有用的，延迟加载，可以从本地，网络下载组件，减少内存占用，热更新方案。。。

## 免责声明

所有的api均来源于网络，请自行更改体验。  
本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。
