import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/nop_database.dart';

import '../../provider/provider.dart';
import '../../widgets/image_text.dart';
import '../../widgets/images.dart';
import '../../widgets/text_builder.dart';
import '../book_content/book_content_page.dart';
import '../book_info/info_page.dart';
import '../book_list/main.dart';
import 'book_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int currentIndex = 0;
  late ContentNotifier painterBloc;
  late OptionsNotifier opts;
  late BookCacheNotifier cache;
  Future? _future;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    Log.i('changed brightness..', onlyDebug: false);
    // opts.toggle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    painterBloc = context.read<ContentNotifier>();
    opts = context.read<OptionsNotifier>();
    final search = context.read<SearchNotifier>();
    cache = context.read<BookCacheNotifier>();
    final data = MediaQuery.of(context);

    final rep = cache.repository;
    _future ??= rep.initState.then((_) {
      painterBloc.metricsChange(data);
      return Future.wait([
        opts.init(),
        cache.load(),
        search.init(),
        painterBloc.initConfigs(),
      ]);
    })
      ..whenComplete(() {
        if (opts.options.updateOnStart == true) {
          _refreshKey.currentState!.show();
        }
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      painterBloc.autoRun.stopSave();
    } else if (state == AppLifecycleState.resumed) {
      painterBloc.autoRun.stopAutoRun();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Timer? _exitTimer;
  @override
  Future<bool> didPopRoute() async {
    final inTime = _exitTimer?.isActive == true;
    if (inTime) {
      // 退出 app
      return false;
    }
    final entry = OverlayEntry(builder: (context) {
      return Positioned(
        bottom: 70,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(6.0),
            color: Colors.grey.shade900.withAlpha(210),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(
                '再按一次退出~',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 15.0),
              ),
            ),
          ),
        ),
      );
    });
    Overlay.of(context)!.insert(entry);
    _exitTimer = Timer(const Duration(seconds: 2), entry.remove);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final child = Scaffold(
      appBar: AppBar(
        title: Text('shudu'),
        elevation: 1 / ui.window.devicePixelRatio,
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
                      onTap: () => showSearch(
                          context: context,
                          delegate: BookSearchPage(
                              textStyle: context
                                  .read<TextStyleConfig>()
                                  .body2
                                  .copyWith(
                                      color: TextStyleConfig.blackColor9))),
                      child: SizedBox(
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
                builder: (_, contraints) {
                  final height = contraints.maxHeight;
                  return InkWell(
                    borderRadius: BorderRadius.circular(height / 2),
                    onTap: () => showbts(),
                    child: SizedBox(
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
      body: RepaintBoundary(
        child: IndexedStack(
          index: currentIndex,
          children: <Widget>[
            RepaintBoundary(child: buildBlocBuilder()),
            RepaintBoundary(child: ListMainPage())
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 18.0,
        selectedFontSize: 11.0,
        unselectedFontSize: 11.0,
        items: const [
          BottomNavigationBarItem(label: '主页', icon: Icon(Icons.home_rounded)),
          BottomNavigationBarItem(
              label: '书城', icon: Icon(Icons.local_grocery_store_rounded))
        ],
        onTap: (index) {
          if (index == currentIndex) {
            if (currentIndex == 0) _refreshKey.currentState!.show(atTop: true);

            return;
          }
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
      ),
    );

    /// 安全地初始化
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snap) {
        return AbsorbPointer(
            absorbing: snap.connectionState != ConnectionState.done,
            child: child);
      },
    );
  }

  void showbts() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
            height: 100, child: Center(child: Text('hello,移动到设置页面')));
      },
    );
  }

  Widget bottomSheet(Cache item, ApiType api) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.grey[200].withAlpha(240),
        borderRadius:
            BorderRadiusDirectional.vertical(top: Radius.circular(6.0)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      height: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          btn2(
              icon: Icons.book,
              text: '书籍详情',
              onTap: () {
                // BookInfoPage.push(context, item.bookId!, api);
                // Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return BookInfoPage(id: item.bookId!, api: item.api);
                }));
                // BookInfoPage.push(context, item.bookId!);
              }),
          Selector<BookCacheNotifier, bool>(
            selector: (_, notifier) {
              final child = notifier.sortChildren;
              final it = child.iterator;
              Cache? current;
              final bookid = item.bookId;
              while (it.moveNext()) {
                final _cache = it.current;
                if (bookid == _cache.bookId) {
                  current = _cache;
                  break;
                }
              }
              current ??= item;
              return current.isTop ?? false;
            },
            builder: (context, isTop, child) {
              return btn2(
                  icon: Icons.touch_app_sharp,
                  text: isTop ? '取消置顶' : '书籍置顶',
                  onTap: () => cache.updateTop(item.bookId!, !isTop, item.api));
            },
            shouldRebuild: (o, n) => o != n,
          ),
          btn2(
              icon: Icons.delete_forever_outlined,
              text: '删除书籍',
              onTap: () {
                cache.deleteBook(item.bookId!, item.api);
                Navigator.of(context).maybePop();
              }),
        ],
      ),
    );
  }

  bool get isLight => Theme.of(context).brightness == Brightness.light;

  Widget buildBlocBuilder() {
    return RefreshIndicator(
      key: _refreshKey,
      displacement: 20.0,
      onRefresh: () => cache.load(update: true),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification no) {
          no.disallowIndicator();
          return false;
        },
        child: AnimatedBuilder(
          animation: cache,
          builder: (_, state) {
            if (!cache.initialized) return const SizedBox();

            final children = cache.showChildren;

            if (children.isEmpty) return const Center(child: Text('点击右上角按钮搜索'));
            return Scrollbar(
              child: ListViewBuilder(
                color: isLight ? null : Color.fromRGBO(25, 25, 25, 1),
                cacheExtent: 100,
                itemCount: children.length,
                itemBuilder: (_, index) {
                  final item = children[index];
                  return ListItem(
                    bgColor: isLight ? null : Colors.grey.shade900,
                    splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
                    onTap: () {
                      BookContentPage.push(context, item.bookId!,
                          item.chapterId!, item.page!, item.api);
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (_) => bottomSheet(item, item.api));
                    },
                    child: BookItem(
                      img: item.img,
                      bookName: item.name,
                      bookUdateItem: item.lastChapter,
                      bookUpdateTime: item.updateTime,
                      isTop: item.isTop ?? false,
                      isNew: item.isNew ?? false,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class BookSearchPage extends SearchDelegate<void> {
  BookSearchPage({
    String? hintText,
    TextStyle? textStyle,
  }) : super(
            searchFieldLabel: '搜索关键字',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.search,
            searchFieldStyle: textStyle);

  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return theme.copyWith(
  //     // primaryColor: Colors.white,
  //     // primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
  //     // primaryColorBrightness: Brightness.light,
  //     primaryTextTheme: theme.textTheme,
  //     // colorScheme: theme.colorScheme.copyWith(primary: Colors.white)
  //   );
  // }

  @override
  Widget buildLeading(BuildContext context) => Center(
      child: SizedBox(
          // color: Colors.cyan,
          height: 100,
          width: 100,
          child: Icon(Icons.ac_unit, size: 30)));
  @override
  Widget buildSuggestions(BuildContext context) {
    return wrap(context, suggestions(context));
  }

  Widget suggestions(BuildContext context) {
    final bloc = context.read<SearchNotifier>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final ts = context.read<TextStyleConfig>();
    return StatefulBuilder(
      builder: (context, setstate) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: SingleChildScrollView(
            primary: false,
            child: Wrap(
              children: [
                for (var i in bloc.searchHistory.reversed)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(3.0),
                      color: isLight
                          ? Color.fromARGB(255, 220, 220, 220)
                          : const Color.fromRGBO(40, 40, 40, 1),
                      child: InkWell(
                        onLongPress: () {
                          bloc.delete(i);
                          setstate(() {});
                        },
                        onTap: () {
                          query = i;
                          showResults(context);
                        },
                        borderRadius: BorderRadius.circular(3.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            i,
                            style: isLight
                                ? ts.body2.copyWith(color: Colors.grey.shade700)
                                : ts.body2
                                    .copyWith(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
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
            elevation: 4.0,
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
                child: Center(
                    child: Text(
                  '返回',
                  style: TextStyle(color: Colors.grey.shade800),
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
    final search = context.read<SearchNotifier>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return wrap(
        context,
        AnimatedBuilder(
          animation: search,
          builder: (context, _) {
            final searchResult = search.list?.data;
            final zhangduData = search.data?.list;
            if (searchResult == null && zhangduData == null) {
              return loadingIndicator();
            }
            final searchLength = searchResult?.length ?? 0;
            final zhangduLength = zhangduData?.length ?? 0;
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  SizedBox(child: suggestions(context), height: 80),
                  const Divider(height: 1),
                  TabBar(
                    tabs: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Text('biqu'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Text('zhangdu'),
                      ),
                    ],
                    labelColor: isLight
                        ? TextStyleConfig.blackColor2
                        : Colors.grey.shade700,
                    unselectedLabelColor: isLight
                        ? TextStyleConfig.blackColor7
                        : Colors.grey.shade400,
                    indicatorColor: Colors.pink.shade200,
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      Scrollbar(
                        interactive: true,
                        thickness: 8,
                        child: ListViewBuilder(
                            itemCount: searchLength,
                            padding: const EdgeInsets.only(bottom: 60.0),
                            color:
                                isLight ? null : Color.fromRGBO(25, 25, 25, 1),
                            itemBuilder: (context, index) {
                              var _currentIndex = index;
                              final data = searchResult![_currentIndex];
                              return ListItem(
                                  height: 108,
                                  bgColor:
                                      isLight ? null : Colors.grey.shade900,
                                  splashColor: isLight
                                      ? null
                                      : Color.fromRGBO(60, 60, 60, 1),
                                  onTap: () => BookInfoPage.push(context,
                                      int.parse(data.id!), ApiType.biquge),
                                  child: Container(
                                    // height: 108,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: CustomMultiChildLayout(
                                      delegate: ImageLayout(width: 72),
                                      children: [
                                        LayoutId(
                                          id: ImageLayout.image,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: ImageResolve(img: data.img),
                                          ),
                                        ),
                                        LayoutId(
                                          id: ImageLayout.text,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 14.0),
                                            child: TextAsyncLayout(
                                                height: 108,
                                                topRightScore:
                                                    '${data.bookStatus}',
                                                top: data.name ?? '',
                                                center:
                                                    '${data.cName} | ${data.author}',
                                                bottom: data.desc ?? ''),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      ),
                      Scrollbar(
                        interactive: true,
                        thickness: 8,
                        child: ListViewBuilder(
                            itemCount: zhangduLength,
                            padding: const EdgeInsets.only(bottom: 60.0),
                            color:
                                isLight ? null : Color.fromRGBO(25, 25, 25, 1),
                            itemBuilder: (context, index) {
                              var _currentIndex = index;

                              assert(_currentIndex >= 0);
                              final data = zhangduData![_currentIndex];
                              return ListItem(
                                  height: 108,
                                  bgColor:
                                      isLight ? null : Colors.grey.shade900,
                                  splashColor: isLight
                                      ? null
                                      : Color.fromRGBO(60, 60, 60, 1),
                                  onTap: () {
                                    if (data.bookId != null)
                                      BookInfoPage.push(context, data.bookId!,
                                          ApiType.zhangdu);
                                  },
                                  child: Container(
                                    // height: 108,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: CustomMultiChildLayout(
                                      delegate: ImageLayout(width: 72),
                                      children: [
                                        LayoutId(
                                          id: ImageLayout.image,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child:
                                                ImageResolve(img: data.picture),
                                          ),
                                        ),
                                        LayoutId(
                                          id: ImageLayout.text,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 14.0),
                                            child: TextAsyncLayout(
                                                height: 108,
                                                topRightScore:
                                                    'zhangdu | ${data.bookStatus}',
                                                top: data.name ?? '',
                                                center:
                                                    '${data.categoryName} | ${data.author}',
                                                bottom: data.intro ?? ''),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      ),
                    ]),
                  )
                ],
              ),
            );
          },
        ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return [
      InkWell(
        splashColor: Colors.blue[700],
        borderRadius: BorderRadius.circular(50.0),
        onTap: () {
          showResults(context);
        },
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '搜索',
            style: TextStyle(color: isLight ? Colors.grey.shade800 : null),
          ),
        )),
      )
    ];
  }

  @override
  void showResults(BuildContext context) {
    final search = context.read<SearchNotifier>();
    search.load(query);
    super.showResults(context);
  }
}
