import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/binding/widget_binding.dart';
import '../utils/tools/event_callback_looper.dart';
import '../utils/utils.dart';
import 'draw_picture.dart';

class AsyncText extends LeafRenderObjectWidget {
  AsyncText.async(this.text, {Key? key})
      : needLayout = false,
        super(key: key);
  AsyncText({
    Key? key,
    required String text,
    TextDirection textDirection = TextDirection.ltr,
    TextStyle? style,
    int? maxLines,
    String? ellipsis,
  })  : needLayout = true,
        text = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: textDirection,
          maxLines: maxLines,
          ellipsis: ellipsis,
        ),
        super(key: key);

  final TextPainter text;
  final bool needLayout;

  // static final _textLooper = EventLooper();
  // static final _texts = <ListKey, TextP>{};
  // static final _asyncTexts = <ListKey, Future<TextP>>{};

  // static TextPainter? getText(ListKey key) {
  //   final text = _texts[key];

  //   text?.start(const Duration(seconds: 20), () {
  //     _texts.remove(key);
  //     print('warn: removed.');
  //   });

  //   return text?.painter;
  // }

  // static TextPainter? syncGet(double width, TextPainter text) {
  //   final key = ListKey([width, text.maxLines, text.text, text.ellipsis]);

  //   return getText(key);
  // }

  // static List<TextPainter?> syncGets(double width, List<TextPainter> text) {
  //   final list = <TextPainter?>[];
  //   for (final t in text) {
  //     final data = syncGet(width, t);

  //     list.add(data);
  //   }
  //   return list;
  // }

  // // 只是尝试，没有做好所有key的匹配
  // static Future<TextPainter> asyncLayout(double width, TextPainter text) {
  //   final key = ListKey([width, text.maxLines, text.text, text.ellipsis]);
  //   text.ellipsis ??= '...';

  //   var textPainter = getText(key);
  //   if (textPainter != null) return Future.sync(() => textPainter);

  //   return _asyncLayout(width, text, key);
  // }

  // static Future<TextPainter> _asyncLayout(
  //     double width, TextPainter text, ListKey key) async {
  //   final _text = await _asyncTexts.putIfAbsent(
  //       key,
  //       () => _textLooper.addEventTask(() async {
  //             await releaseUI;
  //             text.layout(maxWidth: width);
  //             final _t = TextP(text);
  //             _texts[key] = _t;
  //             return _t;
  //           })
  //             ..whenComplete(() => _asyncTexts.remove(key)));

  //   final textPainter = getText(key);

  //   if (textPainter != _text.painter) {
  //     if (kReleaseMode) {
  //       print('textPainter = null ,key 错误');
  //     } else {
  //       Log.e('textPainter = null, key error');
  //     }
  //   }

  //   return textPainter!;
  // }

  static void clear() {
    _textListners.values.forEach((element) {
      element.dispose();
    });
    _textListners.clear();
  }

  static final _tlooper = EventLooper();
  static final _textListners = <ListKey, PictureListener>{};
  static PictureListener? getListener(ListKey key) {
    final text = _textListners[key];
    return text;
  }

  // static PictureListener preText(double width, TextPainter text) {
  //   final key = ListKey([width, text.maxLines, text.text, text.ellipsis]);
  //   text.ellipsis ??= '...';
  //   final _text = getListener(key);
  //   if (_text != null) return _text;
  //   final listener = _textListners[key] = PictureListener();

  //   _tlooper.addEventTask(() async {
  //     await releaseUI;

  //     final recoder = ui.PictureRecorder();
  //     final canvas = Canvas(recoder);
  //     text
  //       ..layout(maxWidth: width)
  //       ..paint(canvas, Offset.zero);

  //     final picture = PictureInfo(
  //         PictureMec(recoder.endRecording(), Size(text.width, text.height)));
  //     // await releaseUI;
  //     if (!listener.close && _textListners.containsKey(key)) {
  //       listener.setPicture(picture.clone());
  //     }
  //     picture.dispose();
  //   });
  //   return listener;
  // }

  static PictureListener putIfAbsent(
      List keys, Future<Size> Function(Canvas canvas) callback) {
    final key = ListKey(keys);

    final _text = getListener(key);
    if (_text != null) return _text;
    final listener = _textListners[key] = PictureListener();

    _tlooper.addEventTask(() async {
      final recoder = ui.PictureRecorder();
      final canvas = Canvas(recoder);

      await releaseUI;
      final size = await callback(canvas);

      final picture = PictureInfo(PictureMec(recoder.endRecording(), size));
      // await releaseUI;
      if (!listener.close && _textListners.containsKey(key)) {
        listener.setPicture(picture.clone());
      }
      picture.dispose();
    });
    return listener;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return AsyncTextRenderBox(text: text, needLayout: needLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant AsyncTextRenderBox renderObject) {
    renderObject
      ..text = text
      ..needLayout = needLayout;
  }
}

class AsyncTextRenderBox extends RenderBox {
  AsyncTextRenderBox({required TextPainter text, required bool needLayout})
      : _textPainter = text,
        _needLayout = needLayout;

  TextPainter _textPainter;

  set text(TextPainter t) {
    _textPainter = t;
    markNeedsLayout();
  }

  bool _needLayout;
  set needLayout(bool n) {
    if (_needLayout == n) return;
    _needLayout = n;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (_needLayout) _textPainter.layout(maxWidth: constraints.maxWidth);
    return constraints.constrain(_textPainter.size);
  }

  @override
  void performLayout() {
    if (_needLayout) _textPainter.layout(maxWidth: constraints.maxWidth);
    size = constraints.constrain(_textPainter.size);
  }

  /// 由于异步导致的重绘，会影响整个 [PictureLayer]
  /// 减少不必要的消耗，只需要重绘自身就好了
  // @override
  // bool get isRepaintBoundary => !_needLayout;

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}

class TextP {
  TextP(this.painter);

  final TextPainter painter;
  Timer? _timer;

  void start(Duration duration, VoidCallback onRemove) {
    _timer?.cancel();
    _timer = Timer(duration, onRemove);
  }
}

class PictureP {
  PictureP(this.picture);

  final PictureInfo picture;
  Timer? _timer;

  void start(Duration duration, VoidCallback onRemove) {
    _timer?.cancel();
    _timer = Timer(duration, onRemove);
  }
}

class ListKey {
  ListKey(this.list);
  final List list;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ListKey &&
            const DeepCollectionEquality().equals(list, other.list);
  }

  @override
  int get hashCode => hashList(list);
}
