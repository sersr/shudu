import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../event/export.dart';
import 'content_notifier/export.dart';

export 'content_notifier/export.dart';

class ContentNotifier extends ChangeNotifier
    with
        ContentDataBase,
        ContentBrightness,
        ContentStatus,
        Configs,
        ContentRestore,
        ContentLayout,
        ContentLoad,
        ContentTasks,
        ContentAuto,
        ContentGetter,
        ContentEvent {
  ContentNotifier({required this.repository});

  @override
  final Repository repository;
}
