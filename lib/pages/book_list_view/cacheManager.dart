import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/utils.dart';
import '../../bloc/bloc.dart';
import '../book_info_view/book_info_page.dart';
import '../../event/event.dart';
import 'package:provider/provider.dart';

class CacheManager extends StatefulWidget {
  @override
  _CacheManagerState createState() => _CacheManagerState();
}

class _CacheManagerState extends State<CacheManager> {
  final _cacheNotifier = _CacheNotifier();
  late Repository repository;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    repository = context.read<Repository>();
    _cacheNotifier.repository = repository;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('缓存管理'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        color: const Color.fromARGB(255, 240, 240, 240),
        child: BlocBuilder<BookCacheBloc, BookChapterIdState>(
          builder: (context, state) {
            final sort = state.sortChildren;
            return AnimatedBuilder(
                animation: _cacheNotifier,
                builder: (context, child) {
                  final data = List.of(_cacheNotifier.data);
                  if (data.isEmpty) {
                    return Container();
                  }

                  return ListView.builder(
                    itemExtent: 60,
                    padding: const EdgeInsets.only(bottom: 10.0),
                    itemBuilder: (context, index) {
                      return FutureBuilder<CacheItem>(
                        future: _cacheNotifier.loadItem(index),
                        builder: (context, snap) {
                          if (!snap.hasData || snap.data!.isEmpty)
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 250, 250, 250),
                                  borderRadius: BorderRadius.circular(6)),
                            );
                          String? name;
                          for (var l in sort) {
                            if (l.id == data[index]) {
                              name = l.name;
                              break;
                            }
                          }
                          final _e = snap.data!;

                          final progess = _e.cacheItemCounts / _e.itemCounts;
                          return InkWell(
                            onTap: () {
                              BookInfoPage.push(context, _e.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 6.0),
                              margin: const EdgeInsets.symmetric(vertical: 3.0),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 250, 250, 250),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const SizedBox(height: 1),
                                        Row(
                                          children: [
                                            SizedBox(height: 2),
                                            Expanded(child: Text('$name')),
                                            SizedBox(width: 3),
                                            Text(
                                              '${_e.cacheItemCounts}/ ${_e.itemCounts}',
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        Center(
                                          child: LinearProgressIndicator(
                                            value: progess,
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.blueGrey),
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  btn1(
                                      onTap: () {
                                        _cacheNotifier.deleteCache(_e.id);
                                      },
                                      radius: 6.0,
                                      bgColor: Colors.blue.shade400,
                                      splashColor: Colors.blue.shade200,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 6.0),
                                      child: Text(
                                        '删除',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade300),
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    itemCount: data.length,
                  );
                });
          },
        ),
      ),
    );
  }
}

class _CacheNotifier extends ChangeNotifier {
  _CacheNotifier();

  final _data = <int>{};

  List<int> get data => List.of(_data);

  Repository? _repository;

  Repository? get repository => _repository;

  set repository(Repository? v) {
    if (_repository == v) return;
    _repository = v;
    startLoad();
  }

  void startLoad() async {
    if (repository == null) return;
    final _l = await repository!.bookEvent.bookInfoEvent.getAllBookId();

    if (_l.isNotEmpty) {
      _data.clear();
      _items.clear();
      _data.addAll(_l);
      notifyListeners();
    }
  }

  final _items = <int, CacheItem>{};
  Future<CacheItem> loadItem(int index) async {
    if (index >= _data.length || repository == null) return CacheItem.e;
    final id = _data.elementAt(index);
    if (_items.containsKey(id)) return _items[id]!;
    final _i = await repository!.bookEvent.getCacheItem(id);
    // var cacheListRaw =
    //     await repository!.bookEvent.bookContentEvent.getCacheContentsCidDb(id);
    // final cacheItemCounts = cacheListRaw.length;

    // int? itemCounts;
    // var queryList = await repository!.bookEvent.bookIndexEvent.getIndexsDb(id);

    // if (queryList.isNotEmpty) {
    //   final restr = queryList.first['bIndexs'] as String?;

    //   if (restr != null) {
    //     final indexs =
    //         await repository!.bookEvent.customEvent.getIndexsDecodeLists(restr);
    //     if (indexs.isNotEmpty) {
    //       final _num = indexs.fold<int>(0,
    //           (previousValue, element) => previousValue + element.length - 1);
    //       itemCounts = _num;
    //     }
    //   }
    // }

    // itemCounts ??= cacheItemCounts;
    // final _i = CacheItem(id, itemCounts, cacheItemCounts);

    _items[id] = _i;
    return _i;
  }

  Future<void> deleteCache(int id) async {
    if (repository == null) return;
    return repository!.bookEvent.bookContentEvent.deleteCache(id);
  }
}

class CacheItem {
  const CacheItem(this.id, this.itemCounts, this.cacheItemCounts);
  static const e = CacheItem(0, 1, 1);
  final int id;
  final int itemCounts;
  final int cacheItemCounts;
  bool get isEmpty => this == e;
}
