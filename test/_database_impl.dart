import 'dart:async';

import 'package:nop_db/nop_db.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/data/zhangdu/zhangdu_chapter.dart';
import 'package:shudu/event/base/complex_event.dart';
import 'package:shudu/event/mixin/database_mixin.dart';

class Database with ComplexOnDatabaseEvent, DatabaseMixin {
  @override
  String get appPath => ':memory:';
  @override
  String get name => '';
  Watcher get watcher => db.watcher;

  @override
  FutureOr<Set<int>?> getZdAllBookId() {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduIndex>?> getZdIndexsDbCacheItem() {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduCacheBookId(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> getZhangduContentCid(int bookid) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    throw UnimplementedError();
  }
}
