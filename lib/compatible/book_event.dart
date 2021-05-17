import 'package:flutter/foundation.dart';
import '../data/data.dart';

import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../utils/utils.dart';

abstract class BookEvent {
  Future<void> initState() async {}

  /// ---------------------------- Database ---------------------
  /// isNew == 1
  Future<void> updateCname(int id, String cname, String updateTime);

  /// isNew == 0
  Future<void> updateMainInfo(int id, int cid, int page);

  Future<void> updateBookIsTop(int id, int isTop);

  Future<List<Map<String, Object?>>> loadFromDb(int bookid, int contentid);

  // 默认返回空
  Future<RawContentLines> load(int bookid, int contentid, int words, {bool update = false}) async =>
      const RawContentLines();

  Future<void> deleteCache(int bookId);

  /// [BookIndexBloc]
  Future<void> cacheinnerdb(int? id, String indexs);

  Future<List<Map<String, Object?>>> sendIndexs(int bookid);

  /// [BookCacheBloc]
  Future<void> addBook(BookCache bookCache);

  Future<int> deleteBook(int id);

  Future<List<Map<String, Object?>>> loadBookInfo();

  /// 默认实现
  Future<RawContentLines?> download(int bookid, int contentid, int words) async {
    assert(Log.i('loading Id: $contentid', stage: this, name: 'download'));

    final bookContent = await getContentFromNet(bookid, contentid);

    if (bookContent.content != null) {
      saveToDatabase(bookContent);
      if (bookContent.content != null) {
        final lines = await textLayout(bookContent.content!, bookContent.cname!, words);
        if (lines.isNotEmpty) {
          return RawContentLines(
            pages: lines,
            nid: bookContent.nid,
            pid: bookContent.pid,
            cid: bookContent.cid,
            hasContent: bookContent.hasContent,
            cname: bookContent.cname,
          );
        }
      }
    }
    return null;
  }

  ///------------------------ Network -------------------------------

  @protected
  Future<BookContent> getContentFromNet(int id, int cid);

  Future<String> getIndexsFromNet(int id);

  Future<List<List>> loadIndexsList(String str);

  Future<BookInfoRoot> loadInfo(int id);

  Future<List<BookList>> getBookList(String c);

  Future<List<BookList>> loadShudan(String c, int index);

  Future<BookListDetailData> loadShudanDetail(int index);

  /// ----------------------------------------------------------------
  // 由内部函数调用
  //
  // 传输层不实现
  @protected
  Future<List<String>> textLayout(String text, String cname, int words) async => divText(text, cname);

  @protected
  Future<void> saveToDatabase(BookContent bookContent) async {}
}

class RawContentLines {
  const RawContentLines({List<String> pages = const [], this.cid, this.pid, this.nid, this.cname, this.hasContent})
      : _pages = pages;
  List<String> get pages => _pages;
  final List<String> _pages;
  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final int? hasContent;
  bool get isEmpty => pages.isEmpty || cid == null || pid == null || nid == null || cname == null || hasContent == null;

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;
}
