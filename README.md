# shudu

## 介绍

    小说阅读，注重文本阅读（其他功能没怎么实现）


## 更新

关键代码重构

多任务实现

    通过 Future 异步的进行加载任务,并添加到 map 中,可以跟踪任务的状态是否已完成,
    在完成后, 调用 then 注册的回调自动从 map 删除,由于删除操作是由 Future 调用的,
    所以在代码逻辑上很简洁,也可以在 then 中调用其他操作,即实现自动下载

全屏优化
    
    通过 plugin 从 Android 端直接获取 size 和 刘海屏相关信息,
    支持横屏切换和刘海防遮挡

UI动画

    在文本阅读界面中,更新动画系统
...

## 注意
    卡顿的原因在于占用 UI 资源进行文本布局，解决方案是使用 ffi 在隔离中布局(计划事项)


## 构建
    Flutter.sdk >= 2.0

## 免责声明

所有的api均来源于网络，请自行更改体验。  
本项目仅用于研究学习,请勿用于商业,否则后果与本人无关。
