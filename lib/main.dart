import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';
import 'event/base/type_adapter.dart';
import 'pages/app.dart';
import 'package:get/get.dart';

import 'provider/options_notifier.dart';

void main() async {
  NopWidgetsFlutterBinding.ensureInitialized();
  uiStyle();
  uiOverlay(hide: false);
  try {
    if (kIsWeb) {
      hiveInit('shudu/hive');
    } else {
      await getApplicationDocumentsDirectory().logi(false).then((appDir) {
        hiveInit(join(appDir.path, 'hive'));
      });
    }
  } catch (e) {
    hiveInit('shudu/hive');
    Log.e('error: $e', onlyDebug: false);
  }

  Get.log = _defaultLog;
  final mode = await OptionsNotifier.getThemeModeUnSafe();

  runApp(MulProvider(mode: mode));
}

void _defaultLog(String message, {bool isError = false}) {}
    // Log.log(Log.info, message, stackTrace: StackTrace.current);
