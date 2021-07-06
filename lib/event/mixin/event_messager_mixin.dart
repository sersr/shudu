import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../base/book_event.dart';
import '../base/constants.dart';

mixin SaveImageMessager on CustomEventMessager {
  final _list = <String, String>{};

  Timer? timer;

  @override
  Future<String> getImagePath(String img) async {
    if (_list.containsKey(img)) {
      final _img = _list[img]!;

      if (await File(_img).exists())
        return _img;
      else
        _list.remove(img);
    }

    final _img = await super.getImagePath(img);

    if (_img != null &&
        _img.isNotEmpty &&
        !_list.containsKey(_img) &&
        _img != errorImg) _list[img] = _img;

    timer?.cancel();
    timer = Timer(const Duration(minutes: 3), _list.clear);

    if (_list.length > 1000) {
      for (var i = 0; i < 100; i++) {
        if (_list.keys.length > i)
          _list.remove(_list.keys.first);
        else
          break;
      }
    }

    return _img ?? img;
  }
}

/// 调用 数据库 和 网络任务
mixin ComplexMessager on ComplexEventMessager {
  @override
  Future<RawContentLines> getContent(
      int bookid, int contentid, bool update) async {
    final result = await getContentDynamic(bookid, contentid, update);

    if (result is TransferableTypedData)
      return RawContentLines.decode(result.materialize());
    else if (result is RawContentLines) return result;

    return const RawContentLines();
  }
}
