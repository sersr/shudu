import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../provider/provider.dart';
import '../utils/binding/widget_binding.dart';
import '../utils/utils.dart';
import 'async_text.dart';
import 'draw_picture.dart';

class TextBuilder extends StatelessWidget {
  const TextBuilder({
    Key? key,
    this.topRightScore,
    this.top,
    this.center,
    this.bottom,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String? top;
  final String? center;
  final String? bottom;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return _TextBuilder(
        top: top,
        topRightScore: topRightScore,
        center: center,
        bottom: bottom,
        height: height,
        constraints: constraints,
      );
    });
  }
}

class _TextBuilder extends StatefulWidget {
  const _TextBuilder({
    Key? key,
    this.topRightScore,
    this.top,
    this.center,
    this.bottom,
    required this.constraints,
    this.height = 112,
  }) : super(key: key);

  final String? topRightScore;
  final String? top;
  final String? center;
  final String? bottom;
  final double height;
  final BoxConstraints constraints;
  @override
  State<_TextBuilder> createState() => _TextBuilderState();
}

class _TextBuilderState extends State<_TextBuilder> {
  late TextStyleConfig ts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ts = context.read<TextStyleConfig>();
    _sub();
  }

  @override
  void didUpdateWidget(_TextBuilder o) {
    super.didUpdateWidget(o);
    if (o.top != widget.top ||
        o.topRightScore != widget.topRightScore ||
        o.center != widget.center ||
        o.bottom != widget.bottom ||
        o.constraints != widget.constraints) _sub();
  }

  TextPainter? tp;
  TextPainter? tc;
  TextPainter? tb;
  void _sub() {
    final tpr = TextPainter(
        text: TextSpan(
          text: widget.topRightScore,
          style: ts.body2.copyWith(color: Colors.yellow.shade700),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr);
    final tp = TextPainter(
        text: TextSpan(text: widget.top, style: ts.title3),
        maxLines: 1,
        textDirection: TextDirection.ltr);
    final tc = TextPainter(
        text: TextSpan(text: widget.center, style: ts.body2),
        maxLines: 1,
        textDirection: TextDirection.ltr);
    final tb = TextPainter(
        text: TextSpan(text: widget.bottom, style: ts.body3),
        maxLines: 2,
        textDirection: TextDirection.ltr);
    final width = widget.constraints.maxWidth;

    final keys = [
      width,
      widget.topRightScore,
      widget.top,
      widget.center,
      widget.bottom,
      1,
      1,
      1,
      2
    ];
    final height = widget.constraints.maxHeight;
    final _all = AsyncText.putIfAbsent(keys, (canvas) async {
      tpr.layout(maxWidth: width);
      await releaseUI;

      tp.layout(maxWidth: width - tpr.width);
      await releaseUI;

      tc.layout(maxWidth: width);
      await releaseUI;

      tb.layout(maxWidth: width);
      await releaseUI;

      final topHeight = math.max(tpr.height, tp.height);
      final allHeight = topHeight + tc.height + tb.height;
      final avg = (height - allHeight) / 4;
      var _h = avg;

      tpr.paint(canvas, Offset(width - tpr.width, _h));
      await releaseUI;

      tp.paint(canvas, Offset(0.0, _h));
      _h += avg + topHeight;
      await releaseUI;

      tc.paint(canvas, Offset(0.0, _h));
      _h += avg + tc.height;
      await releaseUI;

      tb.paint(canvas, Offset(0.0, _h));
      return Size(width, _h);
    });

    if (all != _all) {
      all?.removeListener(liListener);
      _all.addListener(liListener);
      all = _all;
    }
  }

  PictureListener? all;
  PictureInfo? allPictureInfo;

  void liListener(PictureInfo? pic, bool error) {
    setState(() {
      allPictureInfo?.dispose();
      allPictureInfo = pic;
    });
  }

  @override
  void dispose() {
    super.dispose();
    all?.removeListener(liListener);
    allPictureInfo?.dispose();
    allPictureInfo = null;
  }

  @override
  Widget build(BuildContext context) {
    return PictureWidget(info: allPictureInfo);

    // final ts = context.read<TextStyleConfig>();

    // return RepaintBoundary(
    //   child: LayoutBuilder(
    //     builder: (context, constraints) {
    //       final tpr = TextPainter(
    //           text: TextSpan(
    //             text: widget.topRightScore,
    //             style: ts.body2.copyWith(color: Colors.yellow.shade700),
    //           ),
    //           maxLines: 1,
    //           textDirection: TextDirection.ltr);
    //       final tp = TextPainter(
    //           text: TextSpan(text: widget.top, style: ts.title3),
    //           maxLines: 1,
    //           textDirection: TextDirection.ltr);
    //       final tc = TextPainter(
    //           text: TextSpan(text: widget.center, style: ts.body2),
    //           maxLines: 1,
    //           textDirection: TextDirection.ltr);
    //       final tb = TextPainter(
    //           text: TextSpan(text: widget.bottom, style: ts.body3),
    //           maxLines: 2,
    //           textDirection: TextDirection.ltr);

    //       List<TextPainter>? tasks;
    //       Future<List<TextPainter>> _t;
    //       final width = constraints.maxWidth;
    //       final topRightSync = AsyncText.syncGet(width, tpr);

    //       if (topRightSync != null) {
    //         final l = <TextPainter>[];
    //         final topSync = AsyncText.syncGet(width - topRightSync.width, tp);
    //         if (topSync != null) l.add(topSync);
    //         l.add(topRightSync);
    //         final textlist =
    //             AsyncText.syncGets(width, [tc, tb]).whereType<TextPainter>();
    //         l.addAll(textlist);
    //         if (l.length == 4) tasks = l;
    //       }
    //       if (tasks?.length == 4) {
    //         _t = SynchronousFuture(tasks!);
    //       } else {
    //         assert(tasks == null);
    //         final topRight = AsyncText.asyncLayout(width, tpr);
    //         _t = Future.wait([
    //           topRight.then(
    //               (value) => AsyncText.asyncLayout(width - value.width, tp)),
    //           topRight,
    //           AsyncText.asyncLayout(width, tc),
    //           AsyncText.asyncLayout(width, tb),
    //         ]);
    //       }
    //       return FutureBuilder<List<TextPainter>>(
    //           future: _t,
    //           // initialData: tasks,
    //           builder: (context, snap) {
    //             // Log.w('.${tasks?.length}.. ${snap.hasData}');
    //             if (snap.hasData) {
    //               final data = snap.data!;
    //               return _items(data);
    //             }
    //             return ItemWidget(height: widget.height);
    //           });
    //     },
    //   ),
    // );
  }

  // Widget _items(Iterable<TextPainter> data) {
  //   return ItemWidget(
  //       height: widget.height,
  //       top: AsyncText.async(data.elementAt(0)),
  //       topRight: AsyncText.async(data.elementAt(1)),
  //       center: AsyncText.async(data.elementAt(2)),
  //       bottom: AsyncText.async(data.elementAt(3)));
  // }
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

    if (hasChild(_topRight)) topRight = layoutChild(_topRight, constraints);
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
      if (hasChild(_topRight))
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
