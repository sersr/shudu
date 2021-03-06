import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../../../provider/painter_notifier.dart';
import '../../../utils/utils.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});

class NopPageViewController extends ChangeNotifier with ActivityDelegate {
  NopPageViewController({
    required this.scrollingNotify,
    required this.vsync,
    // required this.getDragState,
    required this.getBounds,
  })  : _maxExtent = double.infinity,
        _minExtent = double.negativeInfinity {
    _activity = IdleActivity(this);
  }

  TickerProvider vsync;

  // BoolCallback getDragState;
  void Function(bool) scrollingNotify;
  int Function() getBounds;

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

  static final SpringDescription kDefaultSpring =
      SpringDescription.withDampingRatio(
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
      if (axis == Axis.horizontal) {
        if (ContentBounds.hasRight(getBounds())) {
          if (maxExtent!.isFinite) {
            _maxExtent = double.infinity;
          }
          setPixels(viewPortDimension! * (page + 0.51).round());
        }
      } else {
        if (getBounds() & ContentBounds.addRight != 0) {
          var _n = page;

          if (maxExtent!.isFinite) {
            _maxExtent = double.infinity;
          }

          if (ContentBounds.hasRight(getBounds())) {
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
    if (_activity is IdleActivity && ContentBounds.hasLeft(getBounds())) {
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
    scrollingnotifier(false);
    beginActivity(IdleActivity(this));
  }

  @override
  void setPixels(double v) {
    if (v == _pixels) return;

    v = v.clamp(minExtent!, maxExtent!);
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

  void animateTo(double velocity, {double f = 0.8}) {
    int to;
    if (pixels == minExtent || pixels == maxExtent) notifyListeners();

    if (velocity < -150.0) {
      to = (page - f).round();
      velocity = velocity < -500 ? velocity / 2 : velocity;
    } else if (velocity > 150.0) {
      to = (page + f).round();
      velocity = velocity > 500 ? velocity / 2 : velocity;
    } else {
      to = page.round();
    }

    final end = (to * viewPortDimension!).clamp(minExtent!, maxExtent!);

    beginActivity(BallisticActivity(
      delegate: this,
      vsync: vsync,
      end: () => end,
      simulation: getSpringSimulation(velocity, end),
    ));
  }

  @override
  void goBallistic(double velocity) {
    if (axis == Axis.horizontal) {
      animateTo(velocity, f: 0.52);
    } else {
      if (pixels == minExtent || pixels == maxExtent) notifyListeners();
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

  void applyConentDimension(
      {required double minExtent, required double maxExtent}) {
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
  PreNextDragController? drag(
      DragStartDetails details, VoidCallback cancelCallback) {
    scrollingnotifier(true);
    final _drag =
        PreNextDragController(delegate: this, cancelCallback: cancelCallback);
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
  void updateRenderObject(
      BuildContext context, covariant ContentPreNextRenderObject renderObject) {
    renderObject.nopController = offset;
  }
}

class ContentPreNextElement extends RenderObjectElement {
  ContentPreNextElement(RenderObjectWidget widget) : super(widget);

  @override
  ContentPreNextWidget get widget => super.widget as ContentPreNextWidget;
  @override
  ContentPreNextRenderObject get renderObject =>
      super.renderObject as ContentPreNextRenderObject;

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
    renderObject.needLayout();
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
  ContentPreNextRenderObject({required NopPageViewController vpOffset})
      : _nopController = vpOffset;

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

  void needLayout() {
    markNeedsLayout();
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

    if (canPaint) {
      /// 通知
      final leftRight = nopController.getBounds();
      final hasLeft = ContentBounds.hasLeft(leftRight);
      final hasRight = ContentBounds.hasRight(leftRight);

      _element!._build(nopController.page.round(), changeState: true);

      nopController.applyConentDimension(
        minExtent: hasLeft
            ? double.negativeInfinity
            : indexToLayoutOffset(extent, firstIndex!),
        maxExtent: hasRight
            ? double.infinity
            : indexToLayoutOffset(extent, lastIndex!),
      );
      for (var i = firstIndex!; i <= lastIndex!; i++) {
        final child = childlist[i]!;
        assert(childlist.containsKey(i));
        final data = child.parentData as NopPageViewParenData;

        child.layout(constraints, parentUsesSize: true);

        data.layoutOffset = computeAbsolutePaintOffset(
            indexToLayoutOffset(extent, i)
                .clamp(nopController.minExtent!, nopController.maxExtent!),
            pixels);
      }
      collectGarbage(firstIndex!, lastIndex!);
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

  final _clipRectLayer = LayerHandle<ClipRectLayer>();
  @override
  void paint(PaintingContext context, Offset offset) {
    _clipRectLayer.layer = context.pushClipRect(
        needsCompositing, offset, Offset.zero & size, defaultPaint,
        oldLayer: _clipRectLayer.layer);
  }

  void defaultPaint(PaintingContext context, Offset offset) {
    if (canPaint)
      for (var i = firstIndex!; i <= lastIndex!; i++) {
        assert(childlist.containsKey(i));
        final child = childlist[i]!;
        context.paintChild(child, offset + childScrollOffset(child)!);
      }
  }

  @override
  void dispose() {
    super.dispose();
    _clipRectLayer.layer = null;
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

  double indexToLayoutOffset(double itemExtent, int index) =>
      itemExtent * index;

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
