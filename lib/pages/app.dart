import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shudu/bloc/book_cache_bloc.dart';
import 'package:shudu/bloc/book_index_bloc.dart';
import 'package:shudu/bloc/book_info_bloc.dart';
import 'package:shudu/bloc/book_repository.dart';
import 'package:shudu/bloc/options_bloc.dart';
import 'package:shudu/bloc/painter_bloc.dart';
import 'package:shudu/bloc/search_bloc.dart';
import 'package:shudu/bloc/text_styles.dart';
import 'package:shudu/pages/book_content_view/content_main.dart';

import 'book_info_view/book_info_page.dart';
import 'home_view/home_page.dart';

class ShuduApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NativeApi.initializeApiDLData;
    return BlocBuilder<OptionsBloc, OptionsState>(builder: (context, state) {
      return MaterialApp(
        title: 'shudu',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          platform: state.platform,
        ),
        home: MyHomePage(),
        routes: {
          BookInfoPage.currentRoute: (_) => BookInfoPage(),
          BookContentPage.currentRoute: (_) => BookContentPage(),
        },
        navigatorObservers: [context.watch<OptionsBloc>().routeObserver],
      );
    });
  }
}

class MulProvider extends StatelessWidget {
  const MulProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider(
        create: (_) => defaultTargetPlatform == TargetPlatform.windows ? BookRepositoryWinImpl() : BookRepositoryImpl(),
      ),
      BlocProvider(create: (context) {
        return BookCacheBloc(context.read<BookRepository>())..add(BookChapterIdFirstLoadEvent());
      }),
      BlocProvider(create: (context) {
        return BookIndexBloc(repository: context.read<BookRepository>());
      }),
      BlocProvider(create: (_) => SearchBloc()),
      BlocProvider(create: (context) => BookInfoBloc(context.read<BookRepository>())),
      BlocProvider(
        create: (context) {
          return PainterBloc(
              repository: context.read<BookRepository>(),
              bookCacheBloc: context.read<BookCacheBloc>(),
              bookIndexBloc: context.read<BookIndexBloc>());
        },
      ),
      BlocProvider(create: (_) => OptionsBloc(defaultTargetPlatform)),
      BlocProvider(create: (_) => TextStylesBloc()),
    ], child: ShuduApp());
  }
}
