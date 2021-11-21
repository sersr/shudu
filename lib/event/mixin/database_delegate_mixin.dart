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
import 'network_mixin.dart';
import 'zhangdu_mixin.dart';

class DatabaseDelegate
    with SendEventMixin, SendIsolateMixin, SendCacheMixin, SendInitCloseMixin {
  DatabaseDelegate({
    required this.appPath,
    required this.sqfliteFfiEnabled,
    required this.useSqflite3,
    required this.cachePath,
  });

  final String appPath;
  final bool sqfliteFfiEnabled;
  final bool useSqflite3;
  final String cachePath;

  @override
  Future<Isolate> onCreateIsolate(SendPort remoteSendPort) async {
    return Isolate.spawn(dataBaseEntryPoint,
        [remoteSendPort, appPath, cachePath, sqfliteFfiEnabled, useSqflite3]);
  }
}

void dataBaseEntryPoint(args) async {
  final localSendPort = args[0] as SendPort;
  final appPath = args[1] as String;
  final cachePath = args[2] as String;
  final ffiEnabled = args[3] as bool;
  final useSqflite3 = args[4] as bool;
  final db = DatabaseImpl(
      appPath: appPath,
      cachePath: cachePath,
      sqfliteFfiEnabled: ffiEnabled,
      useSqflite3: useSqflite3);
  final rcPort = ReceivePort();

  await runZonedGuarded(() async {
    await db.initState();
    rcPort.listen((message) {
      if (db.resolveAll(message)) return;
      Log.e('eeeor $message');
    });
  }, (e, s) {
    Log.e('$e\n$s');
  }, zoneSpecification:
      ZoneSpecification(errorCallback: (self, delegate, zone, e, s) {
    Log.e('error:$e\n$s');
    return delegate.errorCallback(zone, e, s);
  }));
  localSendPort.send(rcPort.sendPort);
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
    required this.sqfliteFfiEnabled,
    required this.useSqflite3,
    required this.cachePath,
  });

  Future<void> initState() async {
    await initDb();
  }

  @override
  final String appPath;
  @override
  final bool sqfliteFfiEnabled;
  @override
  final bool useSqflite3;

  final String cachePath;

  @override
  FutureOr<bool> onClose() async {
    await closeDb();
    return true;
  }
}

// 任务隔离(remote):处理 数据库、网络任务
class BookEventIsolateDeleagete extends BookEventResolveMain
    with
        BookCacheEventMessager,
        BookContentEventMessager,
        ZhangduDatabaseEventMessager,
        ComplexOnDatabaseEventMessager,
        ComplexOnDatabaseEvent,
        HiveDioMixin,
        NetworkMixin,
        ComplexMixin,
        ZhangduEventMixin {
  BookEventIsolateDeleagete(this.sp, this.appPath, this.cachePath,
      this.sqfliteFfiEnabled, this.useSqflite3);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  final bool useSqflite3;
  final bool sqfliteFfiEnabled;

  late DatabaseDelegate dbDelegate;
  Future<void> initState() async {
    final d = initNet().logi(false);
    dbDelegate = DatabaseDelegate(
      appPath: appPath,
      cachePath: cachePath,
      sqfliteFfiEnabled: sqfliteFfiEnabled,
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
    // if (msg is IsolateSendMessage || msg is KeyController) {
    //   dbDelegate.sendDelegate(msg);
    //   return;
    // }
    Log.e(error, onlyDebug: false);
  }

  @override
  FutureOr<bool> onClose() async {
    // try {
    await closeNet();
    await dbDelegate.close();
    scheduleMicrotask(() {
      throw 'ssss';
    });
    // } catch (e) {
    //   Log.e('close: error: $e');
    // }
    return true;
  }

  @override
  SendEvent get sendEvent => dbDelegate;
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
