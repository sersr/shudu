import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';
import 'package:flutter_nop/change_notifier.dart';
import 'package:flutter_nop/nop_state.dart';

import 'base/export.dart';
import 'mixin/base/system_infos.dart';
import 'mixin/multi_Isolate_repository.dart';

abstract class Repository extends MultiBookMessagerMain
    with
        BookEvent,
        SendInitCloseMixin,
        NotifyStateMixin,
        SystemInfos,
        NopLifeCycle {
  Repository();

  static Repository? _instance;

  factory Repository.create() {
    _instance ??= MultiIsolateRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }

  @override
  void nopInit() {
    super.nopInit();
    init();
  }
}
