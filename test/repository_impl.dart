// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:nop/nop.dart';
import 'package:shudu/event/base/export.dart';
import 'package:shudu/event/mixin/base/export.dart';
import 'package:shudu/event/mixin/base/system_infos.dart';
import 'package:shudu/event/mixin/multi_isolate_repository.dart';

class RepositoryImplTest extends MultiBookMessagerMain
    with SendCacheMixin, SendEventPortStreamMixin {
  RepositoryImplTest();
  late Server server;
  late Client client;

  Future<void> get initRepository async {
    client = Client(this);
    server = Server();

    final remoteSendHandle = server.sendHandle;
    sendPortOwner = SendHandleOwner(
        localSendHandle: remoteSendHandle, remoteSendHandle: client.sendHandle);
    return server.init();
  }

  @override
  void dispose() {
    super.dispose();
    server.close();
  }

  SendHandleOwner? sendPortOwner;

  @override
  SendHandleOwner? getSendHandleOwner(key) {
    return sendPortOwner ?? super.getSendHandleOwner(key);
  }

  @override
  RemoteServer get bookRemoteServer => NullRemoteServer();

  @override
  RemoteServer get databaseRemoteServer => NullRemoteServer();
}

class Client {
  Client(this.repositoryImpl);

  final SendEventMixin repositoryImpl;

  final client = ReceiveHandle();

  SendHandle get sendHandle => client.sendHandle;
}

class Server {
  final serverHandle = ReceiveHandle();

  void send(data) {
    sendHandle.send(data);
  }

  SendHandle get sendHandle => serverHandle.sendHandle;

  late BookEventIsolateTest bookEventIsolate;
  Future<void> init() async {
    final configs = ServerConfigurations(
        args: BookIsolateArgs('../test/repository', '../test/cache'),
        sendHandle: sendHandle);
    bookEventIsolate = BookEventIsolateTest(configs);
    final list = <Future>[];
    bookEventIsolate.initStateListen((task) {
      if (task is Future) {
        list.add(task);
      }
    });
    await Future.wait(list);

    serverHandle.listen((event) {
      if (bookEventIsolate.listen(event)) return;
    });
  }

  void close() {
    serverHandle.close();
  }
}

class BookEventIsolateTest extends BookEventMultiIsolate
    with
        BookCacheEventResolve,
        BookContentEventResolve,
        ServerEventResolve,
        // 覆盖掉 messager
        DatabaseMixin,
        ComplexOnDatabaseMixin {
  BookEventIsolateTest(ServerConfigurations<BookIsolateArgs> configurations)
      : super(configurations: configurations);

  @override
  bool remove(key) {
    if (key is KeyController) Log.e(key.keyType);
    return super.remove(key);
  }

  @override
  String get name => '';
}
