import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:nop/event_queue.dart';
import 'package:useful_tools/useful_tools.dart';

import '../constants.dart';
import '../text_data.dart';
import 'content_base.dart';
import 'content_config.dart';

mixin ContentLayout on ContentDataBase, Configs {
  bool showrect = false;

  /// 文本布局信息
  Size size = Size.zero;
  EdgeInsets get contentLayoutPadding => _contentLayoutPadding;
  set contentLayoutPadding(EdgeInsets v) {
    _contentLayoutPadding = v;
  }

  var _contentLayoutPadding = EdgeInsets.zero;
  bool _addText(int end, Characters paragraph, String current) {
    return end != paragraph.length ||
        current.replaceAll(regexpEmpty, '').isNotEmpty;
  }

  Future<List<ContentMetrics>> asyncLayout(
      List<String> paragraphs, String cname) async {
    var whiteRows = 0;

    final textPages = <ContentMetrics>[];

    final fontSize = style.fontSize!;

    final _config = config.value;
    final isHorizontal = _config.axis == Axis.horizontal;

    final _size = _contentLayoutPadding.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = _contentLayoutPadding.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - contentWhiteHeight;

    // 配置行高
    final lineHeight = _config.lineTweenHeight! * fontSize;

    final _allExtraHeight = contentHeight % lineHeight;

    // lineCounts
    final rows = contentHeight ~/ lineHeight;

    if (rows <= 0) return textPages;

    final hl = _allExtraHeight / rows;
    // 实际行高
    final lineHeightAndExtra = hl + lineHeight;
    final _key = key;

    await releaseUI;
    // 大标题
    final TextPainter _bigTitlePainter = TextPainter(
        text: TextSpan(
            text: cname,
            style: style.copyWith(
                fontSize: 22, height: 1.2, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: width);

    await releaseUI;
    // 小标题
    final TextPainter smallTitlePainter = TextPainter(
        text: TextSpan(text: cname, style: secstyle),
        ellipsis: '...',
        textDirection: TextDirection.ltr,
        maxLines: 1)
      ..layout(maxWidth: width);

    whiteRows = 150 ~/ lineHeightAndExtra + 1;

    while (lineHeightAndExtra * whiteRows > 140) {
      whiteRows--;
      if (lineHeightAndExtra * whiteRows < 130) break;
      await releaseUI;
    }

    final lines = <TextPainter>[];
    paragraphs.removeWhere((element) =>
        element.isEmpty || element.replaceAll(regexpEmpty, '').isEmpty);

    if (paragraphs.isNotEmpty) {
      var first = paragraphs.first;
      if (!first.startsWith('\u3000\u3000')) {
        if (first.startsWith(regexpEmpty)) {
          first = first.replaceFirst(regexpEmpty, '\u3000\u3000');
        } else {
          first = '\u3000\u3000$first';
        }
        paragraphs[0] = first;
      }
    }
    // 分行布局
    for (var i = 0; i < paragraphs.length; i++) {
      if (_key != key || !inBook) return const [];
      final para = await TextCache.textPainter(
          text: paragraphs[i], width: width, style: style, addText: _addText);
      lines.addAll(para);
    }

    await releaseUI;
    var topExtraRows = (_bigTitlePainter.height / fontSize).floor();
    if (topExtraRows > 2) {
      if (whiteRows > 2) {
        whiteRows--;
      }
    }
    final pages = <List<TextPainter>>[];
    // 首页留白和标题
    final firstPages = math.max(0, rows - whiteRows - topExtraRows);
    pages.add(lines.sublist(0, math.min(firstPages, lines.length)));

    // 分页
    if (firstPages < lines.length - 1)
      for (var i = firstPages; i < lines.length;) {
        pages.add(lines.sublist(i, (i + rows).clamp(i, lines.length)));
        i += rows;
      }

    var extraHeight = lineHeightAndExtra - fontSize;
    await releaseUI;
    if (_key != key || !inBook) return const [];

    bool error = false;
    // 添加页面信息
    for (var r = 0; r < pages.length; r++) {
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

      final right = width - bottomRight.width - leftExtraPadding * 2;
      if (_key != key || !inBook) {
        error = true;
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      await releaseUI;

      paintText(canvas,
          painters: pages[r],
          extraHeight: extraHeight,
          isHorizontal: isHorizontal,
          fontSize: fontSize,
          titlePainter: smallTitlePainter,
          bottomRight: bottomRight,
          cBigPainter: _bigTitlePainter,
          right: right,
          left: left,
          index: r,
          size: _size,
          paddingRect: _contentLayoutPadding,
          showrect: showrect,
          topExtraHeight: lineHeightAndExtra * (whiteRows + topExtraRows));
      await releaseUI;

      final picture = recorder.endRecording();
      await releaseUI;

      final met = ContentMetrics(
        picture: PictureRefInfo(picture),
        secstyle: secstyle,
        left: left,
        size: _size,
      );
      textPages.add(met);
    }
    if (error) {
      for (var text in textPages) {
        text.dispose();
      }
      return const [];
    }
    return textPages;
  }
}
