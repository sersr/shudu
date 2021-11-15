import 'dart:async';
import 'dart:typed_data';

import 'package:useful_tools/common.dart';

import '../base/book_event.dart';

/// `Dynamic`方法需要实现原方法
mixin SaveImageMessager on CustomEventMessager implements CustomEvent {
  // @override
  // Future<String> getImagePath(String img) async {
  //   final _img = await super.getImagePath(img);

  //   return _img ?? img;
  // }

  @override
  Future<Uint8List?> getImageBytes(String img) async {
    final _img = await getImageBytesDynamic(img);

    if (_img is ByteBuffer) {
      return _img.asUint8List();
    }
    return _img;
  }
}

/// 调用 数据库 和 网络任务
mixin ComplexMessager on ComplexEventMessager implements ComplexEvent {
  // @override
  // Future<RawContentLines?> getContent(
  //     int bookid, int contentid, bool update) async {
  //   final result = await getContentDynamic(bookid, contentid, update);

  //   if (result is RawContentLines && !result.decoded) {
  //     result.decode();
  //     Log.w('没有decode???', onlyDebug: false);
  //   }
  //   assert(result is RawContentLines?);
  //   return result;
  // }
}
