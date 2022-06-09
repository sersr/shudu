import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/Material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nop/nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../routes/routes.dart';
import '../../book_list/main.dart';
import '../_import.dart';
import '../providers/book_cache_notifier.dart';
import '../../search/widgets/search.dart';
import '../widgets/book_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, IsolateAutoInitAndCloseMixin {
  late ContentNotifier painterBloc;
  late OptionsNotifier opts;
  late BookCacheNotifier cache;
  late TextStyleConfig config;
  Future? _future;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    Log.i('changed brightness..', onlyDebug: false);
    if (mounted) {
      config.notify(Theme.of(context).brightness);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    painterBloc = context.getType();
    opts = context.getType();
    cache = context.getType();
    config = context.getType();
    final brightness = Theme.of(context).brightness;
    scheduleMicrotask(() {
      config.notify(brightness);
    });

    final data = MediaQuery.of(context);
    painterBloc.metricsChange(data);

    _future ??= opts.init().whenComplete(() {
      if (opts.options.updateOnStart == true) {
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          if (mounted) {
            _refreshKey.currentState!.show();
            // refreshDelegate.show();

          }
        });
      }
      return context.getType<SearchNotifier>().init();
    });
  }

  @override
  SendInitCloseMixin get isolateHandle => cache.repository;

  /// 测试调节数据
  // @override
  // int get closeDelay => 200;
  // @override
  // int get initIDelay => 100;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    closeIsolateState = state.index >= AppLifecycleState.paused.index;
    initIsolateState =
        mounted && state.index < AppLifecycleState.inactive.index;
    assert(Log.i('close: $closeIsolateState, resume: $initIsolateState'));

    onInitIsolate();
    if (closeIsolateState) {
      painterBloc.stopSave();
    } else if (initIsolateState) {
      painterBloc.stopAutoRun();
      ui.window.scheduleFrame();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    onCloseIsolate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_exitToast != null) return false;

    _exitToast = Nav.toast(
      Center(child: Text('再按一次退出~', style: TextStyle(color: Colors.white))),
      color: Colors.grey.shade900.withAlpha(210),
      radius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10.0),
      bottomPadding: 90,
      duration: const Duration(seconds: 2),
    )..future.whenComplete(() => _exitToast = null);

    return true;
  }

  ToastDelegate? _exitToast;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      RepaintBoundary(child: buildBlocBuilder()),
      RepaintBoundary(child: ListMainPage()),
    ];
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
                                  .getType<TextStyleConfig>()
                                  .data
                                  .body2)),
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
      ),
      body: RepaintBoundary(
        child: AnimatedBuilder(
            animation: notifier,
            builder: (context, _) {
              return IndexedStack(index: notifier.value, children: children);
            }),
      ),
      bottomNavigationBar: RepaintBoundary(
        child: AnimatedBuilder(
            animation: notifier,
            builder: (context, _) {
              final light = !context.isDarkMode;
              return BottomNavigationBar(
                iconSize: 18.0,
                selectedFontSize: 11.0,
                unselectedFontSize: 11.0,
                selectedItemColor: light
                    ? ui.Color.fromARGB(255, 5, 145, 238)
                    : ui.Color.fromARGB(255, 216, 216, 216),
                unselectedItemColor: light
                    ? ui.Color.fromARGB(255, 109, 116, 119)
                    : ui.Color.fromARGB(255, 112, 112, 112),
                items: const [
                  BottomNavigationBarItem(
                      label: '主页', icon: Icon(Icons.home_rounded), tooltip: ''),
                  BottomNavigationBarItem(
                      label: '书城',
                      icon: Icon(Icons.local_grocery_store_rounded),
                      tooltip: '')
                ],
                onTap: changed,
                currentIndex: notifier.value,
              );
            }),
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

  ValueNotifier<int> notifier = ValueNotifier(0);
  void changed(index) {
    if (notifier.value == index && index == 0) {
      // refreshDelegate.show();
      scrollController.position
          .jumpTo(scrollController.position.minScrollExtent);
      _refreshKey.currentState!.show();
    }
    notifier.value = index;
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
                // Nav.pushReplacement(MaterialPageRoute(builder: (context) {
                //   return BookInfoPage(id: item.bookId!, api: item.api);
                // }));
                NavRoutes.bookInfoPage(id: item.bookId!, api: api)
                    .goReplacement();
              }),
          ChangeAuto(() {
            final selector =
                context.getType<BookCacheNotifier>().selector((notifier) {
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
            });
            final isTop = selector.al.value;
            return btn2(
                icon: Icons.touch_app_sharp,
                text: isTop ? '取消置顶' : '书籍置顶',
                onTap: () => cache.updateTop(item.bookId!, !isTop, item.api));
          }),
          // ValueListenableBuilder<bool>(
          //   // selector: select,
          //   valueListenable:
          //       context.getType<BookCacheNotifier>().selector((notifier) {
          //     final child = notifier.sortChildren;
          //     final it = child.iterator;
          //     Cache? current;
          //     final bookid = item.bookId;
          //     while (it.moveNext()) {
          //       final _cache = it.current;
          //       if (bookid == _cache.bookId) {
          //         current = _cache;
          //         break;
          //       }
          //     }
          //     current ??= item;
          //     return current.isTop ?? false;
          //   }),
          //   builder: (context, isTop, child) {
          //     return btn2(
          //         icon: Icons.touch_app_sharp,
          //         text: isTop ? '取消置顶' : '书籍置顶',
          //         onTap: () => cache.updateTop(item.bookId!, !isTop, item.api));
          //   },
          // ),
          btn2(
              icon: Icons.delete_forever_outlined,
              text: '删除书籍',
              onTap: () {
                cache.deleteBook(item.bookId!, item.api);
                Nav.maybePop();
              }),
        ],
      ),
    );
  }

  // late final refreshDelegate = RefreshDelegate(
  //     builder: (context, offset, maxExtent, mode, rfreshing) {
  //       String text;
  //       switch (mode) {
  //         case RefreshMode.dragStart:
  //           text = '下拉刷新';
  //           break;
  //         case RefreshMode.dragEnd:
  //           text = '释放刷新';

  //           break;
  //         case RefreshMode.animatedDone:
  //         case RefreshMode.done:
  //           text = '刷新完成';
  //           break;
  //         case RefreshMode.refreshing:
  //           text = '刷新中';
  //           break;
  //         case RefreshMode.animatedIgnore:
  //         case RefreshMode.ignore:
  //           text = '已取消';
  //           break;
  //         default:
  //           text = '';
  //       }

  //       return Center(child: Text(text));
  //     },
  //     maxExtent: 100,
  //     onRefreshing: () => cache.load(update: true));

  Widget buildBlocBuilder() {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () {
        return cache.load(update: true);
      },
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification no) {
          if (no.leading) no.disallowIndicator();
          return false;
        },
        child: AnimatedBuilder(
          animation: cache,
          builder: (_, state) {
            if (!cache.initialized) return const SizedBox();

            final children = cache.showChildren;

            if (children.isEmpty) return const Center(child: Text('点击右上角按钮搜索'));
            final darkMode = context.isDarkMode;
            return Scrollbar(
              child: ListViewBuilder(
                // refreshDelegate: refreshDelegate,
                scrollController: scrollController,
                color: !darkMode
                    ? const Color.fromRGBO(236, 236, 236, 1)
                    : Color.fromRGBO(25, 25, 25, 1),
                cacheExtent: 100,
                itemCount: children.length,
                itemBuilder: (_, index) {
                  final item = children[index];
                  return ListItem(
                    bgColor: !darkMode ? null : Colors.grey.shade900,
                    splashColor: !context.isDarkMode
                        ? null
                        : Color.fromRGBO(60, 60, 60, 1),
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
                      api: item.api,
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
