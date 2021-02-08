import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart' as vec4;

import '../book_list_view/shudan_item.dart';

class BookItem extends StatelessWidget {
  BookItem(
      {Key? key,
      this.img,
      this.bookName,
      this.bookUdateItem,
      this.bookUpdateTime,
      required this.isNew,
      required this.isTop})
      : super(key: key);

  final String? bookName;
  final String? bookUdateItem;
  final String? bookUpdateTime;
  final String? img;
  final bool isNew;
  final bool isTop;
  static final ltsty = TextStyle(fontSize: 11, color: Colors.grey[600]);
  static final mdsty = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static final lgsty = TextStyle(
    // fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.only(left: 12.0, right: 10.0),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: ImageResolve(
              img: img,
              builder: (child) {
                return UpdateIcon(
                  child: child,
                  isNew: isNew,
                  isTop: isTop,
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      bookName!,
                      style: lgsty,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '最新：$bookUdateItem',
                    style: mdsty,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                    child: Text(
                      bookUpdateTime!,
                      style: ltsty,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateIcon extends SingleChildRenderObjectWidget {
  UpdateIcon({
    Key? key,
    Widget? child,
    required this.isNew,
    required this.isTop,
  }) : super(key: key, child: child);
  final bool isNew;
  final bool isTop;
  @override
  UpdateIconRenderObject createRenderObject(BuildContext context) {
    return UpdateIconRenderObject(isNew: isNew, isTop: isTop);
  }

  @override
  void updateRenderObject(BuildContext context, covariant UpdateIconRenderObject renderObject) {
    renderObject
      ..isNew = isNew
      ..isTop = isTop;
  }
}

class UpdateIconRenderObject extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  UpdateIconRenderObject({RenderBox? child, bool? isNew, bool? isTop})
      : _isNew = isNew,
        _isTop = isTop {
    this.child = child;
    resolveNew();
    resolveTop();
  }
  bool? _isNew;
  bool? get isNew => _isNew;
  set isNew(bool? v) {
    if (_isNew == v) return;
    _isNew = v;
    resolveNew();
    markNeedsLayout();
  }

  void resolveNew() {
    if (isNew!) {
      _newPainter = TextPainter(
          text: TextSpan(text: '更新', style: TextStyle(fontSize: 6, color: Colors.grey[200], height: 1.0)),
          textDirection: TextDirection.ltr);
      _newPainter.layout();
    }
  }

  void resolveTop() {
    if (isTop!) {
      _topPainter = TextPainter(
          text: TextSpan(text: '置顶', style: TextStyle(fontSize: 8, color: Colors.grey[100])),
          textDirection: TextDirection.ltr);
      _topPainter.layout();
    }
  }

  late TextPainter _newPainter;
  late TextPainter _topPainter;

  bool? _isTop;
  bool? get isTop => _isTop;
  set isTop(bool? v) {
    if (_isTop == v) return;
    _isTop = v;
    resolveTop();
    markNeedsLayout();
  }

  late Path nP;
  late Path tP;
  late double innerWidth;
  late double height;
  @override
  void performLayout() {
    if (child == null) {
      size = constraints.biggest;
      return;
    }
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;

    /// 旋转之后实际的(横轴)宽度，也就是要减去的宽度，达到贴边的效果
    /// degrees：45° 等边直角三角形
    if (isNew!) {
      /// 右上角到1的距离
      innerWidth = math.sqrt(math.pow(_newPainter.width, 2) / 2);

      /// 右上角到4的距离
      final allWidth = math.sqrt(math.pow(_newPainter.height, 2) * 2) + innerWidth;

      ///4 _____ 1
      ///  \    \
      ///   \    \
      ///    \    \ 2
      ///     \   |
      ///      \  |
      ///       \ |
      ///        \| 3
      nP = Path();
      nP.moveTo(size.width - (innerWidth - 2), 0.0); // 1
      nP.lineTo(size.width, innerWidth - 2); // 2
      nP.lineTo(size.width, allWidth + 1); // 3
      nP.lineTo(size.width - (allWidth + 1), 0.0); // 4
      nP.close();
    }
    if (isTop!) {
      final width = _topPainter.width;
      height = _topPainter.height;
      tP = Path();
      tP.moveTo(0.0, .0);
      tP.lineTo(width + 2.0, .0);
      tP.arcToPoint(Offset(width + 2.0, height), radius: Radius.circular(height / 2));
      tP.lineTo(0.0, height);
      tP.close();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final path = Path();
      path..addRect(Offset.zero & size);
      context.paintChild(child!, offset);
      final canvas = context.canvas;
      if (isNew!) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.drawPath(nP, Paint()..color = Colors.orange.shade600);
        canvas.translate(size.width - innerWidth, 0.0);
        canvas.rotate(vec4.radians(45));
        _newPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }

      if (isTop!) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy + size.height - height);
        canvas.drawPath(tP, Paint()..color = Colors.blue.shade300);
        _topPainter.paint(canvas, Offset(2.0, 0.0));
        canvas.restore();
      }
    }
  }
}
