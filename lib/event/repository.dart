import 'package:flutter/foundation.dart';
import 'package:nop/nop.dart';
import 'package:useful_tools/change_notifier.dart';

import 'base/export.dart';
import 'mixin/base/system_infos.dart';
import 'mixin/multi_Isolate_repository.dart';
import 'mixin/single_repository.dart';

abstract class Repository extends BookMessagerMain
    with SendInitCloseMixin, NotifyStateMixin, SystemInfos {
  Repository();

  static Repository? _instance;

  factory Repository.create() {
    // 切换顺序使用
    _instance ??= MultiIsolateRepository();
    _instance ??= SingleRepository();
    return _instance!;
  }

  @visibleForTesting
  static void repositoryTest(Repository repository) {
    _instance ??= repository;
  }
}
