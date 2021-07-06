import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../base/book_event.dart';
import '../base/constants.dart';

mixin SaveImageMessager on CustomEventMessager {
  var _list = <String, String>{};

  // var _reset = false;
  // set reset(bool v) {
  //   timer ??= Timer.periodic(const Duration(minutes: 60), (_) {
  //     if (_reset) {
  //       reset = false;
  //     } else {
  //       _list.clear();
  //       timer?.cancel();
  //       timer = null;
  //     }
  //   });
  //   _reset = v;
  // }

  @override
  Future<String> getImagePath(String img) async {
    /// 函数块中有异步存在
    /// 如果 异步未完成，[timer] 执行回调，对 [_list] 的操作都是不稳定的
    // reset = true;

    if (_list.containsKey(img)) {
      final _img = _list[img]!;

      if (await File(_img).exists())
        return _img;
      else
        _list.remove(img);
    }

    final _img = await super.getImagePath(img);

    // await looper.scheduleEventTask(() => releaseUI);

    if (_img != null &&
        _img.isNotEmpty &&
        !_list.containsKey(_img) &&
        _img != errorImg) _list[img] = _img;

    if (_list.length > 1000) {
      final _entries = _list.entries.toList()
        ..removeRange(0, _list.length - 100);

      _list = Map.fromEntries(_entries);
    }
    // if (_img != null) nop.preCacheImage(File(_img));

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
