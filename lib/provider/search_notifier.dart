import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:useful_tools/useful_tools.dart';

import '../data/biquge/search_data.dart';
import '../data/zhangdu/zhangdu_search.dart';
import '../event/event.dart';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier(this.repository);
  final Repository repository;
  late List<String> searchHistory;

  late Box box;
  SearchList? list;
  ZhangduSearchData? data;
  Future<void> load(String key) async {
    if (key.isEmpty) return;
    list = null;
    data = null;

    notifyListeners();
    list = await repository.bookEvent.customEvent.getSearchData(key);
    data = await repository.bookEvent.zhangduEvent
        .getZhangduSearchData(key, 1, 20);

    searchHistory
      ..remove(key)
      ..add(key);
    notifyListeners();
    await save();
  }

  Future<void> init() async {
    box = await Hive.openBox('searchHistory');
    try {
      final se = box.get('suggestions', defaultValue: <String>[]);
      final List<String> _searchHistory;
      if (kDartIsWeb) {
        _searchHistory = [];
        for (var item in se) {
          _searchHistory.add(item);
        }
      } else {
        _searchHistory = se;
      }
      if (_searchHistory.length > 20) {
        searchHistory = _searchHistory.sublist(
            _searchHistory.length - 20, _searchHistory.length);
      } else {
        searchHistory = List.of(_searchHistory);
      }
    } catch (e) {
      Log.e('error: $e');
    }
  }

  Future<void> save() async {
    if (searchHistory.length > 20) {
      searchHistory = searchHistory.sublist(
          searchHistory.length - 16, searchHistory.length);
    }
    await box.put('suggestions', searchHistory);
  }

  void delete(String key) {
    searchHistory.remove(key);
    notifyListeners();
  }
}
