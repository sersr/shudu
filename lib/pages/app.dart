import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';

import 'book_content_view/content_main.dart';
import 'book_info_view/book_info_page.dart';
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
          platform: state.platform,
          fontFamily: 'NotoSansSC',
        ),
        home: MyHomePage(),
        showPerformanceOverlay: state.showPerformmanceOverlay ?? false,
        routes: {
          BookInfoPage.currentRoute: (_) => BookInfoPage(),
          BookContentPage.currentRoute: (_) => BookContentPage(),
        },
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
        Provider(
          create: (_) => BookRepository(),
        ),
        BlocProvider(create: (context) {
          return BookCacheBloc(context.read<BookRepository>())..add(BookChapterIdFirstLoadEvent());
        }),
        BlocProvider(create: (context) {
          return BookIndexBloc(repository: context.read<BookRepository>());
        }),
        BlocProvider(create: (context) => SearchBloc(context.read<BookRepository>())),
        BlocProvider(create: (context) => BookInfoBloc(context.read<BookRepository>())),
        BlocProvider(
          create: (context) {
            return PainterBloc(
                repository: context.read<BookRepository>(),
                bookIndexBloc: context.read<BookIndexBloc>());
          },
        ),
        BlocProvider(create: (_) => OptionsBloc(defaultTargetPlatform)),
        BlocProvider(create: (_) => TextStylesBloc()),
      ],
      child: ShuduApp(),
    );
  }
}
