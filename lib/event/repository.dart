import 'package:bangs/bangs.dart';
import 'package:flutter/foundation.dart';

import 'book_event.dart';
import 'book_repository.dart';
import 'messages.dart';

abstract class Repository {
  Repository();

  void addInitCallback(Future<void> Function() callback);
  Future<void> initState();
  void dipose();

  String get dataPath;
  String get appPath;

  late BookEvent bookEvent;

  CustomEvent get customEvent => bookEvent;
  DatabaseEvent get databaseEvent => bookEvent;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= BookRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  Future<T> sendMessage<T extends Object?>(dynamic type, dynamic args);

  Future<void> restartClient() async {
    await sendMessage(CustomMessage.restartClient, '');
  }

  // default
  ViewInsets get viewInsets => ViewInsets.zero;
  Future<ViewInsets> getViewInsets();
  int get bottomHeight;

  int level = 50;
  Future<int> getBatteryLevel() async => level;
}
