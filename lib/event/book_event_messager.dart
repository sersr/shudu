import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../data/data.dart';
import '../database/table.dart';
import '../pages/book_list_view/cacheManager.dart';
import '../utils/utils.dart';
import 'book_event.dart';
import 'messages.dart';
import 'repository.dart';

/// 转发到 Isolate
@mainIsolate
mixin BookEventMessager on CustomEvent {
  late Repository repository;

  @override
  Future<String> getIndexsNet(int id) => repository
      .sendMessage<String>(CustomMessage.indexs, id)
      ._resultResolve('');

  @override
  Future<List<List>> getIndexsDecodeLists(String str) => repository
      .sendMessage<List<List>>(CustomMessage.mainList, str)
      ._resultResolve(const []);

  @override
  Future<BookInfoRoot> getInfo(int id) => repository
      .sendMessage<BookInfoRoot>(CustomMessage.info, id)
      ._resultResolve(const BookInfoRoot());

  @override
  Future<List<BookList>> getHiveShudanLists(String c) => repository
      .sendMessage<List<BookList>>(CustomMessage.bookList, c)
      ._resultResolve(const []);

  @override
  Future<List<BookList>> getShudanLists(String c, int index) =>
      repository.sendMessage<List<BookList>>(
          CustomMessage.shudan, [c, index])._resultResolve(const []);

  @override
  Future<BookListDetailData> getShudanDetail(int index) => repository
      .sendMessage<BookListDetailData>(CustomMessage.shudanDetail, index)
      ._resultResolve(const BookListDetailData());

  @override
  Future<SearchList> getSearchData(String key) => repository
      .sendMessage<SearchList>(CustomMessage.searchWithKey, key)
      ._resultResolve(const SearchList());
}

mixin SaveImageMessager {
  Repository get repository;
  final _list = <String, String>{};

  Timer? timer;

  Future<String> getImagePath(String img) async {
    if (_list.containsKey(img)) {
      final _l = _list[img]!;

      if (await File(_l).exists()) {
        return _l;
      } else {
        _list.remove(img);
      }
    }
    final _img = await repository
        .sendMessage<String>(CustomMessage.saveImage, img)
        ._resultResolve('');

    if (_img.isNotEmpty && !_list.containsKey(_img)) _list[img] = _img;

    timer?.cancel();
    timer = Timer(const Duration(minutes: 3), _list.clear);

    return _img;
  }
}

// 数据库在Isolate中运行
// 以消息传递
mixin BookEventDatabaseMessager on DatabaseEvent {
  late Repository repository;

  // 在 Isolate 初始化

  @override
  Future<void> insertBook(BookCache bookCache) =>
      repository.sendMessage(DatabaseMessage.addBook, bookCache);

  @override
  Future<void> insertOrUpdateIndexs(int? id, String indexs) =>
      repository.sendMessage(DatabaseMessage.insertBookInfo, [id, indexs]);

  @override
  Future<int> deleteBook(int id) => repository
      .sendMessage<int>(DatabaseMessage.deleteBook, id)
      ._resultResolve(0);

  @override
  Future<void> deleteCache(int bookId) =>
      repository.sendMessage(DatabaseMessage.deleteCache, bookId);

  @override
  Future<List<Map<String, Object?>>> getMainBookListDb() => repository
      .sendMessage<List<Map<String, Object?>>>(
          DatabaseMessage.loadBookInfo, null)
      ._resultResolve(const []);

  @override
  Future<List<Map<String, Object?>>> getCacheContentsCidDb(
          int bookid) =>
      repository
          .sendMessage<List<Map<String, Object?>>>(
              DatabaseMessage.getCacheContentsDb, bookid)
          ._resultResolve(const []);

  @override
  Future<void> updateBookStatusAndSetTop(int id, int isTop, int isShow) {
    return repository
        .sendMessage(DatabaseMessage.updateBookIsTop, [id, isTop, isShow]);
  }

  @override
  Future<void> updateBookStatusAndSetNew(int id,
          [String? cname, String? updateTime]) =>
      repository
          .sendMessage(DatabaseMessage.updateCname, [id, cname, updateTime]);

  @override
  Future<void> updateBookStatusCustom(int id, int cid, int page) =>
      repository.sendMessage(DatabaseMessage.updateMainInfo, [id, cid, page]);

  @override
  Future<Set<int>> getAllBookId() {
    return repository
        .sendMessage<Set<int>>(DatabaseMessage.getAllBookId, '')
        ._resultResolve(const {});
  }

  @override
  Future<List<Map<String, Object?>>> getIndexsDb(int bookid) {
    return repository
        .sendMessage<List<Map<String, Object?>>>(
            DatabaseMessage.getIndexDb, bookid)
        ._resultResolve(const []);
  }
}

/// 数据库 和 网络任务 不在同一个 Isolate
/// 需要以消息传递
mixin ComplexMessager {
  Repository get repository;

  Future<RawContentLines> getContent(
      int bookid, int contentid, bool update) async {
    final result = await repository.sendMessage<TransferableTypedData>(
        CustomMessage.getContent, [bookid, contentid, update]);

    if (result is TransferableTypedData)
      return RawContentLines.decode(result.materialize());

    return const RawContentLines();
  }

  Future<CacheItem> getCacheItem(int id) => repository
      .sendMessage<CacheItem>(DatabaseMessage.getCacheItem, id)
      ._resultResolve(CacheItem.e);
}

extension _ResultResolve<T> on Future<T?> {
  Future<T> _resultResolve(T error) async {
    return then((value) {
      if (value == null) return error;
      return value;
    }, onError: (_) => error);
  }
}
