import 'package:hive/hive.dart';
import 'package:nop/nop.dart';

import '../../../data/biquge/search_data.dart';
import '../../../event/export.dart';
import 'search_state.dart';

class SearchNotifier {
  SearchNotifier(this.repository);
  final Repository repository;
  final state = SearchState();

  List<String> get searchHistory => state.searchHistory;

  late Box box;
  SearchList? get list => state.list;
  void load(String key) {
    if (key.isEmpty) return;
    EventQueue.pushOne(_load, () => _load(key));
  }

  Future<void> _load(String key) async {
    state.list = await repository.customEvent.getSearchData(key);

    state.searchHistory
      ..remove(key)
      ..add(key);
    state.updateSearchHistory();

    final ignore = EventQueue.currentTask?.canDiscard ?? false;
    if (!ignore) {
      await save();
    }
  }

  Future<void> init() async {
    return EventQueue.run(this, _init);
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
        state.searchHistory = _searchHistory.sublist(
            _searchHistory.length - 20, _searchHistory.length);
      } else {
        state.searchHistory = List.of(_searchHistory);
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
      state.searchHistory = searchHistory.sublist(
          searchHistory.length - 16, searchHistory.length);
    }
    await box.put('suggestions', searchHistory);
  }

  void delete(String key) {
    searchHistory.remove(key);
    state.updateSearchHistory();
  }
}
