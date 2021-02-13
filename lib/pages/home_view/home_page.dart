import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/book_cache_bloc.dart';
import '../../bloc/book_info_bloc.dart';
import '../../bloc/options_bloc.dart';
import '../../bloc/painter_bloc.dart';
import '../../bloc/search_bloc.dart';
import '../../utils/utils.dart';
import '../book_content_view/content_main.dart';
import '../book_info_view/book_info_page.dart';
import '../book_list_view/list_main.dart';
import 'book_item.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int currentIndex = 0;
  late PainterBloc painterBloc;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    painterBloc = context.read<PainterBloc>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.inactive && painterBloc.bookid != null) {
      painterBloc.add(PainterSaveEvent(changeState: false));
      context.read<BookCacheBloc>()
        ..add(BookChapterIdUpdateCidEvent(
            id: painterBloc.bookid!, cid: painterBloc.tData.cid!, page: painterBloc.currentPage!));
    }
  }

  @override
  void dispose() {
    print('.....dispose...');
    painterBloc.add(PainterSaveEvent());
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Timer? timer;
  @override
  Future<bool> didPopRoute() async {
    final active = timer == null ? false : timer!.isActive;
    if (active) {
      return false;
    }
    final entry = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned(
            bottom: 70,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Material(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.grey[900]!.withAlpha(210),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Text(
                    '再按一次退出',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
    Overlay.of(context)!.insert(entry);
    timer = Timer(Duration(seconds: 2), () {
      entry.remove();
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      appBar: AppBar(
        title: Text('hello world'),
        elevation: 1.0,
        centerTitle: true,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(50.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.search),
            ),
            onTap: () {
              showSearch(context: context, delegate: MySearchPage());
            },
          )
        ],
        leading: InkWell(
          borderRadius: BorderRadius.circular(50.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.menu),
          ),
          onTap: () {
            showdlg(context);
          },
        ),
      ),
      body: IndexedStack(
        children: <Widget>[
          buildBlocBuilder(),
          ListMainPage(),
        ],
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 3.0,
        items: [
          BottomNavigationBarItem(label: '主页', icon: Icon(Icons.home_rounded)),
          BottomNavigationBarItem(label: '书城', icon: Icon(Icons.shop_rounded))
        ],
        onTap: (index) {
          if (index == currentIndex) {
            if (currentIndex == 0) {
              _refreshKey.currentState!.show(atTop: true);
            }
            return;
          }
          setState(() => currentIndex = index);
        },
        currentIndex: currentIndex,
      ),
    );

    /// 安全地初始化
    return AnimatedBuilder(
        animation: painterBloc.repository.init,
        child: RepaintBoundary(child: child),
        builder: (context, child) {
          return AbsorbPointer(
            child: child,
            absorbing: !painterBloc.repository.init.value,
          );
        });
  }

  void showdlg(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              bottom: 0.0,
              left: 16.0,
              right: 16.0,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200]!.withAlpha(240),
                  borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        btn1(
                          child: Container(
                            child: Text('android style'),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          radius: 40,
                          bgColor: Colors.cyan[400],
                          splashColor: Colors.cyan[200],
                          onTap: () {
                            context.read<OptionsBloc>().add(OptionsEvent(TargetPlatform.android));
                            Future.delayed(Duration(milliseconds: 200), () {
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                        btn1(
                          child: Container(
                            child: Text('ios style'),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          radius: 40,
                          bgColor: Colors.cyan[400],
                          splashColor: Colors.cyan[200],
                          onTap: () {
                            context.read<OptionsBloc>().add(OptionsEvent(TargetPlatform.iOS));
                            Future.delayed(Duration(milliseconds: 200), () {
                              Navigator.of(context).pop();
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget bottomSheet(BuildContext context, BookCache item) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.grey[200].withAlpha(240),
        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      height: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          btn1(
            radius: 8.0,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            bgColor: Colors.blue,
            splashColor: Colors.blue[300],
            onTap: () {
              context.read<BookInfoBloc>().add(BookInfoEventSentWithId(item.id!));
              Navigator.of(context).pushReplacementNamed(BookInfoPage.currentRoute);
            },
            child: Text(
              '书籍详情',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
                fontSize: 14,
              ),
            ),
          ),
          btn1(
            radius: 8.0,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            bgColor: Colors.blue,
            splashColor: Colors.blue[300],
            onTap: () {
              context.read<BookCacheBloc>()
                ..add(BookChapterIdIsTopEvent(id: item.id!, isTop: item.isTop == 1 ? 0 : 1))
                ..add(BookChapterIdLoadEvent());
              Navigator.of(context)..pop();
            },
            child: Text(
              item.isTop == 1 ? '取消置顶' : '书籍置顶',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
                fontSize: 14,
              ),
            ),
          ),
          btn1(
            radius: 8.0,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            bgColor: Colors.blue,
            splashColor: Colors.blue[300],
            onTap: () {
              context.read<BookCacheBloc>()..add(BookChapterIdDeleteEvent(id: item.id!))..add(BookChapterIdLoadEvent());
              Navigator.of(context).pop();
            },
            child: Text(
              '删除书籍',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBlocBuilder() {
    final bgColor = Color.fromRGBO(250, 250, 250, 1);
    final spalColor = Color.fromARGB(250, 224, 224, 224);
    return RefreshIndicator(
      key: _refreshKey,
      displacement: 20.0,
      onRefresh: () {
        final bloc = context.read<BookCacheBloc>()
          ..completerLoading()
          ..loading = Completer()
          ..add(BookChapterIdLoadEvent(load: true));
        return bloc.loading!.future;
      },
      child: NotificationListener(
        onNotification: (Notification no) {
          if (no is OverscrollIndicatorNotification) {
            no.disallowGlow();
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<BookCacheBloc, BookChapterIdState>(
              builder: (context, state) {
                final children = state.isTop.toList()..addAll(state.custom);
                return ListView.builder(
                  itemCount: children.length,
                  padding: const EdgeInsets.all(0.0),
                  itemBuilder: (context, index) {
                    final item = children[index];
                    return Container(
                      decoration: index != children.length - 1
                          ? BoxDecoration(
                              border: BorderDirectional(
                                bottom: BorderSide(
                                    width: 1 / MediaQuery.of(context).devicePixelRatio,
                                    color: Color.fromRGBO(210, 210, 210, 1)),
                              ),
                            )
                          : null,
                      child: btn1(
                        background: false,
                        child: BookItem(
                          img: item.img,
                          bookName: item.name,
                          bookUdateItem: item.lastChapter,
                          bookUpdateTime: item.updateTime,
                          isTop: item.isTop == 1,
                          isNew: item.isNew == 1,
                        ),
                        radius: 6.0,
                        bgColor: bgColor,
                        splashColor: spalColor,
                        padding: const EdgeInsets.all(0),
                        onTap: () {
                          context.read<BookCacheBloc>().completerLoading();
                          painterBloc
                            ..add(PainterNewBookIdEvent(item.id, item.chapterId, item.page ?? 1))
                            ..canLoad = Completer<void>();

                          Navigator.of(context).pushNamed(BookContentPage.currentRoute);
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => bottomSheet(context, item),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MySearchPage extends SearchDelegate<void> {
  MySearchPage({
    String? hintText,
  }) : super(
          searchFieldLabel: '搜索',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.cyan,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  Widget buildLeading(BuildContext context) => Center(
      child: Container(
          // color: Colors.cyan,
          height: 100,
          width: 100,
          child: Icon(
            Icons.ac_unit,
            size: 40,
          )));

  @override
  Widget buildSuggestions(BuildContext context) => wrap(context, Center(child: Text('suggestions')));

  Widget wrap(BuildContext context, Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 16.0,
          bottom: 16.0,
          child: Material(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(50.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(50.0),
              splashColor: Colors.grey[400],
              onTap: () {
                close(context, null);
              },
              child: Container(
                height: 40,
                width: 70,
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), ),
                child: Center(
                    child: Text(
                  '返回',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchProvier = context.rd<SearchBloc>();
    searchProvier.add(SearchEventWithKey(key: query));

    return wrap(context, BlocBuilder<SearchBloc, SearchResult>(
      builder: (context, state) {
        if (state is SearchWithoutData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is SearchResultWithData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                for (var value in state.searchList!.data!)
                  GestureDetector(
                    onTap: () {
                      final bookInfoBloc = context.read<BookInfoBloc>();
                      bookInfoBloc.add(BookInfoEventSentWithId(int.parse(value.id!)));
                      Navigator.of(context).pushNamed(BookInfoPage.currentRoute);
                    },
                    child: Container(
                      height: 50,
                      child: Text('${value.name}'),
                    ),
                  ),
              ],
            ),
          );
        }
        return Container(child: Text('出问题了!'));
      },
    ));
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        InkWell(
          splashColor: Colors.blue[700],
          borderRadius: BorderRadius.circular(50.0),
          onTap: () {
            showResults(context);
          },
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('搜索'),
          )),
        )
      ];
}

extension ContextRead on BuildContext {
  T rd<T>() {
    return Provider.of<T>(this, listen: false);
  }
}
