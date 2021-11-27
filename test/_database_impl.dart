import 'dart:async';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:shudu/data/zhangdu/zhangdu_detail.dart';
import 'package:shudu/data/biquge/book_info.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/data/zhangdu/zhangdu_chapter.dart';
import 'package:shudu/event/base/complex_event.dart';
import 'package:shudu/event/mixin/base/database_mixin.dart';

class Database
    with ListenMixin, Resolve, ComplexOnDatabaseEvent, DatabaseMixin {
  @override
  String get appPath => ':memory:';
  @override
  String get name => '';
  Watcher get watcher => db.watcher;

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

  @override
  FutureOr<Set<int>?> getAllBookId() {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<BookCache>?> getBookCacheDb(int bookid) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<BookContentDb>?> getContentDb(int bookid, int contentid) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<BookIndex>?> getIndexsDbCacheItem() {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    throw UnimplementedError();
  }

  @override
  SendPort? get remoteSendPort => throw UnimplementedError();
}
