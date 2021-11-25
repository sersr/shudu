import 'dart:async';

import '../../data/data.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../database/nop_database.dart';


// @NopIsolateEventItem(isolateName: 'complexOnDatabase', create: false)
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
  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId);
  FutureOr<int?> getZhangduContentCid(int bookid);
  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content);
  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId);
  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data);
}
