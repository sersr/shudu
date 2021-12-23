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
  void load(String key) {
    if (key.isEmpty) return;
    EventQueue.pushOne(_load, () => _load(key));
  }

  Future<void> _load(String key) async {
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
    final ignore = EventQueue.currentTask?.canDiscard ?? false;
    if (!ignore) {
      await save();
    }
  }

  Future<void> init() async {
    return EventQueue.runTask(this, _init);
  }

  Future<void> _init() async {
    box = await Hive.openBox('searchHistory');
    try {
      final se = box.get('suggestions', defaultValue: <String>[]);
      final List<String> _searchHistory;
      if (kDartIsWeb) {
        final dynamicList = se as List;
        _searchHistory =
            List.generate(dynamicList.length, (index) => dynamicList[index]);
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
    return EventQueue.pushOne(this, _save);
  }

  Future<void> _save() async {
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
