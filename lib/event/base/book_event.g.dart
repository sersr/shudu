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
  getCacheItems,
  getContent,
  getIndexs,
  updateBookStatus,
  getInfo,
  getZhangduContent,
  deleteZhangduContentCache,
  watchZhangduContentCid,
  getZhangduSearchData,
  updateZhangduMainStatus,
  getZhangduMainList,
  watchZhangduMainList,
  updateZhangduBook,
  insertZhangduBook,
  deleteZhangduBook,
  watchZhangduCurrentCid,
  getZhangduDetail,
  getZhangduIndexDb,
  getZhangduIndex
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
enum ZhangduEventMessage {
  getZhangduContent,
  deleteZhangduContentCache,
  watchZhangduContentCid,
  getZhangduSearchData,
  updateZhangduMainStatus,
  getZhangduMainList,
  watchZhangduMainList,
  updateZhangduBook,
  insertZhangduBook,
  deleteZhangduBook,
  watchZhangduCurrentCid,
  getZhangduDetail,
  getZhangduIndexDb,
  getZhangduIndex
}

abstract class BookEventResolveMain extends BookEvent
    with
        Resolve,
        CustomEventResolve,
        DatabaseEventResolve,
        BookCacheEventResolve,
        BookContentEventResolve,
        ComplexEventResolve,
        ZhangduEventResolve {
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
        ComplexEventMessager,
        ZhangduEventMessager {}

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
    _getMainList_0,
    _watchMainList_1,
    _updateBook_2,
    _insertBook_3,
    _deleteBook_4,
    _watchCurrentCid_5
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

  FutureOr<List<BookCache>?> getMainList() async {
    return sendEvent.sendMessage(BookCacheEventMessage.getMainList, null);
  }

  Stream<List<BookCache>?> watchMainList() {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchMainList, null);
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

  Stream<List<BookCache>?> watchCurrentCid(int id) {
    return sendEvent.sendMessageStream(
        BookCacheEventMessage.watchCurrentCid, id);
  }
}

mixin BookContentEventResolve on Resolve, BookContentEvent {
  late final _bookContentEventResolveFuncList =
      List<DynamicCallback>.unmodifiable(
          [_watchBookContentCid_0, _deleteCache_1]);

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
    _getCacheItems_0,
    _getContent_1,
    _getIndexs_2,
    _updateBookStatus_3,
    _getInfo_4
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

  FutureOr<List<CacheItem>?> _getCacheItems_0(args) => getCacheItems();
  dynamic _getContent_1(args) => getContentDynamic(args[0], args[1], args[2]);
  FutureOr<NetBookIndex?> _getIndexs_2(args) => getIndexs(args[0], args[1]);
  FutureOr<int?> _updateBookStatus_3(args) => updateBookStatus(args);
  FutureOr<BookInfoRoot?> _getInfo_4(args) => getInfo(args);
}

/// implements [ComplexEvent]
mixin ComplexEventMessager {
  SendEvent get sendEvent;

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

mixin ZhangduEventResolve on Resolve, ZhangduEvent {
  late final _zhangduEventResolveFuncList = List<DynamicCallback>.unmodifiable([
    _getZhangduContent_0,
    _deleteZhangduContentCache_1,
    _watchZhangduContentCid_2,
    _getZhangduSearchData_3,
    _updateZhangduMainStatus_4,
    _getZhangduMainList_5,
    _watchZhangduMainList_6,
    _updateZhangduBook_7,
    _insertZhangduBook_8,
    _deleteZhangduBook_9,
    _watchZhangduCurrentCid_10,
    _getZhangduDetail_11,
    _getZhangduIndexDb_12,
    _getZhangduIndex_13
  ]);

  @override
  bool resolve(resolveMessage) {
    if (resolveMessage is IsolateSendMessage) {
      final type = resolveMessage.type;
      if (type is ZhangduEventMessage) {
        dynamic result;
        try {
          result = _zhangduEventResolveFuncList
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
  FutureOr<int?> _deleteZhangduContentCache_1(args) =>
      deleteZhangduContentCache(args);
  Stream<List<int>?> _watchZhangduContentCid_2(args) =>
      watchZhangduContentCid(args);
  FutureOr<ZhangduSearchData?> _getZhangduSearchData_3(args) =>
      getZhangduSearchData(args[0], args[1], args[2]);
  FutureOr<int?> _updateZhangduMainStatus_4(args) =>
      updateZhangduMainStatus(args);
  FutureOr<List<ZhangduCache>?> _getZhangduMainList_5(args) =>
      getZhangduMainList();
  Stream<List<ZhangduCache>?> _watchZhangduMainList_6(args) =>
      watchZhangduMainList();
  FutureOr<int?> _updateZhangduBook_7(args) =>
      updateZhangduBook(args[0], args[1]);
  FutureOr<int?> _insertZhangduBook_8(args) => insertZhangduBook(args);
  FutureOr<int?> _deleteZhangduBook_9(args) => deleteZhangduBook(args);
  Stream<List<ZhangduCache>?> _watchZhangduCurrentCid_10(args) =>
      watchZhangduCurrentCid(args);
  FutureOr<ZhangduDetailData?> _getZhangduDetail_11(args) =>
      getZhangduDetail(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndexDb_12(args) =>
      getZhangduIndexDb(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndex_13(args) =>
      getZhangduIndex(args);
}

/// implements [ZhangduEvent]
mixin ZhangduEventMessager {
  SendEvent get sendEvent;

  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) async {
    return sendEvent.sendMessage(ZhangduEventMessage.getZhangduContent,
        [bookId, contentId, contentUrl, name, sort, update]);
  }

  FutureOr<int?> deleteZhangduContentCache(int bookId) async {
    return sendEvent.sendMessage(
        ZhangduEventMessage.deleteZhangduContentCache, bookId);
  }

  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduEventMessage.watchZhangduContentCid, bookId);
  }

  FutureOr<ZhangduSearchData?> getZhangduSearchData(
      String query, int pageIndex, int pageSize) async {
    return sendEvent.sendMessage(
        ZhangduEventMessage.getZhangduSearchData, [query, pageIndex, pageSize]);
  }

  FutureOr<int?> updateZhangduMainStatus(int bookId) async {
    return sendEvent.sendMessage(
        ZhangduEventMessage.updateZhangduMainStatus, bookId);
  }

  FutureOr<List<ZhangduCache>?> getZhangduMainList() async {
    return sendEvent.sendMessage(ZhangduEventMessage.getZhangduMainList, null);
  }

  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    return sendEvent.sendMessageStream(
        ZhangduEventMessage.watchZhangduMainList, null);
  }

  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) async {
    return sendEvent
        .sendMessage(ZhangduEventMessage.updateZhangduBook, [bookId, book]);
  }

  FutureOr<int?> insertZhangduBook(ZhangduCache book) async {
    return sendEvent.sendMessage(ZhangduEventMessage.insertZhangduBook, book);
  }

  FutureOr<int?> deleteZhangduBook(int bookId) async {
    return sendEvent.sendMessage(ZhangduEventMessage.deleteZhangduBook, bookId);
  }

  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    return sendEvent.sendMessageStream(
        ZhangduEventMessage.watchZhangduCurrentCid, bookId);
  }

  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) async {
    return sendEvent.sendMessage(ZhangduEventMessage.getZhangduDetail, bookId);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) async {
    return sendEvent.sendMessage(ZhangduEventMessage.getZhangduIndexDb, bookId);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndex(int bookId) async {
    return sendEvent.sendMessage(ZhangduEventMessage.getZhangduIndex, bookId);
  }
}
