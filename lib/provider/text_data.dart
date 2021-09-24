import 'package:flutter/material.dart';

import 'package:useful_tools/common.dart';

import 'constansts.dart';

class TextData {
  TextData(
      {List<ContentMetrics> content = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.rawContent,
      bool? hasContent})
      : _content = content,
        _hasContent = hasContent;

  List<ContentMetrics> get content => _content;
  final List<ContentMetrics> _content;
  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? _hasContent;
  final List<String>? rawContent;
  bool get hasContent => _hasContent ?? false;
  bool get isEmpty =>
      content.isEmpty ||
      cid == null ||
      pid == null ||
      nid == null ||
      cname == null ||
      _hasContent == null;

  bool get isNotEmpty => !isEmpty;

  bool get contentIsNotEmpty => isNotEmpty;
  bool get contentIsEmpty => isEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TextData &&
            cid == other.cid &&
            pid == other.pid &&
            nid == other.nid &&
            content == other.content &&
            cname == other.cname &&
            hasContent == other.hasContent;
  }

  TextData clone() {
    return TextData(
        content: _content.map((e) => e.clone()).toList(),
        cid: cid,
        pid: pid,
        nid: nid,
        cname: cname,
        hasContent: hasContent);
  }

  void dispose() {
    for (var element in _content) {
      element.dispose();
    }
  }

  @override
  int get hashCode => hashValues(cid, pid, nid, content, cname, hasContent);

  @override
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class ContentMetrics {
  const ContentMetrics({
    // required this.painters,
    // required this.extraHeightInLines,
    // required this.isHorizontal,
    required this.secstyle,
    // required this.fontSize,
    // required this.cPainter,
    // required this.botRightPainter,
    // required this.cBigPainter,
    // required this.right,
    required this.left,
    // required this.index,
    required this.size,
    // required this.windowTopPadding,
    // required this.showrect,
    // required this.topExtraHeight,
    required this.picture,
  });
  // final List<TextPainter> painters;
  // final double extraHeightInLines;
  final TextStyle secstyle;
  // final double fontSize;
  // final bool isHorizontal;
  // final TextPainter cPainter;
  // final TextPainter botRightPainter;
  // final TextPainter cBigPainter;
  // final double right;
  final double left;
  // final int index;
  final Size size;
  // final double windowTopPadding;
  // final bool showrect;
  // final double topExtraHeight;
  final PictureRefInfo picture;

  ContentMetrics clone() {
    return ContentMetrics(
        secstyle: secstyle, left: left, size: size, picture: picture.clone());
  }

  void dispose() {
    picture.dispose();
  }
}

class ContentMetricsText implements ContentMetrics {
  ContentMetricsText(
      {required this.lines,
      required this.secStyle,
      required this.extraHeight,
      required this.fontSize,
      required this.titleCname,
      required this.bottomRight,
      required this.cBigPainter,
      required this.right,
      required this.left,
      required this.index,
      required this.size,
      required this.paddingRect,
      required this.topExtraHeight});
  final TextStyle secStyle;
  final double extraHeight;
  final double fontSize;
  final TextPainter titleCname;
  final TextPainter bottomRight;
  final TextPainter cBigPainter;
  final double right;
  @override
  final double left;
  final int index;
  @override
  final Size size;
  final EdgeInsets paddingRect;
  final double topExtraHeight;
  final List<TextPainter> lines;

  @override
  ContentMetricsText clone() => this;

  @override
  void dispose() {}

  @override
  PictureRefInfo get picture => throw '使用 ContentViewText';

  @override
  TextStyle get secstyle => secStyle;
}

void paintText(Canvas canvas,
    {required List<TextPainter> painters,
    required double extraHeight,
    required double fontSize,
    required bool isHorizontal,
    required TextPainter titlePainter,
    required TextPainter bottomRight,
    required TextPainter cBigPainter,
    required double right,
    required double left,
    required int index,
    required Size size,
    required EdgeInsets paddingRect,
    required bool showrect,
    required double topExtraHeight}) {
  final _size = size;
  final _windowTopPadding = isHorizontal ? paddingRect.top : 0.0;

  var h = 0.0;
  canvas.translate(left, _windowTopPadding);
  if (isHorizontal) {
    h += contentTopPad;
    titlePainter.paint(canvas, Offset(0.0, h));
    // h += titlePainter.height;
    h += contentFooterSize;
  }
  if (index == 0) {
    if (!isHorizontal) {
      h -= contentPadding;
    }
    h += topExtraHeight;
    cBigPainter.paint(canvas, Offset(0.0, h - cBigPainter.height));
    if (!isHorizontal) {
      h += contentPadding;
    }
  }

  if (isHorizontal) h += contentPadding;

  final xh = h;
  final _e = extraHeight / 2;
  final _end = _e + fontSize;
  for (var _tep in painters) {
    h += _e;
    _tep.paint(canvas, Offset(0.0, h));

    h += _end;
  }
  if (showrect) {
    canvas.drawRect(Rect.fromLTWH(0.0, xh, _size.width, h - xh),
        Paint()..color = Colors.black.withAlpha(100));
  }
  if (isHorizontal) {
    final bottom = _size.height +
        paddingRect.bottom -
        contentFooterSize -
        contentBotttomPad;
    bottomRight.paint(canvas, Offset(right, bottom));
  }
}
