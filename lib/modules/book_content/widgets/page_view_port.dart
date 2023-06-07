import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'delegate.dart';
import 'page_view_controller.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});

class ContentViewPort extends RenderObjectWidget {
  const ContentViewPort({
    Key? key,
    required this.delegate,
    required this.offset,
    this.itemExtent,
  }) : super(key: key);

  final ContentChildBuildDelegate delegate;
  final ContentViewController offset;
  final double? itemExtent;

  @override
  ContentViewElement createElement() => ContentViewElement(this);

  @override
  RenderContentViewPort createRenderObject(BuildContext context) {
    return RenderContentViewPort(vpOffset: offset, itemExtent: itemExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderContentViewPort renderObject) {
    renderObject
      ..itemExtent = itemExtent
      ..nopController = offset;
  }
}

class ContentViewElement extends RenderObjectElement {
  ContentViewElement(RenderObjectWidget widget) : super(widget);

  @override
  ContentViewPort get widget => super.widget as ContentViewPort;
  @override
  RenderContentViewPort get renderObject =>
      super.renderObject as RenderContentViewPort;

  final childElements = SplayTreeMap<int, Element>();
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
    if (childElements.containsKey(index)) {
      childElements.remove(index);
    }
    super.forgetChild(child);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var element in childElements.values) {
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
    renderObject.markNeedsLayout();
  }

  void removeAll() {
    for (var el in childElements.values.toList()) {
      var result = updateChild(el, null, null);
      assert(result == null);
    }
    childElements.clear();
  }

  void createChild(int index) {
    owner!.buildScope(this, () {
      Element? el;
      try {
        el = updateChild(childElements[index], _build(index), index);
      } finally {}
      if (el != null) {
        childElements[index] = el;
      } else {
        childElements.remove(index);
      }
    });
  }

  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    owner!.buildScope(this, () {
      try {
        childElements.removeWhere((key, value) {
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

  Widget? _build(int index) {
    return widget.delegate.build(this, index);
  }

  Extent getExtent(
      int firstIndex, int lastIndex, int currentIndex, double itemExtent) {
    return widget.delegate
        .getExtent(firstIndex, lastIndex, currentIndex, itemExtent);
  }

  @override
  void insertRenderObjectChild(covariant RenderObject child, covariant slot) {
    renderObject.add(child as RenderBox, slot);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant slot) {
    renderObject.remove(child as RenderBox, slot);
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child,
      covariant Object? oldSlot, covariant Object? newSlot) {}
}

class NopPageViewParenData extends BoxParentData {
  Offset? layoutOffset;
  @override
  String toString() {
    return '$runtimeType: $layoutOffset';
  }
}

class RenderContentViewPort extends RenderBox {
  RenderContentViewPort(
      {required ContentViewController vpOffset, double? itemExtent})
      : offset = vpOffset,
        _itemExtent = itemExtent;

  ContentViewElement? _element;
  final children = <int, RenderBox>{};

  void add(RenderBox child, index) {
    assert(index is int);
    if (children[index] != null) {
      dropChild(children[index]!);
    }
    adoptChild(child);
    children[index] = child;
  }

  void remove(RenderBox child, index) {
    assert(children[index] == child);
    children.remove(index);
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

  double? _itemExtent;
  double get itemExtent => _itemExtent ?? viewPortExtent;
  set itemExtent(double? v) {
    if (v == _itemExtent) return;
    _itemExtent = v;
    markNeedsLayout();
  }

  ContentViewController offset;

  ContentViewController get nopController => offset;

  set nopController(ContentViewController v) {
    if (offset == v) return;
    if (attached) {
      offset.removeListener(markNeedsLayout);
      offset = v;
      offset.addListener(markNeedsLayout);
    }
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    offset.addListener(markNeedsLayout);
    for (var element in children.values) {
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
    final _firstIndex = getMinChildIndexForScrollOffset(pixels, itemExtent);
    final _lastIndex =
        getMaxChildIndexForScrollOffset(pixels + extent, itemExtent);
    for (var i = _firstIndex; i <= _lastIndex; i++) {
      if (!children.containsKey(i)) {
        layoutChild(i);
      }
    }
    for (var i = _firstIndex; i <= _lastIndex; i++) {
      if (children.containsKey(i)) {
        firstIndex = i;
        break;
      }
    }
    for (var i = _lastIndex; i >= _firstIndex; i--) {
      if (children.containsKey(i)) {
        lastIndex = i;
        break;
      }
    }
    Extent scrollExtent;
    if (canPaint) {
      scrollExtent = _element!.getExtent(
          firstIndex!, lastIndex!, nopController.page.round(), itemExtent);
    } else {
      final currentIndex = nopController.page.round();
      scrollExtent = _element!
          .getExtent(currentIndex, currentIndex, currentIndex, itemExtent);
      collectGarbage(0, 0);
    }
    if (scrollExtent != Extent.none)
      nopController.applyContentDimension(
          minExtent: scrollExtent.minExtent, maxExtent: scrollExtent.maxExtent);
  }

  double get viewPortExtent {
    axis = nopController.axis;
    if (axis == Axis.horizontal) {
      return size.width;
    } else {
      return size.height;
    }
  }

  @override
  void performLayout() {
    nopController.applyViewPortDimension(viewPortExtent);

    _layout(nopController.pixels, viewPortExtent);

    if (canPaint) {
      final pixels = offset.pixels;

      for (var i = firstIndex!; i <= lastIndex!; i++) {
        final child = children[i]!;
        final data = child.parentData as NopPageViewParenData;

        child.layout(constraints, parentUsesSize: true);

        final s = indexToLayoutOffset(itemExtent, i);
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
      final child = children[i]!;
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
    children.values.forEach((redepthChild));
  }

  @override
  void detach() {
    super.detach();

    offset.removeListener(markNeedsLayout);
    for (var element in children.values) {
      element.detach();
    }
  }

  @override
  void visitChildren(visitor) {
    for (var element in children.values) {
      visitor(element);
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    for (var element in children.values) {
      visitor(element);
    }
  }
}
