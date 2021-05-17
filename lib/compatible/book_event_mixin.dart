import '../utils/utils.dart';

import '../data/data.dart';

import '../api/api.dart';
import '../bloc/bloc.dart';

import '../data/book_content.dart';

import 'book_event.dart';
import 'book_event_impl.dart';

// 网络任务

mixin BookIsolateNet on BookEvent {
  late MessageFunc msg;
  // 网络实现

  @override
  Future<String> getIndexsFromNet(int id) async {
    final url = Api.indexUrl(id);
    late String indexs;
    await msg.indexs(url).then((value) => indexs = value, onError: (_) => indexs = '');
    return indexs;
  }

  /// 章节内容
  @override
  Future<BookContent> getContentFromNet(int bookid, int contentid) async {
    final url = Api.contentUrl(bookid, contentid);
    Api.moveNext();
    late BookContent content;
    await msg.content(url).then((value) => content = value, onError: (_) => content = const BookContent());
    return content;
  }

  @override
  Future<List<List>> loadIndexsList(String str) async {
    late List<List> indexs;
    await msg.mainList(str).then((value) => indexs = value, onError: (_) => indexs = const <List>[]);
    return indexs;
  }

  @override
  Future<BookInfoRoot> loadInfo(int id) async {
    final url = Api.infoUrl(id);
    late BookInfoRoot info;
    await msg.info(url).then((value) => info = value, onError: (_) => info = const BookInfoRoot());
    return info;
  }

  @override
  Future<List<BookList>> getBookList(String c) async {
    late List<BookList> list;
    await msg.bookList(c).then((value) => list = value, onError: (_) => list = const <BookList>[]);
    return list;
  }

  @override
  Future<List<BookList>> loadShudan(String c, int index) async {
    late List<BookList> list;
    await msg.shudan([Api.shudanUrl(c, index), index]).then(
      (value) => list = value,
      onError: (_) => list = const <BookList>[],
    );
    return list;
  }

  @override
  Future<BookListDetailData> loadShudanDetail(int index) async {
    final url = Api.shudanDetailUrl(index);
    late BookListDetailData data;
    await msg.shudanDetail(url).then((value) => data = value, onError: (_) => data = const BookListDetailData());
    return data;
  }
}

/// 转发到 Isolate
@mainIsolate
mixin BookTransformerEvent on BookEvent {
  late Repository repository;

  /// 目录
  @override
  Future<String> getIndexsFromNet(int id) async {
    final url = Api.indexUrl(id);
    return repository.sendMessage<String>(MessageType.indexs, url);
  }

  /// 章节内容
  @override
  Future<BookContent> getContentFromNet(int id, int cid) async {
    final url = Api.contentUrl(id, cid);
    Log.i(url);
    // 切换源
    Api.moveNext();
    return repository.sendMessage<BookContent>(MessageType.content, url);
  }

  @override
  Future<List<List>> loadIndexsList(String str) async {
    return repository.sendMessage<List<List>>(MessageType.mainList, str);
  }

  @override
  Future<BookInfoRoot> loadInfo(int id) async {
    final url = Api.infoUrl(id);
    return repository.sendMessage<BookInfoRoot>(MessageType.info, url);
  }

  @override
  Future<List<BookList>> getBookList(String c) async {
    return repository.sendMessage<List<BookList>>(MessageType.bookList, c);
  }

  @override
  Future<List<BookList>> loadShudan(String c, int index) async {
    return repository.sendMessage<List<BookList>>(MessageType.shudan, [Api.shudanUrl(c, index), index]);
  }

  @override
  Future<BookListDetailData> loadShudanDetail(int index) async {
    final url = Api.shudanDetailUrl(index);
    return repository.sendMessage(MessageType.shudanDetail, url);
  }

  @override
  Future<List<String>> textLayout(String text, String cname, int words) async {
    var list = const <String>[];
    await EventLooper.instance.scheduleEventTask((wait, task) async {
      await wait();
      list = await super.textLayout(text, cname, words);
    });
    return list;
  }
}

