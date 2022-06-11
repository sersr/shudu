import 'package:nop/nop.dart';

import '../../../api/api.dart';
import '../../../data/data.dart';
import '../../../event/export.dart';

import 'book_info_state.dart';

class BookInfoProvider {
  Repository? repository;
  final state = BookInfoState();

  BookInfoRoot? get data => state.data;
  int? get lastId => state.lastId;

  Future<void> getData(int id, ApiType api) async {
    if (repository == null) return;
    if (contains(id)) {
      Log.i('contains');
      return;
    }

    final data = await repository!.getInfo(id) ?? const BookInfoRoot();
    state.data = data;
    state.lastId = id;
  }

  BookInfoRoot? get(int id) {
    if (lastId == id) return data;
    return null;
  }

  void remove(int id) {
    if (lastId == id) state.data = null;
  }

  void reload(int id, ApiType api) {
    remove(id);
    getData(id, api);
  }

  bool contains(int id) => id == lastId && data?.data != null;
}
