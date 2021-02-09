# shudu

## 介绍

一个小说阅读app。

## 支持功能

* 滑动翻页

  > 优化：重新设计，布局重写，不选择通用Widget(PageView...)

* 数据缓存

  > 使用 sqflite3、Hive 实现

* 背景、字体颜色

  > HSV: 自由选择、调节颜色

## 关于 packages

由于 [flutter_sticky_header](https://pub.flutter-io.cn/packages/flutter_sticky_header), [pull_to_refresh](https://pub.flutter-io.cn/packages/pull_to_refresh) 还未进行空安全迁移，
所以这两个package 只是简单的用dart的迁移工具进行本地迁移，不是pub版本！！！

pub -> 本地

* flutter_sticky_header -> sticky_header
* pull-to_refresh -> pull-to_refresh
