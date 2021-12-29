// ignore_for_file: unused_import

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../provider/export.dart';

class TextAsyncLayout extends StatelessWidget {
  const TextAsyncLayout({
    Key? key,
    this.topRightScore,
    required this.top,
    required this.center,
    required this.bottom,
    this.centerLines = 1,
    this.bottomLines = 2,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String top;
  final String center;
  final String bottom;
  final double height;
  final int centerLines;
  final int bottomLines;
  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>().data;
    final child = ItemWidget(
        topRight: topRightScore != null
            ? Text(topRightScore ?? '',
                style: ts.body2.copyWith(color: Colors.yellow.shade700),
                maxLines: 1,
                textDirection: TextDirection.ltr)
            : null,
        top: Text(top,
            style: ts.title3, maxLines: 1, textDirection: TextDirection.ltr),
        center: Text(center,
            style: ts.body2,
            maxLines: centerLines,
            textDirection: TextDirection.ltr),
        bottom: Text(bottom,
            style: ts.body3,
            maxLines: bottomLines,
            textDirection: TextDirection.ltr));

    return RepaintBoundary(
      child: Selector<OptionsNotifier, bool>(
          selector: (_, opt) => opt.options.useTextCache ?? false,
          builder: (context, useTextCache, child) {
            /// 只有绑定 [CacheBinding] 才能启用
            if (useTextCache && textCache != null)
              return LayoutBuilder(builder: (context, constraints) {
                return _CacheText(
                    bottom: bottom,
                    top: top,
                    topRightScore: topRightScore,
                    center: center,
                    centerLines: centerLines,
                    bottomLines: bottomLines,
                    height: height,
                    maxWidth: constraints.maxWidth);
              });

            return child!;
          },
          child: child),
    );
  }
}

class _CacheText extends StatefulWidget {
  const _CacheText({
    Key? key,
    this.topRightScore,
    required this.top,
    required this.center,
    required this.bottom,
    required this.maxWidth,
    this.centerLines = 1,
    this.bottomLines = 2,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String top;
  final String center;
  final String bottom;
  final double height;
  final int centerLines;
  final int bottomLines;
  final double maxWidth;

  @override
  State<_CacheText> createState() => _CacheTextState();
}

class _CacheTextState extends State<_CacheText> {
  late TextStyleConfig tsConfig;

  @override
  void didUpdateWidget(covariant _CacheText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _layoutText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tsConfig = context.read<TextStyleConfig>();
  }

  @override
  void initState() {
    super.initState();
    _layoutText();
  }

  @override
  Widget build(BuildContext context) {
    return _items();
  }

  TextPainter? dataTopR;
  TextPainter? dataTop;
  List<TextPainter>? dataCenter;
  List<TextPainter>? dataBottom;

  Future<void> _layoutText() async {
    await releaseUI;

    final topR = widget.topRightScore;
    final width = widget.maxWidth;
    final ts = tsConfig.data;
    final trs = ts.body2.copyWith(color: Colors.yellow.shade700);
    TextPainter? topRText;
    if (topR != null) {
      final t = await TextCache.textPainter(
          text: topR,
          width: width,
          dir: TextDirection.ltr,
          style: trs,
          maxLines: 1,
          ellipsis: '...');
      topRText = t.first;
    }

    await releaseUI;
    final _tpWidth = topRText?.width ?? 0;

    final topWidth = widget.maxWidth - _tpWidth;
    final style = ts.title2;
    final topText = await TextCache.textPainter(
        text: widget.top,
        width: topWidth,
        dir: TextDirection.ltr,
        style: style,
        maxLines: 1,
        ellipsis: '...');

    await releaseUI;
    final centerText = await TextCache.textPainter(
        text: widget.center,
        width: width,
        dir: TextDirection.ltr,
        style: ts.body2,
        maxLines: widget.centerLines,
        ellipsis: '...');

    await releaseUI;
    final bottomText = await TextCache.textPainter(
        text: widget.bottom,
        width: width,
        dir: TextDirection.ltr,
        style: ts.body3,
        maxLines: widget.bottomLines,
        ellipsis: '...');

    await releaseUI;

    if (mounted) {
      setState(() {
        dataTopR = topRText;
        dataTop = topText.first;
        dataCenter = centerText;
        dataBottom = bottomText;
      });
    }
  }

  Widget item(TextPainter text) {
    return AsyncText.async(text);
  }

  Widget _items() {
    Widget child;
    Widget? top;
    Widget? topR;
    Widget? center;
    Widget? bottom;
    if (dataTop != null) {
      top = item(dataTop!);
    }
    if (dataTopR != null) {
      topR = item(dataTopR!);
    }
    if (dataCenter != null) {
      center = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dataCenter!.map(item).toList());
    }
    if (dataBottom != null) {
      bottom = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dataBottom!.map(item).toList());
    }

    if (top != null && center != null && bottom != null) {
      child = ItemWidget(
          height: widget.height,
          topRight: topR,
          top: top,
          center: center,
          bottom: bottom);
    } else {
      child = ItemWidget(height: widget.height);
    }
    return child;
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    this.bottom,
    this.center,
    this.top,
    this.topRight,
    this.height = 112,
  }) : super(key: key);

  final Widget? top;
  final Widget? topRight;
  final Widget? center;
  final Widget? bottom;
  final double height;
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomMultiChildLayout(
        delegate: _ItemLayoutDelegate(height),
        children: [
          if (top != null) LayoutId(id: 'top', child: top!),
          if (topRight != null) LayoutId(id: 'topRight', child: topRight!),
          if (center != null) LayoutId(id: 'center', child: center!),
          if (bottom != null) LayoutId(id: 'bottom', child: bottom!),
        ],
      ),
    );
  }
}

class _ItemLayoutDelegate extends MultiChildLayoutDelegate {
  _ItemLayoutDelegate(this.height);
  final double height;

  @override
  void performLayout(Size size) {
    const _top = 'top';
    const _topRight = 'topRight';
    const _center = 'center';
    const _bottom = 'bottom';
    if (hasChild(_top) && hasChild(_center) && hasChild(_bottom)) {
      final constraints = BoxConstraints.loose(size);

      var topRight = Size.zero;
      final hasRight = hasChild(_topRight);
      if (hasRight) topRight = layoutChild(_topRight, constraints);
      final top = layoutChild(
          _top,
          constraints.copyWith(
              minWidth: constraints.maxWidth - topRight.width));

      final center = layoutChild(_center, constraints);
      final bottom = layoutChild(_bottom, constraints);
      var cHeight = 0.0;
      var height = 0.0;
      final _topHeight = math.max(top.height, topRight.height);
      height = _topHeight + center.height + bottom.height;

      final d = (size.height - 10 - height) / 4;
      cHeight = d + 2.5;

      positionChild(_top, Offset(0, cHeight));
      if (hasRight)
        positionChild(_topRight, Offset(size.width - topRight.width, cHeight));
      cHeight += _topHeight + d;
      positionChild(_center, Offset(0, cHeight));
      cHeight += center.height + d;
      positionChild(_bottom, Offset(0, cHeight));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(constraints.biggest.width, constraints.constrainHeight(height));
}
