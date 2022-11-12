import 'package:flutter_nop/change_notifier.dart';

import '../../../data/biquge/search_data.dart';

class SearchState {
  final _searchHistory = <String>[].cs;

  List<String> get searchHistory => _searchHistory.value;

  set searchHistory(List<String> value) => _searchHistory.value = value;

  final _list = AutoListenNotifier<SearchList?>(null);

  SearchList? get list => _list.value;
  set list(SearchList? value) => _list.value = value;
}
