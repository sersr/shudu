import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:nop_annotations/nop_annotations.dart';
import 'package:nop_db/database/table.dart';
import 'package:nop_db/nop_db.dart';

import '../../data/data.dart';
import '../../database/database.dart';
import '../../pages/book_list/cache_manager.dart';

part 'book_event.g.dart';

@NopIsolateEvent()
abstract class BookEvent implements CustomEvent, DatabaseEvent, ComplexEvent {
  BookCacheEvent get bookCacheEvent => this;
  BookContentEvent get bookContentEvent => this;
  // BookIndexEvent get bookIndexEvent => this;
  CustomEvent get customEvent => this;
  DatabaseEvent get databaseEvent => this;
}

@NopIsolateEventItem(separate: true)
abstract class DatabaseEvent with BookCacheEvent, BookContentEvent {}

@NopIsolateEventItem()
abstract class BookContentEvent {
  FutureOr<List<BookContentDb>?> getCacheContentsCidDb(int bookid);
  Stream<List<BookContentDb>?> watchCacheContentsCidDb(int bookid);

  FutureOr<int?> deleteCache(int bookId);
}

abstract class ComplexEvent {
  FutureOr<CacheItem?> getCacheItem(int id);
  @NopIsolateMethod(isDynamic: true)
  FutureOr<RawContentLines?> getContent(int bookid, int contentid, bool update);
  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update);
  FutureOr<int?> updateBookStatus(int id);

  FutureOr<Map<int, CacheItem>?> getCacheItemAll();
  FutureOr<BookInfoRoot?> getInfo(int id);
}

@NopIsolateEventItem()
abstract class BookCacheEvent {
  FutureOr<List<BookCache>?> getMainBookListDb();

  FutureOr<int?> updateBook(int id, BookCache book);

  FutureOr<int?> insertBook(BookCache bookCache);

  FutureOr<int?> deleteBook(int id);

  FutureOr<Set<int>?> getAllBookId();

  Stream<List<BookCache>?> watchBookCacheCid(int id);
  Stream<List<BookCache>?> watchMainBookListDb();
}

abstract class CustomEvent {
  FutureOr<SearchList?> getSearchData(String key);

  FutureOr<String?> getImagePath(String img);

  FutureOr<List<BookList>?> getHiveShudanLists(String c);

  FutureOr<List<BookList>?> getShudanLists(String c, int index);
  FutureOr<BookTopData?> getTopLists(String c, String date, int index);
  FutureOr<BookTopData?> getCategLists(int c, String date, int index);

  FutureOr<BookListDetailData?> getShudanDetail(int index);
  FutureOr<List<BookCategoryData>?> getCategoryData();
}

class RawContentLines {
  const RawContentLines(
      {List<String> pages = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.hasContent})
      : _pages = pages;

  List<String> get pages => _pages;
  final List<String> _pages;
  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? hasContent;
  bool get isEmpty =>
      pages.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      hasContent == null;

  static TransferableTypedData encode(RawContentLines raw) {
    final dataInt = <int>[
      raw.cid ?? 0,
      raw.pid ?? 0,
      raw.nid ?? 0,
      Table.boolToInt(raw.hasContent) ?? 0,
    ];
    final dataString = <TypedData>[];
    final cname = utf8.encode(raw.cname ?? '');

    dataInt
      ..add(cname.length)
      ..add(raw.pages.length);
    dataString.add(Uint8List.fromList(cname));

    for (var page in raw.pages) {
      final _p = utf8.encode(page);
      dataInt.add(_p.length);
      dataString.add(Uint8List.fromList(_p));
    }

    final intData = Int32List.fromList(dataInt);
    return TransferableTypedData.fromList(dataString..insert(0, intData));
  }

  static RawContentLines decode(ByteBuffer data) {
    var start = 0;
    const six = 6;
    const sixLengthBytes = six * 4;
    var cname = '';
    final pages = <String>[];
    var list = const <int>[];

    if (data.lengthInBytes >= start + sixLengthBytes) {
      list = data.asInt32List(start, six);
      start += sixLengthBytes;
    }

    if (list.length >= six) {
      final pageLength = list[5];
      final pagesLengthBytes = pageLength * 4;

      var pageListLength = const <int>[];

      if (data.lengthInBytes >= start + pagesLengthBytes) {
        pageListLength = data.asInt32List(start, pageLength);

        start += pagesLengthBytes;
      }
      final cnameLength = list[4];

      if (data.lengthInBytes >= start + cnameLength) {
        final _c = data.asUint8List(start, cnameLength);
        cname = utf8.decode(_c);
        start += cnameLength;
      }
      if (pageListLength.isNotEmpty) {
        for (var i = 0; i < pageListLength.length; i++) {
          final _length = pageListLength[i];
          final _p = data.asUint8List(start, _length);
          pages.add(utf8.decode(_p));
          start += _length;
        }
      }
    }
    if (list.isNotEmpty) {
      return RawContentLines(
          cid: list[0],
          pid: list[1],
          nid: list[2],
          hasContent: Table.intToBool(list[3]),
          cname: cname,
          pages: pages);
    } else {
      return const RawContentLines();
    }
  }

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;
  @override
  String toString() {
    return '$runtimeType: $cid, $pid, $nid, $hasContent, $cname, $pages';
  }
}
