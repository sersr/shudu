// import 'package:bangs/bangs.dart';
import 'package:flutter/foundation.dart';
import 'package:hot_fix/hot_fix.dart';
import 'package:memory_info/memory_info.dart';

import '../repository/book_repository_port.dart' show BookRepositoryPort;
import 'book_event.dart';

abstract class Repository {
  Repository();

  Future<void> get initState;

  DeferredMain? _hotFix;
  DeferredMain? get hotFix => _hotFix;
  void close();
  ValueNotifier<bool> get init;

  BookEvent get bookEvent;

  static Repository? _instance;

  factory Repository.create([DeferredMain? hot]) {
    _instance ??= BookRepositoryPort().._hotFix = hot;
    // _instance ??= BookRepository();

    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }
  ValueListenable<bool> get extenalStorage => throw UnimplementedError('测试未实现');
  int level = 50;
  Future<int> get getBatteryLevel async => level;
  bool get systemOverlaysAreVisible;
  void addSystemOverlaysListener(BoolCallback callback);
  void removeSystemOverlaysListener(BoolCallback callback);
  Future<Memory> getMemoryInfo();
}

typedef BoolCallback = void Function(bool visible);
