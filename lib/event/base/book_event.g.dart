// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_event.dart';

// **************************************************************************
// Generator: IsolateEventGeneratorForAnnotation
// **************************************************************************

enum BookEventMessage {
  getSearchData,
  getImagePath,
  getImageBytes,
  getHiveShudanLists,
  getShudanLists,
  getTopLists,
  getCategLists,
  getShudanDetail,
  getCategoryData,
  getCacheItem,
  getCacheItems,
  getContent,
  getIndexs,
  updateBookStatus,
  getInfo
}
enum CustomEventMessage {
  getSearchData,
  getImagePath,
  getImageBytes,
  getHiveShudanLists,
  getShudanLists,
  getTopLists,
  getCategLists,
  getShudanDetail,
  getCategoryData
}
enum BookCacheEventMessage {
  getMainBookListDb,
  getBookCacheDb,
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
  getCacheItems,
  getContent,
  getIndexs,
  updateBookStatus,
  getInfo
}

abstract class BookEventResolveMain extends BookEvent
    with
        Resolve,
        CustomEventResolve,
        DatabaseEventResolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexEventResolve {
  @override
  bool resolve(resolveMessage) {
    if (remove(resolveMessage)) return true;
    if (resolveMessage is! IsolateSendMessage) return false;
    return super.resolve(resolveMessage);
  }
}

abstract class BookEventMessagerMain extends BookEvent
    with
        CustomEventMessager,
        DatabaseEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        ComplexEventMessager {}

/// implements [CustomEvent]
abstract class CustomEventDynamic {
  dynamic getImageBytesDynamic(String img);
}

mixin CustomEventResolve on Resolve, CustomEvent implements CustomEventDynamic {
  late final _customEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getSearchData_0,
    _getImagePath_1,
    _getImageBytes_2,
    _getHiveShudanLists_3,
    _getShudanLists_4,
    _getTopLists_5,
    _getCategLists_6,
    _getShudanDetail_7,
    _getCategoryData_8
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
          receipt(result, resolveMessage);
        } catch (e) {
          receipt(result, resolveMessage, e);
        }
        return true;
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<SearchList?> _getSearchData_0(args) => getSearchData(args);
  FutureOr<String?> _getImagePath_1(args) => getImagePath(args);
  dynamic _getImageBytes_2(args) => getImageBytesDynamic(args);
  FutureOr<List<BookList>?> _getHiveShudanLists_3(args) =>
      getHiveShudanLists(args);
  FutureOr<List<BookList>?> _getShudanLists_4(args) =>
      getShudanLists(args[0], args[1]);
  FutureOr<BookTopData?> _getTopLists_5(args) =>
      getTopLists(args[0], args[1], args[2]);
  FutureOr<BookTopData?> _getCategLists_6(args) =>
      getCategLists(args[0], args[1], args[2]);
  FutureOr<BookListDetailData?> _getShudanDetail_7(args) =>
      getShudanDetail(args);
  FutureOr<List<BookCategoryData>?> _getCategoryData_8(args) =>
      getCategoryData();
}

/// implements [CustomEvent]
mixin CustomEventMessager {
  SendEvent get sendEvent;

  FutureOr<SearchList?> getSearchData(String key) async {
    return sendEvent.sendMessage(CustomEventMessage.getSearchData, key);
  }

  FutureOr<String?> getImagePath(String img) async {
    return sendEvent.sendMessage(CustomEventMessage.getImagePath, img);
  }

  dynamic getImageBytesDynamic(String img) async {
    return sendEvent.sendMessage(CustomEventMessage.getImageBytes, img);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) async {
    return sendEvent.sendMessage(CustomEventMessage.getHiveShudanLists, c);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) async {
    return sendEvent.sendMessage(CustomEventMessage.getShudanLists, [c, index]);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) async {
    return sendEvent
        .sendMessage(CustomEventMessage.getTopLists, [c, date, index]);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) async {
    return sendEvent
        .sendMessage(CustomEventMessage.getCategLists, [c, date, index]);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) async {
    return sendEvent.sendMessage(CustomEventMessage.getShudanDetail, index);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() async {
    return sendEvent.sendMessage(CustomEventMessage.getCategoryData, null);
  }
}

mixin BookCacheEventResolve on Resolve, BookCacheEvent {
  late final _bookCacheEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getMainBookListDb_0,
    _getBookCacheDb_1,
    _updateBook_2,
    _insertBook_3,
    _deleteBook_4,
    _getAllBookId_5,
    _watchBookCacheCid_6,
    _watchMainBookListDb_7
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
          receipt(result, resolveMessage);
        } catch (e) {
          receipt(result, resolveMessage, e);
        }
        return true;
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<List<BookCache>?> _getMainBookListDb_0(args) => getMainBookListDb();
  FutureOr<List<BookCache>?> _getBookCacheDb_1(args) => getBookCacheDb(args);
  FutureOr<int?> _updateBook_2(args) => updateBook(args[0], args[1]);
  FutureOr<int?> _insertBook_3(args) => insertBook(args);
  FutureOr<int?> _deleteBook_4(args) => deleteBook(args);
  FutureOr<Set<int>?> _getAllBookId_5(args) => getAllBookId();
  Stream<List<BookCache>?> _watchBookCacheCid_6(args) =>
      watchBookCacheCid(args);
  Stream<List<BookCache>?> _watchMainBookListDb_7(args) =>
      watchMainBookListDb();
}

