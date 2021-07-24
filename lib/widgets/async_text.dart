import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'picture_info.dart';

class AsyncText extends LeafRenderObjectWidget {
  AsyncText.async(this.text, {Key? key})
      : needLayout = false,
        super(key: key);
  AsyncText({
    Key? key,
    required String? text,
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
