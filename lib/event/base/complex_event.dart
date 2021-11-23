import 'dart:async';

import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/nop_db.dart';

import '../../data/data.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../database/nop_database.dart';

part 'complex_event.g.dart';

@NopIsolateEvent()
abstract class ComplexOnDatabaseEvent {
  /// biqu
  FutureOr<List<BookIndex>?> getIndexsDbCacheItem();
  FutureOr<Set<int>?> getAllBookId();
  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs);
  FutureOr<List<BookContentDb>?> getContentDb(int bookid, int contentid);
  FutureOr<List<BookIndex>?> getIndexsDb(int bookid);
  FutureOr<List<BookCache>?> getBookCacheDb(int bookid);
  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb);
  FutureOr<int?> insertOrUpdateBook(BookInfo data);

  /// zhangdu
  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data);
  // FutureOr<List<ZhangduIndex>?> getZdIndexsDbCacheItem();
  // FutureOr<Set<int>?> getZdAllBookId();
  // FutureOr<List<ZhangduCache>?> getZhangduCacheBookId(int bookId);
  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId);
  FutureOr<int?> getZhangduContentCid(int bookid);
  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content);
  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId);
  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data);
}
