import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImageLayout extends MultiChildLayoutDelegate {
  ImageLayout({this.width = 62});
  static const image = 'image';
  static const text = 'text';
  final double width;

  @override
  void performLayout(Size size) {
    final _width = math.min(size.width, width);
    final constraints =
        BoxConstraints.tightFor(width: _width, height: size.height);

    layoutChild(image, constraints);
    positionChild(image, Offset.zero);

    if (_width < size.width) {
      final _textConstaints = BoxConstraints.tightFor(
          width: size.width - _width, height: size.height);

      layoutChild(text, _textConstaints);
      positionChild(text, Offset(_width, 0));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
