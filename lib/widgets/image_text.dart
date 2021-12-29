import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'images.dart';
import 'text_builder_fut.dart';

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

    final _textConstaints = BoxConstraints.tightFor(
        width: size.width - _width, height: size.height);

    layoutChild(text, _textConstaints);
    positionChild(text, Offset(_width, 0));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class ImageTextLayout extends StatelessWidget {
  const ImageTextLayout({
    Key? key,
    this.img,
    this.top,
    this.topRightScore,
    this.center,
    this.bottom,
    this.centerLines = 1,
    this.bottomLines = 2,
    this.height = 112,
    this.builder,
  }) : super(key: key);

  final String? img;
  final String? top;
  final String? topRightScore;
  final String? center;
  final String? bottom;
  final double height;
  final int centerLines;
  final int bottomLines;
  final Widget Function(Widget)? builder;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: height, minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: RepaintBoundary(
        child: CustomMultiChildLayout(
          delegate: ImageLayout(width: 72),
          children: [
            LayoutId(
              id: ImageLayout.image,
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ImageResolve(img: img, builder: builder),
                ),
              ),
            ),
            LayoutId(
              id: ImageLayout.text,
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: TextAsyncLayout(
                    topRightScore: topRightScore,
                    top: top ?? '',
                    center: center ?? '',
                    bottom: bottom ?? '',
                    centerLines: centerLines,
                    bottomLines: bottomLines,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
