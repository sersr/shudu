import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import 'home_view/home_page.dart';

class ShuduApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptionsBloc, OptionsState>(builder: (context, state) {
      return MaterialApp(
        title: 'shudu',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          platform: state.options.platform,
          brightness: Brightness.light,
          fontFamily: 'NotoSansSC',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: OptionsState.create(state.options.pageBuilder),
              TargetPlatform.iOS: OptionsState.create(state.options.pageBuilder),
              TargetPlatform.windows: OptionsState.create(state.options.pageBuilder),
              TargetPlatform.macOS: OptionsState.create(state.options.pageBuilder),
              TargetPlatform.linux: OptionsState.create(state.options.pageBuilder),
              TargetPlatform.fuchsia: OptionsState.create(state.options.pageBuilder),
            },
          ),
        ),
        home: RepaintBoundary(child: const MyHomePage()),
        showPerformanceOverlay: state.options.showPerformmanceOverlay ?? false,
        // routes: {
        //   BookInfoPage.currentRoute: (_) => RepaintBoundary(child: BookInfoPage()),
        //   BookContentPage.route: (_) => RepaintBoundary(child: BookContentPage()),
        // },
        navigatorObservers: [Provider.of<OptionsBloc>(context).routeObserver],
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
        BlocProvider(create: (context) => OptionsBloc()),
        Provider(create: (context) => Repository.create()),
        BlocProvider(
          create: (context) => BookCacheBloc(context.read<Repository>()),
        ),
        BlocProvider(
          create: (context) => BookIndexBloc(repository: context.read<Repository>()),
        ),
        BlocProvider(create: (context) => SearchBloc(context.read<Repository>())),
        BlocProvider(create: (context) => BookInfoBloc(context.read<Repository>())),
        BlocProvider(
          create: (context) => PainterBloc(
              repository: context.read<Repository>(),
              bookIndexBloc: context.read<BookIndexBloc>(),
              bookCacheBloc: context.read<BookCacheBloc>()),
        ),
        BlocProvider(create: (context) => TextStylesBloc()),
      ],
      child: ShuduApp(),
    );
  }
}
