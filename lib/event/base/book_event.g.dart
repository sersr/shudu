// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_event.dart';

// **************************************************************************
// Generator: ServerEventGeneratorForAnnotation
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
  getIndexsNet
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
  insertOrUpdateBook
}

enum ComplexEventMessage { getContent, getIndexs, getInfo }

/// 主入口
abstract class MultiBookMessagerMain
    with
        BookEvent,
        ListenMixin,
        SendEventMixin,
        SendMultiServerMixin,
        CustomEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        ServerEventMessager,
        ComplexEventMessager {
  RemoteServer get bookRemoteServer;
  RemoteServer get databaseRemoteServer;
  Map<String, RemoteServer> regRemoteServer() {
    return super.regRemoteServer()
      ..['book'] = bookRemoteServer
      ..['database'] = databaseRemoteServer;
  }

  void onResumeListen() {
    connect('book', 'database');
    super.onResumeListen();
  }
}

/// book Server
abstract class MultiBookResolveMain
    with
        ListenMixin,
        Resolve,
        SendEventMixin,
        SendCacheMixin,
        ResolveMultiRecievedMixin,
        BookCacheEventMessager,
        BookContentEventMessager,
        ServerEventMessager,
        CustomEventResolve,
        ComplexEventResolve {
  MultiBookResolveMain({required ServerConfigurations configurations})
      : remoteSendHandle = configurations.sendHandle;
  final SendHandle remoteSendHandle;
}

/// database Server
abstract class MultiDatabaseResolveMain
    with
        ListenMixin,
        Resolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ServerEventResolve {
  MultiDatabaseResolveMain({required ServerConfigurations configurations})
      : remoteSendHandle = configurations.sendHandle;
  final SendHandle remoteSendHandle;
}

mixin CustomEventResolve on Resolve implements CustomEvent, ServerNetEvent {
  Map<String, List<Type>> getResolveProtocols() {
    return super.getResolveProtocols()
      ..putIfAbsent('book', () => []).add(CustomEventMessage);
  }

  Map<Type, List<Function>> resolveFunctionIterable() {
    return super.resolveFunctionIterable()
      ..[CustomEventMessage] = [
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
        getIndexsNet
      ];
  }

  getImageBytes(String img) =>
      throw NopUseDynamicVersionExection("unused function");
  FutureOr<TransferType<Uint8List?>> getImageBytesDynamic(String img);
}

/// implements [CustomEvent]
mixin CustomEventMessager on SendEvent, Messager {
  String get book => 'book';
  Map<String, List<Type>> getProtocols() {
    return super.getProtocols()
      ..putIfAbsent(book, () => []).add(CustomEventMessage);
  }

  FutureOr<SearchList?> getSearchData(String key) {
    return sendMessage(CustomEventMessage.getSearchData, key, serverName: book);
  }

  FutureOr<Uint8List?> getImageBytes(String img) {
    return sendMessage(CustomEventMessage.getImageBytes, img, serverName: book);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) {
    return sendMessage(CustomEventMessage.getHiveShudanLists, c,
        serverName: book);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) {
    return sendMessage(CustomEventMessage.getShudanLists, [c, index],
        serverName: book);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) {
    return sendMessage(CustomEventMessage.getTopLists, [c, date, index],
        serverName: book);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) {
    return sendMessage(CustomEventMessage.getCategLists, [c, date, index],
        serverName: book);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) {
    return sendMessage(CustomEventMessage.getShudanDetail, index,
        serverName: book);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() {
    return sendMessage(CustomEventMessage.getCategoryData, null,
        serverName: book);
  }

  FutureOr<BookContentDb?> getContentNet(int bookid, int contentid) {
    return sendMessage(CustomEventMessage.getContentNet, [bookid, contentid],
        serverName: book);
  }

  FutureOr<BookInfoRoot?> getInfoNet(int id) {
    return sendMessage(CustomEventMessage.getInfoNet, id, serverName: book);
  }

  FutureOr<String?> getIndexsNet(int id) {
    return sendMessage(CustomEventMessage.getIndexsNet, id, serverName: book);
  }
}
mixin BookCacheEventResolve on Resolve implements BookCacheEvent {
  Map<String, List<Type>> getResolveProtocols() {
    return super.getResolveProtocols()
      ..putIfAbsent('database', () => []).add(BookCacheEventMessage);
  }

  Map<Type, List<Function>> resolveFunctionIterable() {
    return super.resolveFunctionIterable()
      ..[BookCacheEventMessage] = [
        (args) => getMainList(),
        (args) => watchMainList(),
        (args) => updateBook(args[0], args[1]),
        insertBook,
        deleteBook,
        watchCurrentCid,
        (args) => getCacheItems()
      ];
  }
}

/// implements [BookCacheEvent]
mixin BookCacheEventMessager on SendEvent, Messager {
  String get database => 'database';
  Map<String, List<Type>> getProtocols() {
    return super.getProtocols()
      ..putIfAbsent(database, () => []).add(BookCacheEventMessage);
  }

  FutureOr<Option<List<BookCache>>> getMainList() {
    return sendOption(BookCacheEventMessage.getMainList, null,
        serverName: database);
  }

  Stream<List<BookCache>?> watchMainList() {
    return sendMessageStream(BookCacheEventMessage.watchMainList, null,
        serverName: database);
  }

  FutureOr<int?> updateBook(int id, BookCache book) {
    return sendMessage(BookCacheEventMessage.updateBook, [id, book],
        serverName: database);
  }

  FutureOr<int?> insertBook(BookCache bookCache) {
    return sendMessage(BookCacheEventMessage.insertBook, bookCache,
        serverName: database);
  }

  FutureOr<int?> deleteBook(int id) {
    return sendMessage(BookCacheEventMessage.deleteBook, id,
        serverName: database);
  }

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return sendMessageStream(BookCacheEventMessage.watchCurrentCid, id,
        serverName: database);
  }

  FutureOr<List<CacheItem>?> getCacheItems() {
    return sendMessage(BookCacheEventMessage.getCacheItems, null,
        serverName: database);
  }
}
mixin BookContentEventResolve on Resolve implements BookContentEvent {
  Map<String, List<Type>> getResolveProtocols() {
    return super.getResolveProtocols()
      ..putIfAbsent('database', () => []).add(BookContentEventMessage);
  }

  Map<Type, List<Function>> resolveFunctionIterable() {
    return super.resolveFunctionIterable()
      ..[BookContentEventMessage] = [watchBookContentCid, deleteCache];
  }
}

