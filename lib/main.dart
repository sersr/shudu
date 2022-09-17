import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nop/utils.dart';
import 'package:nop_flutter/nop_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:useful_tools/useful_tools.dart';

import 'app.dart';
import 'event/repository.dart';
import 'modules/book_content.dart';
import 'modules/book_index.dart';
import 'modules/home.dart';
import 'modules/search.dart';
import 'modules/setting/providers/options_notifier.dart';
import 'modules/setting/setting.dart';
import 'modules/text_style/text_style.dart';
import 'utils/type_adapter.dart';

void main() {
  OneFile.runZoned(() => Log.logRun(() async {
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

        NopWidgetsFlutterBinding.ensureInitialized();
        Nav.put(() => Repository.create());
        Nav.put(() => OptionsNotifier());
        Nav.put(() => BookIndexNotifier());
        Nav.put(() => SearchNotifier());
        Nav.put(() => ContentNotifier());
        Nav.put(() => BookCacheNotifier());
        Nav.put(() => TextStyleConfig());

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

        runApp(Nop(
            // 提供 Nop.of 支持
            child: ShuduApp(mode: await OptionsNotifier.getThemeModeUnSafe())));
      }));
}
