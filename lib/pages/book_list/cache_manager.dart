import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../database/database.dart';
import '../../event/export.dart';
import '../../provider/export.dart';
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
              color: !context.isDarkMode
                  ? const Color.fromRGBO(236, 236, 236, 1)
                  : Color.fromRGBO(25, 25, 25, 1),
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

    final indicator = Center(
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.blue.shade100,
        valueColor: AlwaysStoppedAnimation(Colors.blueGrey),
      ),
    );

    final isLight = !context.isDarkMode;

    final bgColor = isLight ? null : Colors.grey.shade900;
    final splashColor = isLight ? null : Color.fromRGBO(60, 60, 60, 1);

    final name = _cacheNotifier.getName(_e.id, _e.api);
    final text = '$name${_e.api == ApiType.zhangdu ? ' *' : ''}';

    const padding = EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0);
    final style = TextStyle(fontSize: 12, color: Colors.grey.shade300);

    return ListItem(
      bgColor: bgColor,
      splashColor: splashColor,
      onTap: () {
        _cacheNotifier.exit = true;
        BookInfoPage.push(_e.id, _e.api).whenComplete(() => Future.delayed(
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
                    Expanded(child: Text(text, maxLines: 1)),
                    const SizedBox(width: 3),
                    Text('${_e.cacheItemCounts}/${_e.itemCounts}')
                  ],
                ),
                const SizedBox(height: 1),
                indicator,
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
                padding: padding,
                child: Text('清除缓存', style: style),
              ),
              const SizedBox(height: 3),
              btn1(
                radius: 6.0,
                bgColor: Colors.red.shade400,
                splashColor: Colors.red.shade200,
                onTap: () => _cacheNotifier.deleteBook(_e),
                padding: padding,
                child: Text('删除记录', style: style),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _CacheNotifier extends ChangeNotifier with NotifyStateOnChangeNotifier {
  _CacheNotifier();

  List<CacheItem> get data => List.of(_items);

  Repository? _repository;

  Repository? get repository => _repository;

  bool _exit = false;

  bool get initlized => _items.isEmpty;

  set exit(bool v) {
    _exit = v;
    if (_exit) {
      _cacheSub?.pause();
      _cacheSubZd?.pause();
    } else {
      _cacheSub?.resume();
      _cacheSubZd?.resume();
    }
    notifyListeners();
  }

  StreamSubscription? _cacheSub;
  StreamSubscription? _cacheSubZd;

  @override
  void notifyListeners() {
    if (_exit || _out) return;
    super.notifyListeners();
  }

  set repository(Repository? v) {
    if (_repository == v) return;
    _repository = v;
    handle = v;
  }

  @override
  void onClose() {
    _reset();
  }

  @override
  void onOpen() {
    if (_cacheList.isEmpty || _cacheListZd.isEmpty) startLoad();
  }

  void startLoad() async {
    if (repository == null) return;
    _out = false;
    _cacheSub?.cancel();
    _cacheSub = repository!.bookCacheEvent.watchMainList().listen(_listen);
    _cacheSubZd?.cancel();
    _cacheSubZd =
        _repository!.zhangduEvent.watchZhangduMainList().listen(_listenZd);
    final remoteItems = await repository!.getCacheItems() ?? const [];
    if (_out) return;
    final zhangduItems =
        await repository!.zhangduEvent.getZhangduCacheItems() ?? const [];
    if (_out) return;

    _items
      ..clear()
      ..addAll(zhangduItems.reversed)
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
    if (item.api == ApiType.zhangdu) {
      await repository!.zhangduEvent.deleteZhangduContentCache(item.id);
    } else {
      await repository!.bookContentEvent.deleteCache(item.id);
    }
    notifyListeners();
  }

  final _cacheList = <int, Cache>{};
  final _cacheListZd = <int, Cache>{};
  String getName(int bookid, ApiType api) {
    final Map<int, Cache> dataList;
    if (api == ApiType.zhangdu) {
      dataList = _cacheListZd;
    } else {
      dataList = _cacheList;
    }
    final cache = dataList[bookid];
    if (cache?.name != null) return cache!.name!;
    return '';
  }

  void _listen(List<BookCache>? data) {
    assert(Log.e('cache manager'));
    if (data == null) return;
    _cacheList.clear();
    for (var item in data) {
      if (item.bookId != null)
        _cacheList[item.bookId!] = Cache.fromBookCache(item);
    }
    notifyListeners();
  }

  void _listenZd(List<ZhangduCache>? data) {
    assert(Log.e('cache manager'));
    if (data == null) return;
    _cacheListZd.clear();
    for (var item in data) {
      if (item.bookId != null)
        _cacheListZd[item.bookId!] = Cache.fromZdCache(item);
    }
    notifyListeners();
  }

  Future<void> deleteBook(CacheItem item) async {
    if (repository == null) return;
    await deleteCache(item);
    if (item.api == ApiType.zhangdu) {
      await repository!.zhangduEvent.deleteZhangduBook(item.id);
    } else {
      await repository!.bookCacheEvent.deleteBook(item.id);
    }
  }

  bool _out = false;

  void _reset() {
    _out = true;
    _cacheSub?.cancel();
    _cacheSub = null;
    _cacheSubZd?.cancel();
    _cacheSubZd = null;
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }
}

class CacheItem {
  const CacheItem(this.id, this.itemCounts, this.cacheItemCounts,
      {this.api = ApiType.biquge});
  static const none = CacheItem(0, 1, 1);
  final int id;
  final int itemCounts;
  final int cacheItemCounts;
  final ApiType api;
  bool get isEmpty => this == none;
}
