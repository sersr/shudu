import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/common.dart';

import 'base/book_event.dart';
import 'mixin/complex_mixin.dart';
import 'mixin/database_mixin.dart';
import 'mixin/event_messager_mixin.dart';
import 'mixin/network_mixin.dart';

export 'base/constants.dart';
export 'base/repository.dart';

// 以数据库为基类
// 网络任务 mixin
class BookEventIsolate extends BookEventResolve
    with DatabaseMixin, NetworkMixin, ComplexMixin {
  BookEventIsolate(this.sp, this.appPath, this.cachePath);

  @override
  final SendPort sp;
  @override
  final String appPath;
  @override
  final String cachePath;

  Future<void> initState() => netEventInit();

  @override
  void onError(error) {
    Log.e(error);
  }

  @override
  bool remove(key) {
    assert(key is! KeyController || Log.w(key));
    return super.remove(key);
  }

  @override
  bool resolve(m) {
    return super.resolve(m);
  }
}

class BookEventMain extends BookEventMessager
    with ComplexMessager, SaveImageMessager {
  BookEventMain(this.send);
  @override
  final SendEvent send;
}

void isolateEvent(List args) async {
  final port = args[0];
  final appPath = args[1];
  final cachePath = args[2];
  final receivePort = ReceivePort();

  final db = BookEventIsolate(port, appPath, cachePath);
  await db.initState();

  receivePort.listen((m) {
    if (db.resolve(m)) return;
    Log.e('somthing was error: $m');
  });

  port.send(receivePort.sendPort);
}
