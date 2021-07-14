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
    data = await repository!.bookEvent.getInfo(id) ?? const BookInfoRoot();

    notifyListeners();
  }

  BookInfoRoot? get(int id) {
    if (lastId == id) return data;
  }

  void remove(int id) {
    if (lastId == id) data = null;
  }

  void reload(int id) {
    remove(id);
    notifyListeners();
    getData(id);
  }

  bool contains(int id) => id == lastId && data?.data != null;
}
