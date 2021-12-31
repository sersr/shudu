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
                return ItemAsyncLayout(
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

class ItemAsyncLayout extends StatelessWidget {
  const ItemAsyncLayout({
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
  Widget build(BuildContext context) {
    return AsyncTextBuilder(builder: (_, List<List<TextPainter>?> data) {
      Widget child;
      Widget? top;
      Widget? topR;
      Widget? center;
      Widget? bottom;
      Widget item(TextPainter text) {
        return AsyncText.async(text);
      }

      Widget wrap(List<TextPainter> data) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map(item).toList());
      }

      if (data.length != 4) {
        return const SizedBox();
      }
      final dataTopR = data[0];
      final dataTop = data[1];
      final dataCenter = data[2];
      final dataBottom = data[3];

      if (dataTop != null) {
        top = wrap(dataTop);
      }
      if (dataTopR != null) {
        topR = wrap(dataTopR);
      }
      if (dataCenter != null) {
        center = wrap(dataCenter);
      }
      if (dataBottom != null) {
        bottom = wrap(dataBottom);
      }

      if (top != null && center != null && bottom != null) {
        child = ItemWidget(
            height: height,
            topRight: topR,
            top: top,
            center: center,
            bottom: bottom);
      } else {
        child = ItemWidget(height: height);
      }
      return child;
    }, layout: (BuildContext context, mounted) {
      return TextCache.runTextPainter(() async {
        await releaseUI;
        if (!mounted()) return const [];

        final topR = topRightScore;
        final width = maxWidth;
        final ts = context.read<TextStyleConfig>().data;
        final trs = ts.body2.copyWith(color: Colors.yellow.shade700);
        List<TextPainter>? topRText;
        if (topR != null) {
          topRText = await TextCache.oneTextPainter(
              text: topR,
              width: width,
              dir: TextDirection.ltr,
              style: trs,
              maxLines: 1,
              ellipsis: '...');
        }

        await releaseUI;
        final _tpWidth = topRText?.first.width ?? 0;

        final topWidth = maxWidth - _tpWidth;
        final style = ts.title2;
        if (!mounted()) return const [];

        final topText = await TextCache.oneTextPainter(
            text: top,
            width: topWidth,
            dir: TextDirection.ltr,
            style: style,
            maxLines: 1,
            ellipsis: '...');

        await releaseUI;
        if (!mounted()) return const [];

        final centerText = await TextCache.oneTextPainter(
            text: center,
            width: width,
            dir: TextDirection.ltr,
            style: ts.body2,
            maxLines: centerLines,
            ellipsis: '...');

        await releaseUI;
        if (!mounted()) return const [];
        final bottomText = await TextCache.oneTextPainter(
            text: bottom,
            width: width,
            dir: TextDirection.ltr,
            style: ts.body3,
            maxLines: bottomLines,
            ellipsis: '...');

        await releaseUI;
        return [topRText, topText, centerText, bottomText];
      });
    });
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
