import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ColorPickerPainter extends CustomPainter {
  ColorPickerPainter({this.r, this.g, this.b});
  final ValueNotifier<double>? r;
  final ValueNotifier<double>? g;
  final ValueNotifier<double>? b;

  @override
  void addListener(listener) {
    r!.addListener(listener);
    g!.addListener(listener);
    b!.addListener(listener);
  }

  @override
  void removeListener(listener) {
    r!.removeListener(listener);
    g!.removeListener(listener);
    b!.removeListener(listener);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cenx = size.width / 2;
    final ceny = size.height / 2;
    var allowMax = cenx > ceny ? ceny : cenx;
    canvas.save();
    canvas.translate(cenx - allowMax, ceny - allowMax);
    canvas.drawCircle(Offset(allowMax, allowMax), allowMax,
        Paint()..color = Color.fromRGBO(r!.value.toInt(), g!.value.toInt(), b!.value.toInt(), 1));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ColorPickerPainter oldDelegate) {
    return false;
  }
}

class ColorPickerWidget extends LeafRenderObjectWidget {
  const ColorPickerWidget({Key? key, this.extent, this.center = true, this.elevation = 8.0, this.radius})
      : super(key: key);
  final bool center;
  final double elevation;
  final ValueNotifier<double?>? extent;
  final double? radius;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderColorPicker(
      extent: extent,
      center: center,
      elevation: elevation,
      radius: radius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderColorPicker renderObject) {
    renderObject
      ..extent = extent
      ..center = center
      ..radius = radius
      ..elevation = elevation;
  }
}

class RenderColorPicker extends RenderBox {
  RenderColorPicker({ValueNotifier<double?>? extent, bool? center, double? elevation, double? radius})
      : _extent = extent,
        _center = center,
        _elevation = elevation,
        _radius = radius;

  ValueNotifier<double?>? _extent;
  ValueNotifier<double?>? get extent => _extent;
  set extent(ValueNotifier<double?>? v) {
    if (v == _extent) return;
    _extent = v;
    markNeedsLayout();
  }

  double? _radius;
  double? get radius => _radius;
  set radius(double? v) {
    if (v == _radius) return;
    _radius = v;
    markNeedsLayout();
  }

  bool? _center;
  bool? get center => _center;
  set center(bool? v) {
    if (v == _center) return;
    _center = v;
    markNeedsLayout();
  }

  double? _elevation;
  double? get elevation => _elevation;
  set elevation(double? v) {
    if (v == _elevation) return;
    _elevation = v;
    markNeedsLayout();
  }

  var extentWithElevation = 0.0;
  late Rect rect;
  @override
  void performLayout() {
    // size = constraints.biggest;

    var allExent = (_radius! + _elevation!) * 2;
    size = constraints.constrainDimensions(allExent, allExent);
    if (size.height < allExent || size.width < allExent) {
      if (size.height > size.width) {
        _radius = size.width / 2 - _elevation!;
      } else {
        _radius = size.height / 2 - _elevation!;
      }
    }
    allExent = (_radius! + _elevation!) * 2;
    size = constraints.constrainDimensions(allExent, allExent);
    if (Size(allExent, allExent) != size) {
      print('...............error');
    }
    extentWithElevation = _radius! + _elevation!;
    rect = Offset(_elevation!, _elevation!) & Size(_radius! * 2, _radius! * 2);
    _extent!.value = _radius;
  }

  final red = Color.fromARGB(255, 255, 0, 0);
  final yellow = Color.fromARGB(255, 255, 255, 0);
  final green = Color.fromARGB(255, 0, 255, 0);
  final cyan = Color.fromARGB(255, 0, 255, 255);
  final blue = Color.fromARGB(255, 0, 0, 255);
  final magenta = Color.fromARGB(255, 255, 0, 255);
  final white = Color.fromARGB(255, 255, 255, 255);
  final opy = Color.fromARGB(0, 255, 255, 255);
  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final g = SweepGradient(colors: [
      red,
      yellow,
      green,
      cyan,
      blue,
      magenta,
      red,
    ]).createShader(rect);
    final path = Path();
    path.addArc(rect, 0, math.pi * 2);
    // canvas.drawRect(Offset.zero & Size(extentWithElevation* 2 , extentWithElevation * 2), Paint());
    canvas.drawShadow(path, Colors.black, elevation!, false);
    canvas.drawCircle(Offset(extentWithElevation, extentWithElevation), _radius!, Paint()..shader = g);

    final gr = RadialGradient(radius: 0.5, colors: [white, opy]).createShader(rect);
    canvas.drawCircle(Offset(extentWithElevation, extentWithElevation), _radius!, Paint()..shader = gr);
    // canvas.drawLine(
    //     Offset(extentWithElevation, 0.0), Offset(extentWithElevation, size.height), Paint()..color = Colors.black);
    // canvas.drawPoints(
    //     PointMode.lines,
    //     [Offset(elevation, extentWithElevation), Offset(extentWithElevation + extent.value, extentWithElevation)],
    //     Paint());
    // canvas.drawPoints(
    //     PointMode.lines,
    //     [Offset(extentWithElevation, elevation), Offset(extentWithElevation, extentWithElevation + extent.value)],
    //     Paint());
    canvas.restore();
  }

  @override
  bool hitTestSelf(Offset position) {
    var dx = position.dx - extentWithElevation + 1;
    var dy = position.dy - extentWithElevation + 1;
    if (dx.abs() > extent!.value! || dy.abs() > extent!.value!) return false;

    final po = math.pow(dx, 2);
    final poy = math.pow(dy, 2);
    return math.sqrt(po + poy) <= extent!.value!;
  }
}

