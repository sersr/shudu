import 'package:flutter/foundation.dart';
import 'package:utils/utils.dart';

import '../api/api.dart';
import '../data/data.dart';

import '../event/export.dart';
import 'book_index_notifier.dart';

class BookInfoProvider extends ChangeNotifier {
  Repository? repository;
  int? lastId;
  BookInfoRoot? get data => _data;
  ZhangduDetailData? get zhangduData => _data;
  int? firstCid;
  List<ZhangduSameUsersBooksData>? sameUsers;
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
          await repository!.bookEvent.zhangduEvent.getZhangduIndex(id, false) ??
              [];
      if (zhangduData?.author != null) {
        sameUsers = await repository!.bookEvent.zhangduEvent
            .getZhangduSameUsersBooks(zhangduData!.author!);
      }
      if (rawIndexData.isNotEmpty) {
        firstCid = rawIndexData.first.id;
        Log.w('firstCid: $firstCid', onlyDebug: false);
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
