// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_event.dart';

// **************************************************************************
// Generator: IsolateEventGeneratorForAnnotation
// **************************************************************************

// ignore_for_file: annotate_overrides

enum CustomEventMessage {
  getSearchData,
  getImageBytes,
  getHiveShudanLists,
  getShudanLists,
  getTopLists,
  getCategLists,
  getShudanDetail,
  getCategoryData
}
enum BookCacheEventMessage {
  getMainList,
  watchMainList,
  updateBook,
  insertBook,
  deleteBook,
  watchCurrentCid
}
enum BookContentEventMessage { watchBookContentCid, deleteCache }
enum ComplexOnDatabaseEventMessage {
  getIndexsDbCacheItem,
  getAllBookId,
  insertOrUpdateIndexs,
  getContentDb,
  getIndexsDb,
  getBookCacheDb,
  insertOrUpdateContent,
  insertOrUpdateBook,
  insertOrUpdateZhangduIndex,
  getZhangduContentDb,
  getZhangduContentCid,
  insertOrUpdateZhangduContent,
  getZhangduIndexDb,
  insertOrUpdateZhangduBook
}
enum ComplexEventMessage {
  getCacheItems,
  getContent,
  getIndexs,
  updateBookStatus,
  getInfo
}
enum ZhangduDatabaseEventMessage {
  deleteZhangduContentCache,
  watchZhangduContentCid,
  getZhangduMainList,
  watchZhangduMainList,
  updateZhangduBook,
  insertZhangduBook,
  deleteZhangduBook,
  watchZhangduCurrentCid,
  getZhangduCacheItems
}
enum ZhangduComplexEventMessage {
  getZhangduIndex,
  getZhangduContent,
  updateZhangduMainStatus,
  getZhangduDetail
}
enum ZhangduNetEventMessage { getZhangduSameUsersBooks, getZhangduSearchData }

abstract class BookEventResolveMain extends BookEvent
    with
        ListenMixin,
        Resolve,
        CustomEventResolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexEventResolve,
        ZhangduDatabaseEventResolve,
        ZhangduComplexEventResolve,
        ZhangduNetEventResolve {}

abstract class BookEventMessagerMain extends BookEvent
    with
        SendEvent,
        CustomEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        ComplexEventMessager,
        ZhangduDatabaseEventMessager,
        ZhangduComplexEventMessager,
        ZhangduNetEventMessager {}

