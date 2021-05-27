import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../data/data.dart';
import '../database/table.dart';
import '../pages/book_list_view/cacheManager.dart';

abstract class BookEvent
    implements CustomEvent, DatabaseEvent, ComplexEventBase {
  BookInfoEvent get bookInfoEvent => this;
  BookContentEvent get bookContentEvent => this;
  BookIndexEvent get bookIndexEvent => this;
  CustomEvent get customEvent => this;
  DatabaseEvent get databaseEvent => this;
}

abstract class DatabaseEvent
    with BookInfoEvent, BookContentEvent, BookIndexEvent {}

abstract class BookContentEvent {
  Future<List<Map<String, Object?>>> getCacheContentsCidDb(int bookid);

  Future<void> deleteCache(int bookId);
}

abstract class BookIndexEvent {
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid);

  /// [BookIndexBloc]
  Future<void> insertOrUpdateIndexs(int? id, String indexs);
}

abstract class ComplexEventBase {
  Future<CacheItem> getCacheItem(int id);

  Future<RawContentLines> getContent(int bookid, int contentid, bool update);
}

mixin ComplexEventDatabase {
  void saveContent(BookContent bookContent);
}

mixin ComplexEventInner on ComplexEventBase, ComplexEventDatabase {}

abstract class BookInfoEvent {
  Future<List<Map<String, Object?>>> getMainBookListDb();

  /// isNew == 1
  Future<void> updateBookStatusAndSetNew(int id,
      [String? cname, String? updateTime]);

  Future<void> updateBookStatusCustom(int id, int cid, int page);

  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow);

  Future<void> insertBook(BookCache bookCache);

  Future<int> deleteBook(int id);

  Future<Set<int>> getAllBookId();
}

abstract class CustomEvent {
  Future<SearchList> getSearchData(String key);

  Future<String> getImagePath(String img);

  Future<String> getIndexsNet(int id);

  Future<List<List>> getIndexsDecodeLists(String str);

  Future<BookInfoRoot> getInfo(int id);

  Future<List<BookList>> getHiveShudanLists(String c);

  Future<List<BookList>> getShudanLists(String c, int index);

  Future<BookListDetailData> getShudanDetail(int index);

  // @protected
  // Future<BookContent> getContentNet(int id, int cid);

  // @protected
  // Future<List<String>> textLayout(String text, String cname, int words);
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
  final int? hasContent;
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
      raw.hasContent ?? 0,
    ];
    final dataString = <TypedData>[];
    final cname = utf8.encode(raw.cname ?? '');

    dataInt..add(cname.length)..add(raw.pages.length);
    dataString.add(Uint8List.fromList(cname));

    raw.pages.forEach((page) {
      final _p = utf8.encode(page);
      dataInt.add(_p.length);
      dataString.add(Uint8List.fromList(_p));
    });

    final intData = Int32List.fromList(dataInt);
    return TransferableTypedData.fromList(dataString..insert(0, intData));
  }

  static RawContentLines decode(ByteBuffer data) {
    var start = 0;
    final six = 6;
    final sixLengthBytes = six * 4;
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
          hasContent: list[3],
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
