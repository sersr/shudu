import 'package:flutter/material.dart';

class BatteryView extends CustomPainter {
  BatteryView({required this.progress, Color? color}) {
    this.color = color ?? Colors.grey.shade800;
  }
  final double progress;
  final rrect = RRect.fromLTRBXY(0.0, 0.0, 24, 10, 4, 4.4);
  final path = Path();
  late Color color;
  @override
  void paint(Canvas canvas, Size size) {
    path
      ..reset()
      ..addRRect(rrect);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = 1.4);
    path
      ..reset()
      ..moveTo(23.5, 3)
      ..lineTo(24.0, 3)
      ..arcToPoint(Offset(24.0, 7), radius: Radius.circular(2))
      ..lineTo(23.5, 7.0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    final rect = Rect.fromLTWH(2.0, 2, 20 * progress, 6);
    RRect rrect2;
    if (progress == 1.0) {
      rrect2 = RRect.fromRectXY(rect, 2.5, 2.5);
    } else {
      rrect2 = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(2.5),
        bottomLeft: Radius.circular(2.5),
      );
    }
    canvas.drawRRect(rrect2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
