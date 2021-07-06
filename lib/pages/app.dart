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
        color: Colors.white,
        title: 'shudu',
        theme: ThemeData(
          colorScheme: ColorScheme.light(),
          primarySwatch: Colors.lightBlue,
          visualDensity: VisualDensity.standard,
          platform: list[0] ?? defaultTargetPlatform,
          brightness: Brightness.light,
          fontFamily: 'NotoSansSC',
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.iOS: SlidePageTransition(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
          }),
        ),
        showPerformanceOverlay: list[1] ?? false,
        home: RepaintBoundary(child: const MyHomePage()),
        navigatorObservers: [
          Provider.of<OptionsNotifier>(context).routeObserver
        ],
      );
    });
  }
}

class MulProvider extends StatelessWidget {
  const MulProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => Repository.create(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => OptionsNotifier()),
          // BlocProvider(
          //   create: (context) => BookCacheBloc(context.read<Repository>()),
          // ),
          ChangeNotifierProvider(
            create: (context) =>
                BookIndexNotifier(repository: context.read<Repository>()),
          ),
          ChangeNotifierProvider(
              create: (context) => SearchNotifier(context.read<Repository>())),
          ChangeNotifierProvider(
            create: (context) => ContentNotifier(
                repository: context.read<Repository>(),
                indexBloc: context.read<BookIndexNotifier>()),
          ),
          Provider(create: (context) => TextStyleConfig()),
          ChangeNotifierProvider(
            create: (context) => BookCacheNotifier(context.read<Repository>()),
          )
        ],
        child: ShuduApp(),
      ),
    );
  }
}
