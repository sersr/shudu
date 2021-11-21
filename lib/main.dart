import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';

import 'event/base/type_adapter.dart';
import 'pages/app.dart';

void main() async {
  NopWidgetsFlutterBinding.ensureInitialized();
  uiStyle();
  uiOverlay(hide: false);

  /// TODO: 使用欢迎页面替代
  await getApplicationDocumentsDirectory().logi(false).then((appDir) {
    hiveInit(join(appDir.path, 'hive'));
  });

  runApp(const MulProvider(mode: ThemeMode.system));
}
