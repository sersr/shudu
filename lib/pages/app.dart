import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/provider.dart';
import '../event/event.dart';
import '../utils/utils.dart';
import 'home_view/home_page.dart';

class ShuduApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<OptionsNotifier, List>(selector: (context, opt) {
      return [opt.options.platform, opt.options.showPerformanceOverlay];
    }, builder: (context, list, _) {
      return MaterialApp(
        // color: Colors.white,
        title: 'shudu',
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
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
  const MulProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => Repository.create()),
        Provider(create: (_) => TextStyleConfig()),
        ChangeNotifierProvider(create: (_) => OptionsNotifier()),
        ChangeNotifierProvider(
          create: (context) =>
              BookIndexNotifier(repository: context.read<Repository>()),
        ),
        ChangeNotifierProvider(
            create: (context) => SearchNotifier(context.read<Repository>())),
        ChangeNotifierProvider(
          create: (context) => ContentNotifier(
            repository: context.read<Repository>(),
            // indexBloc: context.read<BookIndexNotifier>()
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BookCacheNotifier(context.read<Repository>()),
        )
      ],
      child: ShuduApp(),
    );
  }
}
