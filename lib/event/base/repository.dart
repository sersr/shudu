import 'package:bangs/bangs.dart';
import 'package:flutter/foundation.dart';

// ignore: unused_import
import '../repository/book_repository.dart' show BookRepository;
// ignore: unused_import
import '../repository/book_repository_port.dart' show BookRepositoryPort;
import 'book_event.dart';

abstract class Repository {
  Repository();

  // void addInitCallback(Future<void> Function() callback);
  Future<void> get initState;
  void dispose();

  BookEvent get bookEvent;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= BookRepositoryPort();
    // _instance ??= BookRepository();

    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  // default
  ViewInsets get viewInsets => ViewInsets.zero;
  Future<ViewInsets> get getViewInsets async => viewInsets;
  int get bottomHeight => 0;

  int level = 50;
  Future<int> get getBatteryLevel async => level;
}
