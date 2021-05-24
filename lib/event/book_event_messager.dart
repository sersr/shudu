import '../bloc/bloc.dart';
import '../data/book_content.dart';
import '../data/data.dart';
import '../utils/utils.dart';
import 'book_event.dart';
import 'messages.dart';
import 'repository.dart';

/// 转发到 Isolate
@mainIsolate
mixin BookEventMessager on CustomEvent {
  late Repository repository;

  @override
  Future<String> getIndexsNet(int id) =>
      repository.sendMessage<String>(CustomMessage.indexs, id);

  @override
  Future<BookContent> getContentNet(int id, int cid) =>
      repository.sendMessage<BookContent>(CustomMessage.content, [id, cid]);

  @override
  Future<List<List>> getIndexsDecodeLists(String str) =>
      repository.sendMessage<List<List>>(CustomMessage.mainList, str);

  @override
  Future<BookInfoRoot> getInfo(int id) =>
      repository.sendMessage<BookInfoRoot>(CustomMessage.info, id);

  @override
  Future<List<BookList>> getHiveShudanLists(String c) =>
      repository.sendMessage<List<BookList>>(CustomMessage.bookList, c);

  @override
  Future<List<BookList>> getShudanLists(String c, int index) =>
      repository.sendMessage<List<BookList>>(CustomMessage.shudan, [c, index]);

  @override
  Future<BookListDetailData> getShudanDetail(int index) =>
      repository.sendMessage(CustomMessage.shudanDetail, index);

  @override
  Future<List<String>> textLayout(String text, String cname, int words) =>
      repository.sendMessage(CustomMessage.divText, [text, cname, words]);

  @override
  Future<String> getImagePath(String img) =>
      repository.sendMessage<String>(CustomMessage.saveImage, img);

  @override
  Future<SearchList> getSearchData(String key) =>
      repository.sendMessage(CustomMessage.searchWithKey, key);
}

// 数据库在Isolate中运行
// 以消息传递
mixin BookEventDatabaseMessager on DatabaseEvent {
  late Repository repository;

  // 在 Isolate 初始化
  @override
  Future<void> initState() async {}

  @override
  Future<void> insertBook(BookCache bookCache) =>
      repository.sendMessage(DatabaseMessage.addBook, bookCache);

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) =>
      repository.sendMessage(DatabaseMessage.cacheinnerdb, [id, indexs]);

  @override
  Future<int> deleteBook(int id) =>
      repository.sendMessage(DatabaseMessage.deleteBook, id);

  @override
  Future<void> deleteCache(int bookId) =>
      repository.sendMessage(DatabaseMessage.deleteCache, bookId);

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() =>
      repository.sendMessage(DatabaseMessage.loadBookInfo, null);

  @override
  Future<List<Map<String, Object?>>> getCacheContentsDb(int bookid) =>
      repository.sendMessage(DatabaseMessage.getCacheContentsDb, bookid);

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow) =>
      repository
          .sendMessage(DatabaseMessage.updateBookIsTop, [id, isTop, isShow]);

  @override
  Future<void> updateBookStatusAndSetNew(
          int id, String cname, String updateTime) =>
      repository
          .sendMessage(DatabaseMessage.updateCname, [id, cname, updateTime]);

  @override
  Future<void> updateBookStatus(int id, int cid, int page) =>
      repository.sendMessage(DatabaseMessage.updateMainInfo, [id, cid, page]);

  /// 数据库所有操作都在 Isolate 中完成
  @override
  Future<List<Map<String, Object?>>> getContentDb(int bookid, int contentid) =>
      throw 'getContentDb is protected';

  @override
  Future<Set<int>> getAllBookId() {
    return repository.sendMessage(DatabaseMessage.getAllBookId, '');
  }

  @override
  Future<void> saveContent(BookContent bookContent) =>
      throw Exception('messager no impletation');

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) {
    return repository.sendMessage(DatabaseMessage.getIndexDb, bookid);
  }
}

/// 数据库 和 网络任务 不在同一个 Isolate
/// 需要以消息传递
mixin ContentMessager on BookEvent {
  Repository get repository;
  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, int words, bool update) async {
    return repository.sendMessage(
        CustomMessage.getContent, [bookid, contentid, words, update]);
  }
}

/// 本地数据库实现
/// 本地是相对而言
/// 同一个 Isolate
mixin ContentDatabaseImpl on BookEvent {
  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, int words, bool update) async {
    if (update) {
      return await _getContentNet(bookid, contentid, words) ??
          await _getContentDb(bookid, contentid, words) ??
          const RawContentLines();
    } else {
      return await _getContentDb(bookid, contentid, words) ??
          await _getContentNet(bookid, contentid, words) ??
          const RawContentLines();
    }
  }

  Future<RawContentLines?> _getContentNet(
      int bookid, int contentid, int words) async {
    assert(Log.i('loading Id: $contentid', stage: this, name: 'download'));

    final bookContent = await getContentNet(bookid, contentid);

    if (bookContent.content != null) {
      saveContent(bookContent);
      final lines =
          await textLayout(bookContent.content!, bookContent.cname!, words);

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
    return null;
  }

  Future<RawContentLines?> _getContentDb(
      int bookid, int contentid, int words) async {
    final queryList = await getContentDb(bookid, contentid);
    if (queryList.isNotEmpty) {
      final map = queryList.first;
      final bookContent = BookContent.fromJson(map);
      if (bookContent.content != null) {
        final lines =
            await textLayout(bookContent.content!, bookContent.cname!, words);
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
}
