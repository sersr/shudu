import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../provider/text_data.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../provider/constants.dart';

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

    canvas.drawPicture(_pictureRefInfo.picture);

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

class ContentViewTextLayout extends MultiChildLayoutDelegate {
  ContentViewTextLayout();
  static const battery = 'battery';
  static const body = 'body';

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints.loose(size);
    if (hasChild(body)) {
      layoutChild(body, loose);
      positionChild(body, Offset.zero);
    }
    if (hasChild(battery)) {
      layoutChild(battery, loose);
      positionChild(battery, Offset.zero);
    }
  }

  @override
  bool shouldRelayout(covariant ContentViewTextLayout oldDelegate) {
    return false;
  }
}

// class ContentViewText extends SingleChildRenderObjectWidget {
//   const ContentViewText({
//     Key? key,
//     required this.contentMetrics,
//     Widget? battery,
//   }) : super(key: key, child: battery);

//   final ContentMetricsText contentMetrics;

//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return RenderContentViewText(contentMetrics: contentMetrics);
//   }

//   @override
//   void updateRenderObject(
//       BuildContext context, covariant RenderContentViewText renderObject) {
//     renderObject..contentMetrics = contentMetrics;
//   }
// }

// class RenderContentViewText extends RenderBox
//     with RenderObjectWithChildMixin<RenderBox> {
//   RenderContentViewText({
//     required ContentMetricsText contentMetrics,
//   }) : _contentMetrics = contentMetrics;

//   final TextPainter bottomLeft =
//       TextPainter(text: const TextSpan(), textDirection: TextDirection.ltr);

//   ContentMetricsText _contentMetrics;

//   ContentMetricsText get contentMetrics => _contentMetrics;
//   set contentMetrics(ContentMetricsText v) {
//     if (_contentMetrics == v) return;
//     _contentMetrics = v;
//     markNeedsLayout();
//   }

//   @override
//   Size computeDryLayout(BoxConstraints constraints) {
//     return constraints.biggest;
//   }

//   @override
//   void performLayout() {
//     size = constraints.biggest;

//     if (child != null) {
//       final time = DateTime.now();
//       bottomLeft
//         ..text = TextSpan(
//             text: time.hourAndMinuteFormat, style: contentMetrics.secStyle)
//         ..layout(maxWidth: size.width);

//       child!.layout(BoxConstraints.loose(size));
//     }
//   }

//   @override
//   void paint(PaintingContext context, Offset offset) {
//     // final _size = contentMetrics.size;
//     // context.setIsComplexHint();

//     if (child != null) {
//       final canvas = context.canvas;

//       final left = contentMetrics.left;
//       final height = bottomLeft.size.height;
//       final width = child!.size.width;
//       final dx = left + offset.dx;
//       final dy = size.height - contentBotttomPad - height + offset.dy;
//       bottomLeft.paint(canvas, Offset(dx + width, dy));
//       context.paintChild(
//           child!, Offset(dx, dy - (child!.size.height - height) / 2));
//     }
//   }

//   // @override
//   // bool hitTestSelf(ui.Offset position) => true;
// }

// class ContentViewTextBody extends SingleChildRenderObjectWidget {
//   const ContentViewTextBody({
//     Key? key,
//     required this.contentMetrics,
//     required this.isHorizontal,
//     required this.shadow,
//     Widget? battery,
//   }) : super(key: key, child: battery);

//   final ContentMetricsText contentMetrics;
//   final bool isHorizontal;
//   final bool shadow;

//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return RenderContentViewTextBody(
//         contentMetrics: contentMetrics,
//         isHorizontal: isHorizontal,
//         shadow: shadow);
//   }

//   @override
//   void updateRenderObject(
//       BuildContext context, covariant RenderContentViewTextBody renderObject) {
//     renderObject
//       ..contentMetrics = contentMetrics
//       ..isHorizontal = isHorizontal
//       ..shadow = shadow;
//   }
// }

// class RenderContentViewTextBody extends RenderBox
//     with RenderObjectWithChildMixin<RenderBox> {
//   RenderContentViewTextBody({
//     required ContentMetricsText contentMetrics,
//     required bool shadow,
//     required bool isHorizontal,
//   })  : _contentMetrics = contentMetrics,
//         _shadow = shadow,
//         _isHorizontal = isHorizontal;

//   final TextPainter bottomLeft =
//       TextPainter(text: const TextSpan(), textDirection: TextDirection.ltr);

//   ContentMetricsText _contentMetrics;

//   ContentMetricsText get contentMetrics => _contentMetrics;
//   set contentMetrics(ContentMetricsText v) {
//     if (_contentMetrics == v) return;
//     _contentMetrics = v;
//     markNeedsLayout();
//   }

//   @override
//   Size computeDryLayout(BoxConstraints constraints) {
//     return constraints.biggest;
//   }

//   @override
//   void performLayout() {
//     size = constraints.biggest;
//   }

//   bool _isHorizontal;
//   bool get isHorizontal => _isHorizontal;
//   set isHorizontal(bool v) {
//     if (_isHorizontal == v) return;
//     _isHorizontal = v;
//     markNeedsPaint();
//   }

//   bool _shadow;
//   bool get shadow => _shadow;
//   set shadow(bool v) {
//     if (_shadow == v) return;
//     _shadow = v;
//     markNeedsPaint();
//   }

//   @override
//   void paint(PaintingContext context, Offset offset) {
//     // final _size = contentMetrics.size;
//     // context.setIsComplexHint();
//     final canvas = context.canvas;

//     paintText(
//       canvas,
//       bottomRight: contentMetrics.bottomRight,
//       cBigPainter: contentMetrics.cBigPainter,
//       extraHeight: contentMetrics.extraHeight,
//       fontSize: contentMetrics.fontSize,
//       index: contentMetrics.index,
//       isHorizontal: isHorizontal,
//       left: contentMetrics.left,
//       paddingRect: contentMetrics.paddingRect,
//       painters: contentMetrics.lines,
//       right: contentMetrics.right,
//       showrect: shadow,
//       size: contentMetrics.size,
//       titlePainter: contentMetrics.titleCname,
//       topExtraHeight: contentMetrics.topExtraHeight,
//     );
//   }

//   // @override
//   // bool hitTestSelf(ui.Offset position) => true;
// }
