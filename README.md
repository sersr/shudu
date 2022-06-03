# shudu

提供简易小说阅读方式

## 个人开发的包：
 - nop_db: 数据库工具包，代码生成，`Isolate`通信协议，动态传输
 - nop_db_sqlite: 使用 sqlite3 作为 nop_db 数据库底层实现
 - useful_tools: 指针采样，图片缓存库（包含flutter相关的库）
 - utils：纯dart工具包

## 构建
- 注释`pubspec.yaml`下`dependency_overrides`项
- flutter channel stable
- 运行下面命令获取最新状态：

        flutter pub upgrade

  note: 如果有插件在本地的要及时拉取最新
- flutter build apk

声明：本项目仅供学习参考
