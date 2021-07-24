import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class MyShaderWarmUp extends DefaultShaderWarmUp {
  const MyShaderWarmUp() : super();

  // @override
  // Future<void> warmUpOnCanvas(Canvas canvas) async {
  //   await super.warmUpOnCanvas(canvas);

  //   final m = Matrix4.identity();
  //   m
  //     ..rotateX(10.0)
  //     ..rotateY(20.0)
  //     ..rotateZ(30.0);
  //   canvas.transform(m.storage);
  // }
}
