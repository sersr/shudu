import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';

import '../data/data.dart';
import '../event/export.dart';
import 'book_index_notifier.dart';

class BookInfoProvider extends ChangeNotifier {
  Repository? repository;
  int? lastId;
  BookInfoRoot? get data => _data;

  int? firstCid;
  dynamic _data;
  Future<void> getData(int id, ApiType api) async {
    if (repository == null) return;
    if (contains(id)) {
      Log.i('contains');
      return;
    }
    lastId = id;

    _data = await repository!.getInfo(id) ?? const BookInfoRoot();

    notifyListeners();
  }

  dynamic get(int id) {
    if (lastId == id) return _data;
  }

  void remove(int id) {
    if (lastId == id) _data = null;
  }

  void reload(int id, ApiType api) {
    remove(id);
    notifyListeners();
    getData(id, api);
  }

  bool contains(int id) => id == lastId && data?.data != null;
}
