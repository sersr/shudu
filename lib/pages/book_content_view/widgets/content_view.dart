import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../provider/constansts.dart';
import '../../../provider/painter_notifier.dart';
import '../../../utils/utils.dart';

/// TODO: 分行渲染
class ContentView extends SingleChildRenderObjectWidget {
  ContentView({
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
  }) : _contentMetrics = contentMetrics;

  final TextPainter bottomLeft =
      TextPainter(text: const TextSpan(), textDirection: TextDirection.ltr);

  ContentMetrics _contentMetrics;

  ContentMetrics get contentMetrics => _contentMetrics;
  set contentMetrics(ContentMetrics v) {
    if (_contentMetrics == v) return;
    _contentMetrics = v;
    markNeedsLayout();
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
            text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}',
            style: contentMetrics.secstyle)
        ..layout(maxWidth: size.width);

      child!.layout(BoxConstraints.loose(size));
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // final _size = contentMetrics.size;

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPicture(contentMetrics.picture);

    final left = contentMetrics.left;

    canvas.restore();
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
