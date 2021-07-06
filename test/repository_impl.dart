import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:nop_db/nop_db.dart';
import 'package:shudu/event/base/book_event.dart';
import 'package:shudu/event/old/book_event_main.dart';
import 'package:shudu/event/event.dart';
import 'package:shudu/event/old/isolate_side.dart';
import 'package:shudu/utils/utils.dart';

class RepositoryImplTest extends Repository with SendEventMixin {
  @override
  void addInitCallback(Future<void> Function() callback) {}

  @override
  late BookEvent bookEvent = BookEventMain(this);

  late Server server;
  late Client client;

  @override
  Future<void> get initState async {
    client = Client(this)..init();
    server = Server()..init(client.sendSP);
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
}

class Client {
  Client(this.repositoryImpl);

  final SendEventMixin repositoryImpl;

  final client = StreamController();
  StreamSubscription? clientListen;

  void init() {
    clientListen = client.stream.listen((event) {
      if (repositoryImpl.add(event)) return;
      Log.e('messager error!!!');
    });
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
  void init(EventSink clientSP) {
    sp = clientSP;

    tranf?.cancel();
    tranf = receivePort.listen(_tran);

    bookEventIsolate = BookEventIsolateTest(receivePort.sendPort)..init();
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
  BookEventIsolateTest(SendPort sp) : super('', sp);
  @override
  bool remove(key) {
    if (key is KeyController) Log.e(key.keyType);
    return super.remove(key);
  }

  @override
  final String appPath = Directory.current.path;
  @override
  String get name => '';
}
