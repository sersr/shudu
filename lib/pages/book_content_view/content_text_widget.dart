import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../utils/utils.dart';

class ContentText extends MultiChildRenderObjectWidget {
  ContentText(
      {this.cname,
      this.showRect = false,
      required List<Widget> children,
      this.page,
      this.maxPage,
      this.style,
      this.secstyle,
      this.lineHeight})
      : super(children: children);
  final String? cname;
  final int? page;
  final int? maxPage;
  final TextStyle? style;
  final TextStyle? secstyle;
  final double? lineHeight;
  final bool showRect;
  @override
  RenderObject createRenderObject(BuildContext context) => ContentTextRenderObject(
      cname: cname,
      page: page,
      maxPage: maxPage,
      style: style!,
      secstyle: secstyle,
      lineHeight: lineHeight,
      showRect: showRect);

  @override
  void updateRenderObject(BuildContext context, covariant ContentTextRenderObject renderObject) {
    renderObject
      ..cname = cname
      ..page = page
      ..maxPage = maxPage
      ..style = style
      ..secstyle = secstyle
      ..showRect = showRect
      ..lineHeight = lineHeight;
  }
}

class MParentData extends ContainerBoxParentData<RenderBox> {}

class ContentTextRenderObject extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MParentData>, RenderBoxContainerDefaultsMixin<RenderBox, MParentData> {
  ContentTextRenderObject({
    String? cname,
    int? page,
    int? maxPage,
    required TextStyle style,
    TextStyle? secstyle,
    double? lineHeight,
    bool? showRect,
    List<RenderBox>? children,
  })  : _cname = cname,
        _page = page,
        _maxPage = maxPage,
        _style = style,
        _secstyle = secstyle,
        _lineHeight = lineHeight,
        _showRect = showRect,
        cPainter = TextPainter(
            text:
                TextSpan(text: cname, style: TextStyle(fontSize: 22, color: style.color, fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr) {
    final time = DateTime.now();
    cnamePainter = TextPainter(text: TextSpan(text: cname, style: secstyle), textDirection: TextDirection.ltr);
    bottomLeft = TextPainter(
        text: TextSpan(text: '${time.hour.timePadLeft}:${time.minute.timePadLeft}', style: secstyle),
        textDirection: TextDirection.ltr);
    bottomRight =
        TextPainter(text: TextSpan(text: '$page/$maxPage页', style: secstyle), textDirection: TextDirection.ltr);
    addAll(children);
  }

  double? _lineHeight;
  double? get lineHeight => _lineHeight;
  set lineHeight(double? v) {
    if (_lineHeight == v) return;
    _lineHeight = v;
    markNeedsLayout();
  }

  String? _cname;
  String? get cname => _cname;
  set cname(String? v) {
    if (_cname == v) return;
    _cname = v;
    cnamePainter.text = TextSpan(text: _cname, style: secstyle);
    cPainter.text =
        TextSpan(text: cname, style: TextStyle(fontSize: 22, color: _secstyle!.color, fontWeight: FontWeight.bold));
    markNeedsLayout();
  }

  int? _page;
  int? get page => _page;
  set page(int? v) {
    if (_page == v) return;
    _page = v;
    markNeedsLayout();
  }

  int? _maxPage;
  int? get maxPage => _maxPage;
  set maxPage(int? v) {
    if (_maxPage == v) return;
    _maxPage = v;
    markNeedsLayout();
  }

  TextStyle? _style;
  TextStyle? get style => _style;
  set style(TextStyle? v) {
    if (_style == v) return;
    _style = v;
    markNeedsLayout();
  }

  TextStyle? _secstyle;
  TextStyle? get secstyle => _secstyle;
  set secstyle(TextStyle? v) {
    if (_secstyle == v) return;
    _secstyle = v;
    if (cnamePainter.text!.style != _secstyle) {
      cnamePainter.text = TextSpan(text: cname, style: _secstyle);
      markNeedsLayout();
    }
    if (cPainter.text!.style!.color != _secstyle!.color) {
      cPainter.text =
          TextSpan(text: cname, style: TextStyle(fontSize: 22, color: _secstyle!.color, fontWeight: FontWeight.bold));
      markNeedsLayout();
    }
  }

  bool? _showRect;
  bool? get showRect => _showRect;
  set showRect(bool? v) {
    if (_showRect == v) return;
    _showRect = v;
    markNeedsPaint();
  }

  late TextPainter cnamePainter;
  late TextPainter bottomLeft;
  late TextPainter bottomRight;
  TextPainter cPainter;

  double exh = 0.0;
  double page1 = 0.0;
  double leftPadding = 0.0;
  final double topTop = 8.0;
  final double padding = 12.0;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! MParentData) {
      child.parentData = MParentData();
    }
  }

  double right = 0.0;

