import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/database.dart';
import '../../event/event.dart';
import '../../provider/provider.dart';
import '../../widgets/page_animation.dart';
import '../book_info/info_page.dart';

class CacheManager extends StatefulWidget {
  const CacheManager({Key? key}) : super(key: key);

  @override
  _CacheManagerState createState() => _CacheManagerState();
}

class _CacheManagerState extends State<CacheManager> with PageAnimationMixin {
  final _cacheNotifier = _CacheNotifier();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.read<Repository>();
    _cacheNotifier.repository = repository;
    if (_cacheNotifier.initlized) addListener(complete);
  }

  void complete() {
    _cacheNotifier.startLoad();
    removeListener(complete);
  }

  @override
  void dispose() {
    super.dispose();
    _cacheNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('缓存管理'),
        elevation: 1.0,
      ),
      body: Scrollbar(
        interactive: true,
        thickness: 6,
        child: AnimatedBuilder(
          animation: _cacheNotifier,
          builder: (context, child) {
            final data = _cacheNotifier.data;
            if (data.isEmpty) return const SizedBox();

            return ListViewBuilder(
              cacheExtent: 100,
              itemExtent: 60,
              color: isLight ? null : Color.fromRGBO(25, 25, 25, 1),
              padding: const EdgeInsets.only(bottom: 12.0),
              itemBuilder: (_, index) => cacheItemBuilder(index),
              itemCount: data.length,
            );
          },
        ),
      ),
    );
  }

// 列表的行
  Widget cacheItemBuilder(int index) {
    final _e = _cacheNotifier.getItem(index);

    final progress =
        _e.isEmpty ? 0.0 : (_e.cacheItemCounts / _e.itemCounts).clamp(0.0, 1.0);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ListItem(
      bgColor: isLight ? null : Colors.grey.shade900,
      splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
      onTap: () {
        _cacheNotifier.exit = true;
        BookInfoPage.push(context, _e.id, ApiType.biquge).whenComplete(() =>
            Future.delayed(
            const Duration(milliseconds: 300),
            () => _cacheNotifier.exit = false));
      },
      child: Row(
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 1),
                Row(
                  children: [
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        _cacheNotifier.getName(_e.id),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${_e.cacheItemCounts}/${_e.itemCounts}',
                    )
                  ],
                ),
                const SizedBox(height: 1),
                Center(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.blue.shade100,
                    valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 1),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              btn1(
                radius: 6.0,
                bgColor: Colors.blue.shade400,
                splashColor: Colors.blue.shade200,
                onTap: () => _cacheNotifier.deleteCache(_e),
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                child: Text(
                  '清除缓存',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              btn1(
                radius: 6.0,
                bgColor: Colors.red.shade400,
                splashColor: Colors.red.shade200,
                onTap: () => _cacheNotifier.deleteBook(_e),
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                child: Text(
                  '删除记录',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _CacheNotifier extends ChangeNotifier {
  _CacheNotifier();

  List<CacheItem> get data => List.of(_items);

  Repository? _repository;

  Repository? get repository => _repository;

  bool _exit = false;

  bool get initlized => _items.isEmpty;

  set exit(bool v) {
    _exit = v;
    _exit ? _cacheSub?.pause() : _cacheSub?.resume();
    notifyListeners();
  }

  StreamSubscription? _cacheSub;

  @override
  void notifyListeners() {
    if (_exit || _out) return;
    super.notifyListeners();
  }

  set repository(Repository? v) {
    if (_repository == v) return;
    _repository = v;
  }

  void startLoad() async {
    if (repository == null) return;
    _out = false;
    _cacheSub?.cancel();
    _cacheSub = repository!.bookEvent.bookCacheEvent
        .watchMainList()
        .listen(_listen);

    final remoteItems = await repository!.bookEvent.getCacheItems() ?? const [];
    if (_out) return;

    _items
      ..clear()
      ..addAll(remoteItems.reversed);
    notifyListeners();
  }

  final _items = <CacheItem>{};
  CacheItem getItem(int index) {
    if (repository == null || _items.length < index) return CacheItem.none;
    return _items.elementAt(index);
  }

  Future<void> deleteCache(CacheItem item) async {
    if (repository == null) return;
    _items.remove(item);
    await repository!.bookEvent.bookContentEvent.deleteCache(item.id);
    notifyListeners();
  }

  final _cacheList = <BookCache>[];
  String getName(int bookid) {
    final n = _cacheList.where((element) => element.bookId == bookid);
    if (n.isNotEmpty && n.last.name != null) return n.last.name!;
    return '';
  }

  void _listen(List<BookCache>? data) {
    assert(Log.e('cache manager'));
    if (data == null) return;

    _cacheList
      ..clear()
      ..addAll(data);

    notifyListeners();
  }

  Future<void> deleteBook(CacheItem item) async {
    if (repository == null) return;
    deleteCache(item);
    await repository!.bookEvent.bookCacheEvent.deleteBook(item.id);
  }

  bool _out = false;
  @override
  void dispose() {
    _out = true;
    _cacheSub?.cancel();
    _cacheSub = null;
    super.dispose();
  }
}

class CacheItem {
  const CacheItem(this.id, this.itemCounts, this.cacheItemCounts);
  static const none = CacheItem(0, 1, 1);
  final int id;
  final int itemCounts;
  final int cacheItemCounts;
  bool get isEmpty => this == none;
}