/// implements [CustomEvent]
mixin CustomEventDynamic {
  FutureOr<TransferType<Uint8List?>> getImageBytesDynamic(String img);
}
mixin CustomEventResolve on Resolve implements CustomEvent, CustomEventDynamic {
  late final _customEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getSearchData_0,
    _getImageBytes_1,
    _getHiveShudanLists_2,
    _getShudanLists_3,
    _getTopLists_4,
    _getCategLists_5,
    _getShudanDetail_6,
    _getCategoryData_7
  ]);
  bool onCustomEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is CustomEventMessage) {
        dynamic result;
        try {
          if (onCustomEventResolve(resolveMessage)) return true;
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
  FutureOr<Uint8List?> getImageBytes(String img) =>
      throw NopUseDynamicVersionExection("不要手动调用");
  FutureOr<TransferType<Uint8List?>> _getImageBytes_1(args) =>
      getImageBytesDynamic(args);
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

/// implements [CustomEvent]
mixin CustomEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'bookEventDefault') yield CustomEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<SearchList?> getSearchData(String key) {
    return sendEvent.sendMessage(CustomEventMessage.getSearchData, key);
  }

  FutureOr<Uint8List?> getImageBytes(String img) {
    return sendEvent.sendMessage(CustomEventMessage.getImageBytes, img);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) {
    return sendEvent.sendMessage(CustomEventMessage.getHiveShudanLists, c);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) {
    return sendEvent.sendMessage(CustomEventMessage.getShudanLists, [c, index]);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) {
    return sendEvent
        .sendMessage(CustomEventMessage.getTopLists, [c, date, index]);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) {
    return sendEvent
        .sendMessage(CustomEventMessage.getCategLists, [c, date, index]);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) {
    return sendEvent.sendMessage(CustomEventMessage.getShudanDetail, index);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() {
    return sendEvent.sendMessage(CustomEventMessage.getCategoryData, null);
  }
}
mixin BookCacheEventResolve on Resolve implements BookCacheEvent {
  late final _bookCacheEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getMainList_0,
    _watchMainList_1,
    _updateBook_2,
    _insertBook_3,
    _deleteBook_4,
    _watchCurrentCid_5
  ]);
  bool onBookCacheEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is BookCacheEventMessage) {
        dynamic result;
        try {
          if (onBookCacheEventResolve(resolveMessage)) return true;
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

  FutureOr<List<BookCache>?> _getMainList_0(args) => getMainList();
  Stream<List<BookCache>?> _watchMainList_1(args) => watchMainList();
  FutureOr<int?> _updateBook_2(args) => updateBook(args[0], args[1]);
  FutureOr<int?> _insertBook_3(args) => insertBook(args);
  FutureOr<int?> _deleteBook_4(args) => deleteBook(args);
  Stream<List<BookCache>?> _watchCurrentCid_5(args) => watchCurrentCid(args);
}

/// implements [BookCacheEvent]
mixin BookCacheEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'database') yield BookCacheEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<List<BookCache>?> getMainList() {
    return sendEvent.sendMessage(BookCacheEventMessage.getMainList, null);
  }

  Stream<List<BookCache>?> watchMainList() {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchMainList, null);
  }

  FutureOr<int?> updateBook(int id, BookCache book) {
    return sendEvent.sendMessage(BookCacheEventMessage.updateBook, [id, book]);
  }

  FutureOr<int?> insertBook(BookCache bookCache) {
    return sendEvent.sendMessage(BookCacheEventMessage.insertBook, bookCache);
  }

  FutureOr<int?> deleteBook(int id) {
    return sendEvent.sendMessage(BookCacheEventMessage.deleteBook, id);
  }

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchCurrentCid, id);
  }
}
mixin BookContentEventResolve on Resolve implements BookContentEvent {
  late final _bookContentEventResolveFuncList =
      List<DynamicCallback>.unmodifiable(
          [_watchBookContentCid_0, _deleteCache_1]);
  bool onBookContentEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is BookContentEventMessage) {
        dynamic result;
        try {
          if (onBookContentEventResolve(resolveMessage)) return true;
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

  Stream<List<BookContentDb>?> _watchBookContentCid_0(args) =>
      watchBookContentCid(args);
  FutureOr<int?> _deleteCache_1(args) => deleteCache(args);
}

/// implements [BookContentEvent]
mixin BookContentEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'database') yield BookContentEventMessage;
    yield* super.getProtocols(name);
  }

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return sendEvent.sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return sendEvent.sendMessage(BookContentEventMessage.deleteCache, bookId);
  }
}
mixin ComplexOnDatabaseEventResolve on Resolve
    implements ComplexOnDatabaseEvent {
  late final _complexOnDatabaseEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getIndexsDbCacheItem_0,
    _getAllBookId_1,
    _insertOrUpdateIndexs_2,
    _getContentDb_3,
    _getIndexsDb_4,
    _getBookCacheDb_5,
    _insertOrUpdateContent_6,
    _insertOrUpdateBook_7,
    _insertOrUpdateZhangduIndex_8,
    _getZhangduContentDb_9,
    _getZhangduContentCid_10,
    _insertOrUpdateZhangduContent_11,
    _getZhangduIndexDb_12,
    _insertOrUpdateZhangduBook_13
  ]);
  bool onComplexOnDatabaseEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ComplexOnDatabaseEventMessage) {
        dynamic result;
        try {
          if (onComplexOnDatabaseEventResolve(resolveMessage)) return true;
          result = _complexOnDatabaseEventResolveFuncList
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

  FutureOr<List<BookIndex>?> _getIndexsDbCacheItem_0(args) =>
      getIndexsDbCacheItem();
  FutureOr<Set<int>?> _getAllBookId_1(args) => getAllBookId();
  FutureOr<int?> _insertOrUpdateIndexs_2(args) =>
      insertOrUpdateIndexs(args[0], args[1]);
  FutureOr<List<BookContentDb>?> _getContentDb_3(args) =>
      getContentDb(args[0], args[1]);
  FutureOr<List<BookIndex>?> _getIndexsDb_4(args) => getIndexsDb(args);
  FutureOr<List<BookCache>?> _getBookCacheDb_5(args) => getBookCacheDb(args);
  FutureOr<int?> _insertOrUpdateContent_6(args) => insertOrUpdateContent(args);
  FutureOr<int?> _insertOrUpdateBook_7(args) => insertOrUpdateBook(args);
  FutureOr<int?> _insertOrUpdateZhangduIndex_8(args) =>
      insertOrUpdateZhangduIndex(args[0], args[1]);
  FutureOr<List<String>?> _getZhangduContentDb_9(args) =>
      getZhangduContentDb(args[0], args[1]);
  FutureOr<int?> _getZhangduContentCid_10(args) => getZhangduContentCid(args);
  FutureOr<int?> _insertOrUpdateZhangduContent_11(args) =>
      insertOrUpdateZhangduContent(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndexDb_12(args) =>
      getZhangduIndexDb(args);
  FutureOr<void> _insertOrUpdateZhangduBook_13(args) =>
      insertOrUpdateZhangduBook(args[0], args[1], args[2]);
}

/// implements [ComplexOnDatabaseEvent]
mixin ComplexOnDatabaseEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'database') yield ComplexOnDatabaseEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<List<BookIndex>?> getIndexsDbCacheItem() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDbCacheItem, null);
  }

  FutureOr<Set<int>?> getAllBookId() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getAllBookId, null);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateIndexs, [id, indexs]);
  }

  FutureOr<List<BookContentDb>?> getContentDb(int bookid, int contentid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getContentDb, [bookid, contentid]);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDb, bookid);
  }

  FutureOr<List<BookCache>?> getBookCacheDb(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getBookCacheDb, bookid);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateContent, contentDb);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateBook, data);
  }

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduIndex,
        [bookId, data]);
  }

  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentDb, [bookId, contentId]);
  }

  FutureOr<int?> getZhangduContentCid(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentCid, bookid);
  }

  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduContent, content);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduIndexDb, bookId);
  }

  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduBook,
        [bookId, firstChapterId, data]);
  }
}
mixin ComplexEventResolve on Resolve implements ComplexEvent {
  late final _complexEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getCacheItems_0,
    _getContent_1,
    _getIndexs_2,
    _updateBookStatus_3,
    _getInfo_4
  ]);
  bool onComplexEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ComplexEventMessage) {
        dynamic result;
        try {
          if (onComplexEventResolve(resolveMessage)) return true;
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

  FutureOr<List<CacheItem>?> _getCacheItems_0(args) => getCacheItems();
  FutureOr<RawContentLines?> _getContent_1(args) =>
      getContent(args[0], args[1], args[2]);
  FutureOr<NetBookIndex?> _getIndexs_2(args) => getIndexs(args[0], args[1]);
  FutureOr<int?> _updateBookStatus_3(args) => updateBookStatus(args);
  FutureOr<BookInfoRoot?> _getInfo_4(args) => getInfo(args);
}

/// implements [ComplexEvent]
mixin ComplexEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'bookEventDefault') yield ComplexEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<List<CacheItem>?> getCacheItems() {
    return sendEvent.sendMessage(ComplexEventMessage.getCacheItems, null);
  }

  FutureOr<RawContentLines?> getContent(
      int bookid, int contentid, bool update) {
    return sendEvent.sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update]);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) {
    return sendEvent
        .sendMessage(ComplexEventMessage.getIndexs, [bookid, update]);
  }

  FutureOr<int?> updateBookStatus(int id) {
    return sendEvent.sendMessage(ComplexEventMessage.updateBookStatus, id);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return sendEvent.sendMessage(ComplexEventMessage.getInfo, id);
  }
}
mixin ZhangduDatabaseEventResolve on Resolve implements ZhangduDatabaseEvent {
  late final _zhangduDatabaseEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _deleteZhangduContentCache_0,
    _watchZhangduContentCid_1,
    _getZhangduMainList_2,
    _watchZhangduMainList_3,
    _updateZhangduBook_4,
    _insertZhangduBook_5,
    _deleteZhangduBook_6,
    _watchZhangduCurrentCid_7,
    _getZhangduCacheItems_8
  ]);
  bool onZhangduDatabaseEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ZhangduDatabaseEventMessage) {
        dynamic result;
        try {
          if (onZhangduDatabaseEventResolve(resolveMessage)) return true;
          result = _zhangduDatabaseEventResolveFuncList
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

  FutureOr<int?> _deleteZhangduContentCache_0(args) =>
      deleteZhangduContentCache(args);
  Stream<List<int>?> _watchZhangduContentCid_1(args) =>
      watchZhangduContentCid(args);
  FutureOr<List<ZhangduCache>?> _getZhangduMainList_2(args) =>
      getZhangduMainList();
  Stream<List<ZhangduCache>?> _watchZhangduMainList_3(args) =>
      watchZhangduMainList();
  FutureOr<int?> _updateZhangduBook_4(args) =>
      updateZhangduBook(args[0], args[1]);
  FutureOr<int?> _insertZhangduBook_5(args) => insertZhangduBook(args);
  FutureOr<int?> _deleteZhangduBook_6(args) => deleteZhangduBook(args);
  Stream<List<ZhangduCache>?> _watchZhangduCurrentCid_7(args) =>
      watchZhangduCurrentCid(args);
  FutureOr<List<CacheItem>?> _getZhangduCacheItems_8(args) =>
      getZhangduCacheItems();
}

/// implements [ZhangduDatabaseEvent]
mixin ZhangduDatabaseEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'database') yield ZhangduDatabaseEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduContentCache, bookId);
  }

  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduContentCid, bookId);
  }

  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.getZhangduMainList, null);
  }

  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduMainList, null);
  }

  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.updateZhangduBook, [bookId, book]);
  }

  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.insertZhangduBook, book);
  }

  FutureOr<int?> deleteZhangduBook(int bookId) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduBook, bookId);
  }

  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduCurrentCid, bookId);
  }

  FutureOr<List<CacheItem>?> getZhangduCacheItems() {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.getZhangduCacheItems, null);
  }
}
mixin ZhangduComplexEventResolve on Resolve implements ZhangduComplexEvent {
  late final _zhangduComplexEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getZhangduIndex_0,
    _getZhangduContent_1,
    _updateZhangduMainStatus_2,
    _getZhangduDetail_3
  ]);
  bool onZhangduComplexEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ZhangduComplexEventMessage) {
        dynamic result;
        try {
          if (onZhangduComplexEventResolve(resolveMessage)) return true;
          result = _zhangduComplexEventResolveFuncList
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

  FutureOr<List<ZhangduChapterData>?> _getZhangduIndex_0(args) =>
      getZhangduIndex(args[0], args[1]);
  FutureOr<List<String>?> _getZhangduContent_1(args) =>
      getZhangduContent(args[0], args[1], args[2], args[3], args[4], args[5]);
  FutureOr<int?> _updateZhangduMainStatus_2(args) =>
      updateZhangduMainStatus(args);
  FutureOr<ZhangduDetailData?> _getZhangduDetail_3(args) =>
      getZhangduDetail(args);
}

/// implements [ZhangduComplexEvent]
mixin ZhangduComplexEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'bookEventDefault') yield ZhangduComplexEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduIndex, [bookId, update]);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return sendEvent.sendMessage(ZhangduComplexEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update]);
  }

  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.updateZhangduMainStatus, bookId);
  }

  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduDetail, bookId);
  }
}
mixin ZhangduNetEventResolve on Resolve implements ZhangduNetEvent {
  late final _zhangduNetEventResolveFuncList =
      List<DynamicCallback>.unmodifiable(
          [_getZhangduSameUsersBooks_0, _getZhangduSearchData_1]);
  bool onZhangduNetEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ZhangduNetEventMessage) {
        dynamic result;
        try {
          if (onZhangduNetEventResolve(resolveMessage)) return true;
          result = _zhangduNetEventResolveFuncList
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

  FutureOr<List<ZhangduSameUsersBooksData>?> _getZhangduSameUsersBooks_0(
          args) =>
      getZhangduSameUsersBooks(args);
  FutureOr<ZhangduSearchData?> _getZhangduSearchData_1(args) =>
      getZhangduSearchData(args[0], args[1], args[2]);
}

/// implements [ZhangduNetEvent]
mixin ZhangduNetEventMessager on SendEvent {
  SendEvent get sendEvent;
  Iterable<Type> getProtocols(String name) sync* {
    if (name == 'bookEventDefault') yield ZhangduNetEventMessage;
    yield* super.getProtocols(name);
  }

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    return sendEvent.sendMessage(
        ZhangduNetEventMessage.getZhangduSameUsersBooks, author);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    return sendEvent.sendMessage(ZhangduNetEventMessage.getZhangduSearchData,
        [query, pageIndex, pageSize]);
  }
}
mixin MultiBookEventDefaultMessagerMixin
    on SendEvent, Send, ListenMixin, SendMultiIsolateMixin /*impl*/ {
  SendPortOwner? get defaultSendPortOwner => bookEventDefaultSendPortOwner;
  Future<Isolate> createIsolateBookEventDefault(SendPort remoteSendPort);
  Future<Isolate> createIsolateDatabase(SendPort remoteSendPort);

  final bookEventDefaultProtocols = [
    CustomEventMessage,
    ComplexEventMessage,
    ZhangduComplexEventMessage,
    ZhangduNetEventMessage,
  ];
  Map<String, List<Type>> get bookEventDefaultAllProtocols => {
        'database': databaseProtocols,
        'bookEventDefault': bookEventDefaultProtocols
      };
  List<Type> get databaseProtocols => [
        ComplexOnDatabaseEventMessage,
        BookCacheEventMessage,
        BookContentEventMessage,
        ZhangduDatabaseEventMessage,
      ];

  SendPortOwner? bookEventDefaultSendPortOwner;
  SendPortOwner? databaseSendPortOwner;

  void createAllIsolate(SendPort remoteSendPort, add) {
    final task = createIsolateBookEventDefault(remoteSendPort)
        .then((isolate) => addNewIsolate('bookEventDefault', isolate));
    add(task);
    final databasetask = createIsolateDatabase(remoteSendPort)
        .then((isolate) => addNewIsolate('database', isolate));
    add(databasetask);
    super.createAllIsolate(remoteSendPort, add);
  }

  void onListenReceivedSendPort(SendPortName sendPortName) {
    final protocols = bookEventDefaultAllProtocols[sendPortName.name];
    if (protocols != null) {
      final equal = sendPortName.protocols != null &&
          sendPortName.protocols!.every(protocols.contains);
      final sendPortOwner = SendPortOwner(
        localSendPort: sendPortName.sendPort,
        remoteSendPort: localSendPort,
      );
      switch (sendPortName.name) {
        case 'database':
          databaseSendPortOwner = sendPortOwner;
          break;
        case 'bookEventDefault':
          bookEventDefaultSendPortOwner = sendPortOwner;
          break;
        default:
      }
      Log.i('init: protocol status: $equal | ${sendPortName.name}',
          onlyDebug: false);
      return;
    }
    super.onListenReceivedSendPort(sendPortName);
  }

  void onResumeListen() {
    if (databaseSendPortOwner == null ||
        bookEventDefaultSendPortOwner == null) {
      Log.e('sendPortOwner error', onlyDebug: false);
    }
    bookEventDefaultSendPortOwner!.localSendPort.send(SendPortName(
        'database', databaseSendPortOwner!.localSendPort,
        protocols: databaseProtocols));
    super.onResumeListen();
  }

  SendPortOwner? getSendPortOwner(messagerType) {
    var matchName = '';
    if (messagerType is String) {
      matchName = messagerType;
    } else {
      for (var entry in bookEventDefaultAllProtocols.entries) {
        if (entry.value.contains(messagerType.runtimeType)) {
          matchName = entry.key;
          break;
        }
      }
    }
    switch (matchName) {
      case 'database':
        return databaseSendPortOwner;
      case 'bookEventDefault':
        return bookEventDefaultSendPortOwner;
      default:
    }
    return super.getSendPortOwner(messagerType);
  }

  void disposeIsolate(String isolateName) {
    switch (isolateName) {
      case 'database':
        databaseSendPortOwner = null;
        return;
      case 'bookEventDefault':
        bookEventDefaultSendPortOwner = null;
        return;
      default:
    }
    super.disposeIsolate(isolateName);
  }
}

