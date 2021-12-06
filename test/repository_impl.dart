// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:nop_db_sqflite/nop_db_sqflite.dart';
import 'package:shudu/data/zhangdu/zhangdu_detail.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/event/base/book_event.dart';
import 'package:shudu/event/event.dart';
import 'package:shudu/event/mixin/single_repository.dart';
import 'package:utils/utils.dart';

class RepositoryTest extends Repository
    with SendEvent, SendCacheMixin, SendEventMixin, SendIsolateMixin {
  @override
  Future<Isolate> onCreateIsolate(SendPort sdPort) async {
    final newIsolate = await Isolate.spawn(singleIsolateEntryPoint,
        [sdPort, './app', './app/cache', false, false]);
    return newIsolate;
  }
}

class RepositoryImplTest extends BookEventMessagerMain with SendEventPortMixin {
  RepositoryImplTest(this.useSqflite);
  late Server server;
  late Client client;
  final bool useSqflite;

  Future<void> get initRepository async {
    client = Client(this);
    server = Server();
    if (useSqflite) {
      SqfliteMainIsolate.initMainDb();
    }
    final sendPort = server.receivePort.sendPort;
    sendPortOwner =
        SendPortOwner(localSendPort: sendPort, remoteSendPort: sendPort);
    return server.init(client.sendSP, useSqflite);
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
  late final SendEvent sendEvent = this;

  SendPortOwner? sendPortOwner;

  @override
  SendPortOwner? getSendPortOwner(key) {
    return sendPortOwner ?? super.getSendPortOwner(key);
  }
}

class Client {
  Client(this.repositoryImpl);

  final SendEventPortMixin repositoryImpl;

  final client = StreamController();
  StreamSubscription? clientListen;

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
  Future<void> init(EventSink clientSP, bool useSqflite) async {
    sp = clientSP;

    tranf?.cancel();
    tranf = receivePort.listen(_tran);

    bookEventIsolate =
        BookEventIsolateTest(receivePort.sendPort, useSqflite: useSqflite);
    final list = <Future>[];
    bookEventIsolate.initStateListen((task) {
      if (task is Future) {
        list.add(task);
      }
    });
    await Future.wait(list);

    serverListen?.cancel();
    serverListen = server.stream.listen((event) {
      if (bookEventIsolate.listen(event)) return;
    });
  }

  void close() {
    serverListen?.cancel();
  }
}

class BookEventIsolateTest extends BookEventIsolate {
  BookEventIsolateTest(SendPort sp, {bool useSqflite = false})
      : super(
            remoteSendPort: sp,
            appPath: '',
            cachePath: '',
            useSqflite3: useSqflite);

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
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> deleteZhangduContentCache(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<String>?> getZhangduContent(int bookId, int contentId,
      String contentUrl, String name, int sort, bool update) {
    throw UnimplementedError();
  }

  @override
  FutureOr<ZhangduDetailData?> getZhangduDetail(int bookId) {
    throw UnimplementedError();
  }

  @override
  FutureOr<List<ZhangduCache>?> getZhangduMainList() {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> insertZhangduBook(ZhangduCache book) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduBook(int bookId, ZhangduCache book) {
    throw UnimplementedError();
  }

  @override
  FutureOr<int?> updateZhangduMainStatus(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<int>?> watchZhangduContentCid(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduCurrentCid(int bookId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<ZhangduCache>?> watchZhangduMainList() {
    throw UnimplementedError();
  }
}
