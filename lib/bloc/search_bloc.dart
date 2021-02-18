import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc.dart';

import '../data/search_data.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('${transition.nextState}');
    super.onTransition(bloc, transition);
  }
}

abstract class SearchEvent extends Equatable {
  SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchEventEnterPageWithoutKey extends SearchEvent {
  SearchEventEnterPageWithoutKey() : super();
}

class SearchEventWithKey extends SearchEvent {
  SearchEventWithKey({this.key}) : super();
  final String? key;

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
    this.searchList,
  }) : super();
  final SearchList? searchList;
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
  final BookRepository repository;
  @override
  Stream<SearchResult> mapEventToState(SearchEvent event) async* {
    if (event is SearchEventEnterPageWithoutKey) {
      yield SearchWithoutData();
    } else if (event is SearchEventWithKey) {
      yield SearchWithoutData();
      var list = await repository.searchWithKey(event.key);
      yield SearchResultWithData(searchList: list);
    }
  }
}
