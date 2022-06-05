import 'package:flutter/material.dart';

class BatteryView extends LeafRenderObjectWidget {
  BatteryView({Key? key, required this.progress, Color? color})
      : color = color ?? Colors.grey.shade800,
        super(key: key);

  final double progress;
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return BatteryViewObject(progress: progress, color: color);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant BatteryViewObject renderObject) {
    renderObject
      ..color = color
      ..progress = progress;
  }
}

class BatteryViewObject extends RenderBox {
  BatteryViewObject({required double progress, required Color color})
      : _progress = progress,
        _color = color;
  @override
  void performLayout() {
    size = constraints.constrain(const Size(30, 10));
  }

  double _progress;
  double get progress => _progress;
  set progress(double v) {
    if (_progress == v) return;
    _progress = v;
    markNeedsPaint();
  }

  Color _color;
  Color get color => _color;
  set color(Color v) {
    if (_color == v) return;
    _color = v;
    markNeedsPaint();
  }

  final rrect = const RRect.fromLTRBXY(0.0, 0.0, 24, 10, 4, 4.4);
  final path = Path();

  static const _radius = 2.5;

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    path
      ..reset()
      ..addRRect(rrect);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = 1.4,
    );

    path
      ..reset()
      ..moveTo(23.5, 3)
      ..lineTo(24.0, 3)
      ..arcToPoint(Offset(24.0, 7), radius: const Radius.circular(2))
      ..lineTo(23.5, 7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    RRect rrect2;

    var _color = color;

    if (progress < 0.11) _color = Colors.red.shade600;

    if (progress == 1.0) {
      const rect = Rect.fromLTWH(2.0, 2, 20, 6);
      rrect2 = RRect.fromRectXY(rect, _radius, _radius);
    } else {
      final rect = Rect.fromLTWH(2.0, 2, 19 * progress, 6);

      rrect2 = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(_radius),
        bottomLeft: const Radius.circular(_radius),
      );
    }

    canvas.drawRRect(rrect2, Paint()..color = _color);
  }
}
