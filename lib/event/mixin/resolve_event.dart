// 任务隔离(remote):处理 数据库、网络任务
import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import 'complex_mixin.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';
import 'zhangdu_mixin.dart';

/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
class BookEventIsolate extends BookEventResolveMain
    with
        DatabaseMixin,
        HiveDioMixin,
        NetworkMixin,
        ComplexMixin,
        ZhangduDatabaseMixin,
        ZhangduEventMixin {
  BookEventIsolate(this.sp, this.appPath, this.cachePath,
      this.useSqflite3);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  @override
  final bool useSqflite3;

  Future<void> initState() async {
    final d = initNet().logi(false);
    await initDb();
    await d;
  }

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    await closeDb();
    await closeNet();
    return true;
  }
}

/// 任务隔离(remote):处理 数据库、网络任务
/// 接受一个[SendPortOwner]处理数据库消息
class BookEventMultiIsolate extends BookEventResolveMain // Resolve 为基类
    with
        ComplexOnDatabaseEvent, // 只是接口声明，[ComplexOnDatabaseEventMessager] 已实现
        BookCacheEventMessager, // 提供本地调用接口（当前Isolate）
        BookContentEventMessager, //
        ZhangduDatabaseEventMessager, //
        ComplexOnDatabaseEventMessager, // （后台之间的交互）
        SendEventMixin,
        SendCacheMixin,
        HiveDioMixin,
        NetworkMixin,
        ComplexMixin,
        ZhangduEventMixin {
  BookEventMultiIsolate(this.sp, this.appPath, this.cachePath,
        this.useSqflite3,
      this.sendPortGroup);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  final bool useSqflite3;

  @override
  SendPortOwner? sendPortGroup;

  Future<void> initState() async {
    final d = initNet().logi(false);
    await d;
  }

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    await closeNet();
    sendPortGroup = null;
    return true;
  }

  @override
  SendEvent get sendEvent => this;

  /// ------ 代理转发 ---------
  /// 几个`Messager`就有几个`Resolve`
  /// 例外：除非是内部之间的通信如：[ComplexOnDatabaseEventMessager]
  ///
  /// 接收者也可以是发送者
  @override
  bool onBookCacheEventResolve(message) {
    sendDelegate(message);
    return true;
  }

  @override
  bool onBookContentEventResolve(message) {
    sendDelegate(message);
    return true;
  }

  @override
  bool onZhangduDatabaseEventResolve(message) {
    sendDelegate(message);
    return true;
  }

  @override
  void send(message) {
    assert(() {
      final msg = message.toString();
      return Log.i('msg: ${msg.substring(0, math.min(100, msg.length))}');
    }());
    super.send(message);
  }
}
