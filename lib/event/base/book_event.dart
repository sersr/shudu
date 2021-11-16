import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/common.dart';

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

@NopIsolateEventItem(separate: true)
abstract class DatabaseEvent with BookCacheEvent, BookContentEvent {}

@NopIsolateEventItem()
abstract class BookContentEvent {
  Stream<List<BookContentDb>?> watchBookContentCid(int bookid);

  FutureOr<int?> deleteCache(int bookId);
}

abstract class ComplexEvent {
  FutureOr<List<CacheItem>?> getCacheItems();

  @NopIsolateMethod(useTransferType: true)
  FutureOr<RawContentLines?> getContent(int bookid, int contentid, bool update);
  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update);
  FutureOr<int?> updateBookStatus(int id);

  FutureOr<BookInfoRoot?> getInfo(int id);
}

@NopIsolateEventItem()
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

  @NopIsolateMethod(isDynamic: true)
  FutureOr<Uint8List?> getImageBytes(String img);

  FutureOr<List<BookList>?> getHiveShudanLists(String c);

  FutureOr<List<BookList>?> getShudanLists(String c, int index);
  FutureOr<BookTopData?> getTopLists(String c, String date, int index);
  FutureOr<BookTopData?> getCategLists(int c, String date, int index);

  FutureOr<BookListDetailData?> getShudanDetail(int index);
  FutureOr<List<BookCategoryData>?> getCategoryData();
}

class RawContentLines with TransferType<RawContentLines> {
  RawContentLines(
      {List<String> pages = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.hasContent})
      : _pages = pages;

  List<String> get pages => _pages;
  List<String> _pages;
  int? cid;
  int? pid;
  int? nid;
  String? cname;
  bool? hasContent;

  bool get isEmpty =>
      pages.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      hasContent == null;

  TransferableTypedData? _typedData;

  @override
  void encode() {
    if (_typedData != null || isEmpty) return;
    final dataInt = <int>[];
    final dataString = <TypedData>[];
    final cname = utf8.encode(this.cname ?? '');

    dataInt
      ..add(cname.length)
      ..add(pages.length);
    dataString.add(Uint8List.fromList(cname));

    for (var page in pages) {
      final _p = utf8.encode(page);
      dataInt.add(_p.length);
      dataString.add(Uint8List.fromList(_p));
    }

    final intData = Int32List.fromList(dataInt);
    // 把dataString放在最后，不用处理字节对齐问题
    _typedData = TransferableTypedData.fromList(dataString..insert(0, intData));
    _dispose();
  }

  void _dispose() {
    _pages = const [];
    cname = null;
  }

  static RawContentLines none = RawContentLines();
  bool _decoded = false;
  bool get decoded => _decoded;
  @override
  RawContentLines decode() {
    if (_typedData == null) {
      assert(Log.w(!_decoded ? '_typeData == null' : 'decoded, return none'));
      return this;
    }

    _decoded = true;
    final data = _typedData!.materialize();
    var cursor = 0;
    // dataInit 有6个元素，每个元素4个字节
    const els = 2;
    const dataIntBytes = els * 4;
    var newCname = '';
    final newPages = <String>[];
    var dataIntList = const <int>[];
    final allBytes = data.lengthInBytes;

    if (allBytes >= cursor + dataIntBytes) {
      dataIntList = data.asInt32List(cursor, els);
      cursor += dataIntBytes;
    }

    if (dataIntList.length >= els) {
      final pageLength = dataIntList[els - 1];
      final pagesLengthBytes = pageLength * 4;

      var pageListLength = const <int>[];

      if (allBytes >= cursor + pagesLengthBytes) {
        pageListLength = data.asInt32List(cursor, pageLength);

        cursor += pagesLengthBytes;
      }
      final cnameLength = dataIntList[els - 2];

      if (allBytes >= cursor + cnameLength) {
        final _c = data.asUint8List(cursor, cnameLength);
        newCname = utf8.decode(_c);
        cursor += cnameLength;
      }

      for (final length in pageListLength) {
        final _p = data.asUint8List(cursor, length);
        newPages.add(utf8.decode(_p));
        cursor += length;
      }

      /// 赋值
      cname = newCname;
      _pages = newPages;
      _typedData = null;
    }
    return this;
  }

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;

  @override
  String toString() {
    return '$runtimeType: $cid, $pid, $nid, $hasContent, $cname, $pages';
  }
}
