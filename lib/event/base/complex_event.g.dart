// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complex_event.dart';

// **************************************************************************
// Generator: IsolateEventGeneratorForAnnotation
// **************************************************************************

// ignore_for_file: annotate_overrides

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

abstract class ComplexOnDatabaseEventResolveMain extends ComplexOnDatabaseEvent
    with Resolve, ComplexOnDatabaseEventResolve {}

abstract class ComplexOnDatabaseEventMessagerMain extends ComplexOnDatabaseEvent
    with ComplexOnDatabaseEventMessager {}

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
mixin ComplexOnDatabaseEventMessager {
  SendEvent get sendEvent;
  SendEvent get complexOnDatabaseEventSendEvent => sendEvent;

  FutureOr<List<BookIndex>?> getIndexsDbCacheItem() {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDbCacheItem, null);
  }

  FutureOr<Set<int>?> getAllBookId() {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getAllBookId, null);
  }

  FutureOr<int?> insertOrUpdateIndexs(int id, String indexs) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateIndexs, [id, indexs]);
  }

  FutureOr<List<BookContentDb>?> getContentDb(int bookid, int contentid) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getContentDb, [bookid, contentid]);
  }

  FutureOr<List<BookIndex>?> getIndexsDb(int bookid) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getIndexsDb, bookid);
  }

  FutureOr<List<BookCache>?> getBookCacheDb(int bookid) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getBookCacheDb, bookid);
  }

  FutureOr<int?> insertOrUpdateContent(BookContentDb contentDb) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateContent, contentDb);
  }

  FutureOr<int?> insertOrUpdateBook(BookInfo data) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateBook, data);
  }

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduIndex,
        [bookId, data]);
  }

  FutureOr<List<String>?> getZhangduContentDb(int bookId, int contentId) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentDb, [bookId, contentId]);
  }

  FutureOr<int?> getZhangduContentCid(int bookid) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduContentCid, bookid);
  }

  FutureOr<int?> insertOrUpdateZhangduContent(ZhangduContent content) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduContent, content);
  }

  FutureOr<List<ZhangduChapterData>?> getZhangduIndexDb(int bookId) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduIndexDb, bookId);
  }

  FutureOr<void> insertOrUpdateZhangduBook(
      int bookId, int firstChapterId, ZhangduDetailData data) {
    return complexOnDatabaseEventSendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduBook,
        [bookId, firstChapterId, data]);
  }
}
