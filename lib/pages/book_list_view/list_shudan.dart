import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../bloc/text_styles.dart';
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
  late ShudanBloc bloc;
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: 3, vsync: this)
      ..addListener(listen);
  }

  void listen() => bloc.add(ShudanLoadFirstEvent(controller.index));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ShudanBloc>();
    bloc.add(ShudanLoadFirstEvent(0));
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listen);
    controller.dispose();
    imageCache?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Scaffold(
        body: BarLayout(
          title: Text('书单'),
          bottom: TabBar(
            controller: controller,
            labelColor: Colors.grey.shade500,
            unselectedLabelColor: Colors.black,
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
            children: List.generate(3, (index) => WrapWidget(index: index)),
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
  }) : super(key: key);

  final int index;

  @override
  _WrapWidgetState createState() => _WrapWidgetState();
}

class _WrapWidgetState extends State<WrapWidget>
    with AutomaticKeepAliveClientMixin {
  late RefreshController controller;
  late ScrollController scrollController;
  late ShudanBloc bloc;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    controller = RefreshController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<ShudanBloc>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: BlocBuilder<ShudanBloc, ShudanState>(
        builder: (context, state) {
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
                final bloc = BlocProvider.of<ShudanBloc>(context);
                await bloc.completer?.future;
                bloc
                  ..completer = Completer<Status>()
                  ..add(ShudanLoadEvent(widget.index));
                final result = await bloc.completer?.future;
                if (mounted) {
                  if (result == Status.done) {
                    controller.refreshCompleted();
                  } else if (result == Status.failed) {
                    controller.refreshFailed();
                  } else {
                    controller.resetNoData();
                  }
                }
              },
              onLoading: () async {
                final bloc = BlocProvider.of<ShudanBloc>(context);
                await bloc.completer?.future;
                bloc
                  ..completer = Completer<Status>()
                  ..add(ShudanLoadEvent(widget.index));
                final result = await bloc.completer?.future;
                if (mounted) {
                  if (result == Status.done) {
                    controller.loadComplete();
                  } else if (result == Status.failed) {
                    controller.loadFailed();
                  } else {
                    controller.loadNoData();
                  }
                }
              },
              header: WaterDropHeader(),
              footer: CustomFooter(
                onClick: () {
                  final bloc = BlocProvider.of<ShudanBloc>(context);
                  bloc.add(ShudanLoadEvent(widget.index));
                },
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
                if (bloc[widget.index].isEmpty) {
                  if (state.status == Status.failed &&
                      widget.index == state.id) {
                    return reloadBotton(() {
                      BlocProvider.of<ShudanBloc>(context)
                          .add(ShudanRefreshEvent(widget.index));
                    });
                  } else {
                    return Center(child: CupertinoActivityIndicator());
                  }
                }
                return buildListView(bloc[widget.index], context, widget.index);
              }()
              // ),
              );
          // return
        },
        buildWhen: (o, n) {
          return widget.index == n.id;
        },
      ),
      // child: Container(),
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
                return BlocProvider(
                  create: (context) =>
                      ShudanListDetailBloc(context.read<Repository>()),
                  child: Builder(builder: (context) {
                    BlocProvider.of<ShudanListDetailBloc>(context)
                        .add(ShudanListDetailLoadEvent(bookList.listId));
                    return wrapData(
                        ShudanDetailPage(total: bookList.bookCount));
                  }),
                );
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

abstract class ShudanEvent extends Equatable {
  const ShudanEvent(
    this.id,
  );
  final int id;

  @override
  List<Object> get props => [];
}

class ShudanLoadEvent extends ShudanEvent {
  ShudanLoadEvent(int id) : super(id);
}

class ShudanLoadFirstEvent extends ShudanEvent {
  ShudanLoadFirstEvent(int id) : super(id);
}

class ShudanRefreshEvent extends ShudanEvent {
  ShudanRefreshEvent(int id) : super(id);
}

class ShudanState {
  ShudanState({this.id = 0, this.status = Status.done});

  final int id;
  final Status status;
}

enum Status {
  done,
  failed,
  ignore,
  noMore,
}

class ShudanBloc extends Bloc<ShudanEvent, ShudanState> {
  ShudanBloc(this.repository) : super(ShudanState());
  Repository repository;
  final c = ['new', 'hot', 'collect'];
  final _lists = List.generate(3, (index) => <BookList>[], growable: false);

  final _listCounts = List.filled(3, 1, growable: false);
  List<BookList> operator [](int index) => _lists[index];

  Completer<Status>? completer;
  @override
  Stream<ShudanState> mapEventToState(ShudanEvent event) async* {
    assert(event.id <= 2);
    await Future.delayed(Duration(milliseconds: 300));
    if (event is ShudanLoadFirstEvent) {
      if (_lists[event.id].isNotEmpty) return;
    } else if (event is ShudanRefreshEvent) {
      _lists[event.id] = <BookList>[];
    }
    yield* resolve(event.id);
  }

  void completerResolve(Status s) {
    if (completer != null && !completer!.isCompleted) {
      completer!.complete(s);
    }
  }

  Stream<ShudanState> resolve(int id) async* {
    var status = Status.done;
    yield shudan(id, status);
    if (_lists[id].isEmpty) {
      var data =
          await repository.bookEvent.customEvent.getHiveShudanLists(c[id]);
      if (data != null && data.isNotEmpty) {
        _lists[id] = data;
        _listCounts[id] = 1;
        yield shudan(id, status);
        completerResolve(status);
      }
      data = await repository.bookEvent.customEvent.getShudanLists(c[id], 1);
      if (data != null && data.isNotEmpty) {
        _lists[id] = data;
        _listCounts[id] = 1;
      } else {
        status = Status.failed;
      }
    } else {
      final data = await repository.bookEvent.customEvent
          .getShudanLists(c[id], _listCounts[id] + 1);
      if (data != null && data.isNotEmpty) {
        _listCounts[id] += 1;
        _lists[id].addAll(data);
      } else {
        status = Status.failed;
      }
    }

    yield shudan(id, status);
    completerResolve(status);
  }

  ShudanState shudan(int id, Status status) {
    return ShudanState(id: id, status: status);
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
    final ts = Provider.of<TextStylesBloc>(context);
    return Material(
      color: Color.fromARGB(255, 240, 240, 240),
      child: SafeArea(
        child: Column(children: [
          CustomMultiChildLayout(
              delegate: MultLayout(mSize: Size(size.width, 72)),
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
                    child: DefaultTextStyle(
                        style: ts.title2.copyWith(fontSize: 16), child: title)),
                LayoutId(id: 'bottom', child: bottom)
              ]),
          Expanded(
            child: body,
          )
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
