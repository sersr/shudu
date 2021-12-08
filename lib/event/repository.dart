import 'package:flutter/foundation.dart';
import 'package:nop_db/nop_db.dart';
import 'package:useful_tools/change_notifier.dart';

import 'base/book_event.dart';
import 'mixin/base/system_infos.dart';
import 'mixin/multi_Isolate_repository.dart';
import 'mixin/single_repository.dart';

abstract class Repository extends BookEventMessagerMain
    with SendInitCloseMixin, NotifyStateMixin, SystemInfos {
  Repository();

  late final BookEvent bookEvent = this;

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
