import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../data/data.dart';
import 'book_event.dart';

// 代理
mixin BookEventDelegateMixin on BookEvent {
  // setter
  BookEvent get target;

  @override
  Future<void> initState() async {
    return target.initState();
  }

  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, int words, bool update) async {
    return target.getContent(bookid, contentid, words, update);
  }

  @override
  Future<void> insertBook(BookCache bookCache) => target.insertBook(bookCache);

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) =>
      target.insertOrUpdateIndexs(id, indexs);

  @override
  Future<int> deleteBook(int id) => target.deleteBook(id);

  @override
  Future<void> deleteCache(int bookId) => target.deleteCache(bookId);

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() =>
      target.getMainBookListDb();
  // @override
  // Future<RawContentLines?> getContentDb(int bookid, int contentid, int words,
  //     {bool update = false}) {
  //   return target.getContentDb(bookid, contentid, words, update: update);
  // }
  // @override
  // Future<List<Map<String, Object?>>> getContentDb(int bookid, int contentid) =>
  //     target!.getContentDb(bookid, contentid);

  @override
  Future<List<Map<String, Object?>>> getContentDb(int bookid, int contentid) {
    return target.getContentDb(bookid, contentid);
  }

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) {
    return target.getIndexsDb(bookid);
  }

  @override
  Future<Set<int>> getAllBookId() => target.getAllBookId();

  @override
  Future<void> saveContent(BookContent bookContent) =>
      target.saveContent(bookContent);

  @override
  Future<List<Map<String, Object?>>> getCacheContentsDb(int bookid) =>
      target.getCacheContentsDb(bookid);

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow) =>
      target.updateBookStatusAndSetTop(id, isTop, isShow);

  @override
  Future<void> updateBookStatusAndSetNew(
          int id, String cname, String updateTime) =>
      target.updateBookStatusAndSetNew(id, cname, updateTime);

  @override
  Future<void> updateBookStatus(int id, int cid, int page) =>
      target.updateBookStatus(id, cid, page);
  @override
  Future<List<String>> textLayout(String text, String cname, int words) =>
      target.textLayout(text, cname, words);

  @override
  Future<BookContent> getContentNet(int bookid, int contentid) =>
      target.getContentNet(bookid, contentid);

  @override
  Future<List<BookList>> getHiveShudanLists(String c) =>
      target.getHiveShudanLists(c);

  @override
  Future<String> getIndexsNet(int id) => target.getIndexsNet(id);

  @override
  Future<List<List>> getIndexsDecodeLists(String str) =>
      target.getIndexsDecodeLists(str);

  @override
  Future<BookInfoRoot> getInfo(int id) => target.getInfo(id);

  @override
  Future<List<BookList>> getShudanLists(String c, int index) =>
      target.getShudanLists(c, index);

  @override
  Future<BookListDetailData> getShudanDetail(int index) =>
      target.getShudanDetail(index);

  @override
  Future<String> getImagePath(String img) => target.getImagePath(img);

  @override
  Future<SearchList> getSearchData(String key) async =>
      target.getSearchData(key);
}
