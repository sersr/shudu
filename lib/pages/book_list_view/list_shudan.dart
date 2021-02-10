import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../bloc/bloc.dart';
import '../../data/book_list.dart';
import '../../utils/utils.dart';
import 'list_shudan_detail.dart';
import 'shudan_item.dart';

class ListShudanPage extends StatefulWidget {
  @override
  _ListShudanPageState createState() => _ListShudanPageState();
}

class _ListShudanPageState extends State<ListShudanPage> with SingleTickerProviderStateMixin {
  late ShudanBloc bloc;
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(initialIndex: 0, length: 3, vsync: this)..addListener(listen);
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

  bool show = false;

  @override
  Widget build(BuildContext context) {
    // if (show) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text('书单'),
          centerTitle: true,
          bottom: TabBar(
            controller: controller,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.pink.shade200,
            tabs: [
              Container(
                child: Text('最新发布'),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
              ),
              Container(
                child: Text('本周最热'),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
              ),
              Container(
                child: Text('最多收藏'),
                padding: const EdgeInsets.symmetric(vertical: 5.0),
              ),
            ],
          ),
        ),
        body: DefaultTextStyle(
          style: TextStyle(fontFamily: 'NotoSansSC', fontSize: 14, color: Color.fromRGBO(30, 30, 30, 1)),
          child: Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(
                overline: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'NotoSansSC'),
              ),
            ),
            child: TabBarView(
              controller: controller,
              children: [WrapWidget(index: 0), WrapWidget(index: 1), WrapWidget(index: 2)],
            ),
          ),
        ));
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

class _WrapWidgetState extends State<WrapWidget> with AutomaticKeepAliveClientMixin {
  late RefreshController controller;
  @override
  void initState() {
    super.initState();
    controller = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: BlocBuilder<ShudanBloc, ShudanState>(
        builder: (context, state) {
          return SmartRefresher(
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
              footer: CustomFooter(
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
                    child: DefaultTextStyle(style: TextStyle(color: Colors.grey[800]), child: Center(child: body)),
                  );
                },
              ),
              child:
                  // return
                  state.all[widget.index].isEmpty
                      ? Center(child: CupertinoActivityIndicator())
                      : buildListView(state.all[widget.index], context, widget.index));
        },
        // buildWhen: (o, n) {
        //   return widget.index == n.id;
        // },
      ),
      // child: Container(),
    );
  }

  ListView buildListView(List<BookList> list, BuildContext context, int index) {
    final width = 1 / MediaQuery.of(context).devicePixelRatio;
    return ListView.builder(
      // itemExtent: 112,
      // key: PageStorageKey<String>('shudan$index'),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final bookList = list[index];
        return RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(width: width, color: Color.fromRGBO(210, 210, 210, 1)),
              ),
            ),
            child: btn1(
              onTap: () {
                final route = MaterialPageRoute(builder: (_) {
                  return BlocProvider(
                    create: (context) => ShudanListDetailBloc(context.read<BookRepository>()),
                    child: Builder(builder: (context) {
                      BlocProvider.of<ShudanListDetailBloc>(context).add(ShudanListDetailLoadEvent(bookList.listId));
                      return ShudanDetailPage(total: bookList.bookCount);
                    }),
                  );
                });
                Navigator.of(context).push(route);
              },
              radius: 0,
              bgColor: Colors.grey[100],
              splashColor: Colors.grey[300],
              padding: const EdgeInsets.all(0),
              child: RepaintBoundary(
                child: ShudanItem(
                  desc: bookList.description,
                  name: bookList.title,
                  total: bookList.bookCount,
                  img: bookList.cover,
                  title: bookList.title,
                ),
              ),
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
  const ShudanEvent();
  @override
  List<Object> get props => [];
}

class ShudanLoadEvent extends ShudanEvent {
  ShudanLoadEvent(
    this.id,
  );
  final int id;
}

class ShudanLoadFirstEvent extends ShudanEvent {
  ShudanLoadFirstEvent(this.id);
  final int id;
}