  @override
  void performLayout() {
    size = constraints.biggest;
    var ph = 0.0;
    final width = size.width - 32.0;
    // var now = DateTime.now().microsecondsSinceEpoch;
    var now = Timeline.now;
    cnamePainter.layout(maxWidth: width);
    bottomRight.layout(maxWidth: width);
    bottomLeft.layout(maxWidth: width);
    print('用时: ${(Timeline.now - now) / 1000}ms');
    now = Timeline.now;
    // print('o layout: ${(DateTime.now().microsecondsSinceEpoch - now) / 1000}ms');
    // now = DateTime.now().microsecondsSinceEpoch;
    leftPadding = (width % style!.fontSize!) / 2;
    if (childCount == 0) {
      return;
    }
    var nheight = size.height - cnamePainter.height - bottomLeft.height - padding * 2 - topTop - 4.0;
    var child = firstChild;
    final boxConstraints = BoxConstraints(maxWidth: width);
    while (child != null) {
      child.layout(boxConstraints, parentUsesSize: true);
      ph += child.size.height;
      child = childAfter(child);
    }
    if (page == 1) {
      cPainter.layout(maxWidth: width);
      page1 = firstChild!.size.height * 3 * lineHeight! + cPainter.height;
      nheight -= page1;
    }
    final height = nheight / lineHeight!;
    if (height > ph + firstChild!.size.height * 2) {
      exh = (lineHeight! - 1) * firstChild!.size.height;
    } else {
      exh = ((nheight - ph) / childCount).clamp(0.0, firstChild!.size.height);
    }
    left = 16.0 + leftPadding;
    right = size.width - bottomRight.width - left * 2;
    print('用时: ${(Timeline.now - now) / 1000}ms');

    // print('content layout: ${(DateTime.now().microsecondsSinceEpoch - now) / 1000}ms');
  }

  // void paint(PaintingContext context, Offset offset) {
  //   npaint(context, offset);
  // }
  double left = 0.0;
  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx + left, offset.dy);
    var h = topTop;
    cnamePainter.paint(canvas, Offset(0.0, h));
    // canvas.drawRect(Offset(0.0, h) & Size(size.width, bottomRight.height), Paint()..color = Colors.black12);
    h += cnamePainter.height;
    if (page == 1) {
      // assert(page1 > cPainter.height || Log.i('page1 > cPainter.height', stage: this, name: 'paint'));
      h += page1;
      cPainter.paint(canvas, Offset(0.0, h - cPainter.height));
      // canvas.drawRect(
      //     Offset(0.0, h - cPainter.height) & Size(size.width, cPainter.height), Paint()..color = Colors.black12);
    }
    if (showRect!) {
      canvas.drawRect(Offset(0.0, h) & Size(size.width - left * 2, size.height - h * 2 + page1),
          Paint()..color = Colors.black.withAlpha(100));
    }

    /// padding
    // canvas.drawRect(Offset(0.0, h) & Size(size.width, padding + exh / 2), Paint()..color = Colors.black12);
    h += padding + exh / 2;
    var child = firstChild;
    while (child != null) {
      context.paintChild(child, Offset(0.0, h));
      h += child.size.height + exh;
      child = childAfter(child);
    }

    /// padding
    // canvas.drawRect(Offset(0.0, h - exh) & Size(size.width, padding + exh/ 2 ), Paint()..color = Colors.black12);
    bottomLeft.paint(canvas, Offset(0.0, size.height - bottomLeft.height - 4.0));
    bottomRight.paint(canvas, Offset(right, size.height - bottomRight.height - 4.0));
    // canvas.drawRect(
    //     Offset(size.width - bottomRight.width - left - 16.0, size.height - bottomLeft.height - 4.0) &
    //         Size(bottomRight.width, bottomRight.height),
    //     Paint()..color = Colors.black12);

    canvas.restore();
  }

  @override
  bool hitTestSelf(Offset position) => true;
  // @override
  // bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
  //   return defaultHitTestChildren(result, position: position);
  // }
}

class LineText extends LeafRenderObjectWidget {
  LineText({required this.text});
  final TextSpan text;
  @override
  RenderObject createRenderObject(BuildContext context) => RenderLineText(textSpan: text);
  @override
  void updateRenderObject(BuildContext context, covariant RenderLineText renderObject) {
    renderObject.textSpan = text;
  }
}

class RenderLineText extends RenderBox {
  RenderLineText({TextSpan? textSpan})
      : _textSpan = textSpan,
        _painter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.longestLine,
        );
  final TextPainter _painter;

  TextSpan? _textSpan;
  TextSpan? get textSpan => _textSpan;
  set textSpan(TextSpan? v) {
    if (_textSpan == v) return;
    _textSpan = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    _painter.layout(maxWidth: constraints.maxWidth);
    size = Size(_painter.width < 0 ? 0.0 : _painter.width, _painter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // context.canvas
    //     .drawRect(offset & Size(constraints.maxWidth, size.height), Paint()..color = Colors.black.withAlpha(100));
    _painter.paint(context.canvas, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) => true;
}
