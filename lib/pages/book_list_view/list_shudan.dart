import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../data/book_list.dart';
import '../../event/event.dart';
import '../../provider/text_styles.dart';
import '../../utils/utils.dart';
import '../embed/list_builder.dart';
import 'list_shudan_detail.dart';
import 'shudan_item.dart';

class ListShudanPage extends StatefulWidget {
  @override
  _ListShudanPageState createState() => _ListShudanPageState();
}

class _ListShudanPageState extends State<ListShudanPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  final c = const ['new', 'hot', 'collect'];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
        body: BarLayout(
          title: Text('书单'),
          bottom: TabBar(
            controller: controller,
            labelColor: TextStyleConfig.blackColor7,
            unselectedLabelColor: TextStyleConfig.blackColor2,
            indicatorColor: Colors.pink.shade200,
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
            controller: controller,
            children: List.generate(
                3, (index) => WrapWidget(index: index, urlKey: c[index])),
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
  late RefreshController controller;
  late ScrollController scrollController;

  late ShudanCategProvider shudanProvider;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    controller = RefreshController();
    shudanProvider = ShudanCategProvider(widget.index, widget.urlKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shudanProvider.repository = context.read<Repository>();
    shudanProvider.load();
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

  Widget buildListView(List<BookList> list) {
    return Scrollbar(
      interactive: true,
      controller: scrollController,
      child: ListViewBuilder(
          scrollController: scrollController,
          itemCount: list.length + 1,
          cacheExtent: 100,
          finishLayout: (first, last) {
            final state = shudanProvider.state;

            if (last == list.length) {
              if (state == LoadingStatus.success) {
                shudanProvider.loadNext(last);
              }
            }
          },
          itemBuilder: (context, index) {
            if (index == list.length) {
              final state = shudanProvider.state;
              Widget? child;

              if (state == LoadingStatus.error ||
                  state == LoadingStatus.failed) {
                child = reloadBotton(() => shudanProvider.loadNext(index));
              }

              child ??= loadingIndicator();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(height: 40, child: child),
              );
            }

            final bookList = list[index];
            return ListItem(
              height: 112,
              onTap: () {
                final route = MaterialPageRoute(builder: (_) {
                  return ShudanDetailPage(
                      total: bookList.bookCount, index: bookList.listId);
                });
                Navigator.of(context).push(route);
              },
              child: ShudanItem(
                desc: bookList.description,
                name: bookList.title,
                total: bookList.bookCount,
                img: bookList.cover,
                title: bookList.title,
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ShudanCategProvider extends ChangeNotifier {
  ShudanCategProvider(this.index, this.key);
  Repository? repository;

  List<BookList>? list;

  var _listCounts = 0;
  bool get initialized => list != null;
  int index;
  String key;

  void reset(int newIndex, String newKey) {
    if (newIndex != index || key != newKey) {
      index = newIndex;
      key = newKey;
    }
  }

  final _loop = EventLooper();

  bool get onWork => _loop.runner == null;

  /// 同一个对象在队列中只能有一个，[_load] 是一个函数对象
  void load() => _loop.addEventTask(_load);

  LoadingStatus state = LoadingStatus.success;

  var _index = 0;
  void loadNext(int index) async {
    if (state == LoadingStatus.loading && onWork && _index == index) return;
    state = LoadingStatus.loading;
    _index = index;

    notifyListeners();

    load();
    await _loop.runner;
    if (_index == index) {
      state = list == null
          ? LoadingStatus.error
          : list?.length != index
              ? LoadingStatus.success
              : LoadingStatus.failed;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    scheduleMicrotask(() {
      super.notifyListeners();
    });
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
      var data =
          await _repository.bookEvent.customEvent.getHiveShudanLists(key);
      if (data != null && data.isNotEmpty) {
        list = data;
        _listCounts = 1;
      }
      data = await _repository.bookEvent.customEvent.getShudanLists(key, 1);
      if (data != null && data.isNotEmpty) {
        list = data;
        _listCounts = 1;
      }
    } else {
      final data = await _repository.bookEvent.customEvent
          .getShudanLists(key, _listCounts + 1);

      if (data != null && data.isNotEmpty) {
        _listCounts += 1;
        _list.addAll(data);
      }
    }

    // if (_list == null)
    await release(const Duration(milliseconds: 400));
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
    final size = MediaQuery.of(context).size;
    final ts = Provider.of<TextStyleConfig>(context);
    return Material(
      color: Color.fromARGB(255, 240, 240, 240),
      child: SafeArea(
        child: Column(children: [
          CustomMultiChildLayout(
              delegate: MultLayout(mSize: Size(size.width, 90)),
              children: [
                LayoutId(
                    id: 'back',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () => Navigator.maybePop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_back, size: 24),
                          )),
                    )),
                LayoutId(
                    id: 'title',
                    child: DefaultTextStyle(style: ts.bigTitle1, child: title)),
                LayoutId(id: 'bottom', child: bottom)
              ]),
          Expanded(child: body)
        ]),
      ),
    );
  }
}

class MultLayout extends MultiChildLayoutDelegate {
  MultLayout({required this.mSize});
  final Size mSize;
  @override
  void performLayout(Size size) {
    final boxConstraints = BoxConstraints.loose(size);
    final _backSize = layoutChild('back', boxConstraints);
    final _titleSize = layoutChild('title', boxConstraints);
    final _bottomSize = layoutChild('bottom', boxConstraints);
    var height = _backSize.height;

    final _backOffset =
        Offset(0, (size.height - _bottomSize.height - _backSize.height) / 2);
    positionChild('back', _backOffset);
    if (_titleSize.height > height) height = _titleSize.height;

    final _offset = Offset(math.max(0, (size.width - _titleSize.width) / 2),
        (size.height - _bottomSize.height - _titleSize.height) / 2);

    positionChild('title', _offset);
    positionChild('bottom', Offset(0, size.height - _bottomSize.height));
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.constrain(mSize);
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
