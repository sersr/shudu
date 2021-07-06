import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/search_data.dart';
import '../event/event.dart';

class SearchNotifier extends ChangeNotifier {
  SearchNotifier(this.repository);
  final Repository repository;
  late List<String> searchHistory;

  late Box box;
  SearchList? list;
  Future<void> load(String key) async {
    if (key.isEmpty) return;
    list = null;
    notifyListeners();
    list = await repository.bookEvent.customEvent.getSearchData(key);
    searchHistory
      ..remove(key)
      ..add(key);
    notifyListeners();
    await save();
  }

  Future<void> init() async {
    box = await Hive.openBox('searchHistory');
    final List<String> _searchHistory =
        box.get('suggestions', defaultValue: const <String>[]);
    if (_searchHistory.length > 20) {
      searchHistory = _searchHistory.sublist(
          _searchHistory.length - 20, _searchHistory.length);
    } else {
      searchHistory = List.of(_searchHistory);
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
