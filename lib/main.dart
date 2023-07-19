import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:nop/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';

import 'app.dart';
import 'event/repository.dart';
import 'modules/book_content.dart';
import 'modules/book_content/import.dart';
import 'modules/book_index.dart';
import 'modules/home.dart';
import 'modules/search.dart';
import 'modules/setting/providers/options_notifier.dart';
import 'modules/setting/setting.dart';
import 'modules/text_style/text_style.dart';
import 'routes/routes.dart';
import 'utils/type_adapter.dart';

void main() {
  Log.logRun(() async {
    // 异步
    // final style =
    //     TextStyle(fontSize: 15, color: Color.fromARGB(255, 187, 187, 187));
    // Nav.snackBar(
    //   Container(
    //       color: Color.fromARGB(255, 61, 61, 61),
    //       height: 56,
    //       child: Center(child: Text('init!', style: style))),
    //   duration: const Duration(milliseconds: 1500),
    //   delayDuration: const Duration(milliseconds: 3000),
    // );

    Routes.init(observers: [Nav.observer]);

    router.put(() => Repository.create());
    router.put(() => OptionsNotifier());
    router.put(() => BookIndexNotifier());
    router.put(() => SearchNotifier());
    router.put(() => ContentNotifier());
    router.put(() => BookCacheNotifier());
    router.put(() => TextStyleConfig());
    router.put(() => RestorationContent());
    router.put(() => ContentViewConfigProvider());
    router.grass<Repository>();

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

    assert(() {
      final reg = RegExp(r'\((package:)(.+?)/(.*)');
      Log.logPathFn = (path) {
        final newPath = path.replaceFirstMapped(reg, (match) {
          final package = match[2];
          if (package == 'shudu') {
            return '(./lib/${match[3]}';
          }

          return '';
        });
        if (newPath.isEmpty) {
          return null;
        }
        return newPath;
      };
      return true;
    }());

    /// 全局变量，初始化配置
    await router.grass<ContentViewConfigProvider>().initConfigs();

    runApp(ShuduApp(mode: await OptionsNotifier.getThemeModeUnSafe()));
  });
}
