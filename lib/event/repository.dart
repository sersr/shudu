import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';

import 'base/book_event.dart';
import 'mixin/base/system_infos.dart';
import 'mixin/multi_Isolate_repository.dart';
import 'mixin/single_repository.dart';

abstract class Repository extends BookEventMessagerMain
    with SendInitCloseMixin, SystemInfos, SystemInfosPlus {
  Repository();
  final ValueNotifier<bool> _initStatus = ValueNotifier(false);

  ValueListenable<bool> get initStatus => _initStatus;
  late final BookEvent bookEvent = this;

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= MultiIsolateRepository();
    _instance ??= SingleRepository();
    return _instance!;
  }

  void notifiyStateRoot(bool init) {
    _initStatus.value = init;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }
}

abstract class RepositoryBase extends Repository
    with SendEventMixin, SendCacheMixin, SendIsolateMixin {
  @override
  void notifiyState(bool init) {
    notifiyStateRoot(init);
  }
}
