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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', CustomEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(CustomEventMessage, [
      _getSearchData_0,
      _getImageBytes_1,
      _getHiveShudanLists_2,
      _getShudanLists_3,
      _getTopLists_4,
      _getCategLists_5,
      _getShudanDetail_6,
      _getCategoryData_7,
      _getContentNet_8,
      _getInfoNet_9,
      _getIndexsNet_10,
      _getZhangduContentNet_11
    ]);
    yield* super.resolveFunctionIterable();
  }

  _getSearchData_0(args) => getSearchData(args);
  getImageBytes(String img) => throw NopUseDynamicVersionExection("不要手动调用");
  _getImageBytes_1(args) => getImageBytesDynamic(args);
  _getHiveShudanLists_2(args) => getHiveShudanLists(args);
  _getShudanLists_3(args) => getShudanLists(args[0], args[1]);
  _getTopLists_4(args) => getTopLists(args[0], args[1], args[2]);
  _getCategLists_5(args) => getCategLists(args[0], args[1], args[2]);
  _getShudanDetail_6(args) => getShudanDetail(args);
  _getCategoryData_7(args) => getCategoryData();
  _getContentNet_8(args) => getContentNet(args[0], args[1]);
  _getInfoNet_9(args) => getInfoNet(args);
  _getIndexsNet_10(args) => getIndexsNet(args);
  _getZhangduContentNet_11(args) => getZhangduContentNet(args);
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', BookCacheEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(BookCacheEventMessage, [
      _getMainList_0,
      _watchMainList_1,
      _updateBook_2,
      _insertBook_3,
      _deleteBook_4,
      _watchCurrentCid_5,
      _getCacheItems_6
    ]);
    yield* super.resolveFunctionIterable();
  }

  _getMainList_0(args) => getMainList();
  _watchMainList_1(args) => watchMainList();
  _updateBook_2(args) => updateBook(args[0], args[1]);
  _insertBook_3(args) => insertBook(args);
  _deleteBook_4(args) => deleteBook(args);
  _watchCurrentCid_5(args) => watchCurrentCid(args);
  _getCacheItems_6(args) => getCacheItems();
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', BookContentEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(
        BookContentEventMessage, [_watchBookContentCid_0, _deleteCache_1]);
    yield* super.resolveFunctionIterable();
  }

  _watchBookContentCid_0(args) => watchBookContentCid(args);
  _deleteCache_1(args) => deleteCache(args);
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', ServerEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ServerEventMessage, [
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
    yield* super.resolveFunctionIterable();
  }

  _getContentDb_0(args) => getContentDb(args[0], args[1]);
  _insertOrUpdateIndexs_1(args) => insertOrUpdateIndexs(args[0], args[1]);
  _getIndexsDb_2(args) => getIndexsDb(args);
  _insertOrUpdateContent_3(args) => insertOrUpdateContent(args);
  _insertOrUpdateBook_4(args) => insertOrUpdateBook(args);
  _insertOrUpdateZhangduIndex_5(args) =>
      insertOrUpdateZhangduIndex(args[0], args[1]);
  _getZhangduContentDb_6(args) => getZhangduContentDb(args[0], args[1]);
  _getZhangduContentCid_7(args) => getZhangduContentCid(args);
  _insertOrUpdateZhangduContent_8(args) => insertOrUpdateZhangduContent(args);
  _getZhangduIndexDb_9(args) => getZhangduIndexDb(args);
  _insertOrUpdateZhangduBook_10(args) =>
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ComplexEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ComplexEventMessage,
        [_getContent_0, _getIndexs_1, _getInfo_2, _getZhangduContent_3]);
    yield* super.resolveFunctionIterable();
  }

  _getContent_0(args) => getContent(args[0], args[1], args[2]);
  _getIndexs_1(args) => getIndexs(args[0], args[1]);
  _getInfo_2(args) => getInfo(args);
  _getZhangduContent_3(args) =>
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', ZhangduDatabaseEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ZhangduDatabaseEventMessage, [
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
    yield* super.resolveFunctionIterable();
  }

  _deleteZhangduContentCache_0(args) => deleteZhangduContentCache(args);
  _watchZhangduContentCid_1(args) => watchZhangduContentCid(args);
  _getZhangduMainList_2(args) => getZhangduMainList();
  _watchZhangduMainList_3(args) => watchZhangduMainList();
  _updateZhangduBook_4(args) => updateZhangduBook(args[0], args[1]);
  _insertZhangduBook_5(args) => insertZhangduBook(args);
  _deleteZhangduBook_6(args) => deleteZhangduBook(args);
  _watchZhangduCurrentCid_7(args) => watchZhangduCurrentCid(args);
  _getZhangduCacheItems_8(args) => getZhangduCacheItems();
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ZhangduComplexEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ZhangduComplexEventMessage, [
      _getZhangduIndex_0,
      _getZhangduContent_1,
      _updateZhangduMainStatus_2,
      _getZhangduDetail_3
    ]);
    yield* super.resolveFunctionIterable();
  }

  _getZhangduIndex_0(args) => getZhangduIndex(args[0], args[1]);
  _getZhangduContent_1(args) =>
      getZhangduContent(args[0], args[1], args[2], args[3], args[4], args[5]);
  _updateZhangduMainStatus_2(args) => updateZhangduMainStatus(args);
  _getZhangduDetail_3(args) => getZhangduDetail(args);
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
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ZhangduNetEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ZhangduNetEventMessage,
        [_getZhangduSameUsersBooks_0, _getZhangduSearchData_1]);
    yield* super.resolveFunctionIterable();
  }

  _getZhangduSameUsersBooks_0(args) => getZhangduSameUsersBooks(args);
  _getZhangduSearchData_1(args) =>
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
