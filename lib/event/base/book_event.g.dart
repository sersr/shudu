// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_event.dart';

// **************************************************************************
// Generator: IsolateEventGeneratorForAnnotation
// **************************************************************************

enum CustomEventMessage {
  getSearchData,
  getImagePath,
  getHiveShudanLists,
  getShudanLists,
  getTopLists,
  getCategLists,
  getShudanDetail,
  getCategoryData
}
enum BookCacheEventMessage {
  getMainBookListDb,
  updateBook,
  insertBook,
  deleteBook,
  getAllBookId,
  watchBookCacheCid,
  watchMainBookListDb
}
enum BookContentEventMessage {
  getCacheContentsCidDb,
  watchCacheContentsCidDb,
  deleteCache
}
enum ComplexEventMessage {
  getCacheItem,
  getContent,
  getIndexs,
  updateBookStatus,
  getCacheItemAll,
  getInfo
}

abstract class BookEventResolve extends BookEvent
    with
        Resolve,
        CustomEventResolve,
        DatabaseEventResolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        BookIndexEventResolve,
        ComplexEventResolve {
  @override
  bool resolve(m) {
    if (remove(m)) return true;
    if (m is! IsolateSendMessage) return false;
    return super.resolve(m);
  }
}

abstract class BookEventMessager extends BookEvent
    with
        CustomEventMessager,
        DatabaseEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        BookIndexEventMessager,
        ComplexEventMessager {}

mixin CustomEventResolve on Resolve, CustomEvent {
  late final _customEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getSearchData_0,
    _getImagePath_1,
    _getHiveShudanLists_2,
    _getShudanLists_3,
    _getTopLists_4,
    _getCategLists_5,
    _getShudanDetail_6,
    _getCategoryData_7
  ]);

  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is CustomEventMessage) {
        dynamic result;
        try {
          result = _customEventResolveFuncList
              .elementAt(type.index)(resolveMessage.args);
          send(result, resolveMessage);
        } catch (e) {
          send(result, resolveMessage, e);
        } finally {
          return true;
        }
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<SearchList?> _getSearchData_0(args) => getSearchData(args);
  FutureOr<String?> _getImagePath_1(args) => getImagePath(args);
  FutureOr<List<BookList>?> _getHiveShudanLists_2(args) =>
      getHiveShudanLists(args);
  FutureOr<List<BookList>?> _getShudanLists_3(args) =>
      getShudanLists(args[0], args[1]);
  FutureOr<BookTopData?> _getTopLists_4(args) =>
      getTopLists(args[0], args[1], args[2]);
  FutureOr<BookTopData?> _getCategLists_5(args) =>
      getCategLists(args[0], args[1], args[2]);
  FutureOr<BookListDetailData?> _getShudanDetail_6(args) =>
      getShudanDetail(args);
  FutureOr<List<BookCategoryData>?> _getCategoryData_7(args) =>
      getCategoryData();
}

mixin CustomEventMessager implements CustomEvent {
  SendEvent get send;

  @override
  FutureOr<SearchList?> getSearchData(String key) async {
    return send.sendMessage(CustomEventMessage.getSearchData, key);
  }

  @override
  FutureOr<String?> getImagePath(String img) async {
    return send.sendMessage(CustomEventMessage.getImagePath, img);
  }

  @override
  FutureOr<List<BookList>?> getHiveShudanLists(String c) async {
    return send.sendMessage(CustomEventMessage.getHiveShudanLists, c);
  }

  @override
  FutureOr<List<BookList>?> getShudanLists(String c, int index) async {
    return send.sendMessage(CustomEventMessage.getShudanLists, [c, index]);
  }

  @override
  FutureOr<BookTopData?> getTopLists(String c, String date, int index) async {
    return send.sendMessage(CustomEventMessage.getTopLists, [c, date, index]);
  }

  @override
  FutureOr<BookTopData?> getCategLists(int c, String date, int index) async {
    return send.sendMessage(CustomEventMessage.getCategLists, [c, date, index]);
  }

  @override
  FutureOr<BookListDetailData?> getShudanDetail(int index) async {
    return send.sendMessage(CustomEventMessage.getShudanDetail, index);
  }

  @override
  FutureOr<List<BookCategoryData>?> getCategoryData() async {
    return send.sendMessage(CustomEventMessage.getCategoryData, null);
  }
}

mixin BookCacheEventResolve on Resolve, BookCacheEvent {
  late final _bookCacheEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getMainBookListDb_0,
    _updateBook_1,
    _insertBook_2,
    _deleteBook_3,
    _getAllBookId_4,
    _watchBookCacheCid_5,
    _watchMainBookListDb_6
  ]);

  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is BookCacheEventMessage) {
        dynamic result;
        try {
          result = _bookCacheEventResolveFuncList
              .elementAt(type.index)(resolveMessage.args);
          send(result, resolveMessage);
        } catch (e) {
          send(result, resolveMessage, e);
        } finally {
          return true;
        }
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<List<BookCache>?> _getMainBookListDb_0(args) => getMainBookListDb();
  FutureOr<int?> _updateBook_1(args) => updateBook(args[0], args[1]);
  FutureOr<int?> _insertBook_2(args) => insertBook(args);
  FutureOr<int?> _deleteBook_3(args) => deleteBook(args);
  FutureOr<Set<int>?> _getAllBookId_4(args) => getAllBookId();
  Stream<List<BookCache>?> _watchBookCacheCid_5(args) =>
      watchBookCacheCid(args);
  Stream<List<BookCache>?> _watchMainBookListDb_6(args) =>
      watchMainBookListDb();
}

