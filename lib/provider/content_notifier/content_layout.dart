import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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

  Future<List<ContentMetrics>> asyncLayout(
      List<String> paragraphs, String cname) async {
    var whiteRows = 0;

    final textPages = <ContentMetrics>[];

    final fontSize = style.fontSize!;

    final config = this.config.value.copyWith();

    final words = (size.width - _contentLayoutPadding.horizontal) ~/ fontSize;

    final _size = _contentLayoutPadding.deflateSize(size);
    final width = _size.width;
    final leftExtraPadding = (width % fontSize) / 2;
    final left = _contentLayoutPadding.left + leftExtraPadding;

    // 文本占用高度
    final contentHeight = _size.height - contentWhiteHeight;

    // 配置行高
    final lineHeight = config.lineTweenHeight! * fontSize;

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

    final _oneHalf = fontSize * 1.6;

    final lines = <TextPainter>[];

    final _t = TextPainter(textDirection: TextDirection.ltr);
    // 只需要最小的位移，会自动计算位置
    final _offset = Offset(width, 0.1);
    // 分行布局
    for (var i = 0; i < paragraphs.length; i++) {
      if (_key != key) return const [];

      // character 版本
      final pc = paragraphs[i].characters;
      var start = 0;
      while (start < pc.length) {
        var end = math.min(start + words, pc.length);
        await releaseUI;

        // 确定每一行的字数
        while (true) {
          if (end >= pc.length) break;

          end++;
          final s = pc.getRange(start, end).toString();
          _t
            ..text = TextSpan(text: s, style: style)
            ..layout(maxWidth: width);

          await releaseUI;

          if (_t.height > _oneHalf) {
            final endOffset = _t.getPositionForOffset(_offset).offset;
            final _s = s.substring(0, endOffset).characters;
            assert(() {
              if (endOffset != _s.length) {
                // Unicode 字符占用的字节数不相等
                // 避免多字节字符导致 [subString] 出错
                Log.i('no: $_s |$start, ${pc.length}');
              }
              return true;
            }());
            end = start + _s.length;
            break;
          }
        }

        await releaseUI;
        final _s = pc.getRange(start, end).toString();
        if (end == pc.length && _s.replaceAll(regexpEmpty, '').isEmpty) break;

        final _text = TextPainter(
            text: TextSpan(text: _s, style: style),
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: width);

        start = end;
        lines.add(_text);
      }
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
    final isHorizontal = config.axis == Axis.horizontal;
    await releaseUI;
    if (_key != key) {
      return const [];
    }
    bool error = false;
    // 添加页面信息
    for (var r = 0; r < pages.length; r++) {
      final bottomRight = TextPainter(
          text: TextSpan(text: '${r + 1}/${pages.length}页', style: secstyle),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: width);

      final right = width - bottomRight.width - leftExtraPadding * 2;
      if (_key != key) {
        error = true;
        break;
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
