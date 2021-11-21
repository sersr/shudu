import 'dart:async';

import 'package:nop_annotations/nop_annotations.dart';

import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../data/zhangdu/zhangdu_same_users_books.dart';
import '../../data/zhangdu/zhangdu_search.dart';
import '../../database/database.dart';
import '../../pages/book_list/cache_manager.dart';

@NopIsolateEventItem(separate: true)
abstract class ZhangduEvent
    implements ZhangduDatabaseEvent, ZhangduComplexEvent {}

abstract class ZhangduDatabaseEvent {
  FutureOr<int?> deleteZhangduContentCache(int bookId);

  Stream<List<int>?> watchZhangduContentCid(int bookId);

  FutureOr<List<ZhangduCache>?> getZhangduMainList();
  Stream<List<ZhangduCache>?> watchZhangduMainList();
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book);
  FutureOr<int?> insertZhangduBook(ZhangduCache book);
  FutureOr<int?> deleteZhangduBook(int bookId);
  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId);
  FutureOr<List<CacheItem>?> getZhangduCacheItems();
}

abstract class ZhangduComplexEvent {
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update);

  FutureOr<int?> updateZhangduMainStatus(int bookId);
  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId);
  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update);

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author);

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize);
}
