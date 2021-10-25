// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:memory_info_platform_interface/model/memory.dart';
import 'package:nop_db/nop_db.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
// ignore: unused_import
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shudu/data/zhangdu/zhangdu_detail.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/event/base/book_event.dart';
import 'package:shudu/event/event.dart';
import 'package:useful_tools/common.dart';

class RepositoryImplTest extends Repository with SendEventPortMixin {
  @override
  late BookEvent bookEvent = BookEventMain(this);

  late Server server;
  late Client client;

  @override
  Future<void> get initState async {
    client = Client(this)..init();
    server = Server();
    SqfliteMainIsolate.initMainDb();
    return server.init(client.sendSP);
  }

  @override
  void send(message) {
    server.send(message);
  }

  @override
  void dispose() {
    super.dispose();
    server.close();
  }

  @override
  void addSystemOverlaysListener(BoolCallback callback) {}

  @override
  void removeSystemOverlaysListener(BoolCallback callback) {}

  @override
  bool get systemOverlaysAreVisible => throw UnimplementedError();

  @override
  ValueNotifier<bool> get init => throw UnimplementedError();

  @override
  void close() {}

  @override
  Future<Memory> getMemoryInfo() {
    // TODO: implement getMemoryInfo
    throw UnimplementedError();
  }
}

class Client {
  Client(this.repositoryImpl);

  final SendEventPortMixin repositoryImpl;

  final client = StreamController();
  StreamSubscription? clientListen;

  void init() {
    // clientListen = client.stream.listen((event) {
    //   if (repositoryImpl.add(event)) return;
    //   Log.e('messager error!!!');
    // });
  }

  EventSink get sendSP => client.sink;
}

class Server {
  final server = StreamController(sync: true);
  StreamSubscription? serverListen;

  late EventSink sp;

  void send(data) {
    server.add(data);
  }

  final receivePort = ReceivePort();
  StreamSubscription? tranf;
  void _tran(data) {
    sp.add(data);
  }

  late BookEventIsolate bookEventIsolate;
  Future<void> init(EventSink clientSP) async {
    sp = clientSP;

    tranf?.cancel();
    tranf = receivePort.listen(_tran);

    bookEventIsolate = BookEventIsolateTest(receivePort.sendPort);
    await bookEventIsolate.db.initDb();
    await bookEventIsolate.netEventInit();
    serverListen?.cancel();
    serverListen = server.stream.listen((event) {
      if (bookEventIsolate.resolve(event)) return;
    });
  }

  void close() {
    serverListen?.cancel();
  }
}

class BookEventIsolateTest extends BookEventIsolate {
  BookEventIsolateTest(SendPort sp) : super(sp, '', '', false, true);
  @override
  bool remove(key) {
    if (key is KeyController) Log.e(key.keyType);
    return super.remove(key);
  }

  @override
  final String cachePath = Directory.current.path;
  @override
  final String appPath = Directory.current.path;
  @override
  String get name => '';

  @override
  FutureOr<int?> deleteZhangduBook(int bookId) {
    // TODO: implement deleteZhangduBook
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    // TODO: implement deleteZhangduContentCache
    throw UnimplementedError();
  }

  @override
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    // TODO: implement getZhangduContent
    throw UnimplementedError();
  }

  @override
  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    // TODO: implement getZhangduDetail
    throw UnimplementedError();
  }

  @override
  FutureOr<ZhangduIndex?> getZhangduIndexs(int bookId) {
    // TODO: implement getZhangduIndexs
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    // TODO: implement getZhangduMainList
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    // TODO: implement insertZhangduBook
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    // TODO: implement updateZhangduBook
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    // TODO: implement updateZhangduMainStatus
    throw UnimplementedError();
  }

  @override
  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    // TODO: implement watchZhangduContentCid
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    // TODO: implement watchZhangduCurrentCid
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    // TODO: implement watchZhangduMainList
    throw UnimplementedError();
  }
}