mixin BookCacheEventMessager implements BookCacheEvent {
  SendEvent get send;

  @override
  FutureOr<List<BookCache>?> getMainBookListDb() async {
    return send.sendMessage(BookCacheEventMessage.getMainBookListDb, null);
  }

  @override
  FutureOr<int?> updateBook(int id, BookCache book) async {
    return send.sendMessage(BookCacheEventMessage.updateBook, [id, book]);
  }

  @override
  FutureOr<int?> insertBook(BookCache bookCache) async {
    return send.sendMessage(BookCacheEventMessage.insertBook, bookCache);
  }

  @override
  FutureOr<int?> deleteBook(int id) async {
    return send.sendMessage(BookCacheEventMessage.deleteBook, id);
  }

  @override
  FutureOr<Set<int>?> getAllBookId() async {
    return send.sendMessage(BookCacheEventMessage.getAllBookId, null);
  }

  @override
  Stream<List<BookCache>?> watchBookCacheCid(int id) {
    return send.sendMessageStream(BookCacheEventMessage.watchBookCacheCid, id);
  }

  @override
  Stream<List<BookCache>?> watchMainBookListDb() {
    return send.sendMessageStream(
        BookCacheEventMessage.watchMainBookListDb, null);
  }
}

mixin BookContentEventResolve on Resolve, BookContentEvent {
  late final _bookContentEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getCacheContentsCidDb_0,
    _watchCacheContentsCidDb_1,
    _deleteCache_2
  ]);

  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is BookContentEventMessage) {
        dynamic result;
        try {
          result = _bookContentEventResolveFuncList
              .elementAt(type.index)(resolveMessage.args);
          send(result, resolveMessage);
        } catch (e) {
          send(result, resolveMessage, e);
        } finally {
          return true;
        }
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<List<BookContentDb>?> _getCacheContentsCidDb_0(args) =>
      getCacheContentsCidDb(args);
  Stream<List<BookContentDb>?> _watchCacheContentsCidDb_1(args) =>
      watchCacheContentsCidDb(args);
  FutureOr<int?> _deleteCache_2(args) => deleteCache(args);
}

mixin BookContentEventMessager implements BookContentEvent {
  SendEvent get send;

  @override
  FutureOr<List<BookContentDb>?> getCacheContentsCidDb(int bookid) async {
    return send.sendMessage(
        BookContentEventMessage.getCacheContentsCidDb, bookid);
  }

  @override
  Stream<List<BookContentDb>?> watchCacheContentsCidDb(int bookid) {
    return send.sendMessageStream(
        BookContentEventMessage.watchCacheContentsCidDb, bookid);
  }

  @override
  FutureOr<int?> deleteCache(int bookId) async {
    return send.sendMessage(BookContentEventMessage.deleteCache, bookId);
  }
}

mixin BookIndexEventResolve on Resolve, BookIndexEvent {}

mixin BookIndexEventMessager implements BookIndexEvent {}

mixin DatabaseEventResolve on Resolve, DatabaseEvent {}

mixin DatabaseEventMessager implements DatabaseEvent {}

abstract class ComplexEventDynamic implements ComplexEvent {
  dynamic getContentDynamic(int bookid, int contentid, bool update);
}

mixin ComplexEventResolve
    on Resolve, ComplexEvent
    implements ComplexEventDynamic {
  late final _complexEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getCacheItem_0,
    _getContent_1,
    _getIndexs_2,
    _updateBookStatus_3,
    _getCacheItemAll_4,
    _getInfo_5
  ]);

  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ComplexEventMessage) {
        dynamic result;
        try {
          result = _complexEventResolveFuncList
              .elementAt(type.index)(resolveMessage.args);
          send(result, resolveMessage);
        } catch (e) {
          send(result, resolveMessage, e);
        } finally {
          return true;
        }
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<CacheItem?> _getCacheItem_0(args) => getCacheItem(args);
  dynamic _getContent_1(args) => getContentDynamic(args[0], args[1], args[2]);
  FutureOr<NetBookIndex?> _getIndexs_2(args) => getIndexs(args[0], args[1]);
  FutureOr<int?> _updateBookStatus_3(args) => updateBookStatus(args);
  FutureOr<Map<int, CacheItem>?> _getCacheItemAll_4(args) => getCacheItemAll();
  FutureOr<BookInfoRoot?> _getInfo_5(args) => getInfo(args);
}

mixin ComplexEventMessager implements ComplexEvent {
  SendEvent get send;

  @override
  FutureOr<CacheItem?> getCacheItem(int id) async {
    return send.sendMessage(ComplexEventMessage.getCacheItem, id);
  }

  dynamic getContentDynamic(int bookid, int contentid, bool update) async {
    return send.sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update]);
  }

  @override
  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) async {
    return send.sendMessage(ComplexEventMessage.getIndexs, [bookid, update]);
  }

  @override
  FutureOr<int?> updateBookStatus(int id) async {
    return send.sendMessage(ComplexEventMessage.updateBookStatus, id);
  }

  @override
  FutureOr<Map<int, CacheItem>?> getCacheItemAll() async {
    return send.sendMessage(ComplexEventMessage.getCacheItemAll, null);
  }

  @override
  FutureOr<BookInfoRoot?> getInfo(int id) async {
    return send.sendMessage(ComplexEventMessage.getInfo, id);
  }
}
