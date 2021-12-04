// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_event.dart';

// **************************************************************************
// Generator: IsolateEventGeneratorForAnnotation
// **************************************************************************

// ignore_for_file: annotate_overrides
// ignore_for_file: curly_braces_in_flow_control_structures
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
  late final _customEventResolveFuncList = List<Function>.unmodifiable([
    _getSearchData_0,
    _getImageBytes_1,
    _getHiveShudanLists_2,
    _getShudanLists_3,
    _getTopLists_4,
    _getCategLists_5,
    _getShudanDetail_6,
    _getCategoryData_7
  ]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', CustomEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, CustomEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<SearchList?> getSearchData(String key) {
    return sendEvent.sendMessage(CustomEventMessage.getSearchData, key,
        isolateName: bookEventDefault);
  }

  FutureOr<Uint8List?> getImageBytes(String img) {
    return sendEvent.sendMessage(CustomEventMessage.getImageBytes, img,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) {
    return sendEvent.sendMessage(CustomEventMessage.getHiveShudanLists, c,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) {
    return sendEvent.sendMessage(CustomEventMessage.getShudanLists, [c, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) {
    return sendEvent.sendMessage(
        CustomEventMessage.getTopLists, [c, date, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) {
    return sendEvent.sendMessage(
        CustomEventMessage.getCategLists, [c, date, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) {
    return sendEvent.sendMessage(CustomEventMessage.getShudanDetail, index,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() {
    return sendEvent.sendMessage(CustomEventMessage.getCategoryData, null,
        isolateName: bookEventDefault);
  }
}
mixin BookCacheEventResolve on Resolve implements BookCacheEvent {
  late final _bookCacheEventResolveFuncList = List<Function>.unmodifiable([
    _getMainList_0,
    _watchMainList_1,
    _updateBook_2,
    _insertBook_3,
    _deleteBook_4,
    _watchCurrentCid_5
  ]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', BookCacheEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, BookCacheEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<BookCache>?> getMainList() {
    return sendEvent.sendMessage(BookCacheEventMessage.getMainList, null,
        isolateName: database);
  }

  Stream<List<BookCache>?> watchMainList() {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchMainList, null,
        isolateName: database);
  }

  FutureOr<int?> updateBook(int id, BookCache book) {
    return sendEvent.sendMessage(BookCacheEventMessage.updateBook, [id, book],
        isolateName: database);
  }

  FutureOr<int?> insertBook(BookCache bookCache) {
    return sendEvent.sendMessage(BookCacheEventMessage.insertBook, bookCache,
        isolateName: database);
  }

  FutureOr<int?> deleteBook(int id) {
    return sendEvent.sendMessage(BookCacheEventMessage.deleteBook, id,
        isolateName: database);
  }

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchCurrentCid, id,
        isolateName: database);
  }
}
mixin BookContentEventResolve on Resolve implements BookContentEvent {
  late final _bookContentEventResolveFuncList =
      List<Function>.unmodifiable([_watchBookContentCid_0, _deleteCache_1]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', BookContentEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, BookContentEventMessage);
    yield* super.getProtocols();
  }

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return sendEvent.sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid,
        isolateName: database);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return sendEvent.sendMessage(BookContentEventMessage.deleteCache, bookId,
        isolateName: database);
  }
}
mixin ComplexOnDatabaseEventResolve on Resolve
    implements ComplexOnDatabaseEvent {
  late final _complexOnDatabaseEventResolveFuncList =
      List<Function>.unmodifiable([
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', ComplexOnDatabaseEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, ComplexOnDatabaseEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<BookIndex>?> getIndexsDbCacheItem() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDbCacheItem, null,
        isolateName: database);
  }

  FutureOr<Set<int>?> getAllBookId() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getAllBookId, null,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateIndexs, [id, indexs],
        isolateName: database);
  }

  FutureOr<List<BookContentDb>?> getContentDb(int bookid, int contentid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getContentDb, [bookid, contentid],
        isolateName: database);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDb, bookid,
        isolateName: database);
  }

  FutureOr<List<BookCache>?> getBookCacheDb(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getBookCacheDb, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateContent, contentDb,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateBook, data,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduIndex,
        [bookId, data],
        isolateName: database);
  }

  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentDb, [bookId, contentId],
        isolateName: database);
  }

  FutureOr<int?> getZhangduContentCid(int bookid) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentCid, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduContent, content,
        isolateName: database);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduIndexDb, bookId,
        isolateName: database);
  }

  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduBook,
        [bookId, firstChapterId, data],
        isolateName: database);
  }
}
mixin ComplexEventResolve on Resolve implements ComplexEvent {
  late final _complexEventResolveFuncList = List<Function>.unmodifiable([
    _getCacheItems_0,
    _getContent_1,
    _getIndexs_2,
    _updateBookStatus_3,
    _getInfo_4
  ]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ComplexEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ComplexEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<CacheItem>?> getCacheItems() {
    return sendEvent.sendMessage(ComplexEventMessage.getCacheItems, null,
        isolateName: bookEventDefault);
  }

  FutureOr<RawContentLines?> getContent(
      int bookid, int contentid, bool update) {
    return sendEvent.sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update],
        isolateName: bookEventDefault);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) {
    return sendEvent.sendMessage(
        ComplexEventMessage.getIndexs, [bookid, update],
        isolateName: bookEventDefault);
  }

  FutureOr<int?> updateBookStatus(int id) {
    return sendEvent.sendMessage(ComplexEventMessage.updateBookStatus, id,
        isolateName: bookEventDefault);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return sendEvent.sendMessage(ComplexEventMessage.getInfo, id,
        isolateName: bookEventDefault);
  }
}
mixin ZhangduDatabaseEventResolve on Resolve implements ZhangduDatabaseEvent {
  late final _zhangduDatabaseEventResolveFuncList =
      List<Function>.unmodifiable([
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', ZhangduDatabaseEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, ZhangduDatabaseEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduContentCache, bookId,
        isolateName: database);
  }

  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduContentCid, bookId,
        isolateName: database);
  }

  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.getZhangduMainList, null,
        isolateName: database);
  }

  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduMainList, null,
        isolateName: database);
  }

  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.updateZhangduBook, [bookId, book],
        isolateName: database);
  }

  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.insertZhangduBook, book,
        isolateName: database);
  }

  FutureOr<int?> deleteZhangduBook(int bookId) {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduBook, bookId,
        isolateName: database);
  }

  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduCurrentCid, bookId,
        isolateName: database);
  }

  FutureOr<List<CacheItem>?> getZhangduCacheItems() {
    return sendEvent.sendMessage(
        ZhangduDatabaseEventMessage.getZhangduCacheItems, null,
        isolateName: database);
  }
}
mixin ZhangduComplexEventResolve on Resolve implements ZhangduComplexEvent {
  late final _zhangduComplexEventResolveFuncList = List<Function>.unmodifiable([
    _getZhangduIndex_0,
    _getZhangduContent_1,
    _updateZhangduMainStatus_2,
    _getZhangduDetail_3
  ]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ZhangduComplexEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ZhangduComplexEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduIndex, [bookId, update],
        isolateName: bookEventDefault);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return sendEvent.sendMessage(ZhangduComplexEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update],
        isolateName: bookEventDefault);
  }

  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.updateZhangduMainStatus, bookId,
        isolateName: bookEventDefault);
  }

  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduDetail, bookId,
        isolateName: bookEventDefault);
  }
}
mixin ZhangduNetEventResolve on Resolve implements ZhangduNetEvent {
  late final _zhangduNetEventResolveFuncList = List<Function>.unmodifiable(
      [_getZhangduSameUsersBooks_0, _getZhangduSearchData_1]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ZhangduNetEventMessage);
    yield* super.getResolveProtocols();
  }

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
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ZhangduNetEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    return sendEvent.sendMessage(
        ZhangduNetEventMessage.getZhangduSameUsersBooks, author,
        isolateName: bookEventDefault);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    return sendEvent.sendMessage(ZhangduNetEventMessage.getZhangduSearchData,
        [query, pageIndex, pageSize],
        isolateName: bookEventDefault);
  }
}
mixin MultiBookEventDefaultMessagerMixin
    on SendEvent, ListenMixin, SendMultiServerMixin /*impl*/ {
  String get defaultSendPortOwnerName => 'bookEventDefault';
  Future<RemoteServer> createRemoteServerBookEventDefault();
  Future<RemoteServer> createRemoteServerDatabase();
  Iterable<MapEntry<String, CreateRemoteServer>>
      createRemoteServerIterable() sync* {
    yield MapEntry('bookEventDefault', createRemoteServerBookEventDefault);
    yield MapEntry('database', createRemoteServerDatabase);
    yield* super.createRemoteServerIterable();
  }

  void onResumeListen() {
    sendPortOwners['bookEventDefault']!.localSendPort.send(SendPortName(
        'database', sendPortOwners['database']!.localSendPort,
        protocols: getResolveProtocols('database')));

    super.onResumeListen();
  }
}

abstract class MultiBookEventDefaultResolveMain
    with
        SendEvent,
        ListenMixin,
        Resolve,
        ResolveMultiRecievedMixin,
        CustomEventResolve,
        ComplexEventResolve,
        ZhangduComplexEventResolve,
        ZhangduNetEventResolve {}

abstract class MultiDatabaseResolveMain
    with
        ListenMixin,
        Resolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexOnDatabaseEventResolve,
        ZhangduDatabaseEventResolve {}