typedef ColorCallback = void Function(HSVColor value);

class SelectColor extends StatefulWidget {
  SelectColor({
    Key? key,
    this.onChangeStart,
    this.onChangeUpdate,
    this.onChangeEnd,
    this.onChangeCancel,
    this.onChangeDown,
    this.value,
    this.alpha = 1.0,
    this.radius = 100,
  })  : assert(alpha <= 1.0 && alpha >= 0.0),
        assert(radius > 0),
        super(key: key);
  final ColorCallback? onChangeStart;
  final ColorCallback? onChangeDown;
  final ColorCallback? onChangeUpdate;
  final ColorCallback? onChangeEnd;
  final VoidCallback? onChangeCancel;
  final ValueNotifier<double>? value;
  final double alpha;
  final double radius;

  @override
  State<StatefulWidget> createState() => _SelectColorState();
}

class _SelectColorState extends State<SelectColor> {
  final ValueNotifier<HSVColor> color = ValueNotifier(HSVColor.fromColor(Colors.black));
  final ValueNotifier<double> extent = ValueNotifier(0.0);
  ValueNotifier<double>? value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(covariant SelectColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    value = widget.value;
  }

  ValueNotifier<Offset> poinOffset = ValueNotifier<Offset>(Offset.zero);

  HSVColor inner(Offset d) {
    final radius = extent.value;
    final zeropad = radius + 8;
    final _v = value!.value;
    final y = d.dy - zeropad;
    final x = d.dx - zeropad;
    final length = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
    final fac = length / radius;
    if (length > radius) {
      poinOffset.value = Offset(x / fac + zeropad, y / fac + zeropad);
    } else {
      poinOffset.value = d;
    }
    // x, y 轴相反；
    final hue = math.atan2(-y, -x) * 180 / math.pi + 180;
    final saturation = math.min(1.0, fac);
    // final xa = math.atan2(-y, -x);
    // print(-x);
    // final _x = math.sqrt(math.pow(radius * saturation, 2) / (math.pow(xa, 2) + 1));
    // if (hue > 180) {
    //   print(-_x);
    //   if (hue > 270) {
    //     poinOffset.value = Offset(-_x + zeropad, -_x * xa + zeropad);
    //   } else {
    //     poinOffset.value = Offset(-_x + zeropad, _x * xa + zeropad);
    //   }
    // } else {
    //   print(_x);
    //   if (hue > 90) {
    //     poinOffset.value = Offset(_x, x * xa + zeropad);
    //   } else {
    //     poinOffset.value = Offset(_x + zeropad, -_x * xa + zeropad);
    //   }
    // }

    return HSVColor.fromAHSV(widget.alpha, hue, saturation, _v);
  }

  void down(DragDownDetails d) {
    if (widget.onChangeDown != null) {
      color.value = inner(d.localPosition);
      widget.onChangeDown!(color.value);
    }
  }

  void start(DragStartDetails d) {
    if (widget.onChangeStart != null) {
      color.value = inner(d.localPosition);
      widget.onChangeStart!(color.value);
    }
  }

  void update(DragUpdateDetails d) {
    if (widget.onChangeUpdate != null) {
      color.value = inner(d.localPosition);
      widget.onChangeUpdate!(color.value);
    }
  }

  void end(DragEndDetails d) {
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(color.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: down,
      onPanStart: start,
      onPanUpdate: update,
      onPanEnd: end,
      onPanCancel: widget.onChangeCancel,
      child: Poin(
        poinOffset: poinOffset,
        child: RepaintBoundary(
            child: ColorPickerWidget(
          extent: extent,
          radius: widget.radius,
        )),
      ),
    );
  }
}

class Poin extends SingleChildRenderObjectWidget {
  const Poin({required Widget child, required this.poinOffset}) : super(child: child);
  final ValueNotifier<Offset> poinOffset;
  @override
  PoinRender createRenderObject(BuildContext context) {
    return PoinRender(poinOffset: poinOffset);
  }

  @override
  void updateRenderObject(BuildContext context, covariant PoinRender renderObject) {
    renderObject.poinOffset = poinOffset;
  }
}

class PoinRender extends RenderProxyBox {
  PoinRender({required poinOffset}) : _poinOffset = poinOffset;
  ValueNotifier<Offset> _poinOffset;
  ValueNotifier<Offset> get poinOffset => _poinOffset;
  set poinOffset(ValueNotifier<Offset> v) {
    if (v == _poinOffset) return;
    _poinOffset.removeListener(markNeedsPaint);
    _poinOffset = v;
    _poinOffset.addListener(markNeedsPaint);
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _poinOffset.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    super.detach();
    _poinOffset.removeListener(markNeedsPaint);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!size.isEmpty) {
      final canvas = context.canvas;
      canvas.drawCircle(
          _poinOffset.value == Offset.zero ? Offset(size.width / 2, size.height / 2) : poinOffset.value,
          3,
          Paint()
            ..strokeWidth = 2
            ..color = Colors.black38
            ..style = PaintingStyle.stroke);
    }
  }
}
