import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';

import 'event/base/type_adapter.dart';
import 'pages/app.dart';
import 'provider/options_notifier.dart';

void main() {
  Log.logRun(() async {
    final style =
        TextStyle(fontSize: 15, color: Color.fromARGB(255, 187, 187, 187));
    Nav.snackBar(
      Container(
          color: Color.fromARGB(255, 61, 61, 61),
          height: 56,
          child: Center(child: Text('init!', style: style))),
      duration: const Duration(milliseconds: 1500),
      delayDuration: const Duration(milliseconds: 3000),
    );

    NopWidgetsFlutterBinding.ensureInitialized();

    uiStyle();
    uiOverlay(hide: false);
    try {
      if (kIsWeb) {
        hiveInit('shudu/hive');
      } else {
        await getApplicationDocumentsDirectory().then((appDir) {
          if (defaultTargetPlatform == TargetPlatform.windows) {
            hiveInit(join(appDir.path, 'shudu', 'hive'));
          } else {
            hiveInit(join(appDir.path, 'hive'));
          }
        });
      }
    } catch (e) {
      hiveInit('shudu/hive');
      Log.e('error: $e', onlyDebug: false);
    }

    Get.isLogEnable = false;
    Get.log = _emptyFunction;
    runApp(MulProvider(mode: await OptionsNotifier.getThemeModeUnSafe()));
  });
}

void _emptyFunction(String text, {bool isError = false}) {}