/// implements [BookContentEvent]
mixin BookContentEventMessager on SendEvent, Messager {
  String get database => 'database';
  Map<String, List<Type>> getProtocols() {
    return super.getProtocols()
      ..putIfAbsent(database, () => []).add(BookContentEventMessage);
  }

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid,
        serverName: database);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return sendMessage(BookContentEventMessage.deleteCache, bookId,
        serverName: database);
  }
}
mixin ServerEventResolve on Resolve implements ServerEvent {
  Map<String, List<Type>> getResolveProtocols() {
    return super.getResolveProtocols()
      ..putIfAbsent('database', () => []).add(ServerEventMessage);
  }

  Map<Type, List<Function>> resolveFunctionIterable() {
    return super.resolveFunctionIterable()
      ..[ServerEventMessage] = [
        (args) => getContentDb(args[0], args[1]),
        (args) => insertOrUpdateIndexs(args[0], args[1]),
        getIndexsDb,
        insertOrUpdateContent,
        insertOrUpdateBook
      ];
  }
}

/// implements [ServerEvent]
mixin ServerEventMessager on SendEvent, Messager {
  String get database => 'database';
  Map<String, List<Type>> getProtocols() {
    return super.getProtocols()
      ..putIfAbsent(database, () => []).add(ServerEventMessage);
  }

  FutureOr<RawContentLines?> getContentDb(int bookid, int contentid) {
    return sendMessage(ServerEventMessage.getContentDb, [bookid, contentid],
        serverName: database);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return sendMessage(ServerEventMessage.insertOrUpdateIndexs, [id, indexs],
        serverName: database);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return sendMessage(ServerEventMessage.getIndexsDb, bookid,
        serverName: database);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return sendMessage(ServerEventMessage.insertOrUpdateContent, contentDb,
        serverName: database);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return sendMessage(ServerEventMessage.insertOrUpdateBook, data,
        serverName: database);
  }
}
mixin ComplexEventResolve on Resolve implements ComplexEvent {
  Map<String, List<Type>> getResolveProtocols() {
    return super.getResolveProtocols()
      ..putIfAbsent('book', () => []).add(ComplexEventMessage);
  }

  Map<Type, List<Function>> resolveFunctionIterable() {
    return super.resolveFunctionIterable()
      ..[ComplexEventMessage] = [
        (args) => getContent(args[0], args[1], args[2]),
        (args) => getIndexs(args[0], args[1]),
        getInfo
      ];
  }
}

/// implements [ComplexEvent]
mixin ComplexEventMessager on SendEvent, Messager {
  String get book => 'book';
  Map<String, List<Type>> getProtocols() {
    return super.getProtocols()
      ..putIfAbsent(book, () => []).add(ComplexEventMessage);
  }

  FutureOr<RawContentLines?> getContent(
      int bookid, int contentid, bool update) {
    return sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update],
        serverName: book);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) {
    return sendMessage(ComplexEventMessage.getIndexs, [bookid, update],
        serverName: book);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return sendMessage(ComplexEventMessage.getInfo, id, serverName: book);
  }
}