// 代理
mixin BookEventDelegateMixin on BookEvent {
  covariant late BookEvent? target;

  @override
  Future<void> initState() async {
    if (target == null) return;
    return target!.initState();
  }

  @override
  Future<RawContentLines> load(int bookid, int contentid, int words, {bool update = false}) async {
    if (update) {
      var _raw =
          await download(bookid, contentid, words) ?? await target!.load(bookid, contentid, words, update: update);
      return _raw;
    }
    final lines = await target!.load(bookid, contentid, words, update: update);
    if (lines.contentIsEmpty) {
      var _raw = await download(bookid, contentid, words) ?? lines;
      return _raw;
    }
    return lines;
  }

  @override
  Future<void> addBook(BookCache bookCache) => target!.addBook(bookCache);

  @override
  Future<void> cacheinnerdb(int? id, String indexs) => target!.cacheinnerdb(id, indexs);

  @override
  Future<int> deleteBook(int id) => target!.deleteBook(id);

  @override
  Future<void> deleteCache(int bookId) => target!.deleteCache(bookId);

  @override
  Future<List<Map<String, Object?>>> loadBookInfo() => target!.loadBookInfo();

  @override
  Future<List<Map<String, Object?>>> loadFromDb(int bookid, int contentid) => target!.loadFromDb(bookid, contentid);

  @override
  Future<void> saveToDatabase(BookContent bookContent) => target!.saveToDatabase(bookContent);

  @override
  Future<List<Map<String, Object?>>> sendIndexs(int bookid) => target!.sendIndexs(bookid);

  @override
  Future<void> updateBookIsTop(int id, int isTop) => target!.updateBookIsTop(id, isTop);

  @override
  Future<void> updateCname(int id, String cname, String updateTime) => target!.updateCname(id, cname, updateTime);

  @override
  Future<void> updateMainInfo(int id, int cid, int page) => target!.updateMainInfo(id, cid, page);
  @override
  Future<List<String>> textLayout(String text, String cname, int words) => target!.textLayout(text, cname, words);

  @override
  Future<BookContent> getContentFromNet(int bookid, int contentid) => target!.getContentFromNet(bookid, contentid);

  @override
  Future<List<BookList>> getBookList(String c) => target!.getBookList(c);

  @override
  Future<String> getIndexsFromNet(int id) => target!.getIndexsFromNet(id);

  @override
  Future<List<List>> loadIndexsList(String str) => target!.loadIndexsList(str);

  @override
  Future<BookInfoRoot> loadInfo(int id) => target!.loadInfo(id);

  @override
  Future<List<BookList>> loadShudan(String c, int index) => target!.loadShudan(c, index);

  @override
  Future<BookListDetailData> loadShudanDetail(int index) => target!.loadShudanDetail(index);
}

mixin BookDatabaseTransformerEvent on BookEvent {
  late Repository repository;
  @override
  Future<void> addBook(BookCache bookCache) {
    return repository.sendMessage(MessageDatabase.addBook, bookCache);
  }

  @override
  Future<void> cacheinnerdb(int? id, String indexs) {
    return repository.sendMessage(MessageDatabase.cacheinnerdb, [id, indexs]);
  }

  @override
  Future<int> deleteBook(int id) {
    return repository.sendMessage(MessageDatabase.deleteBook, id);
  }

  @override
  Future<void> deleteCache(int bookId) {
    return repository.sendMessage(MessageDatabase.deleteCache, bookId);
  }

  @override
  Future<List<Map<String, Object?>>> loadBookInfo() {
    return repository.sendMessage(MessageDatabase.loadBookInfo, null);
  }

  @override
  Future<List<Map<String, Object?>>> loadFromDb(int bookid, int contentid) {
    return repository.sendMessage(MessageDatabase.loadFromDb, [bookid, contentid]);
  }

  @override
  Future<List<Map<String, Object?>>> sendIndexs(int bookid) {
    return repository.sendMessage(MessageDatabase.sendIndexs, bookid);
  }

  @override
  Future<void> updateBookIsTop(int id, int isTop) {
    return repository.sendMessage(MessageDatabase.updateBookIsTop, [id, isTop]);
  }

  @override
  Future<void> updateCname(int id, String cname, String updateTime) {
    return repository.sendMessage(MessageDatabase.updateCname, [id, cname, updateTime]);
  }

  @override
  Future<void> updateMainInfo(int id, int cid, int page) {
    return repository.sendMessage(MessageDatabase.updateMainInfo, [id, cid, page]);
  }

  @override
  Future<RawContentLines> load(int bookid, int contentid, int words, {bool update = false}) async {
    return repository.sendMessage(MessageDatabase.load, [bookid, contentid, words, update]);
  }
}
