import 'package:flutter/foundation.dart';
import 'package:useful_tools/common.dart';

import '../api/api.dart';
import '../data/data.dart';
import '../data/zhangdu/zhangdu_detail.dart';
import '../event/event.dart';
import 'book_index_notifier.dart';

class BookInfoProvider extends ChangeNotifier {
  Repository? repository;
  int? lastId;
  BookInfoRoot? get data => _data;
  ZhangduDetailData? get zhangduData => _data;
  int? firstCid;

  dynamic _data;
  Future<void> getData(int id, ApiType api) async {
    if (repository == null) return;
    if (contains(id)) {
      Log.i('contains');
      return;
    }
    lastId = id;
    if (api == ApiType.biquge) {
      _data = await repository!.bookEvent.getInfo(id) ?? const BookInfoRoot();
    } else {
      _data = await repository!.bookEvent.zhangduEvent.getZhangduDetail(id) ??
          const ZhangduDetailData();
      var rawIndexData =
          await repository!.bookEvent.zhangduEvent.getZhangduIndexDb(id) ?? [];
      if (rawIndexData.isEmpty)
        rawIndexData =
            await repository!.bookEvent.zhangduEvent.getZhangduIndex(id) ?? [];
      if (rawIndexData.isNotEmpty) {
        firstCid = rawIndexData.first.id;
        Log.w('firstCid: $firstCid');
        Log.i(ZhangduApi.getBookIndexDetail(id));
      }
    }

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
