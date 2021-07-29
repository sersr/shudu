// ignore_for_file: unused_import

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:useful_tools/useful_tools.dart';

import '../provider/provider.dart';

class TextBuilder extends StatelessWidget {
  const TextBuilder({
    Key? key,
    this.topRightScore,
    this.top,
    this.center,
    this.bottom,
    this.centerLines = 1,
    this.bottomLines = 2,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String? top;
  final String? center;
  final String? bottom;
  final double height;
  final int centerLines;
  final int bottomLines;
  @override
  Widget build(BuildContext context) {
    final ts = context.read<TextStyleConfig>();

    final child = ItemWidget(
        topRight: topRightScore != null
            ? Text('$topRightScore',
                style: ts.body2.copyWith(color: Colors.yellow.shade700),
                maxLines: 1,
                textDirection: TextDirection.ltr)
            : null,
        top: Text('$top',
            style: ts.title3, maxLines: 1, textDirection: TextDirection.ltr),
        center: Text('$center',
            style: ts.body2,
            maxLines: centerLines,
            textDirection: TextDirection.ltr),
        bottom: Text('$bottom',
            style: ts.body3,
            maxLines: bottomLines,
            textDirection: TextDirection.ltr));

    return Selector<OptionsNotifier, bool>(
        selector: (_, opt) => opt.options.useTextCache ?? false,
        builder: (context, useTextCache, child) {
          if (useTextCache)
            return LayoutBuilder(builder: (context, constraints) {
              return _TextBuilder(
                top: top,
                topRightScore: topRightScore,
                center: center,
                bottom: bottom,
                height: height,
                centerLines: centerLines,
                bottomLines: bottomLines,
                constraints: constraints,
              );
            });
          return child!;
        },
        child: child);
  }
}

class _TextBuilder extends StatefulWidget {
  const _TextBuilder({
    Key? key,
    this.topRightScore,
    this.top,
    this.center,
    this.bottom,
    this.centerLines = 1,
    this.bottomLines = 2,
    required this.constraints,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String? top;
  final String? center;
  final String? bottom;
  final double height;
  final BoxConstraints constraints;
  final int centerLines;
  final int bottomLines;
  @override
  State<_TextBuilder> createState() => _TextBuilderState();
}

class _TextBuilderState extends State<_TextBuilder> {
  late TextStyleConfig ts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ts = context.read<TextStyleConfig>();
    _subText();
  }

  @override
  void didUpdateWidget(_TextBuilder o) {
    super.didUpdateWidget(o);
    if (o.top != widget.top ||
        o.topRightScore != widget.topRightScore ||
        o.center != widget.center ||
        o.bottom != widget.bottom ||
        o.constraints != widget.constraints) _subText();
  }

  List<TextInfo>? textInfos;

  TextPainter _painter(String? text,
      {required TextStyle style, int maxLines = 1}) {
    return TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: maxLines,
        ellipsis: '...',
        textDirection: TextDirection.ltr);
  }

  void _subText() {
    final width = widget.constraints.maxWidth;
    final top = widget.top;
    final topRight = widget.topRightScore;
    final center = widget.center;
    final bottom = widget.bottom;
    final centerLines = widget.centerLines;
    final bottomLines = widget.bottomLines;

    final keys = [
      // 'asyncText_builder',
      width,
      topRight,
      top,
      center,
      bottom,
      1,
      1,
      centerLines,
      bottomLines
    ];

    final all = textCache!.putIfAbsent(keys, (find, putIfAbsent) async {
      final tpr = _painter(widget.topRightScore,
          style: ts.body2.copyWith(color: Colors.yellow.shade700), maxLines: 1);

      final tp = _painter(widget.top, style: ts.title3, maxLines: 1);

      final tc = _painter(widget.center,
          style: ts.body2, maxLines: widget.centerLines);

      final tb = _painter(widget.bottom,
          style: ts.body3, maxLines: widget.bottomLines);

      final topRightKey = [width, topRight, 1];
      final _tpr = await putIfAbsent(topRightKey, () async {
        // await releaseUI;
        return tpr..layout(maxWidth: width);
      });

      final _tpWidth = _tpr.painter.width;

      final topWidth = width - _tpWidth;
      final topKey = [topWidth, top, 1];
      await putIfAbsent(topKey, () async {
        // await releaseUI;
        return tp..layout(maxWidth: topWidth);
      });

      final centerKey = [width, center, centerLines];
      await putIfAbsent(centerKey, () async {
        // await releaseUI;
        return tc..layout(maxWidth: width);
      });

      final bottomKey = [width, bottom, bottomLines];
      await putIfAbsent(bottomKey, () async {
        // await releaseUI;
        return tb..layout(maxWidth: width);
      });
      await EventQueue.scheduler.endOfFrame;
    });

    if (all != _textStream) {
      _textStream?.removeListener(onTextListener);
      all.addListener(onTextListener);
      _textStream = all;
    }
  }

  TextStream? _textStream;

  void onTextListener(List<TextInfo>? infos, bool error) {
    setState(() {
      textInfos?.forEach((info) => info.dispose());
      textInfos = infos;
    });
  }

  @override
  void dispose() {
    super.dispose();
    textInfos?.forEach((info) => info.dispose());
    _textStream?.removeListener(onTextListener);
  }

  @override
  Widget build(BuildContext context) {
    return _items(textInfos);
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
    final _top = 'top';
    final _topRight = 'topRight';
    final _center = 'center';
    final _bottom = 'bottom';
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