import 'package:flutter/painting.dart';

class MyShaderWarmUp extends DefaultShaderWarmUp {
  const MyShaderWarmUp() : super();

  @override
  Future<void> warmUpOnCanvas(Canvas canvas) {
    final _text = TextPainter(text: TextSpan(text: 'shader warm up'), textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);
    _text.paint(canvas, Offset.zero);
    return super.warmUpOnCanvas(canvas);
  }
}
