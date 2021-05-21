import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../../../bloc/painter_bloc.dart';
import '../../../utils/utils.dart';

typedef BoolCallback = bool Function();

class NopPageViewController extends ChangeNotifier with ActivityDelegate {
  NopPageViewController({
    required this.scrollingNotify,
    required this.vsync,
    // required this.getDragState,
    required this.hasContent,
  })  : _maxExtent = double.infinity,
        _minExtent = double.negativeInfinity {
    _activity = IdleActivity(this);
  }

  TickerProvider vsync;

  // BoolCallback getDragState;
  void Function(bool) scrollingNotify;
  int Function(int) hasContent;

  Activity? _activity;

  double _pixels = 0.0;
  @override
  double get pixels => _pixels;

  void beginActivity(Activity activity) {
    if (_activity is BallisticActivity || _activity is DrivenAcitvity) {
      _lastvelocity = _activity!.velocity;
    }
    _activity?.dispose();
    _activity = activity;
    _currentDrag?.dispose();
    _currentDrag = null;
  }

  Axis _axis = Axis.vertical;
  Axis get axis => _axis;
  set axis(Axis v) {
    if (v == _axis) return;
    _axis = v;
    notifyListeners();
  }

  double get page {
    // assert(viewPortDimension != null);
    return pixels / viewPortDimension!;
  }

  double? _viewPortDimension;
  double? get viewPortDimension => _viewPortDimension;

  void applyViewPortDimension(double dimension) {
    if (_viewPortDimension != null && _viewPortDimension != dimension) {
      _pixels = page.toInt() * dimension;
    }
    _viewPortDimension = dimension;
  }

