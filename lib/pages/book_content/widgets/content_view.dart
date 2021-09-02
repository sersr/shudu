import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:useful_tools/common.dart';

import '../../../provider/constansts.dart';
import '../../../provider/painter_notifier.dart';

class ContentView extends SingleChildRenderObjectWidget {
  const ContentView({
    Key? key,
    required this.contentMetrics,
    Widget? battery,
  }) : super(key: key, child: battery);

  final ContentMetrics contentMetrics;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContentView(contentMetrics: contentMetrics);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderContentView renderObject) {
    renderObject.contentMetrics = contentMetrics;
  }
}

class RenderContentView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderContentView({
    required ContentMetrics contentMetrics,
  })  : _contentMetrics = contentMetrics,
        _pictureRefInfo = contentMetrics.picture.clone();

  final TextPainter bottomLeft =
      TextPainter(text: const TextSpan(), textDirection: TextDirection.ltr);

  ContentMetrics _contentMetrics;

  ContentMetrics get contentMetrics => _contentMetrics;
  set contentMetrics(ContentMetrics v) {
    if (_contentMetrics == v) return;
    _contentMetrics = v;
    pictureRef = _contentMetrics.picture.clone();
    markNeedsLayout();
  }

  PictureRefInfo _pictureRefInfo;
  set pictureRef(PictureRefInfo ref) {
    if (ref.isCloneOf(_pictureRefInfo)) {
      ref.dispose();
      return;
    }
    _pictureRefInfo.dispose();
    _pictureRefInfo = ref;
    markNeedsLayout();
  }

  @override
  void dispose() {
    _pictureRefInfo.dispose();
    super.dispose();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    if (child != null) {
      final time = DateTime.now();
      bottomLeft
        ..text = TextSpan(
            text: time.hourAndMinuteFormat, style: contentMetrics.secstyle)
        ..layout(maxWidth: size.width);

      child!.layout(BoxConstraints.loose(size));
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // final _size = contentMetrics.size;
    // context.setIsComplexHint();
    final canvas = context.canvas;

    canvas.drawPicture(_pictureRefInfo.pictureRef.picture);

    final left = contentMetrics.left;

    if (child != null) {
      final height = bottomLeft.size.height;
      final width = child!.size.width;
      final dx = left + offset.dx;
      final dy = size.height - contentBotttomPad - height + offset.dy;
      bottomLeft.paint(canvas, Offset(dx + width, dy));
      context.paintChild(
          child!, Offset(dx, dy - (child!.size.height - height) / 2));
    }
  }

  // @override
  // bool hitTestSelf(ui.Offset position) => true;
}
