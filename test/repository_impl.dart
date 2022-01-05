// ignore_for_file: overridden_fields

import 'dart:async';
import 'dart:io';

import 'package:nop_db/nop_db.dart';
import 'package:shudu/data/zhangdu/zhangdu_detail.dart';
import 'package:shudu/database/nop_database.dart';
import 'package:shudu/event/base/export.dart';
import 'package:shudu/event/mixin/single_repository.dart';
import 'package:utils/utils.dart';

class RepositoryImplTest extends BookEventMessagerMain
    with SendCacheMixin, SendEventPortMixin {
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
}

class Client {
  Client(this.repositoryImpl);

  final SendEventPortMixin repositoryImpl;

  final client = ReceiveHandle();

  SendHandle get sendHandle => client.sendHandle;
}

class Server {
  final serverHandle = ReceiveHandle();

  void send(data) {
    sendHandle.send(data);
  }

  SendHandle get sendHandle => serverHandle.sendHandle;

  late BookEventIsolate bookEventIsolate;
  Future<void> init() async {
    bookEventIsolate = BookEventIsolateTest(serverHandle.sendHandle);
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

class BookEventIsolateTest extends BookEventIsolate {
  BookEventIsolateTest(SendHandle sp)
      : super(
            remoteSendHandle: sp,
            appPath: '../test/repository',
            cachePath: '../test/cache');

  @override
  bool remove(key) {
    if (key is KeyController) Log.e(key.keyType);
    return super.remove(key);
  }

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
