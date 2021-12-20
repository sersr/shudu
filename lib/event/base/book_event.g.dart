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
        SendMessage,
        CustomEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        ServerEventMessager,
        ComplexEventMessager,
        ZhangduDatabaseEventMessager,
        ZhangduComplexEventMessager,
        ZhangduNetEventMessager {}

mixin CustomEventResolve on Resolve implements CustomEvent, ServerNetEvent {
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', CustomEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(CustomEventMessage, [
      getSearchData,
      getImageBytesDynamic,
      getHiveShudanLists,
      (args) => getShudanLists(args[0], args[1]),
      (args) => getTopLists(args[0], args[1], args[2]),
      (args) => getCategLists(args[0], args[1], args[2]),
      getShudanDetail,
      (args) => getCategoryData(),
      (args) => getContentNet(args[0], args[1]),
      getInfoNet,
      getIndexsNet,
      getZhangduContentNet
    ]);
    yield* super.resolveFunctionIterable();
  }

  getImageBytes(String img) =>
      throw NopUseDynamicVersionExection("unused function");
  FutureOr<TransferType<Uint8List?>> getImageBytesDynamic(String img);
}

/// implements [CustomEvent]
mixin CustomEventMessager on SendEvent, SendMessage {
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, CustomEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<SearchList?> getSearchData(String key) {
    return sendMessage(CustomEventMessage.getSearchData, key,
        isolateName: bookEventDefault);
  }

  FutureOr<Uint8List?> getImageBytes(String img) {
    return sendMessage(CustomEventMessage.getImageBytes, img,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) {
    return sendMessage(CustomEventMessage.getHiveShudanLists, c,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) {
    return sendMessage(CustomEventMessage.getShudanLists, [c, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) {
    return sendMessage(CustomEventMessage.getTopLists, [c, date, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) {
    return sendMessage(CustomEventMessage.getCategLists, [c, date, index],
        isolateName: bookEventDefault);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) {
    return sendMessage(CustomEventMessage.getShudanDetail, index,
        isolateName: bookEventDefault);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() {
    return sendMessage(CustomEventMessage.getCategoryData, null,
        isolateName: bookEventDefault);
  }

  FutureOr<BookContentDb?> getContentNet(int bookid, int contentid) {
    return sendMessage(CustomEventMessage.getContentNet, [bookid, contentid],
        isolateName: bookEventDefault);
  }

  FutureOr<BookInfoRoot?> getInfoNet(int id) {
    return sendMessage(CustomEventMessage.getInfoNet, id,
        isolateName: bookEventDefault);
  }

  FutureOr<String?> getIndexsNet(int id) {
    return sendMessage(CustomEventMessage.getIndexsNet, id,
        isolateName: bookEventDefault);
  }

  FutureOr<String?> getZhangduContentNet(String url) {
    return sendMessage(CustomEventMessage.getZhangduContentNet, url,
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
      (args) => getMainList(),
      (args) => watchMainList(),
      (args) => updateBook(args[0], args[1]),
      insertBook,
      deleteBook,
      watchCurrentCid,
      (args) => getCacheItems()
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [BookCacheEvent]
mixin BookCacheEventMessager on SendEvent, SendMessage {
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, BookCacheEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<Option<List<BookCache>>> getMainList() {
    return sendOption(BookCacheEventMessage.getMainList, null,
        isolateName: database);
  }

  Stream<List<BookCache>?> watchMainList() {
    return sendMessageStream(BookCacheEventMessage.watchMainList, null,
        isolateName: database);
  }

  FutureOr<int?> updateBook(int id, BookCache book) {
    return sendMessage(BookCacheEventMessage.updateBook, [id, book],
        isolateName: database);
  }

  FutureOr<int?> insertBook(BookCache bookCache) {
    return sendMessage(BookCacheEventMessage.insertBook, bookCache,
        isolateName: database);
  }

  FutureOr<int?> deleteBook(int id) {
    return sendMessage(BookCacheEventMessage.deleteBook, id,
        isolateName: database);
  }

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return sendMessageStream(BookCacheEventMessage.watchCurrentCid, id,
        isolateName: database);
  }

  FutureOr<List<CacheItem>?> getCacheItems() {
    return sendMessage(BookCacheEventMessage.getCacheItems, null,
        isolateName: database);
  }
}
mixin BookContentEventResolve on Resolve implements BookContentEvent {
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('database', BookContentEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(BookContentEventMessage, [watchBookContentCid, deleteCache]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [BookContentEvent]
mixin BookContentEventMessager on SendEvent, SendMessage {
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, BookContentEventMessage);
    yield* super.getProtocols();
  }

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid,
        isolateName: database);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return sendMessage(BookContentEventMessage.deleteCache, bookId,
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
      (args) => getContentDb(args[0], args[1]),
      (args) => insertOrUpdateIndexs(args[0], args[1]),
      getIndexsDb,
      insertOrUpdateContent,
      insertOrUpdateBook,
      (args) => insertOrUpdateZhangduIndex(args[0], args[1]),
      (args) => getZhangduContentDb(args[0], args[1]),
      getZhangduContentCid,
      insertOrUpdateZhangduContent,
      getZhangduIndexDb,
      (args) => insertOrUpdateZhangduBook(args[0], args[1], args[2])
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [ServerEvent]
mixin ServerEventMessager on SendEvent, SendMessage {
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, ServerEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<RawContentLines?> getContentDb(int bookid, int contentid) {
    return sendMessage(ServerEventMessage.getContentDb, [bookid, contentid],
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return sendMessage(ServerEventMessage.insertOrUpdateIndexs, [id, indexs],
        isolateName: database);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return sendMessage(ServerEventMessage.getIndexsDb, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return sendMessage(ServerEventMessage.insertOrUpdateContent, contentDb,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return sendMessage(ServerEventMessage.insertOrUpdateBook, data,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return sendMessage(
        ServerEventMessage.insertOrUpdateZhangduIndex, [bookId, data],
        isolateName: database);
  }

  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    return sendMessage(
        ServerEventMessage.getZhangduContentDb, [bookId, contentId],
        isolateName: database);
  }

  FutureOr<int?> getZhangduContentCid(int bookid) {
    return sendMessage(ServerEventMessage.getZhangduContentCid, bookid,
        isolateName: database);
  }

  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    return sendMessage(ServerEventMessage.insertOrUpdateZhangduContent, content,
        isolateName: database);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    return sendMessage(ServerEventMessage.getZhangduIndexDb, bookId,
        isolateName: database);
  }

  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    return sendMessage(ServerEventMessage.insertOrUpdateZhangduBook,
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
    yield MapEntry(ComplexEventMessage, [
      (args) => getContent(args[0], args[1], args[2]),
      (args) => getIndexs(args[0], args[1]),
      getInfo,
      (args) => getZhangduContent(
          args[0], args[1], args[2], args[3], args[4], args[5])
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [ComplexEvent]
mixin ComplexEventMessager on SendEvent, SendMessage {
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ComplexEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<RawContentLines?> getContent(
      int bookid, int contentid, bool update) {
    return sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update],
        isolateName: bookEventDefault);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) {
    return sendMessage(ComplexEventMessage.getIndexs, [bookid, update],
        isolateName: bookEventDefault);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return sendMessage(ComplexEventMessage.getInfo, id,
        isolateName: bookEventDefault);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return sendMessage(ComplexEventMessage.getZhangduContent,
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
      deleteZhangduContentCache,
      watchZhangduContentCid,
      (args) => getZhangduMainList(),
      (args) => watchZhangduMainList(),
      (args) => updateZhangduBook(args[0], args[1]),
      insertZhangduBook,
      deleteZhangduBook,
      watchZhangduCurrentCid,
      (args) => getZhangduCacheItems()
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [ZhangduDatabaseEvent]
mixin ZhangduDatabaseEventMessager on SendEvent, SendMessage {
  String get database => 'database';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(database, ZhangduDatabaseEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    return sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduContentCache, bookId,
        isolateName: database);
  }

  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    return sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduContentCid, bookId,
        isolateName: database);
  }

  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return sendMessage(ZhangduDatabaseEventMessage.getZhangduMainList, null,
        isolateName: database);
  }

  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduMainList, null,
        isolateName: database);
  }

  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    return sendMessage(
        ZhangduDatabaseEventMessage.updateZhangduBook, [bookId, book],
        isolateName: database);
  }

  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    return sendMessage(ZhangduDatabaseEventMessage.insertZhangduBook, book,
        isolateName: database);
  }

  FutureOr<int?> deleteZhangduBook(int bookId) {
    return sendMessage(ZhangduDatabaseEventMessage.deleteZhangduBook, bookId,
        isolateName: database);
  }

  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    return sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduCurrentCid, bookId,
        isolateName: database);
  }

  FutureOr<List<CacheItem>?> getZhangduCacheItems() {
    return sendMessage(ZhangduDatabaseEventMessage.getZhangduCacheItems, null,
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
      (args) => getZhangduIndex(args[0], args[1]),
      (args) => getZhangduContent(
          args[0], args[1], args[2], args[3], args[4], args[5]),
      updateZhangduMainStatus,
      getZhangduDetail
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [ZhangduComplexEvent]
mixin ZhangduComplexEventMessager on SendEvent, SendMessage {
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ZhangduComplexEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    return sendMessage(
        ZhangduComplexEventMessage.getZhangduIndex, [bookId, update],
        isolateName: bookEventDefault);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return sendMessage(ZhangduComplexEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update],
        isolateName: bookEventDefault);
  }

  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    return sendMessage(
        ZhangduComplexEventMessage.updateZhangduMainStatus, bookId,
        isolateName: bookEventDefault);
  }

  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    return sendMessage(ZhangduComplexEventMessage.getZhangduDetail, bookId,
        isolateName: bookEventDefault);
  }
}
mixin ZhangduNetEventResolve on Resolve implements ZhangduNetEvent {
  Iterable<MapEntry<String, Type>> getResolveProtocols() sync* {
    yield const MapEntry('bookEventDefault', ZhangduNetEventMessage);
    yield* super.getResolveProtocols();
  }

  Iterable<MapEntry<Type, List<Function>>> resolveFunctionIterable() sync* {
    yield MapEntry(ZhangduNetEventMessage, [
      getZhangduSameUsersBooks,
      (args) => getZhangduSearchData(args[0], args[1], args[2])
    ]);
    yield* super.resolveFunctionIterable();
  }
}

/// implements [ZhangduNetEvent]
mixin ZhangduNetEventMessager on SendEvent, SendMessage {
  String get bookEventDefault => 'bookEventDefault';
  Iterable<MapEntry<String, Type>> getProtocols() sync* {
    yield MapEntry(bookEventDefault, ZhangduNetEventMessage);
    yield* super.getProtocols();
  }

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    return sendMessage(ZhangduNetEventMessage.getZhangduSameUsersBooks, author,
        isolateName: bookEventDefault);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    return sendMessage(ZhangduNetEventMessage.getZhangduSearchData,
        [query, pageIndex, pageSize],
        isolateName: bookEventDefault);
  }
}
mixin MultiBookEventDefaultMessagerMixin
    on SendEvent, ListenMixin, SendMultiServerMixin /*impl*/ {
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
