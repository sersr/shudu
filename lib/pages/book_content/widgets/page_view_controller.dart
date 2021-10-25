import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:useful_tools/common.dart';

import '../../../provider/content_notifier.dart';
import '../../../widgets/activity.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});

class NopPageViewController extends ChangeNotifier with ActivityDelegate {
  NopPageViewController({
    required this.scrollingNotify,
    required this.vsync,
    required this.canDrag, // required this.getDragState,
    required this.getBounds,
  })  : _maxExtent = double.infinity,
        _minExtent = double.negativeInfinity {
    _activity = IdleActivity(this);
  }

  TickerProvider vsync;

  // BoolCallback getDragState;
  void Function(bool) scrollingNotify;
  int Function() getBounds;
  bool Function() canDrag;
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
    if (_activity is! IdleActivity) {
      goIdle();
    }
    notifyListeners();
  }

  double get page {
    // assert(viewPortDimension != null);
    return pixels / viewPortDimension!;
  }

  bool _reset = false;
  void needLayout() {
    _reset = true;

    applyConentDimension(
        minExtent: double.negativeInfinity, maxExtent: double.infinity);

    notifyListeners();
  }

  void resetDone(VoidCallback? reset) {
    if (_reset && reset != null) {
      reset();
    }
    _reset = false;
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
    if (_lastActivityIsIdle && viewPortDimension != null) {
      // if (axis == Axis.horizontal) {
      if (ContentBoundary.hasRight(getBounds())) {
        if (maxExtent.isFinite) {
          _maxExtent = double.infinity;
        }
        setPixels(viewPortDimension! * (page + 0.51).round());
      }
      // }
      goIdle();
    }
  }

  void prePage() {
    if (_lastActivityIsIdle && ContentBoundary.hasLeft(getBounds())) {
      if (minExtent.isFinite) {
        _minExtent = double.negativeInfinity;
      }
      setPixels(viewPortDimension! * (page - 0.51).round());
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
    v = v.clamp(minExtent, maxExtent);
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
    } else if (velocity > 150.0) {
      to = (page + f).round();
    } else {
      to = page.round();
    }

    final end = (to * viewPortDimension!).clamp(minExtent, maxExtent);

    beginActivity(BallisticActivity(
      delegate: this,
      vsync: vsync,
      end: () => end.clamp(minExtent, maxExtent),
      simulation: getSpringSimulation(velocity, end),
    ));
  }

  @override
  void goBallistic(double velocity) {
    if (axis == Axis.horizontal) {
      animateTo(velocity, f: 0.52);
    } else {
      // if (pixels == minExtent || pixels == maxExtent) notifyListeners();
      beginActivity(BallisticActivity(
        delegate: this,
        vsync: vsync,
        end: () => velocity >= 0.0 ? maxExtent : minExtent,
        simulation: getSimulation(velocity),
        isVerticalDown: velocity >= 0,
      ));
    }
  }

  void correct(double v) {
    if (_pixels == v) return;
    _pixels = v.clamp(minExtent, maxExtent);
  }

  void correctBy(double v) {
    correct(_pixels + v);
  }

  double _minExtent;
  double _maxExtent;

  double get minExtent => _minExtent;
  double get maxExtent => _maxExtent;

  void applyConentDimension({double? minExtent, double? maxExtent}) {
    if (minExtent != null && _minExtent != minExtent) {
      _minExtent = minExtent;
    }
    if (maxExtent != null && _maxExtent != maxExtent) {
      _maxExtent = maxExtent;
    }
  }

  @override
  void applyUserOffset(double delta) {
    if (delta == 0.0) return;
    if (pixels == minExtent || pixels == maxExtent) {
      final contentValue = getBounds();
      final hasRight = ContentBoundary.hasRight(contentValue);
      final hasLeft = ContentBoundary.hasLeft(contentValue);
      applyConentDimension(
          minExtent: hasLeft ? double.negativeInfinity : minExtent,
          maxExtent: hasRight ? double.infinity : maxExtent);
    }

    setPixels(pixels - delta);
  }

  PreNextDragController? _currentDrag;

  PreNextDragController? drag(
      DragStartDetails details, VoidCallback cancelCallback) {
    // if (!canDrag()) return null;
    final _drag =
        PreNextDragController(delegate: this, cancelCallback: cancelCallback);
    beginActivity(DragActivity(delegate: this, controller: _drag));
    _currentDrag = _drag;
    return _drag;
  }

  var _lastActivityIsIdle = true;
  ScrollHoldController hold(VoidCallback cancel) {
    scrollingnotifier(true);

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
  const ContentPreNextWidget(
      {Key? key, required this.builder, required this.offset})
      : super(key: key);
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
    for (var element in childElement.values) {
      visitor(element);
    }
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
          final clear = key < leadingGarbage || key > trailingGarbage;
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
      _nopController.addListener(markNeedsLayout);
    }
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _nopController.addListener(markNeedsLayout);
    for (var element in childlist.values) {
      element.attach(owner);
    }
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
  void _layout(double pixels, double extent) {
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
      _element!._build(nopController.page.round(), changeState: true);

      final contentBoundary = nopController.getBounds();
      final hasLeft = ContentBoundary.hasLeft(contentBoundary);
      final hasRight = ContentBoundary.hasRight(contentBoundary);

      nopController.applyConentDimension(
        minExtent: hasLeft
            ? double.negativeInfinity
            : indexToLayoutOffset(extent, firstIndex!),
        maxExtent: hasRight
            ? double.infinity
            : indexToLayoutOffset(extent, lastIndex!),
      );
    } else {
      collectGarbage(0, 0);
    }
  }

  // 布局之后，属性会改变，确保 `pixels` 还在 范围区间
  bool correct() {
    final rawPixels = _nopController.pixels;
    _nopController.correct(rawPixels);

    final pixels = _nopController.pixels;

    return rawPixels == pixels;
  }

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

    nopController.resetDone(_element?.removeAll);

    _layout(nopController.pixels, extent);

    // 一次校验
    if (!correct() || !canPaint) {
      _layout(_nopController.pixels, extent);
    }

    if (canPaint) {
      final pixels = _nopController.pixels;

      for (var i = firstIndex!; i <= lastIndex!; i++) {
        final child = childlist[i]!;
        final data = child.parentData as NopPageViewParenData;

        child.layout(constraints, parentUsesSize: true);

        data.layoutOffset = computeAbsolutePaintOffset(
            indexToLayoutOffset(extent, i)
                .clamp(nopController.minExtent, nopController.maxExtent),
            pixels);
      }
      collectGarbage(firstIndex! - 1, lastIndex! + 1);
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

  /// 渲染边界
  @override
  bool get isRepaintBoundary => true;

  final _clipRectLayer = LayerHandle<ClipRectLayer>();
  @override
  void paint(PaintingContext context, Offset offset) {
    if (canPaint)
      _clipRectLayer.layer = context.pushClipRect(
          needsCompositing, offset, Offset.zero & size, defaultPaint,
          oldLayer: _clipRectLayer.layer);
  }

  void defaultPaint(PaintingContext context, Offset offset) {
    // context.setWillChangeHint();
    for (var i = firstIndex!; i <= lastIndex!; i++) {
      final child = childlist[i]!;
      context.paintChild(child, offset + childScrollOffset(child)!);
    }
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
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
    for (var element in childlist.values) {
      element.detach();
    }
  }

  @override
  void visitChildren(visitor) {
    for (var element in childlist.values) {
      visitor(element);
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    for (var element in childlist.values) {
      visitor(element);
    }
  }
}