  static final SpringDescription kDefaultSpring = SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100.0,
    ratio: 1.1,
  );

  Simulation getSimulation(double velocity) {
    return ClampingScrollSimulation(position: pixels, velocity: velocity);
  }

  Simulation getSpringSimulation(double velocity, double end) {
    return ScrollSpringSimulation(kDefaultSpring, pixels, end, velocity);
  }

  void nextPage() {
    if (_lastActivityIsIdle) {
      final nextPage = page.round();

      if (axis == Axis.horizontal) {
        if (ContentBounds.hasRight(hasContent(nextPage))) {
          if (maxExtent!.isFinite) {
            _maxExtent = double.infinity;
          }
          setPixels(viewPortDimension! * (page + 0.51).round());
        }
      } else {
        if (hasContent(nextPage) & ContentBounds.addRight != 0) {
          var _n = page;

          if (maxExtent!.isFinite) {
            _maxExtent = double.infinity;
          }

          if (ContentBounds.hasRight(hasContent((page + 0.5).round()))) {
            _n += 1;
          } else {
            _n = (page + 0.5).roundToDouble();
          }
          setPixels(viewPortDimension! * _n);
        } else {
          setPixels(viewPortDimension! * (page + 0.5).round());
        }
      }
      goIdle();
    }
  }

  void prePage() {
    if (_activity is IdleActivity && ContentBounds.hasLeft(hasContent(page.toInt() - 1))) {
      if (minExtent!.isFinite) {
        _minExtent = double.negativeInfinity;
      }
      setPixels(viewPortDimension! * (page - 0.6).round());
    }
  }

  bool get isScrolling => _activity is! IdleActivity;
  void scrollingnotifier(bool value) {
    scrollingNotify(value);
  }

  @override
  void goIdle() {
    // _canDrag = true;
    scrollingnotifier(false);
    beginActivity(IdleActivity(this));
  }

  @override
  void setPixels(double v) {
    if (v == _pixels) return;
    // 边界信息，在 [performLayout] 中设置，
    // 只要 [v] 值不同，就要更新并重新设置边界，不然会卡住
    v = v.clamp(minExtent!, maxExtent!);
    // if (_pixels == v && v != minExtent) {
    //   // 帧后回调
    //   SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
    //     goBallisticResolveWithLastActivity();
    //   });
    // }
    _pixels = v;
    notifyListeners();
  }

  double _lastvelocity = 0.0;
  double get lastvelocity => _lastvelocity;

  // 判断是否立即停止
  @override
  void goBallisticResolveWithLastActivity() {
    if (viewPortDimension == null) return;
    final la = pixels % viewPortDimension!;
    if (axis == Axis.vertical || la <= 1.0 || la + 1.0 >= viewPortDimension!) {
      _lastvelocity = 0.0;
      goIdle();
    }
    if (_lastvelocity != 0.0) {
      goBallistic(_lastvelocity);
    }
  }

  @override
  void goBallistic(double velocity) {
    // if (!_canDrag) {
    // goIdle();
    // return;
    // }

    int to;

    if (axis == Axis.horizontal) {
      if (velocity < -200.0) {
        to = (page - 0.5).round();
        velocity = velocity < -500 ? velocity / 2 : velocity;
      } else if (velocity > 200.0) {
        to = (page + 0.5).round();
        velocity = velocity > 500 ? velocity / 2 : velocity;
      } else {
        to = page.round();
      }

      final end = (to * viewPortDimension!).clamp(minExtent!, maxExtent!);

      // var duration = ((end - pixels).abs() * ui.window.devicePixelRatio).toInt();
      // duration = duration > 400 ? 400 : duration;

      // beginActivity(DrivenAcitvity(
      //   delegate: this,
      //   vsync: vsync,
      //   to: end,
      //   from: pixels,
      //   duration: Duration(milliseconds: duration),
      //   curve: Curves.ease,
      // ));

      beginActivity(BallisticActivity(
        delegate: this,
        vsync: vsync,
        end: () => end,
        simulation: getSpringSimulation(velocity, end),
      ));
    } else {
      beginActivity(BallisticActivity(
        delegate: this,
        vsync: vsync,
        end: () => velocity >= 0.0 ? maxExtent! : minExtent!,
        simulation: getSimulation(velocity),
        swipeDown: velocity >= 0,
      ));
    }
  }

  void setPixelsWithoutNtf(double v) {
    _pixels = v;
  }

  double? _minExtent;
  double? _maxExtent;

  double? get minExtent => _minExtent;
  double? get maxExtent => _maxExtent;

  void applyConentDimension({required double minExtent, required double maxExtent}) {
    if (_minExtent != minExtent || _maxExtent != maxExtent) {
      _minExtent = minExtent;
      _maxExtent = maxExtent;
    }
  }

  @override
  void applyUserOffset(double delta) {
    if (delta == 0.0) return;
    setPixels(pixels - delta);
  }

  PreNextDragController? _currentDrag;
  // 指示是否可拖动
  // 当进行文本布局时，占用UI资源
  // bool _canDrag = true;
  PreNextDragController? drag(DragStartDetails details, VoidCallback cancelCallback) {
    // _canDrag = getDragState();
    // if (!_canDrag) {
    //   return null;
    // }
    scrollingnotifier(true);
    final _drag = PreNextDragController(delegate: this, cancelCallback: cancelCallback);
    beginActivity(DragActivity(delegate: this, controller: _drag));
    _currentDrag = _drag;
    return _drag;
  }

  var _lastActivityIsIdle = true;
  ScrollHoldController hold(VoidCallback cancel) {
    final _hold = HoldActivity(this, cancelCallback: cancel);
    _lastActivityIsIdle = _activity is IdleActivity;

    beginActivity(_hold);
    return _hold;
  }

  @override
  void dispose() {
    _activity?.dispose();
    _activity = null;
    _currentDrag?.dispose();
    _currentDrag = null;
    super.dispose();
  }
}

class ContentPreNextWidget extends RenderObjectWidget {
  ContentPreNextWidget({required this.builder, required this.offset});
  final WidgetCallback builder;
  final NopPageViewController offset;
  @override
  ContentPreNextElement createElement() => ContentPreNextElement(this);

  @override
  ContentPreNextRenderObject createRenderObject(BuildContext context) {
    return ContentPreNextRenderObject(vpOffset: offset);
  }

  @override
  void updateRenderObject(BuildContext context, covariant ContentPreNextRenderObject renderObject) {
    renderObject.nopController = offset;
  }
}

class ContentPreNextElement extends RenderObjectElement {
  ContentPreNextElement(RenderObjectWidget widget) : super(widget);

  @override
  ContentPreNextWidget get widget => super.widget as ContentPreNextWidget;
  @override
  ContentPreNextRenderObject get renderObject => super.renderObject as ContentPreNextRenderObject;

  final childElement = <int, Element>{};
  @override
  void mount(Element? parent, newSlot) {
    super.mount(parent, newSlot);
    renderObject._element = this;
  }

  @override
  void unmount() {
    renderObject._element = null;
    super.unmount();
  }

