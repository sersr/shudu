import 'package:flutter/foundation.dart';
import 'package:flutter_nop/change_notifier.dart';

import 'book_cache_notifier.dart';

class BookCacheState {
  ValueListenable<bool> isTop(Cache item) {
    return _sortChildren.select((sortChildren) {
      final it = sortChildren.value.iterator;
      Cache? current;
      final bookid = item.bookId;
      while (it.moveNext()) {
        final _cache = it.current;
        if (bookid == _cache.bookId) {
          current = _cache;
          break;
        }
      }
      current ??= item;
      return current.isTop ?? false;
    }, key: item.bookId).cs; // 自动监听
  }

  final _rawList = AutoListenNotifier<List<Cache>?>(null);

  List<Cache>? get rawList => _rawList.value;
  ValueListenable<List<Cache>?> get rawLists => _rawList;

  set rawList(List<Cache>? value) {
    _rawList.value = value;
  }

  /// 不会自动监听
  late final _sortChildren = _rawList.select((parent) {
    final _list = parent.value;
    List<Cache> _sortChildren = const <Cache>[];
    if (_list != null && _list.isNotEmpty) {
      _list.sort((p, n) =>
          n.sortKey == null || p.sortKey == null ? 0 : n.sortKey! - p.sortKey!);
      final isTop = _list.where((element) => element.isTop == true);
      final custom = _list.where((element) => element.isTop != true);
      _sortChildren = [...isTop, ...custom];
    }

    return _sortChildren;
  });

  /// 添加 al 支持自动监听
  List<Cache> get sortChildren => _sortChildren.cs.value;

  late final _showChildren = _sortChildren.select((sortChildren) {
    return sortChildren.value.where((e) => e.isShow == true).toList();
  });
  List<Cache> get showChildren => _showChildren.cs.value;
}
