import 'dart:async';
import 'dart:isolate';

import '../base/book_event.dart';

mixin SaveImageMessager on CustomEventMessager {
  @override
  Future<String> getImagePath(String img) async {
    final _img = await super.getImagePath(img);

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
