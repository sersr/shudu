# shudu

## 介绍

一个小说阅读app。
> 能阅读就好

![实际效果](./效果.gif)

## 支持功能

* 滑动翻页

  > 简单的 Widget > Element > RenderObject  
  > GestureDetector > Activity

* 数据缓存

  > 使用 sqflite3、Hive 实现

* 背景、字体颜色

  > HSV: 自由选择颜色，调节亮度

## 遇到的问题
页面进出的动画卡顿
> 解决：在页面动画期间不要占用UI,等待任务完成时( 或打断，如HttpClient.close )退出，使用WillPopScope

## 得到的东西
简化PageView(ListView),通用的Widget无法达到需要，项目中一个需求：
> 随机给出一个值(某个章节的页数)，都可以自由(向前，向后) 滑动，也就是双向增长(0不是最小值)  
>...

理清 layout 和 paint 的关系（提示：RenderObject.isRepaintBoundary)
> 本项目的文本(章节内容)布局渲染都参考flutter源码：  
> 手势行为化，viewPort -- ViewportOffset, invokeLayoutCallback 的使用  
> Element 管理 RenderObject  

## 如何提高性能：
> 减少layout，paint；  
> 这个前提是，对渲染管道要有较高的掌握，知道flutter在哪里进行优化；  
> 我的理解是图层（ui.Scene -- Layer)

## 构建

    flutter --version  
>Flutter 1.26.0-17.2.pre • channel dev • https://github.com/flutter/flutter  
>Framework • revision 79b49b9e10 (11 天前) • 2021-02-03 15:33:39 -0800  
> Engine • revision 2c527d6c7e  
> Tools • Dart 2.12.0 (build 2.12.0-259.8.beta)  

由于使用的api来源于网络，有关信息已成为注释参考（lib/bloc/book_repository.dart#BookRepository）,
直接 `flutter run`，达不到预期的效果。

## 关于 packages

由于 [flutter_sticky_header](https://pub.flutter-io.cn/packages/flutter_sticky_header), [pull_to_refresh](https://pub.flutter-io.cn/packages/pull_to_refresh) 还未进行空安全迁移，
所以这两个package 只是简单的用dart的迁移工具进行本地迁移，不是pub版本！！！

pub -> 本地

* flutter_sticky_header -> sticky_header
* pull_to_refresh -> pull_to_refresh


## 免责声明
本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。