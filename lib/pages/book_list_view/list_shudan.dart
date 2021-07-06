import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../provider/text_styles.dart';
import '../../data/book_list.dart';
import '../../event/event.dart';
import '../../utils/utils.dart';
import 'list_shudan_detail.dart';
import 'shudan_item.dart';

class ListShudanPage extends StatefulWidget {
  @override
  _ListShudanPageState createState() => _ListShudanPageState();
}

class _ListShudanPageState extends State<ListShudanPage>
    with SingleTickerProviderStateMixin {
  // late ShudanBloc bloc;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  // void listen() => bloc.add(ShudanLoadFirstEvent(controller.index));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // bloc = context.read<ShudanBloc>();
    // bloc.add(ShudanLoadFirstEvent(0));
  }

  @override
  void dispose() {
    super.dispose();
    // controller.removeListener(listen);
    controller.dispose();

    // imageCache?.clear();
  }

  final c = ['new', 'hot', 'collect'];

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
          // return Scrollbar(
          //   controller: scrollController,
          //   interactive: true,
          //   isAlwaysShown: true,
          //   thickness: 8,
          //   radius: Radius.circular(8),
          //   child:
          return SmartRefresher(
              scrollController: scrollController,
              enablePullDown: true,
              enablePullUp: true,
              controller: controller,
              onRefresh: () async {
                final _count = shudanProvider._listCounts;
                await shudanProvider.load();
                final current = shudanProvider._listCounts;

                if (mounted) {
                  if (_count < current) {
                    controller.refreshCompleted();
                  } else if (_count == current) {
                    controller.refreshFailed();
                  } else {
                    controller.resetNoData();
                  }
                }
              },
              onLoading: () async {
                final _count = shudanProvider._listCounts;
                await shudanProvider.load();
                final current = shudanProvider._listCounts;

                if (mounted) {
                  if (_count < current) {
                    controller.loadComplete();
                  } else if (_count == current) {
                    controller.loadFailed();
                  } else {
                    controller.loadNoData();
                  }
                }
              },
              header: WaterDropHeader(),
              footer: CustomFooter(
                onClick: shudanProvider.load,
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text('上拉加载');
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text('加载失败');
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text('释放加载');
                  } else {
                    body = Text('没有更多了');
                  }
                  return Container(
                    height: 55.0,
                    child: DefaultTextStyle(
                        style: TextStyle(color: Colors.grey[800]),
                        child: Center(child: body)),
                  );
                },
              ),
              child: () {
                final list = shudanProvider.list;
                if (list == null) {
                  return loadingIndicator();
                } else if (list.isEmpty) {
                  return reloadBotton(shudanProvider.load);
                }
                return buildListView(list, context, widget.index);
              }());
        },
      ),
    );
  }

  Widget buildListView(List<BookList> list, BuildContext context, int index) {
    final width = 1 / MediaQuery.of(context).devicePixelRatio;
    return ListView.builder(
      primary: false,
      // controller: scrollController,
      itemExtent: 112,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final bookList = list[index];
        return Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(
                  width: width, color: Color.fromRGBO(210, 210, 210, 1)),
            ),
          ),
          child: btn1(
            onTap: () {
              final route = MaterialPageRoute(builder: (_) {
                return wrapData(ShudanDetailPage(
                  total: bookList.bookCount,
                  index: bookList.listId,
                ));
              });
              Navigator.of(context).push(route);
            },
            radius: 0,
            bgColor: Colors.grey[100],
            splashColor: Colors.grey[300],
            padding: const EdgeInsets.all(0),
            child: ShudanItem(
              desc: bookList.description,
              name: bookList.title,
              total: bookList.bookCount,
              img: bookList.cover,
              title: bookList.title,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class ShudanCategProvider extends ChangeNotifier {
  ShudanCategProvider(this.index, this.key);
  Repository? repository;
  final c = ['new', 'hot', 'collect'];
  List<BookList>? list;

  var _listCounts = 0;
  // List<BookList> operator [](int index) => _lists[index];

  int index;
  String key;

  void reset(int newIndex, String newKey) {
    if (newIndex != index || key != newKey) {
      index = newIndex;
      key = newKey;
    }
  }

  Future<void> load() async {
    final _repository = repository;
    if (_repository == null) return;
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
    if (list != null) {
      await release(const Duration(milliseconds: 200));
      notifyListeners();
    }
  }
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
