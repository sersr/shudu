import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import 'modules/setting/setting.dart';
import 'routes/routes.dart';

class ShuduApp extends StatelessWidget {
  const ShuduApp({Key? key, required this.mode}) : super(key: key);
  final ThemeMode mode;
  @override
  Widget build(BuildContext context) {
    final listenable = router.global<OptionsNotifier>().select((opt) => [
          opt.options.themeMode,
          opt.options.platform,
          opt.options.showPerformanceOverlay,
        ]);
    // return ValueListenableBuilder<List>(
    //     valueListenable: listenable,
    //     builder: (context, list, child) {
    return Cs(() {
      final List<dynamic> list = listenable.cs.value;
      final themeMode = list[0] ?? mode;
      return MaterialApp.router(
        routerConfig: router,
        themeMode: themeMode,
        title: 'shudu',
        restorationScopeId: 'app',
        showPerformanceOverlay: list[2] ?? false,
        theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 15, 152, 231),
              secondary: Color.fromARGB(255, 179, 179, 179),
              onPrimary: Color.fromARGB(255, 245, 245, 245),
              onSurface: Color.fromARGB(255, 17, 30, 41),
            ),
            splashColor: Color.fromARGB(255, 212, 212, 212),
            scrollbarTheme: ScrollbarThemeData(radius: Radius.circular(6)),
            platform: list[1] ?? defaultTargetPlatform,
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: SlidePageTransition(),
              TargetPlatform.android: SlidePageTransition()
            }),
            appBarTheme:
                AppBarTheme(systemOverlayStyle: getOverlayStyle(dark: true))),
        darkTheme: ThemeData.dark().copyWith(
            splashColor: Color.fromARGB(255, 212, 212, 212),
            scrollbarTheme: ScrollbarThemeData(radius: Radius.circular(6)),
            platform: list[1] ?? defaultTargetPlatform,
            colorScheme: const ColorScheme.dark(secondary: Colors.grey),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: SlidePageTransition(),
              TargetPlatform.android: SlidePageTransition()
            }),
            appBarTheme:
                AppBarTheme(systemOverlayStyle: getOverlayStyle(dark: true))),
        // showPerformanceOverlay: list[2] ?? false,
        // home: Builder(builder: (context) {
        //   return AnnotatedRegion<SystemUiOverlayStyle>(
        //       value:
        //           getOverlayStyle(dark: context.isDarkMode, statusDark: true),
        //       child: const MyHomePage());
        // }),
        // initialRoute: Routes.root.fullName,
        // onGenerateRoute: (settings) {
        //   return Routes.root.onMatch(settings)?.wrapMaterial;
        // },
        // builder: (context, __) {
        //   return router.build(context);
        // },
        // navigatorObservers: [
        //   // Nav.observer
        // ],
      );
    });
    // return Selector<OptionsNotifier, List>(
    //   selector: (context, opt) {
    //     return [
    //       opt.options.themeMode,
    //       opt.options.platform,
    //       opt.options.showPerformanceOverlay,
    //     ];
    //   },
    //   builder: (context, list, _) {
    //     final themeMode = list[0] ?? mode;
    //     return MaterialApp(
    //       themeMode: themeMode,
    //       title: 'shudu',
    //       theme: ThemeData.light().copyWith(
    //           colorScheme: ColorScheme.light(
    //             primary: Color.fromARGB(255, 15, 152, 231),
    //             secondary: Color.fromARGB(255, 179, 179, 179),
    //             onPrimary: Color.fromARGB(255, 245, 245, 245),
    //             onSurface: Color.fromARGB(255, 17, 30, 41),
    //           ),
    //           splashColor: Color.fromARGB(255, 212, 212, 212),
    //           scrollbarTheme: ScrollbarThemeData(radius: Radius.circular(6)),
    //           platform: list[1] ?? defaultTargetPlatform,
    //           pageTransitionsTheme: const PageTransitionsTheme(builders: {
    //             TargetPlatform.iOS: SlidePageTransition(),
    //             TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
    //           }),
    //           appBarTheme:
    //               AppBarTheme(systemOverlayStyle: getOverlayStyle(dark: true))),
    //       darkTheme: ThemeData.dark().copyWith(
    //           splashColor: Color.fromARGB(255, 212, 212, 212),
    //           scrollbarTheme: ScrollbarThemeData(radius: Radius.circular(6)),
    //           platform: list[1] ?? defaultTargetPlatform,
    //           colorScheme: const ColorScheme.dark(secondary: Colors.grey),
    //           pageTransitionsTheme: const PageTransitionsTheme(builders: {
    //             TargetPlatform.iOS: SlidePageTransition(),
    //             TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
    //           }),
    //           appBarTheme:
    //               AppBarTheme(systemOverlayStyle: getOverlayStyle(dark: true))),
    //       showPerformanceOverlay: list[2] ?? false,
    //       // home: Builder(builder: (context) {
    //       //   return AnnotatedRegion<SystemUiOverlayStyle>(
    //       //       value:
    //       //           getOverlayStyle(dark: context.isDarkMode, statusDark: true),
    //       //       child: const MyHomePage());
    //       // }),
    //       initialRoute: Routes.root.fullName,
    //       onGenerateRoute: (settings) {
    //         return Routes.root.onMatch(settings)?.wrapMaterial;
    //       },
    //       navigatorObservers: [
    //         context.grass<OptionsNotifier>().routeObserver,
    //         Nav.observer
    //       ],
    //     );
    //   },
    // );
  }
}

// class MulProvider extends StatelessWidget {
//   const MulProvider({Key? key, required this.mode}) : super(key: key);

//   final ThemeMode mode;
//   @override
//   Widget build(BuildContext context) {

//     return MultiProvider(
//       providers: [
//         Provider(create: (_) => Repository.create()..init()),
//         ChangeNotifierProvider(
//             create: (context) => OptionsNotifier( context.grass())..init()),
//         ChangeNotifierProvider(
//           create: (context) => BookIndexNotifier(repository:  context.grass()),
//         ),
//         ChangeNotifierProvider(
//             create: (context) => SearchNotifier( context.grass())..init()),
//         Provider<ContentNotifier>(
//           create: (context) =>
//               ContentNotifier(repository:  context.grass())..initConfigs(),
//           dispose: (_, self) => self.dispose(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => BookCacheNotifier( context.grass())..load(),
//         ),
//         ChangeNotifierProvider(create: (_) => TextStyleConfig()),
//       ],
//       child: ShuduApp(mode: mode),
//     );
//   }
// }
