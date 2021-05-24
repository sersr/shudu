import 'package:flutter/foundation.dart';

import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../data/data.dart';

abstract class BookEvent implements CustomEvent, DatabaseEvent {
  Future<RawContentLines> getContent(
      int bookid, int contentid, int words, bool update);
}

abstract class DatabaseEvent {
  Future<void> initState();

  /// isNew == 1
  Future<void> updateBookStatusAndSetNew(
      int id, String cname, String updateTime);

  /// isNew == 0
  Future<void> updateBookStatus(int id, int cid, int page);

  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow);

  Future<void> deleteCache(int bookId);

  /// [BookIndexBloc]
  Future<void> insertOrUpdateIndexs(int? id, String indexs);
 
  Future<List<Map<String, Object?>>> getCacheContentsDb(int bookid);

  /// [BookCacheBloc]
  Future<void> insertBook(BookCache bookCache);

  Future<int> deleteBook(int id);

  Future<List<Map<String, Object?>>> getMainBookListDb();

  @protected
  Future<void> saveContent(BookContent bookContent);
  @protected
  Future<List<Map<String, Object?>>> getContentDb(int bookid, int contentid);
  Future<Set<int>> getAllBookId();
    Future<List<Map<String, Object?>>> getIndexsDb(int bookid);
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

  @protected
  Future<BookContent> getContentNet(int id, int cid);

  @protected
  Future<List<String>> textLayout(String text, String cname, int words);
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

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;
}
