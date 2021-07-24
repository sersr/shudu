import 'dart:ui';

import 'package:bangs/bangs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// ignore: unused_import
import '../repository/book_repository.dart' show BookRepository;
// ignore: unused_import
import '../repository/book_repository_port.dart' show BookRepositoryPort;
import 'book_event.dart';

abstract class Repository {
  Repository();

  Future<void> get initState;
  void dispose();

  BookEvent get bookEvent;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= BookRepositoryPort();
    // _instance ??= BookRepository();

    return _instance!;
  }
 ValueNotifier<double> get safeBottom;
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
  bool get systemOverlaysAreVisible;
  void addSystemOverlaysListener(BoolCallback callback);
  void removeSystemOverlaysListener(BoolCallback callback);
}

typedef BoolCallback = void Function(bool visible);
