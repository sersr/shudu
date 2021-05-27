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

  late BookEvent bookEvent;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= BookRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  Future<T?> sendMessage<T>(dynamic type, dynamic args);

  Future<void> restartClient() async {
    await sendMessage(CustomMessage.restartClient, '');
  }

  // default
  ViewInsets get viewInsets => ViewInsets.zero;
  Future<ViewInsets> getViewInsets();
  int get bottomHeight;

  int level = 50;
  Future<int> get getBatteryLevel async => level;
}
