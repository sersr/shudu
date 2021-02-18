import 'dart:ui';

import 'package:flutter/painting.dart';

class MyShaderWarmUp extends DefaultShaderWarmUp {
  const MyShaderWarmUp() : super();

  @override
  Future<void> warmUpOnCanvas(Canvas canvas) {
    final recoder = PictureRecorder();
    final pcanvas = Canvas(recoder);
    final _text = TextPainter(text: TextSpan(text: 'shader warm up'), textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);
    _text.paint(pcanvas, Offset.zero);
    pcanvas.clipRect(Offset.zero & (size / 2));
    final pic = recoder.endRecording();
    canvas.drawPicture(pic);
    return super.warmUpOnCanvas(canvas);
  }
}
