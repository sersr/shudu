import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../data/data.dart';
import '../../data/zhangdu/zhangdu_chapter.dart';
import '../../data/zhangdu/zhangdu_detail.dart';
import '../../data/zhangdu/zhangdu_same_users_books.dart';
import '../../data/zhangdu/zhangdu_search.dart';
import '../../database/database.dart';
import '../../pages/book_list/cache_manager.dart';
import 'zhangdu_event.dart';

part 'book_event.g.dart';

@NopIsolateEvent()
abstract class BookEvent
    implements CustomEvent, DatabaseEvent, ComplexEvent, ZhangduEvent {
  BookCacheEvent get bookCacheEvent => this;
  BookContentEvent get bookContentEvent => this;
  CustomEvent get customEvent => this;
  DatabaseEvent get databaseEvent => this;
  ComplexEvent get complexEvent => this;
  ZhangduEvent get zhangduEvent => this;
}

@NopIsolateEventItem(separate: true, isolateName: 'database')
abstract class DatabaseEvent with BookCacheEvent, BookContentEvent {}

abstract class BookContentEvent {
  Stream<List<BookContentDb>?> watchBookContentCid(int bookid);

  FutureOr<int?> deleteCache(int bookId);
}

abstract class ComplexEvent {
  FutureOr<List<CacheItem>?> getCacheItems();

  FutureOr<RawContentLines?> getContent(int bookid, int contentid, bool update);
  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update);
  FutureOr<int?> updateBookStatus(int id);

  FutureOr<BookInfoRoot?> getInfo(int id);
}

abstract class BookCacheEvent {
  FutureOr<List<BookCache>?> getMainList();
  Stream<List<BookCache>?> watchMainList();

  FutureOr<int?> updateBook(int id, BookCache book);
  FutureOr<int?> insertBook(BookCache bookCache);
  FutureOr<int?> deleteBook(int id);

  Stream<List<BookCache>?> watchCurrentCid(int id);
}

abstract class CustomEvent {
  FutureOr<SearchList?> getSearchData(String key);

  @NopIsolateMethod(useTransferType: true)
  FutureOr<Uint8List?> getImageBytes(String img);

  FutureOr<List<BookList>?> getHiveShudanLists(String c);

  FutureOr<List<BookList>?> getShudanLists(String c, int index);
  FutureOr<BookTopData?> getTopLists(String c, String date, int index);
  FutureOr<BookTopData?> getCategLists(int c, String date, int index);

  FutureOr<BookListDetailData?> getShudanDetail(int index);
  FutureOr<List<BookCategoryData>?> getCategoryData();
}

class Uint8ListType with TransferTypeMapData<Uint8List?> {
  Uint8ListType(this.list);
  Uint8List? list;
  @override
  FutureOr<Uint8List?> tranDecode() {
    final buffer = getData('list');
    if (buffer != null) {
      final data = buffer.materialize();
      return data.asUint8List();
    }
  }

  @override
  FutureOr<void> tranEncode() {
    if (list != null) {
      final data = list!;
      list = null;
      final typeData = TransferableTypedData.fromList([data]);
      push('list', typeData);
    }
  }
}

class RawContentLines {
  RawContentLines(
      {this.source = '',
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.hasContent});

  final String source;

  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? hasContent;

  bool get isEmpty =>
      source.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      hasContent == null;

  static RawContentLines none = RawContentLines();

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;

  @override
  String toString() {
    return '$runtimeType: $cid, $pid, $nid, $hasContent, $cname, $source';
  }
}