  @override
  void forgetChild(Element child) {
    final index = child.slot as int?;
    if (childElement.containsKey(index)) {
      childElement.remove(index);
    }
    super.forgetChild(child);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    childElement.values.forEach((element) {
      visitor(element);
    });
  }

  @override
  void update(covariant RenderObjectWidget newWidget) {
    super.update(newWidget);
    performRebuild();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    removeAll();
  }

  void removeAll() {
    for (var el in childElement.values.toList()) {
      var result = updateChild(el, null, null);
      assert(result == null);
    }
    childElement.clear();
  }

  void createChild(int index) {
    owner!.buildScope(this, () {
      Element? el;
      try {
        el = updateChild(childElement[index], _build(index), index);
      } finally {}
      if (el != null) {
        childElement[index] = el;
      } else {
        childElement.remove(index);
      }
    });
  }

  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    owner!.buildScope(this, () {
      try {
        childElement.removeWhere((key, value) {
          final clear = key < leadingGarbage - 1 || key > trailingGarbage + 1;
          if (clear) {
            final el = updateChild(value, null, null);
            assert(el == null);
          }
          return clear;
        });
      } finally {}
    });
  }

  Widget? _build(int index, {bool changeState = false}) {
    return widget.builder(index, changeState: changeState);
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant slot) {
    renderObject.add(child as RenderBox, slot);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant slot) {
    renderObject.remove(child as RenderBox, slot);
  }
}

class NopPageViewParenData extends BoxParentData {
  Offset? layoutOffset;
  @override
  String toString() {
    return '$runtimeType: $layoutOffset';
  }
}

class ContentPreNextRenderObject extends RenderBox {
  ContentPreNextRenderObject({required NopPageViewController vpOffset}) : _nopController = vpOffset;

  ContentPreNextElement? _element;
  final childlist = <int, RenderBox>{};

  void add(RenderBox child, index) {
    assert(index is int);
    if (childlist[index] != null) {
      dropChild(childlist[index]!);
    }
    adoptChild(child);
    childlist[index] = child;
  }

