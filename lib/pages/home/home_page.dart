import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/Material.dart';
import 'package:get/get.dart';
import 'package:nop_db/nop_db.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../provider/provider.dart';
import '../book_content/book_content_page.dart';
import '../book_info/info_page.dart';
import '../book_list/main.dart';
import 'book_item.dart';
import 'search.dart';

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
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
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
    // opts.toggle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    painterBloc = context.read();
    opts = context.read();
    final search = context.read<SearchNotifier>();
    cache = context.read();
    config = context.read();
    final brightness = Theme.of(context).brightness;
    scheduleMicrotask(() {
      config.notify(brightness);
    });

    final data = MediaQuery.of(context);
    if (_future == null) {
      final any = FutureAny();
      cache.load();
      any
        ..add(opts.init())
        ..add(painterBloc.initConfigs())
        ..add(search.init());
      _future = Future.value(any.wait).whenComplete(() {
        painterBloc.metricsChange(data);
        Timer.run(() {
          if (opts.options.updateOnStart == true && mounted) {
            _refreshKey.currentState!.show();
          }
        });
      });
    }
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
      painterBloc.autoRun.stopSave();
    } else if (initIsolateState) {
      painterBloc.autoRun.stopAutoRun();
      setState(() {});
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
                              textStyle:
                                  context.read<TextStyleConfig>().data.body2)),
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
      _refreshKey.currentState!.show(atTop: true);
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
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return BookInfoPage(id: item.bookId!, api: item.api);
                }));
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
                color:
                    !context.isDarkMode ? null : Color.fromRGBO(25, 25, 25, 1),
                cacheExtent: 100,
                itemCount: children.length,
                itemBuilder: (_, index) {
                  final item = children[index];
                  return ListItem(
                    bgColor: !context.isDarkMode ? null : Colors.grey.shade900,
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
