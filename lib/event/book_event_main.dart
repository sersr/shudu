import 'package:flutter/foundation.dart';

import 'book_event.dart';
import 'book_event_delegate.dart';
import 'book_event_messager.dart';
import 'database.dart';
import 'repository.dart';

// 验证平台，判断是否可以开启隔离任务
class BookEventMain extends BookEvent with BookEventDelegateMixin {
  BookEventMain({required Repository repository}) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        target = InnerBookEventMainIsolate(repository);
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        target = InnerDatabaseIsoateTransformer(repository);
        break;
      default:
    }
  }

  @override
  late BookEvent target;
}

/// 数据库在 main Isolate 中调用
///
/// 网络任务在 另一个 Isolate 中调用
class InnerBookEventMainIsolate extends BookEvent
    with
        SqfliteDatabase,
        InnerDatabaseImpl,
        ContentDatabaseImpl,
        BookEventMessager {
  InnerBookEventMainIsolate(this.repository);
  @override
  final Repository repository;
}

/// 中间层
///
/// 由 main Isolate 传输到另一个 Isolate
class InnerDatabaseIsoateTransformer extends BookEvent
    with BookEventDatabaseMessager, ContentMessager, BookEventMessager {
  InnerDatabaseIsoateTransformer(this.repository);
  @override
  final Repository repository;
}
