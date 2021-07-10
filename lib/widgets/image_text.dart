import 'package:flutter/material.dart';
import 'dart:math' as math;

class ImageLayout extends MultiChildLayoutDelegate {
  ImageLayout({this.width = 62});
  final _image = 'image';
  final _text = 'text';
  final double width;

  @override
  void performLayout(Size size) {
    final _width = math.min(size.width, width);
    final constraints = BoxConstraints.tight(Size(_width, size.height));
    layoutChild(_image, constraints);
    positionChild(_image, Offset.zero);
    if (_width < size.width) {
      final _con = BoxConstraints.tight(Size(size.width - _width, size.height));
      layoutChild(_text, _con);
      positionChild(_text, Offset(_width, 0));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
