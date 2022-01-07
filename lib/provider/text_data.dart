import 'package:flutter/material.dart';

import 'package:useful_tools/common.dart';

import 'book_index_notifier.dart';
import 'constants.dart';

class TextData {
  TextData(
      {List<ContentMetrics> content = const [],
      this.cid,
      this.pid,
      this.nid,
      this.cname,
      this.api = ApiType.biquge,
      bool? hasContent})
      : _content = content,
        _hasContent = hasContent;
  final ApiType api;
  List<ContentMetrics> get content => _content;
  final List<ContentMetrics> _content;
  final int? cid;
  final int? pid;
  final int? nid;
  final String? cname;
  final bool? _hasContent;
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
  String toString() {
    return 'cid: $cid, pid: $pid, nid: $nid, cname: $cname';
  }
}

class ContentMetrics {
  const ContentMetrics({
    required this.secstyle,
    required this.left,
    required this.size,
    required this.picture,
  });

  final TextStyle secstyle;
  final double left;
  final Size size;
  final PictureRefInfo picture;

  ContentMetrics clone() {
    return ContentMetrics(
        secstyle: secstyle, left: left, size: size, picture: picture.clone());
  }

  void dispose() {
    picture.dispose();
  }
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
    h += contentFontSize;
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
    canvas.drawRRect(RRect.fromLTRBXY(0.0, xh, _size.width, h, 5, 5),
        Paint()..color = Colors.black.withAlpha(100));
  }
  if (isHorizontal) {
    final bottom = _size.height +
        paddingRect.bottom -
        contentFontSize -
        contentBotttomPad;
    bottomRight.paint(canvas, Offset(right, bottom));
  }
}
