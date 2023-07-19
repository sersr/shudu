import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nop/nop_state.dart';
import 'package:nop/event_queue.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../data/data.dart';
import '../../../event/export.dart';
import '../../text_style/providers/text_styles.dart';
import '../../../routes/routes.dart';
import '../../../widgets/image_text.dart';

// 书单页面
class BooklistPage extends StatelessWidget {
  const BooklistPage({Key? key}) : super(key: key);
  final c = const ['new', 'hot', 'collect'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        child: DefaultTabController(
          length: 3,
          child: BarLayout(
            title: Text('书单'),
            bottom: TabBar(
              unselectedLabelColor: !context.isDarkMode
                  ? const Color.fromARGB(255, 204, 204, 204)
                  : const Color.fromARGB(255, 110, 110, 110),
              labelColor: const Color.fromARGB(255, 255, 255, 255),
              indicatorColor: const Color.fromARGB(255, 252, 137, 175),
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('最新发布'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('本周最热'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text('最多收藏'),
                ),
              ],
            ),
            body: TabBarView(
              // controller: controller,
              children: List.generate(
                  3, (index) => WrapWidget(index: index, urlKey: c[index])),
            ),
          ),
        ),
      ),
    );
  }
}

class WrapWidget extends StatefulWidget {
  const WrapWidget({
    Key? key,
    required this.index,
    required this.urlKey,
  }) : super(key: key);

  final int index;
  final String urlKey;

  @override
  _WrapWidgetState createState() => _WrapWidgetState();
}

