// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:nop_db/database/nop_impl/sqflite_main_isolate.dart';
import 'package:nop_db/nop_db.dart';
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
  ValueNotifier<double> get safeBottom => ValueNotifier(0);

  @override
  ValueNotifier<bool> get init => throw UnimplementedError();

  @override
  void close() {}
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
}