abstract class MultiBookEventDefaultResolveMain
    with
        Send,
        SendEvent,
        ListenMixin,
        Resolve,
        MultiBookEventDefaultMixin,
        CustomEventResolve,
        ComplexEventResolve,
        ZhangduComplexEventResolve,
        ZhangduNetEventResolve {}

/// 在[Resolve]中为`Messager`提供便携
mixin MultiBookEventDefaultMixin on Send, SendEvent, Resolve {
  SendPortOwner? databaseSendPortOwner;
  void onListenReceivedSendPort(SendPortName sendPortName) {
    final sendPortOwner = SendPortOwner(
      localSendPort: sendPortName.sendPort,
      remoteSendPort: localSendPort,
    );
    final localProts = sendPortName.protocols;
    final prots = getProtocols(sendPortName.name).toList();
    if (localProts != null) {
      if (prots.every((e) => localProts.contains(e))) {
        Log.w('bookEventDefault: received ${sendPortName.name}, prots: matched',
            onlyDebug: false);
      } else {
        Log.w(
            'bookEventDefault: not metched, ${sendPortName.name}:$localProts, remote: $prots',
            onlyDebug: false);
      }
    }
    switch (sendPortName.name) {
      case 'database':
        databaseSendPortOwner = sendPortOwner;
        return;
      default:
    }
    super.onListenReceivedSendPort(sendPortName);
  }

  SendPortOwner? getSendPortOwner(key) {
    switch (key.runtimeType) {
      case ComplexOnDatabaseEventMessage:
      case BookCacheEventMessage:
      case BookContentEventMessage:
      case ZhangduDatabaseEventMessage:
        return databaseSendPortOwner;

      default:
    }
    return super.getSendPortOwner(key);
  }

  FutureOr<bool> onClose() async {
    databaseSendPortOwner = null;
    return super.onClose();
  }

  bool listen(message) {
    if (add(message)) return true;
    return super.listen(message);
  }

  void onResumeListen() {
    if (remoteSendPort != null)
      remoteSendPort!.send(SendPortName(
        'bookEventDefault',
        localSendPort,
        protocols: [
          CustomEventMessage,
          ComplexEventMessage,
          ZhangduComplexEventMessage,
          ZhangduNetEventMessage,
        ],
      ));
    super.onResumeListen();
  }
}

abstract class MultiDatabaseResolveMain
    with
        ListenMixin,
        Resolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexOnDatabaseEventResolve,
        ZhangduDatabaseEventResolve,
        MultiDatabaseOnResumeMixin {}

mixin MultiDatabaseOnResumeMixin on Resolve /*impl*/ {
  void onResumeListen() {
    if (remoteSendPort != null)
      remoteSendPort!.send(SendPortName(
        'database',
        localSendPort,
        protocols: [
          BookCacheEventMessage,
          BookContentEventMessage,
          ComplexOnDatabaseEventMessage,
          ZhangduDatabaseEventMessage,
        ],
      ));
    super.onResumeListen();
  }
}
