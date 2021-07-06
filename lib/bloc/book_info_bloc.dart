import 'package:flutter/foundation.dart';

import '../data/book_info.dart';
import '../event/event.dart';

class BookInfoProvider extends ChangeNotifier {
  Repository? repository;
  int? lastId;
  BookInfoRoot? data;

  Future<void> getData(int id) async {
    if (repository == null) return;
    if (contains(id)) {
      print('contains');
      return;
    }
    lastId = id;
    data = await repository!.bookEvent.getInfo(id);

    notifyListeners();
  }

  BookInfoRoot? get(int id) {
    if (lastId == id && data?.data != null) return data;
  }

  void remove(int id) {
    if (lastId == id) data = null;
  }

  bool contains(int id) => id == lastId && data != null && data!.data != null;
}
