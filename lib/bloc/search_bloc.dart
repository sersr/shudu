import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
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
  SearchBloc() : super(SearchWithoutData());

  @override
  Stream<SearchResult> mapEventToState(SearchEvent event) async* {
    if (event is SearchEventEnterPageWithoutKey) {
      yield SearchWithoutData();
    } else if (event is SearchEventWithKey) {
      yield SearchWithoutData();
      var list = await searchWithKey(event.key);
      yield SearchResultWithData(searchList: list);
    }
  }

  Future<SearchList> searchWithKey(String? key) async {
    var url = 'https://souxs.syqcnfj.com/search.aspx?key=$key&page=1&siteid=app2';
    var respone = await http.get(Uri.parse(url));
    if (respone.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(respone.body);
      return SearchList.fromJson(map);
    } else {
      return Future.value();
    }
  }

  Future<Uint8List> getImageData(String img) async {
    var url = 'https://imgapixs.pigqq.com/BookFiles/BookImages/$img';
    var respone = http.readBytes(Uri.dataFromString(url));
    return respone;
  }
}
