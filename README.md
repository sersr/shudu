# shudu

## 介绍

    提供简易小说阅读方式

## 使用到的包：
 - nop_db: 数据库工具包，代码生成，`Isolate`通信协议，动态传输
 - nop_db_sqlite: 使用 sqlite3 作为 nop_db 数据库底层实现

- useful_tools: 指针采样，异步任务队列，图片缓存库

## 构建
- flutter channel stable
- 运行下面命令获取最新状态：

        flutter pub upgrade
- flutter build apk / windows

## web平台可能有跨域问题：  
可以在`flutter/packages/flutter_tools/lib/web/chrome.dart`下添加`--disable-web-security`启动参数

声明：本项目仅供学习参考，请支持书籍原作者