  void remove(RenderBox child, index) {
    assert(childlist[index] == child);
    childlist.remove(index);
    dropChild(child);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! NopPageViewParenData) {
      child.parentData = NopPageViewParenData();
    }
  }

  void layoutChild(int index) {
    invokeLayoutCallback<BoxConstraints>((_) {
      _element!.createChild(index);
    });
  }

  NopPageViewController _nopController;

  NopPageViewController get nopController => _nopController;

  set nopController(NopPageViewController v) {
    if (_nopController == v) return;
    if (attached) {
      _nopController.removeListener(markNeedsLayout);
      _nopController = v;
    }
    if (attached) {
      _nopController.addListener(markNeedsLayout);
    }
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _nopController.addListener(markNeedsLayout);
    childlist.values.forEach((element) {
      element.attach(owner);
    });
  }

  int? firstIndex;
  int? lastIndex;

  bool get canPaint => firstIndex != null && lastIndex != null;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  Axis axis = Axis.horizontal;

  @override
  void performLayout() {
    double extent;
    axis = nopController.axis;
    if (axis == Axis.horizontal) {
      extent = size.width;
    } else {
      extent = size.height;
    }
    nopController.applyViewPortDimension(extent);

    final pixels = nopController.pixels;
    firstIndex = lastIndex = null;
    final _firstIndex = getMinChildIndexForScrollOffset(pixels, extent);
    final _lastIndex = getMaxChildIndexForScrollOffset(pixels + extent, extent);
    for (var i = _firstIndex; i <= _lastIndex; i++) {
      if (!childlist.containsKey(i)) {
        layoutChild(i);
      }
      childlist[i]?.layout(constraints, parentUsesSize: true);
    }
    for (var i = _firstIndex; i <= _lastIndex; i++) {
      if (childlist.containsKey(i)) {
        firstIndex = i;
        break;
      }
    }
    for (var i = _lastIndex; i >= _firstIndex; i--) {
      if (childlist.containsKey(i)) {
        lastIndex = i;
        break;
      }
    }

    /// 更正
    if (canPaint) {
      for (var i = firstIndex!; i <= lastIndex!; i++) {
        assert(childlist.containsKey(i));
        final data = childlist[i]!.parentData as NopPageViewParenData;
        data.layoutOffset = computeAbsolutePaintOffset(indexToLayoutOffset(extent, i), pixels);
      }
      collectGarbage(firstIndex!, lastIndex!);
      _element!._build(nopController.page.round(), changeState: true);

      final leftRight = nopController.hasContent(firstIndex!);
      final hasLeft = ContentBounds.hasLeft(leftRight);
      final hasRight = ContentBounds.hasRight(leftRight);

      nopController.applyConentDimension(
        minExtent: hasLeft ? double.negativeInfinity : indexToLayoutOffset(extent, firstIndex!),
        maxExtent: hasRight ? double.infinity : indexToLayoutOffset(extent, lastIndex!),
      );
    }
  }

  Offset computeAbsolutePaintOffset(double layoutOffset, double pixels) {
    switch (axis) {
      case Axis.horizontal:
        return Offset(layoutOffset - pixels, 0.0);
      case Axis.vertical:
        return Offset(0.0, layoutOffset - pixels);
      default:
        return Offset.zero;
    }
  }

  Offset? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final childParentData = child.parentData as NopPageViewParenData;
    return childParentData.layoutOffset;
  }

  /// 渲染节点
  @override
  bool get isRepaintBoundary => true;

  ClipRectLayer? _clipRectLayer;

  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRectLayer =
        context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint, oldLayer: _clipRectLayer);
  }

  void defaultPaint(PaintingContext context, Offset offset) {
    if (canPaint) {
      for (var i = firstIndex!; i <= lastIndex!; i++) {
        assert(childlist.containsKey(i));
        final child = childlist[i]!;
        context.paintChild(child, offset + childScrollOffset(child)!);
      }
    }
  }

  int getMinChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    if (itemExtent > 0.0) {
      final actual = scrollOffset / itemExtent;
      final round = actual.round();
      if ((actual - round).abs() < precisionErrorTolerance) {
        return round;
      }
      return actual.floor();
    }
    return 0;
  }

  int getMaxChildIndexForScrollOffset(double scrollOffset, double itemExtent) {
    return itemExtent > 0.0 ? (scrollOffset / itemExtent).ceil() - 1 : 0;
  }

  double indexToLayoutOffset(double itemExtent, int index) => itemExtent * index;

  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    invokeLayoutCallback<BoxConstraints>((_) {
      _element!.collectGarbage(leadingGarbage, trailingGarbage);
    });
  }

  @override
  bool hitTestSelf(Offset position) {
    // if (position.isInRange(size)) {
    //   return true;
    // }
    return true;
  }

  @override
  void redepthChildren() {
    childlist.values.forEach((redepthChild));
  }

  @override
  void detach() {
    super.detach();

    _nopController.removeListener(markNeedsLayout);
    childlist.values.forEach((element) {
      element.detach();
    });
  }

  @override
  void visitChildren(visitor) {
    childlist.values.forEach((element) {
      visitor(element);
    });
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    childlist.values.forEach((element) {
      visitor(element);
    });
  }
}

extension OffsetCompare on Offset {
  bool isInRange(Size size) {
    return dx <= size.width && dy <= size.height;
  }
}
const double _inflexion = 0.35;

/// flutter master
class ClampingScrollSimulation extends Simulation {
  ClampingScrollSimulation({
    required this.position,
    required this.velocity,
    this.friction = 0.015,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) : super(tolerance: tolerance) {
    _duration = _splineFlingDuration(velocity);
    _distance = _splineFlingDistance(velocity);
  }

  final double position;

  final double velocity;

  final double friction;

  late int _duration;
  late double _distance;

  static final double _kDecelerationRate = math.log(0.78) / math.log(0.9);

  static double _decelerationForFriction(double friction) {
    return 9.80665 *
        39.37 *
        friction *
        1.0 * // Flutter operates on logical pixels so the DPI should be 1.0.
        160.0;
  }

  double _splineDeceleration(double velocity) {
    return math.log(_inflexion *
        velocity.abs() /
        (friction * _decelerationForFriction(0.84)));
  }

  int _splineFlingDuration(double velocity) {
    final deceleration = _splineDeceleration(velocity);
    return (1000 * math.exp(deceleration / (_kDecelerationRate - 1.0))).round();
  }

  // See getSplineFlingDistance().
  double _splineFlingDistance(double velocity) {
    final l = _splineDeceleration(velocity);
    final decelMinusOne = _kDecelerationRate - 1.0;
    return friction *
        _decelerationForFriction(0.84) *
        math.exp(_kDecelerationRate / decelMinusOne * l);
  }

  @override
  double x(double time) {
    if (time == 0) {
      return position;
    }
    final sample = _NBSample(time, _duration);
    return position + (sample.distanceCoef * _distance) * velocity.sign;
  }

  @override
  double dx(double time) {
    if (time == 0) {
      return velocity;
    }
    final sample = _NBSample(time, _duration);
    return sample.velocityCoef * _distance / _duration * velocity.sign * 1000.0;
  }

  @override
  bool isDone(double time) {
    return time * 1000.0 >= _duration;
  }
}

class _NBSample {
  _NBSample(double time, int duration) {
    // See computeScrollOffset().
    final t = time * 1000.0 / duration;
    final index = (_nbSamples * t).clamp(0, _nbSamples).round();
    _distanceCoef = 1.0;
    _velocityCoef = 0.0;
    if (index < _nbSamples) {
      final tInf = index / _nbSamples;
      final tSup = (index + 1) / _nbSamples;
      final dInf = _splinePosition[index];
      final dSup = _splinePosition[index + 1];
      _velocityCoef = (dSup - dInf) / (tSup - tInf);
      _distanceCoef = dInf + (t - tInf) * _velocityCoef;
    }
  }

