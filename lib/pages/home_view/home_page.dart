import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/book_cache_bloc.dart';
import '../../bloc/book_info_bloc.dart';
import '../../bloc/options_bloc.dart';
import '../../bloc/painter_bloc.dart';
import '../../bloc/search_bloc.dart';
import '../../utils/utils.dart';
import '../book_content_view/content_page.dart';
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
    if (state == AppLifecycleState.detached) {
      painterBloc.repository.dipose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Timer? timer;
  @override
  Future<bool> didPopRoute() async {
    final inTime = timer == null ? false : timer!.isActive;
    if (inTime) {
      // 退出 app
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
                color: Colors.grey.shade900.withAlpha(210),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Text(
                    '再按一次退出',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),
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
    final child = Column(children: [
      AppBar(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade700,
        title: Text('hello world'),
        elevation: .0,
        centerTitle: true,
        actions: [
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, contraints) {
                    final height = contraints.maxHeight;
                    return InkWell(
                      borderRadius: BorderRadius.circular(height / 2),
                      onTap: () => showSearch(context: context, delegate: MySearchPage()),
                      child: Container(
                        height: height,
                        width: height,
                        child: Icon(Icons.search),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ],
        leading: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, contraints) {
                  final height = contraints.maxHeight;
                  return InkWell(
                    borderRadius: BorderRadius.circular(height / 2),
                    onTap: () => showdlg(context),
                    child: Container(
                      height: height,
                      width: height,
                      child: Icon(Icons.menu),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      Expanded(
        child: RepaintBoundary(
          child: IndexedStack(
            index: currentIndex,
            children: <Widget>[RepaintBoundary(child: buildBlocBuilder()), ListMainPage()],
          ),
        ),
      ),
      BottomNavigationBar(
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
    ]);

    /// 安全地初始化
    return AnimatedBuilder(
      animation: painterBloc.repository.init,
      builder: (context, child) {
        if (painterBloc.repository.init.value) {
          painterBloc.add(PainterInitEvent());
        }
        return AbsorbPointer(
          absorbing: !painterBloc.repository.init.value,
          child: Material(child: child),
        );
      },
      child: RepaintBoundary(child: child),
    );
  }

  void showdlg(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200]!.withAlpha(240),
            borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('选择平台样式'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Android',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.cyan.shade600,
                      splashColor: Colors.cyan.shade200,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(platform: TargetPlatform.android));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'IOS',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.cyan.shade600,
                      splashColor: Colors.cyan.shade200,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(platform: TargetPlatform.iOS));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    )
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('页面过度动画'),
                  ),
                ),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'FadeUpwards',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.lightBlue.shade700,
                      splashColor: Colors.lightBlue.shade400,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(pageBuilder: PageBuilder.fadeUpwards));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'OpenUpwards',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.lightBlue.shade700,
                      splashColor: Colors.lightBlue.shade400,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(pageBuilder: PageBuilder.openUpwards));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Cupertino',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.lightBlue.shade700,
                      splashColor: Colors.lightBlue.shade400,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(pageBuilder: PageBuilder.cupertino));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'FadeThrough',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.lightBlue.shade700,
                      splashColor: Colors.lightBlue.shade400,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(pageBuilder: PageBuilder.fadeThrough));
                        Future.delayed(Duration(milliseconds: 200), () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    btn1(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Zoom',
                          style: TextStyle(color: Colors.grey.shade100),
                        ),
                      ),
                      radius: 5,
                      bgColor: Colors.lightBlue.shade700,
                      splashColor: Colors.lightBlue.shade400,
                      onTap: () {
                        context.read<OptionsBloc>().add(OptionsEvent(pageBuilder: PageBuilder.zoom));
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
          btn2(
              icon: Icons.book,
              text: '书籍详情',
              onTap: () {
                context.read<BookInfoBloc>().add(BookInfoEventSentWithId(item.id!));
                Navigator.of(context).pushReplacementNamed(BookInfoPage.currentRoute);
              }),
          btn2(
              icon: Icons.touch_app_sharp,
              text: item.isTop == 1 ? '取消置顶' : '书籍置顶',
              onTap: () {
                context.read<BookCacheBloc>()
                  ..add(BookChapterIdIsTopEvent(id: item.id!, isTop: item.isTop == 1 ? 0 : 1))
                  ..add(BookChapterIdLoadEvent());
                Navigator.of(context).pop();
              }),
          btn2(
              icon: Icons.delete_forever_outlined,
              text: '删除书籍',
              onTap: () {
                context.read<BookCacheBloc>()
                  ..add(BookChapterIdDeleteEvent(id: item.id!))
                  ..add(BookChapterIdLoadEvent());
                Navigator.of(context).pop();
              }),
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
                final children = state.sortChildren;
                if (state.first) {
                  return SizedBox();
                }
                if (children.isEmpty) {
                  return Center(child: Text('点击右上角搜索按钮搜索'));
                }
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
                            ..canLoad = Completer<void>()
                            ..ignore.value = true
                            ..add(PainterNewBookIdEvent(item.id!, item.chapterId!, item.page!));

                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return BookContentPage();
                          }));
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
      primaryColor: Colors.white,
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
            size: 30,
          )));
  @override
  Widget buildSuggestions(BuildContext context) {
    return wrap(context, suggestions(context));
  }

  Widget suggestions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setstate) {
        final bloc = BlocProvider.of<SearchBloc>(context);
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Wrap(
            children: [
              for (var i in bloc.searchHistory)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey.shade300,
                    child: InkWell(
                      onTap: () {
                        query = i;
                        showResults(context);
                        // setstate(() {
                        //   bloc.searchHistory.remove(i);
                        // });
                      },
                      borderRadius: BorderRadius.circular(3.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.0),
                        child: Text(i),
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget wrap(BuildContext context, Widget child) {
    return Stack(
      fit: StackFit.expand,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Center(child: Text('返回')),
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              children: [
                suggestions(context),
                if (searchProvier.searchHistory.isNotEmpty) Divider(height: 1),
                for (var value in state.searchList.data!)
                  GestureDetector(
                    onTap: () {
                      final bookInfoBloc = context.read<BookInfoBloc>();
                      bookInfoBloc.add(BookInfoEventSentWithId(int.parse(value.id!)));
                      Navigator.of(context).pushNamed(BookInfoPage.currentRoute);
                    },
                    child: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
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

/// no throws
extension ContextRead on BuildContext {
  T rd<T>() {
    return Provider.of<T>(this, listen: false);
  }
}
