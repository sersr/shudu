import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hot_fix/hot_fix.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/common.dart';

import '../event/event.dart';
import '../provider/provider.dart';
import 'home/home_page.dart';

class ShuduApp extends StatefulWidget {
  const ShuduApp({Key? key}) : super(key: key);

  @override
  State<ShuduApp> createState() => _ShuduAppState();
}

class _ShuduAppState extends State<ShuduApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<OptionsNotifier, List>(selector: (context, opt) {
      return [opt.options.platform, opt.options.showPerformanceOverlay];
    }, builder: (context, list, _) {
      return MaterialApp(
        // color: Colors.white,
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
          platform: list[0] ?? defaultTargetPlatform,
          // brightness: Brightness.light,
          // primaryColorBrightness: Brightness.light,
          // primaryColor: Colors.grey.shade900,
          // fontFamily: 'NotoSansSC',]

          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.iOS: SlidePageTransition(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
          }),
        ),
        showPerformanceOverlay: list[1] ?? false,
        home: const MyHomePage(),
        navigatorObservers: [context.read<OptionsNotifier>().routeObserver],
      );
    });
  }
}

class MulProvider extends StatelessWidget {
  const MulProvider({Key? key, required this.hotFix}) : super(key: key);
  final DeferredMain? hotFix;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => Repository.create(hotFix)),
        Provider(create: (_) => TextStyleConfig()),
        ChangeNotifierProvider(create: (_) => OptionsNotifier()),
        ChangeNotifierProvider(
          create: (context) =>
              BookIndexNotifier(repository: context.read<Repository>()),
        ),
        ChangeNotifierProvider(
            create: (context) => SearchNotifier(context.read<Repository>())),
        ChangeNotifierProvider(
          create: (context) =>
              ContentNotifier(repository: context.read<Repository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BookCacheNotifier(context.read<Repository>()),
        )
      ],
      child: const ShuduApp(),
    );
  }
}
