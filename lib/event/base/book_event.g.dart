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
  getCategoryData,
  updateBookStatus,
  getContentNet,
  getInfoNet,
  getIndexsNet,
  getZhangduContentNet
}
enum BookCacheEventMessage {
  getMainList,
  watchMainList,
  updateBook,
  insertBook,
  deleteBook,
  watchCurrentCid,
  getCacheItems
}
enum BookContentEventMessage { watchBookContentCid, deleteCache }
enum ServerEventMessage {
  getContentDb,
  insertOrUpdateIndexs,
  getIndexsDb,
  insertOrUpdateContent,
  insertOrUpdateBook,
  insertOrUpdateZhangduIndex,
  getZhangduContentDb,
  getZhangduContentCid,
  insertOrUpdateZhangduContent,
  getZhangduIndexDb,
  insertOrUpdateZhangduBook
}
enum ComplexEventMessage { getContent, getIndexs, getInfo, getZhangduContent }
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
        ServerEventResolve,
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
        ServerEventMessager,
        ComplexEventMessager,
        ZhangduDatabaseEventMessager,
        ZhangduComplexEventMessager,
        ZhangduNetEventMessager {}

/// implements [CustomEvent]
mixin CustomEventDynamic {
  FutureOr<TransferType<Uint8List?>> getImageBytesDynamic(String img);
}
mixin CustomEventResolve on Resolve
    implements CustomEvent, ServerNetEvent, CustomEventDynamic {
  late final _customEventResolveFuncList = List<Function>.unmodifiable([
    _getSearchData_0,
    _getImageBytes_1,
    _getHiveShudanLists_2,
    _getShudanLists_3,
    _getTopLists_4,
    _getCategLists_5,
    _getShudanDetail_6,
    _getCategoryData_7,
    _updateBookStatus_8,
    _getContentNet_9,
    _getInfoNet_10,
    _getIndexsNet_11,
    _getZhangduContentNet_12
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
  FutureOr<int?> _updateBookStatus_8(args) => updateBookStatus(args);
  FutureOr<BookContentDb?> _getContentNet_9(args) =>
      getContentNet(args[0], args[1]);
  FutureOr<BookInfoRoot?> _getInfoNet_10(args) => getInfoNet(args);
  FutureOr<String?> _getIndexsNet_11(args) => getIndexsNet(args);
  FutureOr<String?> _getZhangduContentNet_12(args) =>
      getZhangduContentNet(args);
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

  FutureOr<int?> updateBookStatus(int id) {
    return sendEvent.sendMessage(CustomEventMessage.updateBookStatus, id,
        isolateName: bookEventDefault);
  }

  FutureOr<BookContentDb?> getContentNet(int bookid, int contentid) {
    return sendEvent.sendMessage(
        CustomEventMessage.getContentNet, [bookid, contentid],
        isolateName: bookEventDefault);
  }

  FutureOr<BookInfoRoot?> getInfoNet(int id) {
    return sendEvent.sendMessage(CustomEventMessage.getInfoNet, id,
        isolateName: bookEventDefault);
  }

  FutureOr<String?> getIndexsNet(int id) {
    return sendEvent.sendMessage(CustomEventMessage.getIndexsNet, id,
        isolateName: bookEventDefault);
  }

  FutureOr<String?> getZhangduContentNet(String url) {
    return sendEvent.sendMessage(CustomEventMessage.getZhangduContentNet, url,
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
    _watchCurrentCid_5,
    _getCacheItems_6
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
  FutureOr<List<CacheItem>?> _getCacheItems_6(args) => getCacheItems();
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

  FutureOr<List<CacheItem>?> getCacheItems() {
    return sendEvent.sendMessage(BookCacheEventMessage.getCacheItems, null,
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
mixin ServerEventResolve on Resolve implements ServerEvent {
  late final _serverEventResolveFuncList = List<Function>.unmodifiable([
    _getContentDb_0,
    _insertOrUpdateIndexs_1,
    _getIndexsDb_2,
    _insertOrUpdateContent_3,
    _insertOrUpdateBook_4,
    _insertOrUpdateZhangduIndex_5,
    _getZhangduContentDb_6,
    _getZhangduContentCid_7,
    _insertOrUpdateZhangduContent_8,
    _getZhangduIndexDb_9,
    _insertOrUpdateZhangduBook_10
  ]);
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', ServerEventMessage);
    yield* super.getResolveProtocols();
  }

  bool onServerEventResolve(message) => false;
  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ServerEventMessage) {
        dynamic result;
        try {
          if (onServerEventResolve(resolveMessage)) return true;
          result = _serverEventResolveFuncList
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

  FutureOr<RawContentLines?> _getContentDb_0(args) =>
      getContentDb(args[0], args[1]);
  FutureOr<int?> _insertOrUpdateIndexs_1(args) =>
      insertOrUpdateIndexs(args[0], args[1]);
  FutureOr<List<BookIndex>?> _getIndexsDb_2(args) => getIndexsDb(args);
  FutureOr<int?> _insertOrUpdateContent_3(args) => insertOrUpdateContent(args);
  FutureOr<int?> _insertOrUpdateBook_4(args) => insertOrUpdateBook(args);
  FutureOr<int?> _insertOrUpdateZhangduIndex_5(args) =>
      insertOrUpdateZhangduIndex(args[0], args[1]);
  FutureOr<List<String>?> _getZhangduContentDb_6(args) =>
      getZhangduContentDb(args[0], args[1]);
  FutureOr<int?> _getZhangduContentCid_7(args) => getZhangduContentCid(args);
  FutureOr<int?> _insertOrUpdateZhangduContent_8(args) =>
      insertOrUpdateZhangduContent(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndexDb_9(args) =>
      getZhangduIndexDb(args);
  FutureOr<void> _insertOrUpdateZhangduBook_10(args) =>
      insertOrUpdateZhangduBook(args[0], args[1], args[2]);
}

/// implements [ServerEvent]
mixin ServerEventMessager on SendEvent {
  SendEvent get sendEvent;
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, ServerEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<RawContentLines?> getContentDb(int bookid, int contentid) {
    return sendEvent.sendMessage(
        ServerEventMessage.getContentDb, [bookid, contentid],
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return sendEvent.sendMessage(
        ServerEventMessage.insertOrUpdateIndexs, [id, indexs],
        isolateName: database);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return sendEvent.sendMessage(ServerEventMessage.getIndexsDb, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return sendEvent.sendMessage(
        ServerEventMessage.insertOrUpdateContent, contentDb,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return sendEvent.sendMessage(ServerEventMessage.insertOrUpdateBook, data,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return sendEvent.sendMessage(
        ServerEventMessage.insertOrUpdateZhangduIndex, [bookId, data],
        isolateName: database);
  }

  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    return sendEvent.sendMessage(
        ServerEventMessage.getZhangduContentDb, [bookId, contentId],
        isolateName: database);
  }

  FutureOr<int?> getZhangduContentCid(int bookid) {
    return sendEvent.sendMessage(
        ServerEventMessage.getZhangduContentCid, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    return sendEvent.sendMessage(
        ServerEventMessage.insertOrUpdateZhangduContent, content,
        isolateName: database);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    return sendEvent.sendMessage(ServerEventMessage.getZhangduIndexDb, bookId,
        isolateName: database);
  }

  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    return sendEvent.sendMessage(ServerEventMessage.insertOrUpdateZhangduBook,
        [bookId, firstChapterId, data],
        isolateName: database);
  }
}
mixin ComplexEventResolve on Resolve implements ComplexEvent {
  late final _complexEventResolveFuncList = List<Function>.unmodifiable(
      [_getContent_0, _getIndexs_1, _getInfo_2, _getZhangduContent_3]);
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

  FutureOr<RawContentLines?> _getContent_0(args) =>
      getContent(args[0], args[1], args[2]);
  FutureOr<NetBookIndex?> _getIndexs_1(args) => getIndexs(args[0], args[1]);
  FutureOr<BookInfoRoot?> _getInfo_2(args) => getInfo(args);
  FutureOr<List<String>?> _getZhangduContent_3(args) =>
      getZhangduContent(args[0], args[1], args[2], args[3], args[4], args[5]);
}

/// implements [ComplexEvent]
mixin ComplexEventMessager on SendEvent {
  SendEvent get sendEvent;
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ComplexEventMessage);
    yield* super.getProtocols();
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

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return sendEvent.sendMessage(ComplexEventMessage.getInfo, id,
        isolateName: bookEventDefault);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return sendEvent.sendMessage(ComplexEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update],
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
  late final _zhangduComplexEventResolveFuncList = List<Function>.unmodifiable(
      [_getZhangduIndex_0, _updateZhangduMainStatus_1, _getZhangduDetail_2]);
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
  FutureOr<int?> _updateZhangduMainStatus_1(args) =>
      updateZhangduMainStatus(args);
  FutureOr<ZhangduDetailData?> _getZhangduDetail_2(args) =>
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
        protocols: getServerProtocols('database')));

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
        ServerEventResolve,
        ZhangduDatabaseEventResolve {}