/// implements [BookCacheEvent]
mixin BookCacheEventMessager {
  SendEvent get sendEvent;

  FutureOr<List<BookCache>?> getMainBookListDb() async {
    return sendEvent.sendMessage(BookCacheEventMessage.getMainBookListDb, null);
  }

  FutureOr<List<BookCache>?> getBookCacheDb(int bookid) async {
    return sendEvent.sendMessage(BookCacheEventMessage.getBookCacheDb, bookid);
  }

  FutureOr<int?> updateBook(int id, BookCache book) async {
    return sendEvent.sendMessage(BookCacheEventMessage.updateBook, [id, book]);
  }

  FutureOr<int?> insertBook(BookCache bookCache) async {
    return sendEvent.sendMessage(BookCacheEventMessage.insertBook, bookCache);
  }

  FutureOr<int?> deleteBook(int id) async {
    return sendEvent.sendMessage(BookCacheEventMessage.deleteBook, id);
  }

  FutureOr<Set<int>?> getAllBookId() async {
    return sendEvent.sendMessage(BookCacheEventMessage.getAllBookId, null);
  }

  Stream<List<BookCache>?> watchBookCacheCid(int id) {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchBookCacheCid, id);
  }

  Stream<List<BookCache>?> watchMainBookListDb() {
    return sendEvent.sendMessageStream(
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
          receipt(result, resolveMessage);
        } catch (e) {
          receipt(result, resolveMessage, e);
        }
        return true;
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<int?> _getCacheContentsCidDb_0(args) => getCacheContentsCidDb(args);
  Stream<List<BookContentDb>?> _watchCacheContentsCidDb_1(args) =>
      watchCacheContentsCidDb(args);
  FutureOr<int?> _deleteCache_2(args) => deleteCache(args);
}

/// implements [BookContentEvent]
mixin BookContentEventMessager {
  SendEvent get sendEvent;

  FutureOr<int?> getCacheContentsCidDb(int bookid) async {
    return sendEvent.sendMessage(
        BookContentEventMessage.getCacheContentsCidDb, bookid);
  }

  Stream<List<BookContentDb>?> watchCacheContentsCidDb(int bookid) {
    return sendEvent.sendMessageStream(
        BookContentEventMessage.watchCacheContentsCidDb, bookid);
  }

  FutureOr<int?> deleteCache(int bookId) async {
    return sendEvent.sendMessage(BookContentEventMessage.deleteCache, bookId);
  }
}

mixin DatabaseEventResolve on Resolve, DatabaseEvent {}

/// implements [DatabaseEvent]
mixin DatabaseEventMessager {}

/// implements [ComplexEvent]
abstract class ComplexEventDynamic {
  dynamic getContentDynamic(int bookid, int contentid, bool update);
}

mixin ComplexEventResolve
    on Resolve, ComplexEvent
    implements ComplexEventDynamic {
  late final _complexEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getCacheItem_0,
    _getCacheItems_1,
    _getContent_2,
    _getIndexs_3,
    _updateBookStatus_4,
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
          receipt(result, resolveMessage);
        } catch (e) {
          receipt(result, resolveMessage, e);
        }
        return true;
      }
    }
    return super.resolve(resolveMessage);
  }

  FutureOr<CacheItem?> _getCacheItem_0(args) => getCacheItem(args);
  FutureOr<List<CacheItem>?> _getCacheItems_1(args) => getCacheItems();
  dynamic _getContent_2(args) => getContentDynamic(args[0], args[1], args[2]);
  FutureOr<NetBookIndex?> _getIndexs_3(args) => getIndexs(args[0], args[1]);
  FutureOr<int?> _updateBookStatus_4(args) => updateBookStatus(args);
  FutureOr<BookInfoRoot?> _getInfo_5(args) => getInfo(args);
}

/// implements [ComplexEvent]
mixin ComplexEventMessager {
  SendEvent get sendEvent;

  FutureOr<CacheItem?> getCacheItem(int id) async {
    return sendEvent.sendMessage(ComplexEventMessage.getCacheItem, id);
  }

  FutureOr<List<CacheItem>?> getCacheItems() async {
    return sendEvent.sendMessage(ComplexEventMessage.getCacheItems, null);
  }

  dynamic getContentDynamic(int bookid, int contentid, bool update) async {
    return sendEvent.sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update]);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) async {
    return sendEvent
        .sendMessage(ComplexEventMessage.getIndexs, [bookid, update]);
  }

  FutureOr<int?> updateBookStatus(int id) async {
    return sendEvent.sendMessage(ComplexEventMessage.updateBookStatus, id);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) async {
    return sendEvent.sendMessage(ComplexEventMessage.getInfo, id);
  }
}
