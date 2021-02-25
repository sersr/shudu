# shudu

## 介绍

一个小说阅读app。
> 功能并没有齐全，是一个Demo，解决在特定场景下遇到的问题。

由于`TextPainter.layout`不能在其他`Isolate` 中调用，布局会消耗大量的ui资源，不过如果遵循用户行为，我们可以发现它可控。当用户无手势或贴边，并且有任务在等待时，占用ui，此时手势操作无效。  
理论上文本布局应该不占用ui的。(GitHub有相关的issue)  
release 版本

![实际效果](./效果.gif)

## 构建

    flutter --version  
> Flutter 1.27.0-4.0.pre • channel dev • <https://github.com/flutter/flutter.git>  
> Framework • revision f8cd24de95 (7 days ago) • 2021-02-16 11:24:17 -0800  
> Engine • revision 1d537824d6  
> Tools • Dart 2.13.0 (build 2.13.0-30.0.dev)  

## 全面屏

Android只有官方(android 9)适配; 从`ui.window`中取得的数据分析的，理论上Iphone应该也适配了，待测试。  

## 关于 packages

由于 [flutter_sticky_header](https://pub.flutter-io.cn/packages/flutter_sticky_header), [pull_to_refresh](https://pub.flutter-io.cn/packages/pull_to_refresh) 还未进行空安全迁移，
所以这两个package 只是简单的用dart的迁移工具进行本地迁移，不是pub版本！！！(ps: 先用着)

pub -> 本地

* flutter_sticky_header -> sticky_header
* pull_to_refresh -> pull_to_refresh

## API

所有的api均来源于网络，请自行更改体验。

## 免责声明

本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。
