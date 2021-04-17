import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../bloc/painter_bloc.dart';
import '../../../utils/utils.dart';

class ContentView extends SingleChildRenderObjectWidget {
  ContentView({
    Key? key,
    required this.contentMetrics,
    required Widget battery,
  }) : super(key: key, child: battery);

  final ContentMetrics contentMetrics;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContentView(contentMetrics: contentMetrics);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderContentView renderObject) {
    renderObject.contentMetrics = contentMetrics;
  }
}

class RenderContentView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderContentView({
    required ContentMetrics contentMetrics,
  }) : _contentMetrics = contentMetrics {
    bottomLeft = TextPainter(text: TextSpan(), textDirection: TextDirection.ltr);
  }
  late TextPainter bottomLeft;

  ContentMetrics? _contentMetrics;
  ContentMetrics? get contentMetrics => _contentMetrics;
  set contentMetrics(ContentMetrics? v) {
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
  void performLayout() {
    size = constraints.biggest;
    if (contentMetrics!.isHorizontal) {
      final time = DateTime.now();
      bottomLeft.text =
          TextSpan(text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}', style: contentMetrics!.secstyle);
      bottomLeft.layout(maxWidth: size.width);
    }
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    dpaint(context, offset);
  }

  void dpaint(PaintingContext context, Offset offset) {
    context.setIsComplexHint();
    final canvas = context.canvas;
    final isHorizontal = contentMetrics!.isHorizontal;
    final topPad = contentMetrics!.topPad;
    final bottomRight = contentMetrics!.botRightPainter;
    final right = contentMetrics!.right;
    final botPad = PainterBloc.botPad;
    final e = contentMetrics!.extraHeightInLines;
    final fontSize = contentMetrics!.fontSize;
    final topHeight = contentMetrics!.topHeight;
    final _teps = contentMetrics!.painters;
    final index = contentMetrics!.index;
    final left = contentMetrics!.left;
    final cnamePainter = contentMetrics!.cPainter;
    final cBigPainter = contentMetrics!.cBigPainter;
    final _size = contentMetrics!.size;
    final whiteHeight = contentMetrics!.whiteLines;
    final windowTopPadding = isHorizontal ? contentMetrics!.windowTopPadding : 0;

    var h = 0.0;
    canvas.save();
    canvas.translate(offset.dx + left, offset.dy + windowTopPadding);
    if (isHorizontal) {
      h += topPad;
      cnamePainter.paint(canvas, Offset(0.0, h));
      h += cnamePainter.height;
    }
    if (index == 0) {
      if (!isHorizontal) {
        h -= PainterBloc.ePadding;
      }
      h += (fontSize + e) * topHeight + whiteHeight;
      cBigPainter.paint(canvas, Offset(0.0, h - cBigPainter.height));
      if (!isHorizontal) {
        h += PainterBloc.ePadding;
      }
    }

    if (isHorizontal) {
      h += PainterBloc.ePadding;
    }
    // canvas.drawRect(Offset(0.0, h) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    final xh = h;
    for (var _tep in _teps) {
      h += e / 2;
      _tep.paint(canvas, Offset(0.0, h));
      h += fontSize + e / 2;
    }
    // h -= e / 2;
    if (contentMetrics!.showrect) {
      canvas.drawRect(
          Offset(0.0, xh + e / 2) & Size(_size.width, h - xh - e - 1), Paint()..color = Colors.black.withAlpha(100));
    }
    // canvas.drawRect(
    //     Offset(0.0, h - e / 2 - 1) & Size(_size.width, e / 2), Paint()..color = Colors.black.withAlpha(100));
    // canvas.drawRect(Offset(0.0, 0) & Size(_size.width, h), Paint()..color = Colors.black.withAlpha(100));
    if (isHorizontal) {
      bottomRight.paint(canvas, Offset(right, _size.height - bottomRight.height - botPad));
      var bleft = 0.0;
      final _offset = Offset(0.0, _size.height - bottomLeft.height - botPad);
      if (child != null) {
        bleft = child!.size.width;
        context.paintChild(child!, _offset.translate(0.0, (bottomLeft.height - child!.size.height) / 5));
      }
          // canvas.drawRect(_offset.translate(0.0, 0.0) & Size(bottomLeft.width, bottomLeft.height),
      // Paint()..color = Colors.black.withAlpha(100));
      bottomLeft.paint(canvas, _offset.translate(bleft, 0.0));
    }
    canvas.restore();
  }

  // @override
  // bool hitTestSelf(ui.Offset position) => true;
}
 