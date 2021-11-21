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
  getZhangduContent,
  updateZhangduMainStatus,
  getZhangduDetail,
  getZhangduIndex,
  getZhangduSameUsersBooks,
  getZhangduSearchData
}

abstract class BookEventResolveMain extends BookEvent
    with
        Resolve,
        CustomEventResolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexEventResolve,
        ZhangduDatabaseEventResolve,
        ZhangduComplexEventResolve {}

abstract class BookEventMessagerMain extends BookEvent
    with
        CustomEventMessager,
        BookCacheEventMessager,
        BookContentEventMessager,
        ComplexEventMessager,
        ZhangduDatabaseEventMessager,
        ZhangduComplexEventMessager {}

/// implements [CustomEvent]
mixin CustomEventDynamic {
  FutureOr<TransferType<Uint8List?>> getImageBytesDynamic(String img);
}
mixin CustomEventResolve on Resolve, CustomEvent implements CustomEventDynamic {
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

mixin BookCacheEventResolve on Resolve, BookCacheEvent {
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

mixin BookContentEventResolve on Resolve, BookContentEvent {
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

  Stream<List<BookContentDb>?> watchBookContentCid(int bookid) {
    return sendEvent.sendMessageStream(
        BookContentEventMessage.watchBookContentCid, bookid);
  }

  FutureOr<int?> deleteCache(int bookId) {
    return sendEvent.sendMessage(BookContentEventMessage.deleteCache, bookId);
  }
}

mixin ComplexEventResolve on Resolve, ComplexEvent {
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

mixin ZhangduDatabaseEventResolve on Resolve, ZhangduDatabaseEvent {
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

mixin ZhangduComplexEventResolve on Resolve, ZhangduComplexEvent {
  late final _zhangduComplexEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getZhangduContent_0,
    _updateZhangduMainStatus_1,
    _getZhangduDetail_2,
    _getZhangduIndex_3,
    _getZhangduSameUsersBooks_4,
    _getZhangduSearchData_5
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

  FutureOr<List<String>?> _getZhangduContent_0(args) =>
      getZhangduContent(args[0], args[1], args[2], args[3], args[4], args[5]);
  FutureOr<int?> _updateZhangduMainStatus_1(args) =>
      updateZhangduMainStatus(args);
  FutureOr<ZhangduDetailData?> _getZhangduDetail_2(args) =>
      getZhangduDetail(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndex_3(args) =>
      getZhangduIndex(args[0], args[1]);
  FutureOr<List<ZhangduSameUsersBooksData>?> _getZhangduSameUsersBooks_4(
          args) =>
      getZhangduSameUsersBooks(args);
  FutureOr<ZhangduSearchData?> _getZhangduSearchData_5(args) =>
      getZhangduSearchData(args[0], args[1], args[2]);
}

/// implements [ZhangduComplexEvent]
mixin ZhangduComplexEventMessager {
  SendEvent get sendEvent;

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

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId, bool update) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduIndex, [bookId, update]);
  }

  FutureOr<List<ZhangduSameUsersBooksData>?> getZhangduSameUsersBooks(
      String author) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduSameUsersBooks, author);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) {
    return sendEvent.sendMessage(
        ZhangduComplexEventMessage.getZhangduSearchData,
        [query, pageIndex, pageSize]);
  }
}
