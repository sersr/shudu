import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/tools/event_callback_looper.dart';
import 'package:equatable/equatable.dart';

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
  })  : text = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: textDirection,
          maxLines: maxLines,
          ellipsis: ellipsis,
        ),
        needLayout = true,
        super(key: key);

  final TextPainter text;
  final bool needLayout;
  static final _textLooper = EventLooper();
  static final _asyncTexts = <_TextLayoutKey, Future<TextPainter>>{};

  static Future<TextPainter> asyncLayout(double width, TextPainter text) {
    final key = _TextLayoutKey(text.maxLines, text.text);
    text.ellipsis = '...';

    return _asyncTexts.putIfAbsent(
        key,
        () => _textLooper.addEventTask(() async {
              text.layout(maxWidth: width);
              await releaseUI;
            }).then((_) => text)
              ..whenComplete(() {
                Timer(
                    const Duration(seconds: 2), () => _asyncTexts.remove(key));
              }));
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
    _needLayout = true;
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

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}

class _TextLayoutKey extends Equatable {
  _TextLayoutKey(this.maxLines, this.text);
  final int? maxLines;
  final InlineSpan? text;

  @override
  List<Object?> get props => [maxLines, text];
}
