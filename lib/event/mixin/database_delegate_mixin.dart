import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';
import 'package:utils/utils.dart';

import '../base/book_event.dart';
import '../base/complex_event.dart';
import '../base/zhangdu_event.dart';
import 'complex_mixin.dart';
import 'database_mixin.dart';
import 'entry_point.dart';
import 'network_mixin.dart';
import 'zhangdu_mixin.dart';

class DatabaseDelegate
    with SendEventMixin, SendIsolateMixin, SendCacheMixin, SendInitCloseMixin {
  DatabaseDelegate({
    required this.appPath,
    required this.useSqflite3,
    required this.cachePath,
  });

  final String appPath;
  final bool useSqflite3;
  final String cachePath;

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) async {
    return Isolate.spawn(
        dataBaseEntryPoint, [remoteSendPort, appPath, cachePath, useSqflite3]);
  }
}

class DatabaseDelegateMessger extends DatabaseDelegate
    with
        BookCacheEventMessager,
        BookContentEventMessager,
        ZhangduDatabaseEventMessager
// ComplexOnDatabaseEventMessager // 由其他函数间接调用
{
  DatabaseDelegateMessger({
    required String appPath,
    required bool useSqflite3,
    required String cachePath,
  }) : super(
          appPath: appPath,
          useSqflite3: useSqflite3,
          cachePath: cachePath,
        );

  @override
  SendEvent get sendEvent => this;
}

class DatabaseImpl
    with
        Resolve,
        BookCacheEvent,
        BookContentEvent,
        ZhangduDatabaseEvent,
        DatabaseMixin,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexOnDatabaseEventResolve,
        ZhangduDatabaseMixin,
        ZhangduDatabaseEventResolve {
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
}

// 任务隔离(remote):处理 数据库、网络任务
// 在隔离中再创建一个隔离处理数据库任务
class BookEventIsolateDeleagete extends BookEventResolveMain // Resolve 为基类
    with
        BookCacheEventMessager, // 提供本地调用接口（当前Isolate）
        BookContentEventMessager, //
        ZhangduDatabaseEventMessager, //
        ComplexOnDatabaseEventMessager, // （后台之间的交互）
        ComplexOnDatabaseEvent,
        HiveDioMixin,
        NetworkMixin,
        ComplexMixin,
        ZhangduEventMixin {
  BookEventIsolateDeleagete(
      this.sp, this.appPath, this.cachePath, this.useSqflite3);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  final bool useSqflite3;

  late DatabaseDelegate dbDelegate;
  Future<void> initState() async {
    final d = initNet().logi(false);
    dbDelegate = DatabaseDelegate(
      appPath: appPath,
      cachePath: cachePath,
      useSqflite3: useSqflite3,
    );
    await dbDelegate.init();
    await d;
  }

  @override
  bool resolveAll(resolveMessage) {
    if (super.resolveAll(resolveMessage)) return true;
    if (resolveMessage is IsolateSendMessage ||
        resolveMessage is KeyController) {
      Log.i(resolveMessage);
      dbDelegate.sendDelegate(resolveMessage);
      return true;
    }
    return false;
  }

  @override
  void onError(msg, error) {
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    await closeNet();
    await dbDelegate.close();
    return true;
  }

  @override
  SendEvent get sendEvent => dbDelegate;

  /// ------ 代理转发 ---------
  @override
  bool onBookCacheEventResolve(message) {
    dbDelegate.sendDelegate(message);
    return true;
  }

  @override
  bool onBookContentEventResolve(message) {
    dbDelegate.sendDelegate(message);
    return true;
  }

  @override
  bool onZhangduDatabaseEventResolve(message) {
    dbDelegate.sendDelegate(message);
    return true;
  }
}
