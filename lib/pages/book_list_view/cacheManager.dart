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
                    itemBuilder: (context, index) {
                      final itemdata =
                          _CacheBookItemNotifier(repository, data[index]);
                      return AnimatedBuilder(
                        animation: itemdata,
                        builder: (context, child) {
                          if (itemdata.isEmpty)
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

                          final progess =
                              itemdata.cacheItemCounts! / itemdata.itemCounts!;
                          return InkWell(
                            onTap: () {
                              BookInfoPage.push(context, itemdata.id);
                              // int? cid;
                              // int? currentPage;
                              // for (var l in sort) {
                              //   if (l.id == itemdata.id) {
                              //     cid = l.chapterId;
                              //     currentPage = l.page;
                              //     break;
                              //   }
                              // final data = state.
                              // final _cid = cid ?? data!.firstChapterId!;
                              // final page = currentPage ?? 1;
                              // }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 250, 250, 250),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            SizedBox(height: 2),
                                            Expanded(child: Text('$name')),
                                            SizedBox(width: 3),
                                            Text(
                                              '${itemdata.cacheItemCounts}/ ${itemdata.itemCounts}',
                                            )
                                          ],
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: LinearProgressIndicator(
                                              value: progess,
                                              backgroundColor:
                                                  Colors.blue.shade100,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.blueGrey),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  btn1(
                                      onTap: () {
                                        itemdata.deleteCache();
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
    final _l = await repository!.databaseEvent.getAllBookId();

    if (_l.isNotEmpty) {
      _data.clear();
      _data.addAll(_l);
      notifyListeners();
    }
  }
}

class _CacheBookItemNotifier extends ChangeNotifier {
  _CacheBookItemNotifier(this.repository, this.id) {
    startLoad();
  }
  final id;
  final Repository repository;
  String? name;
  int? itemCounts;
  int? cacheItemCounts;

  bool get isEmpty => itemCounts == null || cacheItemCounts == null;

  void startLoad() async {
    var cacheListRaw = await repository.databaseEvent.getCacheContentsDb(id);
    cacheItemCounts = cacheListRaw.length;
    print(cacheListRaw);
    var queryList = await repository.databaseEvent.getIndexsDb(id);
    if (queryList.isNotEmpty) {
      final restr = queryList.first['bIndexs'] as String?;
      if (restr != null) {
        final indexs = await repository.customEvent.getIndexsDecodeLists(restr);
        if (indexs.isNotEmpty) {
          var _num = 0;
          indexs.forEach((element) {
            _num += element.length - 1;
          });
          itemCounts = _num;
        }
      }
    }
    itemCounts ??= cacheItemCounts;
    if (!isEmpty) {
      notifyListeners();
    }
  }

  Future<void> deleteCache() async {
    return repository.databaseEvent.deleteCache(id);
  }
}
