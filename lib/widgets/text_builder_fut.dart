// ignore_for_file: unused_import

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_nop/router.dart';
import 'package:nop/event_queue.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../modules/setting/setting.dart';
import '../modules/text_style/text_style.dart';

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
    final ts = context.grass<TextStyleConfig>().data;
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
      child: ValueListenableBuilder<bool>(
          valueListenable: context
              .grass<OptionsNotifier>()
              .select((parent) => parent.options.useTextCache ?? false),
          builder: (context, useTextCache, child) {
            if (useTextCache)
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
  Widget item(TextPainter text) {
    return AsyncText.async(text);
  }

  Widget wrap(List<TextPainter> data) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map(item).toList());
  }

  @override
  Widget build(BuildContext context) {
    return AsyncTextBuilder(
      builder: (_, List<List<TextPainter>?> data) {
        Widget child;
        Widget? topR;

        if (data.length != 4) {
          return const SizedBox();
        }
        final dataTopR = data[0];
        final dataTop = data[1];
        final dataCenter = data[2];
        final dataBottom = data[3];
        if (dataTopR != null) {
          topR = wrap(dataTopR);
        }

        if (dataTop != null && dataCenter != null && dataBottom != null) {
          child = ItemWidget(
              height: height,
              topRight: topR,
              top: wrap(dataTop),
              center: wrap(dataCenter),
              bottom: wrap(dataBottom));
        } else {
          child = ItemWidget(height: height);
        }
        return child;
      },
      layout: (BuildContext context, mounted) {
        return TextCache.runTextPainter(() async {
          await idleWait;

          final topR = topRightScore;
          final width = maxWidth;
          if (!mounted()) return const [];
          // ignore: use_build_context_synchronously
          final ts = context.grass<TextStyleConfig>().data;
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

          await idleWait;
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

          await idleWait;
          if (!mounted()) return const [];

          final centerText = await TextCache.oneTextPainter(
              text: center,
              width: width,
              dir: TextDirection.ltr,
              style: ts.body2,
              maxLines: centerLines,
              ellipsis: '...');

          await idleWait;
          if (!mounted()) return const [];
          final bottomText = await TextCache.oneTextPainter(
              text: bottom,
              width: width,
              dir: TextDirection.ltr,
              style: ts.body3,
              maxLines: bottomLines,
              ellipsis: '...');

          await idleWait;
          return [topRText, topText, centerText, bottomText];
        });
      },
    );
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
