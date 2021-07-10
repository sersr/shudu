import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';

import '../utils/utils.dart';
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
  BookEventIsolate(this.appPath, this.sp);

  @override
  final SendPort sp;
  @override
  final String appPath;

  Future<void> initState() => init();

  @override
  void sendEnd(error) {
    Log.e(error);
  }

  @override
  bool remove(key) {
    if (key is KeyController) Log.w(key.keyType);
    return super.remove(key);
  }

  @override
  bool resolve(m) {
    if (super.resolve(m)) return true;

    Log.e(m);

    return false;
  }
}

class BookEventMain extends BookEventMessager
    with ComplexMessager, SaveImageMessager {
  BookEventMain(this.send);
  @override
  final SendEvent send;
}
