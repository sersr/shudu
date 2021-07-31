// ignore_for_file: unused_import

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../provider/provider.dart';

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
    final ts = context.read<TextStyleConfig>();

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

    return Selector<OptionsNotifier, bool>(
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
        child: child);
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
  late TextStyleConfig ts;

  late List _keys;

  @override
  void initState() {
    super.initState();
    _updateKeys();
  }

  void _updateKeys() {
    _keys = [
      runtimeType, // 以[runtimeType]识别布局方式
      widget.maxWidth,
      widget.topRightScore,
      widget.top,
      widget.center,
      widget.bottom,
      1,
      1,
      widget.centerLines,
      widget.bottomLines
    ];
  }

  @override
  void didUpdateWidget(covariant _CacheText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateKeys();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ts = context.read<TextStyleConfig>();
  }

  @override
  Widget build(BuildContext context) {
    return TextBuilder(
      keys: _keys,
      layout: _layoutText,
      builder: (infos, error) {
        return _items(infos);
      },
    );
  }

  // 如果是一个匿名函数每次重建都会新建一个对象
  Future<void> _layoutText(FindTextInfo _, PutIfAbsentText putIfAbsent) async {
    final tpr = _painter(widget.topRightScore,
        style: ts.body2.copyWith(color: Colors.yellow.shade700), maxLines: 1);

    final tp = _painter(widget.top, style: ts.title3, maxLines: 1);

    final tc =
        _painter(widget.center, style: ts.body2, maxLines: widget.centerLines);

    final tb =
        _painter(widget.bottom, style: ts.body3, maxLines: widget.bottomLines);

    final topRightKey = [widget.maxWidth, widget.topRightScore, 1];
    final _tpr = await putIfAbsent(topRightKey, () async {
      return tpr..layout(maxWidth: widget.maxWidth);
    });

    final _tpWidth = _tpr.painter.width;

    final topWidth = widget.maxWidth - _tpWidth;
    final topKey = [topWidth, widget.top, 1];
    await putIfAbsent(topKey, () async {
      return tp..layout(maxWidth: topWidth);
    });

    final centerKey = [widget.maxWidth, widget.center, widget.centerLines];
    await putIfAbsent(centerKey, () async {
      return tc..layout(maxWidth: widget.maxWidth);
    });

    final bottomKey = [widget.maxWidth, widget.bottom, widget.bottomLines];
    await putIfAbsent(bottomKey, () async {
      return tb..layout(maxWidth: widget.maxWidth);
    });
    await EventQueue.scheduler.endOfFrame;
  }

  Widget _items(Iterable<TextInfo>? data) {
    final length = data?.length;
    if (data != null && length! >= 4) {
      return ItemWidget(
          height: widget.height,
          topRight: AsyncText.async(data.elementAt(0).painter),
          top: AsyncText.async(data.elementAt(1).painter),
          center: AsyncText.async(data.elementAt(2).painter),
          bottom: AsyncText.async(data.elementAt(3).painter));
    } else {
      return const SizedBox();
    }
  }

  TextPainter _painter(String? text,
      {required TextStyle style, int maxLines = 1}) {
    return TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: maxLines,
        ellipsis: '...',
        textDirection: TextDirection.ltr);
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
    final constraints = BoxConstraints.loose(size);

    var topRight = Size.zero;
    final hasRight = hasChild(_topRight);
    if (hasRight) topRight = layoutChild(_topRight, constraints);
    if (hasChild(_top) && hasChild(_center) && hasChild(_bottom)) {
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
