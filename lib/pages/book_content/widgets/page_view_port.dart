import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'page_view_controller.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});

class ContentViewPort extends RenderObjectWidget {
  const ContentViewPort({Key? key, required this.builder, required this.offset})
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
  ContentViewPort get widget => super.widget as ContentViewPort;
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
    } else {
      collectGarbage(0, 0);
    }
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

    _layout(nopController.pixels, extent);

    if (canPaint) {
      final pixels = _nopController.pixels;

      for (var i = firstIndex!; i <= lastIndex!; i++) {
        final child = childlist[i]!;
        final data = child.parentData as NopPageViewParenData;

        child.layout(constraints, parentUsesSize: true);

        final s = indexToLayoutOffset(extent, i);
        final d = computeAbsolutePaintOffset(
            s.clamp(nopController.minExtent, nopController.maxExtent), pixels);
        data.layoutOffset = d;
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
