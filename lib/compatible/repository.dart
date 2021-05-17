import 'dart:isolate';

import 'package:bangs/bangs.dart';
import 'package:flutter/foundation.dart';
import '../data/data.dart';

import '../api/api.dart';
import 'book_event.dart';
import 'book_repository.dart';

abstract class Repository {
  Repository();

  String get dataPath;
  BookEvent get bookEvent;
  String get appPath;

  void addInitCallback(Future<void> Function() callback);
  Future<void> initState();
  void dipose();

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= BookRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  Future<String> saveImage(String img);
  // Future<String> getImageFromNet(String img);

  Future<T> sendMessage<T extends Object?>(dynamic type, dynamic args);
  Future<SearchList> searchWithKey(String key) async {
    var url = Api.searchUrl(key);
    return sendMessage(MessageType.searchWithKey, url);
  }

  Future<void> restartClient() async {
    await sendMessage(MessageType.restartClient, '');
  }

  // default
  ViewInsets get viewInsets => ViewInsets.zero;
  Future<ViewInsets> getViewInsets();
  int get bottomHeight;

  int level = 50;
  Future<int> getBatteryLevel() async => level;
}

enum MessageType {
  info,
  shudanDetail,
  indexs,
  content,
  shudan,
  bookList,
  mainList,
  restartClient,
  searchWithKey,
  saveImage,
  divText,
}
enum MessageDatabase {
  // database
  addBook,
  cacheinnerdb,
  deleteBook,
  deleteCache,
  loadBookInfo,
  loadFromDb,
  sendIndexs,
  updateBookIsTop,
  updateCname,
  updateMainInfo,
  load,
}

class IsolateSendMessage {
  IsolateSendMessage(this.type, this.args, this.sp);
  final dynamic type;
  final dynamic args;
  final SendPort sp;
}

enum Result {
  success,
  failed,
  error,
}

class IsolateReceiveMessage {
  IsolateReceiveMessage({required this.data, this.result = Result.success});
  final dynamic data;
  final Result result;
}
