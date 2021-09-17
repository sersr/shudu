import 'dart:ui';
import 'package:flutter/painting.dart';

import 'package:useful_tools/common.dart';

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