class _WrapWidgetState extends State<WrapWidget>
    with AutomaticKeepAliveClientMixin {
  late ScrollController scrollController;

  late ShudanCategProvider shudanProvider;
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    shudanProvider = ShudanCategProvider(widget.urlKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shudanProvider.repository = context.getType<Repository>();
    // shudanProvider.load();
    tabController?.removeListener(onUpdate);
    tabController = DefaultTabController.of(context);
    tabController?.addListener(onUpdate);
    onUpdate();
  }

  void onUpdate() {
    if (tabController?.index == widget.index) {
      if (!shudanProvider.initialized) shudanProvider.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: shudanProvider,
        builder: (context, _) {
          final list = shudanProvider.list;
          if (list == null) {
            return loadingIndicator();
          } else if (list.isEmpty) {
            return reloadBotton(shudanProvider.load);
          }

          return buildListView(list);
        },
      ),
    );
  }

  bool get isLight => !context.isDarkMode;

  Widget buildListView(List<BookList> list) {
    return Scrollbar(
      interactive: true,
      controller: scrollController,
      child: ListViewBuilder(
        scrollController: scrollController,
        itemCount: list.length + 1,
        cacheExtent: 200,
        color: isLight
            ? const Color.fromRGBO(236, 236, 236, 1)
            : Color.fromRGBO(25, 25, 25, 1),
        refreshDelegate: RefreshDelegate(
            maxExtent: 80,
            onRefreshing: shudanProvider.refresh,
            onDone: shudanProvider.refreshDone,
            builder: (context, offset, maxExtent, mode, refreshing) {
              return ColoredBox(
                color: Colors.blue,
                child: Center(
                  child: Text('$mode | $refreshing'),
                ),
              );
            }),
        finishLayout: (first, last) {
          final state = shudanProvider.state;
          if (last >= list.length - 3) {
            if (state == LoadingStatus.success) {
              shudanProvider.loadNext(last);
            }
          }
        },
        itemBuilder: (context, index) {
          if (index == list.length) {
            final state = shudanProvider.state;
            Widget? child;

            if (state == LoadingStatus.error || state == LoadingStatus.failed) {
              child = reloadBotton(() => shudanProvider.loadNext(index));
            }

            child ??= loadingIndicator();

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              height: 60,
              child: child,
            );
          }

          final bookList = list[index];
          return ListItem(
            height: 112,
            bgColor: isLight ? null : Colors.grey.shade900,
            splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
            onTap: () {
              // final route = MaterialPageRoute(builder: (_) {
              //   return BooklistDetailPage(
              //       total: bookList.bookCount, index: bookList.listId);
              // });
              // Nav.push(route);
              NavRoutes.booklistDetailPage(
                      total: bookList.bookCount, index: bookList.listId)
                  .go;
            },
            child: ImageTextLayout(
              img: bookList.cover,
              top: bookList.title,
              center: bookList.description,
              bottom: '共${bookList.bookCount}本书',
              height: 112,
              centerLines: 2,
              bottomLines: 1,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    tabController?.removeListener(onUpdate);
    scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ShudanCategProvider extends ChangeNotifierBase {
  ShudanCategProvider(this.key);
  Repository? repository;

  List<BookList>? list;

  var _listCounts = 0;
  bool get initialized => list != null;

  String key;

  void reset(String newKey) {
    if (key != newKey) {
      key = newKey;
    }
  }

  final _loop = TaskQueue();

  bool get idle => !_loop.actived;

  void load() => _loop.runOne(_load);

  LoadingStatus state = LoadingStatus.success;

  void loadNext(int index) {
    _loop.pushOne(() => _loadNext(index));
  }

  void _loadNext(int index) async {
    if (list != null && index < list!.length) return;
    if (_loop.ignore) return;
    await idleWait;
    state = LoadingStatus.loading;

    notifyListeners();

    await _load();

    state = list == null
        ? LoadingStatus.error
        : list?.length != index
            ? LoadingStatus.success
            : LoadingStatus.failed;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_loop.ignore) return;
    // return _loop.runOne(() {
    list = null;
    _listCounts = 0;
    return _load();
    // });
  }

  void refreshDone() {
    notifyListeners();
  }

  Future<void> _load() async {
    final _repository = repository;
    if (_repository == null) return;

    final _olist = list;
    if (_olist != null && _olist.isEmpty) {
      list = null;
      notifyListeners();
    }

    final _list = list;
    if (_list == null) {
      var data = await _repository.customEvent.getHiveShudanLists(key);
      Timer? timer;
      if (data?.isNotEmpty == true) {
        list = data;
        _listCounts = 1;
        timer = Timer(const Duration(milliseconds: 300), notifyListeners);
      }
      data = await _repository.customEvent.getShudanLists(key, 1);
      if (data != null && data.isNotEmpty) {
        list = data;
        _listCounts = 1;
      }
      timer?.cancel();
    } else {
      final data =
          await _repository.customEvent.getShudanLists(key, _listCounts + 1);

      if (data != null && data.isNotEmpty) {
        _listCounts += 1;
        _list.addAll(data);
      }
    }

    await release(const Duration(milliseconds: 300));
    list ??= const [];

    notifyListeners();
  }
}

enum LoadingStatus {
  initial,
  loading,
  success,
  failed,
  error,
}

class BarLayout extends StatelessWidget {
  const BarLayout({
    Key? key,
    required this.bottom,
    required this.title,
    required this.body,
  }) : super(key: key);
  final Widget bottom;
  final Widget title;
  final Widget body;
  @override
  Widget build(BuildContext context) {
    final ts = context.getType<TextStyleConfig>().data;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    Widget? leading;
    if (canPop) {
      leading = Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: BackButton(color: Colors.grey.shade100),
      );
    }
    var middle = DefaultTextStyle(
        style: ts.bigTitle1.copyWith(fontSize: 20, color: Colors.grey.shade100),
        child: title);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: getOverlayStyle(dark: context.isDarkMode, statusDark: true),
      child: Column(children: [
        Material(
          color: !context.isDarkMode
              ? Color.fromARGB(255, 13, 157, 224)
              : Color.fromRGBO(25, 25, 25, 1),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                    height: kToolbarHeight,
                    child: NavigationToolbar(leading: leading, middle: middle)),
                bottom,
              ],
            ),
          ),
        ),
        Expanded(
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: RepaintBoundary(child: body)))
      ]),
    );
  }
}