class ShudanRefreshEvent extends ShudanEvent {
  ShudanRefreshEvent(this.id);
  final int id;
}

class ShudanState {
  ShudanState({this.all = const [[], [], []], this.id = 0});
  final List<List<BookList>> all;
  final int id;
}

enum Status {
  done,
  failed,
  ignore,
  noMore,
}

class ShudanBloc extends Bloc<ShudanEvent, ShudanState> {
  ShudanBloc(this.repository) : super(ShudanState());
  BookRepository repository;
  final c = ['new', 'hot', 'collect'];
  var newList = <BookList>[];
  var hotList = <BookList>[];
  var collectList = <BookList>[];

  Completer<Status>? completer;
  @override
  Stream<ShudanState> mapEventToState(ShudanEvent event) async* {
    await Future.delayed(Duration(milliseconds: 300));
    if (event is ShudanLoadFirstEvent) {
      if ((event.id == 0 && newList.isEmpty) ||
          (event.id == 1 && hotList.isEmpty) ||
          (event.id == 2 && collectList.isEmpty)) {
        yield* resolve(event.id);
      }
    } else if (event is ShudanLoadEvent) {
      yield* resolve(event.id);
    } else if (event is ShudanRefreshEvent) {
      if (event.id == 0) {
        newList = <BookList>[];
      } else if (event.id == 1) {
        hotList = <BookList>[];
      } else if (event.id == 2) {
        collectList = <BookList>[];
      }
      yield* resolve(event.id);
    }
  }

  void completerResolve(Status s) {
    if (completer != null && !completer!.isCompleted) {
      completer!.complete(s);
    }
  }

  int newCount = 1;
  int hotCount = 1;
  int collectCount = 1;
  Stream<ShudanState> resolve(int id) async* {
    // box = await Hive.openLazyBox('shudanlist');
    var status = Status.done;
    if (id == 0) {
      if (newList.isEmpty) {
        // final first = await box.get('shudanNewList');
        var data = await repository.getBookList(c[id]);
        if (data.isNotEmpty) {
          newList = data;
          newCount = 1;
          yield shudan(id);
          completerResolve(status);
        }
        data = await repository.loadShudan(c[id], 1);
        if (data.isNotEmpty) {
          newCount = 1;
          newList = data;
        } else {
          status = Status.failed;
        }
      } else {
        final data = await repository.loadShudan(c[id], newCount + 1);
        if (data.isNotEmpty) {
          newCount += 1;
          newList.addAll(data);
        } else {
          status = Status.failed;
        }
      }
    } else if (id == 1) {
      if (hotList.isEmpty) {
        var data = await repository.getBookList(c[id]);
        if (data.isNotEmpty) {
          hotList = data;
          hotCount = 1;
          yield shudan(id);
          completerResolve(status);
        }
        data = await repository.loadShudan(c[id], 1);
        if (data.isNotEmpty) {
          hotList = data;
          hotCount = 1;
        } else {
          status = Status.noMore;
        }
      } else {
        final data = await repository.loadShudan(c[id], hotCount + 1);
        if (data.isNotEmpty) {
          hotCount += 1;
          hotList.addAll(data);
        } else {
          status = Status.failed;
        }
      }
    } else if (id == 2) {
      if (collectList.isEmpty) {
        var data = await repository.getBookList(c[id]);
        if (data.isNotEmpty) {
          collectList = data;
          collectCount = 1;
          yield shudan(id);
          completerResolve(status);
        }
        data = await repository.loadShudan(c[id], 1);
        if (data.isNotEmpty) {
          collectList = data;
        } else {
          status = Status.failed;
        }
      } else {
        final data = await repository.loadShudan(c[id], collectCount + 1);
        if (data.isNotEmpty) {
          collectCount += 1;
          collectList.addAll(data);
        } else {
          status = Status.failed;
        }
      }
    }
    yield shudan(id);
    completerResolve(status);
  }

  ShudanState shudan(int id) {
    return ShudanState(all: [newList, hotList, collectList], id: id);
  }
}
