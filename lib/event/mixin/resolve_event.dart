// 任务隔离(remote):处理 数据库、网络任务
import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import '../base/zhangdu_event.dart';
import 'complex_mixin.dart';
import 'database_mixin.dart';
import 'network_mixin.dart';
import 'zhangdu_mixin.dart';

/// 所有的事件都在同一个隔离中运行
/// 缺点: 随着任务增加，处理消息的速度会变慢
class BookEventIsolate extends BookEventResolveMain
    with
        ComplexOnDatabaseEvent,
        // base
        DatabaseMixin,
        ZhangduDatabaseMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        ZhangduNetMixin,
        // complex on Database
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin,
        // complex
        ComplexMixin,
        ZhangduComplexMixin {
  BookEventIsolate(this.sp, this.appPath, this.cachePath, this.useSqflite3);

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
        BookCacheEventMessager, // 1 提供本地调用接口（当前Isolate）
        BookContentEventMessager, // 2
        ZhangduDatabaseEventMessager, // 3
        ComplexOnDatabaseEventMessager, // 4（后台之间的交互）
        // sender
        SendEventMixin,
        SendCacheMixin,
        // net
        HiveDioMixin,
        NetworkMixin,
        ZhangduNetMixin,
        // complex
        ComplexMixin,
        ZhangduComplexMixin {
  BookEventMultiIsolate(
      this.appPath, this.cachePath, this.useSqflite3, this.sendPortGroup);

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
  void onResolvedFailed(message) {
    final msg = message.toString();
    Log.e('error: ${msg.substring(100, msg.length)}', onlyDebug: false);
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
    // 当前隔离需要处理的任务如网络任务，需要与数据库通信时，会使用此接口
    // 在Debug模式下查看发送消息的类别
    assert(() {
      final msg = message.toString();
      return Log.i('msg: ${msg.substring(0, math.min(100, msg.length))}');
    }());
    super.send(message);
  }
}

/// 只处理数据库相关操作
class DatabaseImpl
    with
        Resolve,
        BookCacheEvent,
        BookContentEvent,
        ZhangduDatabaseEvent,
        DatabaseMixin,
        ZhangduDatabaseMixin,
        ComplexOnDatabaseMixin,
        ZhangduComplexOnDatabaseMixin,
        BookCacheEventResolve, // 1
        BookContentEventResolve, // 2
        ZhangduDatabaseEventResolve, // 3
        ComplexOnDatabaseEventResolve /* 4 */
{
  DatabaseImpl({
    required this.appPath,
    required this.useSqflite3,
  });

  Future<void> initState() async {
    await initDb();
  }

  @override
  final String appPath;
  @override
  final bool useSqflite3;

  @override
  FutureOr<bool> onClose() async {
    await closeDb();
    return true;
  }

  @override
  void onResolvedFailed(message) {
    final msg = message.toString();
    Log.e('error: ${msg.substring(100, msg.length)}', onlyDebug: false);
  }
}
