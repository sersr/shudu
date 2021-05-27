import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../data/search_data.dart';
import '../event/event.dart';

abstract class SearchEvent extends Equatable {
  SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchEventEnterPageWithoutKey extends SearchEvent {
  SearchEventEnterPageWithoutKey() : super();
}

class _SearchEventSave extends SearchEvent {}

class SearchEventWithKey extends SearchEvent {
  SearchEventWithKey({required this.key}) : super();
  final String key;

  @override
  List<Object?> get props => [key];
}

abstract class SearchResult extends Equatable {
  SearchResult();

  @override
  List<Object?> get props => [];
}

class SearchWithoutData extends SearchResult {
  SearchWithoutData() : super();
}

class SearchResultWithData extends SearchResult {
  SearchResultWithData({
    required this.searchList,
  }) : super();
  final SearchList searchList;
  SearchResultWithData copywith({SearchList? searchList, Uint8List? imgdata}) {
    return SearchResultWithData(
      searchList: searchList ?? this.searchList,
    );
  }

  @override
  List<Object?> get props => [searchList];
}

class SearchBloc extends Bloc<SearchEvent, SearchResult> {
  SearchBloc(this.repository) : super(SearchWithoutData());
  final Repository repository;
  late List<String> searchHistory;
  late Box box;
  @override
  Stream<SearchResult> mapEventToState(SearchEvent event) async* {
    if (event is SearchEventEnterPageWithoutKey) {
      yield SearchWithoutData();
    } else if (event is SearchEventWithKey) {
      yield SearchWithoutData();
      var list =
          await repository.bookEvent.customEvent.getSearchData(event.key);
      yield SearchResultWithData(searchList: list);
      searchHistory
        ..remove(event.key)
        ..add(event.key);
      await save();
    } else if (event is _SearchEventSave) {
      await save();
    }
  }

  Future<void> init() async {
    box = await Hive.openBox('searchHistory');
    final List<String> _searchHistory =
        box.get('suggestions', defaultValue: const <String>[]);
    if (_searchHistory.length > 20) {
      searchHistory = _searchHistory.sublist(
          _searchHistory.length - 20, _searchHistory.length);
    } else {
      searchHistory = List<String>.of(_searchHistory);
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
    add(_SearchEventSave());
  }
}
