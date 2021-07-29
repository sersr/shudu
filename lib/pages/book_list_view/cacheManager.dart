import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/database.dart';
import '../../event/event.dart';
import '../../widgets/page_animation.dart';
import '../book_info_view/book_info_page.dart';


class CacheManager extends StatefulWidget {
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _cacheNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final ts = context.read<TextStyleConfig>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('缓存管理'),
        // backgroundColor: Colors.white,
        // titleTextStyle: ts.bigTitle1,
        elevation: 1.0,
      ),
      body: AnimatedBuilder(
        animation: _cacheNotifier,
        builder: (context, child) {
          final data = _cacheNotifier.data;
          if (data.isEmpty) return const SizedBox();

          return ListViewBuilder(
            cacheExtent: 100,
            itemExtent: 60,
            padding: const EdgeInsets.only(bottom: 12.0),
            itemBuilder: (_, index) => cacheItemBuilder(index),
            itemCount: data.length,
          );
        },
      ),
    );
  }

// 列表的行
  FutureBuilder<CacheItem> cacheItemBuilder(int index) {
    return FutureBuilder<CacheItem>(
      future: _cacheNotifier.loadItem(index),
      builder: (context, snap) {
        if (!snap.hasData)
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 250, 250, 250),
                borderRadius: BorderRadius.circular(6)),
          );
        final _e = snap.data!;

        final progress = _e.isEmpty
            ? 0.0
            : (_e.cacheItemCounts / _e.itemCounts).clamp(0.0, 1.0);

        return ListItem(
          onTap: () {
            _cacheNotifier.exit = true;
            BookInfoPage.push(context, _e.id).whenComplete(() => Future.delayed(
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
                            '${_cacheNotifier.getName(_e.id)}',
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
              btn1(
                radius: 6.0,
                bgColor: Colors.blue.shade400,
                splashColor: Colors.blue.shade200,
                onTap: () => _cacheNotifier.deleteCache(_e.id),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Text(
                  '清除缓存',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        );
      },
    );
  }
}

class _CacheNotifier extends ChangeNotifier {
  _CacheNotifier();

  final _data = <int>{};

  List<int> get data => List.of(_data);

  Repository? _repository;

  Repository? get repository => _repository;

  bool _exit = false;

  bool get initlized => _data.isEmpty;

  set exit(bool v) {
    _exit = v;
    _exit ? _cacheSub?.pause() : _cacheSub?.resume();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_exit) return;
    super.notifyListeners();
  }

  set repository(Repository? v) {
    if (_repository == v) return;
    _repository = v;
  }

  void startLoad() async {
    if (repository == null) return;
    final _l = await repository!.bookEvent.bookCacheEvent.getAllBookId();
    _cacheSub?.cancel();
    _cacheSub = repository!.bookEvent.bookCacheEvent
        .watchMainBookListDb()
        .listen(_listen);

    if (_l != null && _l.isNotEmpty) {
      _data.clear();
      _data.addAll(_l);
      _auto();
      await release(const Duration(milliseconds: 400));
      notifyListeners();
    }
  }

  void _auto() async {
    for (var item in _data) {
      if (_items.containsKey(item)) continue;
      final _i =
          await repository!.bookEvent.getCacheItem(item) ?? CacheItem.none;
      if (!_i.isEmpty) _items[item] = _i;
    }
  }

  final _items = <int, CacheItem>{};
  Future<CacheItem> loadItem(int index) async {
    if (index >= _data.length || repository == null) return CacheItem.none;
    final id = _data.elementAt(index);
    if (_items.containsKey(id)) return _items[id]!;
    final _i = await repository!.bookEvent.getCacheItem(id) ?? CacheItem.none;
    if (!_i.isEmpty) _items[id] = _i;
    return _i;
  }

  Future<void> deleteCache(int id) async {
    if (repository == null) return;
    _items.remove(id);
    await repository!.bookEvent.bookContentEvent.deleteCache(id);
    loadItem(id);
    notifyListeners();
  }

  StreamSubscription? _cacheSub;

  void cancel() {
    _cacheSub?.cancel();
    _cacheSub = null;
  }

  final _cacheList = <BookCache>[];
  String getName(int bookid) {
    final n = _cacheList.where((element) => element.bookId == bookid);
    if (n.isNotEmpty && n.last.name != null) return n.last.name!;
    return '';
  }

  void _listen(List<BookCache>? data) {
    Log.e('cache mangaer');
    if (data == null) return;

    _cacheList
      ..clear()
      ..addAll(data);

    notifyListeners();
  }

  @override
  void dispose() {
    cancel();
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
