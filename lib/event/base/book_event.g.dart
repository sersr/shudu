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
mixin CustomEventMessager {
  SendEvent get sendEvent;
  SendEvent get customEventSendEvent => sendEvent;

  FutureOr<SearchList?> getSearchData(String key) {
    return customEventSendEvent.sendMessage(
        CustomEventMessage.getSearchData, key);
  }

  FutureOr<Uint8List?> getImageBytes(String img) {
    return customEventSendEvent.sendMessage(
        CustomEventMessage.getImageBytes, img);
  }

  FutureOr<List<BookList>?> getHiveShudanLists(String c) {
    return customEventSendEvent.sendMessage(
        CustomEventMessage.getHiveShudanLists, c);
  }

  FutureOr<List<BookList>?> getShudanLists(String c, int index) {
    return customEventSendEvent
        .sendMessage(CustomEventMessage.getShudanLists, [c, index]);
  }

  FutureOr<BookTopData?> getTopLists(String c, String date, int index) {
    return customEventSendEvent
        .sendMessage(CustomEventMessage.getTopLists, [c, date, index]);
  }

  FutureOr<BookTopData?> getCategLists(int c, String date, int index) {
    return customEventSendEvent
        .sendMessage(CustomEventMessage.getCategLists, [c, date, index]);
  }

  FutureOr<BookListDetailData?> getShudanDetail(int index) {
    return customEventSendEvent.sendMessage(
        CustomEventMessage.getShudanDetail, index);
  }

  FutureOr<List<BookCategoryData>?> getCategoryData() {
    return customEventSendEvent.sendMessage(
        CustomEventMessage.getCategoryData, null);
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
mixin BookCacheEventMessager {
  SendEvent get sendEvent;
  SendEvent get bookCacheEventSendEvent => sendEvent;

  FutureOr<List<BookCache>?> getMainList() {
    return bookCacheEventSendEvent.sendMessage(
        BookCacheEventMessage.getMainList, null);
  }

  Stream<List<BookCache>?> watchMainList() {
    return bookCacheEventSendEvent.sendMessageStream(
        BookCacheEventMessage.watchMainList, null);
  }

  FutureOr<int?> updateBook(int id, BookCache book) {
    return bookCacheEventSendEvent
        .sendMessage(BookCacheEventMessage.updateBook, [id, book]);
  }

  FutureOr<int?> insertBook(BookCache bookCache) {
    return bookCacheEventSendEvent.sendMessage(
        BookCacheEventMessage.insertBook, bookCache);
  }

  FutureOr<int?> deleteBook(int id) {
    return bookCacheEventSendEvent.sendMessage(
        BookCacheEventMessage.deleteBook, id);
  }

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return bookCacheEventSendEvent.sendMessageStream(
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
mixin BookContentEventMessager {
  SendEvent get sendEvent;
  SendEvent get bookContentEventSendEvent => sendEvent;

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return bookContentEventSendEvent.sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return bookContentEventSendEvent.sendMessage(
        BookContentEventMessage.deleteCache, bookId);
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
mixin ComplexEventMessager {
  SendEvent get sendEvent;
  SendEvent get complexEventSendEvent => sendEvent;

  FutureOr<List<CacheItem>?> getCacheItems() {
    return complexEventSendEvent.sendMessage(
        ComplexEventMessage.getCacheItems, null);
  }

  FutureOr<RawContentLines?> getContent(
      int bookid, int contentid, bool update) {
    return complexEventSendEvent.sendMessage(
        ComplexEventMessage.getContent, [bookid, contentid, update]);
  }

  FutureOr<NetBookIndex?> getIndexs(int bookid, bool update) {
    return complexEventSendEvent
        .sendMessage(ComplexEventMessage.getIndexs, [bookid, update]);
  }

  FutureOr<int?> updateBookStatus(int id) {
    return complexEventSendEvent.sendMessage(
        ComplexEventMessage.updateBookStatus, id);
  }

  FutureOr<BookInfoRoot?> getInfo(int id) {
    return complexEventSendEvent.sendMessage(ComplexEventMessage.getInfo, id);
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
mixin ZhangduDatabaseEventMessager {
  SendEvent get sendEvent;
  SendEvent get zhangduDatabaseEventSendEvent => sendEvent;

  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    return zhangduDatabaseEventSendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduContentCache, bookId);
  }

  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    return zhangduDatabaseEventSendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduContentCid, bookId);
  }

  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    return zhangduDatabaseEventSendEvent.sendMessage(
        ZhangduDatabaseEventMessage.getZhangduMainList, null);
  }

  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return zhangduDatabaseEventSendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduMainList, null);
  }

  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    return zhangduDatabaseEventSendEvent.sendMessage(
        ZhangduDatabaseEventMessage.updateZhangduBook, [bookId, book]);
  }

  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    return zhangduDatabaseEventSendEvent.sendMessage(
        ZhangduDatabaseEventMessage.insertZhangduBook, book);
  }

  FutureOr<int?> deleteZhangduBook(int bookId) {
    return zhangduDatabaseEventSendEvent.sendMessage(
        ZhangduDatabaseEventMessage.deleteZhangduBook, bookId);
  }

  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    return zhangduDatabaseEventSendEvent.sendMessageStream(
        ZhangduDatabaseEventMessage.watchZhangduCurrentCid, bookId);
  }

  FutureOr<List<CacheItem>?> getZhangduCacheItems() {
    return zhangduDatabaseEventSendEvent.sendMessage(
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
mixin ZhangduComplexEventMessager {
  SendEvent get sendEvent;
  SendEvent get zhangduComplexEventSendEvent => sendEvent;

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    return zhangduComplexEventSendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduIndex, [bookId, update]);
  }

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    return zhangduComplexEventSendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update]);
  }

  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    return zhangduComplexEventSendEvent.sendMessage(
        ZhangduComplexEventMessage.updateZhangduMainStatus, bookId);
  }

  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    return zhangduComplexEventSendEvent.sendMessage(
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
mixin ZhangduNetEventMessager {
  SendEvent get sendEvent;
  SendEvent get zhangduNetEventSendEvent => sendEvent;

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    return zhangduNetEventSendEvent.sendMessage(
        ZhangduNetEventMessage.getZhangduSameUsersBooks, author);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    return zhangduNetEventSendEvent.sendMessage(
        ZhangduNetEventMessage.getZhangduSearchData,
        [query, pageIndex, pageSize]);
  }
}
