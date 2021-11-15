import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hot_fix/hot_fix.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../event/event.dart';
import '../provider/provider.dart';
import 'home/home_page.dart';

class ShuduApp extends StatelessWidget {
  const ShuduApp({Key? key, required this.mode}) : super(key: key);
  final ThemeMode mode;
  @override
  Widget build(BuildContext context) {
    return Selector<OptionsNotifier, List>(
      selector: (context, opt) {
        return [
          opt.options.themeMode,
          opt.options.platform,
          opt.options.showPerformanceOverlay,
        ];
      },
      builder: (context, list, _) {
        //TODO: 国际化 状态栏颜色...

        return MaterialApp(
          themeMode: list[0] ?? mode,
          title: 'shudu',
          theme: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              // primary: Colors.grey.shade100,
              // primaryVariant: Colors.grey.shade200,
              secondary: Colors.grey,
              // onPrimary: Colors.grey.shade700,
              // onSurface: Colors.blue,
              // secondaryVariant: Colors.grey.shade400
            ),
            // primarySwatch: Colors.grey,
            platform: list[1] ?? defaultTargetPlatform,
            // brightness: Brightness.light,
            // primaryColorBrightness: Brightness.light,
            // primaryColor: Colors.grey.shade900,
            // fontFamily: 'NotoSansSC',]

            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: SlidePageTransition(),
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
            }),
          ),
          darkTheme: ThemeData.dark().copyWith(
            platform: list[1] ?? defaultTargetPlatform,
            colorScheme: const ColorScheme.dark(secondary: Colors.grey),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: SlidePageTransition(),
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
            }),
          ),
          showPerformanceOverlay: list[2] ?? false,
          home: const MyHomePage(),
          navigatorObservers: [context.read<OptionsNotifier>().routeObserver],
        );
      },
    );
  }
}

class MulProvider extends StatelessWidget {
  const MulProvider({Key? key, required this.hotFix, required this.mode})
      : super(key: key);
  final DeferredMain? hotFix;
  final ThemeMode mode;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => Repository.create(hotFix)..init()),
        Provider(create: (_) => TextStyleConfig()),
        ChangeNotifierProvider(create: (_) => OptionsNotifier()),
        ChangeNotifierProvider(
          create: (context) => BookIndexNotifier(repository: context.read()),
        ),
        ChangeNotifierProvider(
            create: (context) => SearchNotifier(context.read())),
        ChangeNotifierProvider(
            create: (context) => ContentNotifier(repository: context.read())),
        ChangeNotifierProvider(
          create: (context) => BookCacheNotifier(context.read()),
        )
      ],
      child: ShuduApp(mode: mode),
    );
  }
}
