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
  insertOrUpdateZhangduIndex,
  getZdIndexsDbCacheItem,
  getZdAllBookId,
  getZhangduCacheBookId,
  getZhangduContentDb,
  getZhangduContentCid,
  insertOrUpdateZhangduContent,
  getZhangduIndexDb
}

abstract class ComplexOnDatabaseEventResolveMain extends ComplexOnDatabaseEvent
    with Resolve, ComplexOnDatabaseEventResolve {}

abstract class ComplexOnDatabaseEventMessagerMain extends ComplexOnDatabaseEvent
    with ComplexOnDatabaseEventMessager {}

mixin ComplexOnDatabaseEventResolve on Resolve, ComplexOnDatabaseEvent {
  late final _complexOnDatabaseEventResolveFuncList =
      List<DynamicCallback>.unmodifiable([
    _getIndexsDbCacheItem_0,
    _getAllBookId_1,
    _insertOrUpdateIndexs_2,
    _getContentDb_3,
    _getIndexsDb_4,
    _getBookCacheDb_5,
    _insertOrUpdateContent_6,
    _insertOrUpdateZhangduIndex_7,
    _getZdIndexsDbCacheItem_8,
    _getZdAllBookId_9,
    _getZhangduCacheBookId_10,
    _getZhangduContentDb_11,
    _getZhangduContentCid_12,
    _insertOrUpdateZhangduContent_13,
    _getZhangduIndexDb_14
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
  FutureOr<int?> _insertOrUpdateZhangduIndex_7(args) =>
      insertOrUpdateZhangduIndex(args[0], args[1]);
  FutureOr<List<ZhangduIndex>?> _getZdIndexsDbCacheItem_8(args) =>
      getZdIndexsDbCacheItem();
  FutureOr<Set<int>?> _getZdAllBookId_9(args) => getZdAllBookId();
  FutureOr<List<ZhangduCache>?> _getZhangduCacheBookId_10(args) =>
      getZhangduCacheBookId(args);
  FutureOr<List<String>?> _getZhangduContentDb_11(args) =>
      getZhangduContentDb(args[0], args[1]);
  FutureOr<int?> _getZhangduContentCid_12(args) => getZhangduContentCid(args);
  FutureOr<int?> _insertOrUpdateZhangduContent_13(args) =>
      insertOrUpdateZhangduContent(args);
  FutureOr<List<ZhangduChapterData>?> _getZhangduIndexDb_14(args) =>
      getZhangduIndexDb(args);
}

/// implements [ComplexOnDatabaseEvent]
mixin ComplexOnDatabaseEventMessager {
  SendEvent get sendEvent;

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

  FutureOr<int?> insertOrUpdateZhangduIndex(int bookId, String data) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.insertOrUpdateZhangduIndex,
        [bookId, data]);
  }

  FutureOr<List<ZhangduIndex>?> getZdIndexsDbCacheItem() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZdIndexsDbCacheItem, null);
  }

  FutureOr<Set<int>?> getZdAllBookId() {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZdAllBookId, null);
  }

  FutureOr<List<ZhangduCache>?> getZhangduCacheBookId(int bookId) {
    return sendEvent.sendMessage(
        ComplexOnDatabaseEventMessage.getZhangduCacheBookId, bookId);
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
}
