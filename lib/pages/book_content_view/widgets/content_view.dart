import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../provider/constansts.dart';
import 'dart:ui' as ui;
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
  }) : _contentMetrics = contentMetrics {
    bottomLeft =
        TextPainter(text: TextSpan(), textDirection: TextDirection.ltr);
  }
  late TextPainter bottomLeft;

  ContentMetrics _contentMetrics;

  ContentMetrics get contentMetrics => _contentMetrics;
  set contentMetrics(ContentMetrics v) {
    if (_contentMetrics == v) return;
    _contentMetrics = v;
    markNeedsLayout();
  }

  // @override
  // bool get sizedByParent => true;

  // @override
  // void performResize() {
  //   size = constraints.biggest;
  // }
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    if (child != null) {
      // if (contentMetrics.isHorizontal) {
      final time = DateTime.now();
      bottomLeft.text = TextSpan(
          text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}',
          style: contentMetrics.secstyle);
      bottomLeft.layout(maxWidth: size.width);
      // }
      child!.layout(BoxConstraints.loose(size));
    }
  }

  @override
  bool get isRepaintBoundary => true;
  // ClipRectLayer? _clipRectLayer;
  @override
  void paint(PaintingContext context, Offset offset) {
    // _clipRectLayer = context.pushClipRect(
    //     needsCompositing, offset, Offset.zero & size, dpaint,
    //     oldLayer: _clipRectLayer);
    dpaint(context, offset);
  }

  void dpaint(PaintingContext context, Offset offset) {
    // context.setIsComplexHint();
    // final ePadding = contentPadding;
    // final bottomRight = contentMetrics.botRightPainter;
    // final right = contentMetrics.right;
    // final e = contentMetrics.extraHeightInLines;
    // final fontSize = contentMetrics.fontSize;
    // final _teps = contentMetrics.painters;
    // final index = contentMetrics.index;
    // final cnamePainter = contentMetrics.cPainter;
    // final cBigPainter = contentMetrics.cBigPainter;
    final _size = contentMetrics.size;
    // final topExtraHeight = contentMetrics.topExtraHeight;
    // final windowTopPadding = isHorizontal ? contentMetrics.windowTopPadding : 0;

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPicture(contentMetrics.picture);
    // final isHorizontal = contentMetrics.isHorizontal;
    final left = contentMetrics.left;

    // if (isHorizontal) {
    // }
    canvas.restore();
    if (child != null) {
      final height = child!.size.height;
      final _h = _size.height - botPad - height + offset.dy;
      context.paintChild(child!, Offset(left + offset.dx, _h));
      // canvas.drawRect(Offset(left, _h) & Size(_size.width, 10),
      //     Paint()..color = Colors.black38);
      bottomLeft.paint(
          canvas,
          Offset(left + child!.size.width + offset.dx,
              _h + (height - bottomLeft.height) / 2));
    }

    // var h = 0.0;
    // canvas.save();
    // canvas.translate(offset.dx + left, offset.dy + windowTopPadding);
    // if (isHorizontal) {
    //   h += topPad;
    //   cnamePainter.paint(canvas, Offset(0.0, h));
    //   h += cnamePainter.height;
    // }
    // if (index == 0) {
    //   if (!isHorizontal) {
    //     h -= ePadding;
    //   }
    //   h += topExtraHeight;
    //   cBigPainter.paint(canvas, Offset(0.0, h - cBigPainter.height));
    //   if (!isHorizontal) {
    //     h += ePadding;
    //   }
    // }

    // if (isHorizontal) h += ePadding;

    // // canvas.drawRect(Offset(0.0, h) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    // final xh = h;
    // final _e = e / 2;
    // final _end = _e + fontSize;
    // for (var _tep in _teps) {
    //   h += _e;
    //   _tep.paint(canvas, Offset(0.0, h));
    //   // canvas.drawRect(Offset(0.0, h) & Size(_size.width, _tep.height), Paint()..color = Colors.red.withAlpha(70));
    //   h += _end;
    // }
    // if (contentMetrics.showrect) {
    //   canvas.drawRect(Rect.fromLTWH(0.0, xh, _size.width, h),
    //       Paint()..color = Colors.black.withAlpha(100));
    // }
    // canvas.drawRect(
    //     Offset(0.0, h - e / 2 - 1) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    // canvas.drawRect(Offset(0.0, 0) & Size(_size.width, h), Paint()..color = Colors.black.withAlpha(100));
    // if (isHorizontal) {
    //   bottomRight.paint(
    //       canvas, Offset(right, _size.height - bottomRight.height - botPad));
    //   var bleft = 0.0;
    //   final _offset = Offset(0.0, _size.height - bottomRight.height - botPad);
    //   if (child != null) {
    //     bleft = child!.size.width;
    //     context.paintChild(
    //         child!,
    //         _offset.translate(
    //             0.0, (bottomRight.height - child!.size.height) / 2));
    //   }
    //   // canvas.drawRect(_offset.translate(0.0, 0.0) & Size(bottomLeft.width, bottomLeft.height),
    //   //     Paint()..color = Colors.black.withAlpha(100));
    //   bottomLeft.paint(canvas, _offset.translate(bleft, 0.0));
    // }
    // canvas.restore();
  }

  // @override
  // bool hitTestSelf(ui.Offset position) => true;
}
