import 'package:flutter_nop/change_notifier.dart';

import '../../../data/biquge/book_info.dart';

class BookInfoState {
  final _lastId = AutoListenNotifier<int?>(null);
  int? get lastId => _lastId.value;

  set lastId(int? id) => _lastId.value = id;
  final _data = AutoListenNotifier<BookInfoRoot?>(null);
  BookInfoRoot? get data => _data.value;
  set data(BookInfoRoot? data) => _data.value = data;
}