  late double _velocityCoef;
  double get velocityCoef => _velocityCoef;

  late double _distanceCoef;
  double get distanceCoef => _distanceCoef;

  static const int _nbSamples = 100;

  // Generated from dev/tools/generate_android_spline_data.dart.
  static final List<double> _splinePosition = <double>[
    0.000022888183591973643,
    0.028561000304762274,
    0.05705195792956655,
    0.08538917797618413,
    0.11349556286812107,
    0.14129881694635613,
    0.16877157254923383,
    0.19581093511175632,
    0.22239649722992452,
    0.24843841866631658,
    0.2740024733220569,
    0.298967680744136,
    0.32333234658228116,
    0.34709556909569184,
    0.3702249257894571,
    0.39272483400399893,
    0.41456988647721615,
    0.43582889025419114,
    0.4564192786416,
    0.476410299013587,
    0.4957560715637827,
    0.5145493169954743,
    0.5327205670880077,
    0.5502846891191615,
    0.5673274324802855,
    0.583810881323224,
    0.5997478744397482,
    0.615194045299478,
    0.6301165005270208,
    0.6445484042257972,
    0.6585198219185201,
    0.6720397744233084,
    0.6850997688076114,
    0.6977281404741683,
    0.7099506591298411,
    0.7217749311525871,
    0.7331784038850426,
    0.7442308394229518,
    0.7549087205105974,
    0.7652471277371271,
    0.7752251637549381,
    0.7848768260203478,
    0.7942056937103814,
    0.8032299679689082,
    0.8119428702388629,
    0.8203713516576219,
    0.8285187880808974,
    0.8363794492831295,
    0.8439768562813565,
    0.851322799855549,
    0.8584111051351724,
    0.8652534074722162,
    0.8718525580962131,
    0.8782333271742155,
    0.8843892099362031,
    0.8903155590440985,
    0.8960465359221951,
    0.9015574505919048,
    0.9068736766459904,
    0.9119951682409297,
    0.9169321898723632,
    0.9216747065581234,
    0.9262420604674766,
    0.9306331858366086,
    0.9348476990715433,
    0.9389007110754832,
    0.9427903495057521,
    0.9465220679845756,
    0.9500943036519721,
    0.9535176728088761,
    0.9567898524767604,
    0.959924306623116,
    0.9629127700159108,
    0.9657622101750765,
    0.9684818726275105,
    0.9710676079044347,
    0.9735231939498,
    0.9758514437576309,
    0.9780599066560445,
    0.9801485715370128,
    0.9821149805689633,
    0.9839677526782791,
    0.9857085499421516,
    0.9873347811966005,
    0.9888547171706613,
    0.9902689443512227,
    0.9915771042095881,
    0.9927840651641069,
    0.9938913963715834,
    0.9948987305580712,
    0.9958114963810524,
    0.9966274782266875,
    0.997352148697352,
    0.9979848677523623,
    0.9985285021374979,
    0.9989844084453229,
    0.9993537595844986,
    0.999638729860106,
    0.9998403888004533,
    0.9999602810470701,
    1.0,
  ];
}
