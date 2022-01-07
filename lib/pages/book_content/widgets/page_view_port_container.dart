import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'delegate.dart';
import 'page_view_controller.dart';

typedef WidgetCallback = Widget? Function(int page, {bool changeState});

class ContentViewPortContainer extends RenderObjectWidget {
  const ContentViewPortContainer({
    Key? key,
    required this.offset,
    this.itemExtent,
    required this.delegate,
  }) : super(key: key);
  final ContentViewController offset;
  final double? itemExtent;
  final ContentChildBuildDelegate delegate;
  @override
  RenderObjectElement createElement() {
    return ContentViewElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    final manager = context as ContentViewElement;
    return RenderContentViewPort(
        childManager: manager, offset: offset, itemExtent: itemExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderContentViewPort renderObject) {
    renderObject
      ..offset = offset
      ..itemExtent = itemExtent;
  }
}

class ContentViewElement extends RenderObjectElement
    implements ContentChildManager {
  ContentViewElement(RenderObjectWidget widget) : super(widget);

  @override
  ContentViewPortContainer get widget =>
      super.widget as ContentViewPortContainer;
  @override
  RenderContentViewPort get renderObject =>
      super.renderObject as RenderContentViewPort;

  final _childElements = SplayTreeMap<int, Element>();
  @override
  void update(ContentViewPortContainer newWidget) {
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
    for (var el in _childElements.entries.toList()) {
      var result = updateChild(el.value, null, el.key);
      assert(result == null);
    }
    _childElements.clear();
  }

  @override
  void createChild(int index, {RenderBox? after}) {
    owner!.buildScope(this, () {
      Element? el;
      try {
        el = updateChild(_childElements[index], _build(index), index);
      } finally {}
      if (el != null) {
        _childElements[index] = el;
      } else {
        _childElements.remove(index);
      }
    });
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    owner!.buildScope(this, () {
      assert(_childElements.containsKey(index));
      final Element? result = updateChild(_childElements[index], null, index);
      assert(result == null);
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final ContentParentData? oldParentData =
        child?.renderObject?.parentData as ContentParentData?;
    final Element? newChild = super.updateChild(child, newWidget, newSlot);
    final ContentParentData? newParentData =
        newChild?.renderObject?.parentData as ContentParentData?;
    if (newParentData != null) {
      newParentData.index = newSlot! as int;
      if (oldParentData != null) newParentData.offset = oldParentData.offset;
    }

    return newChild;
  }

  Widget? _build(int index) {
    return widget.delegate.build(this, index);
  }

  @override
  bool childExistsAt(int index) {
    return widget.delegate.childExistsAt(index);
  }

  @override
  Extent getExtent(
      int firstIndex, int lastIndex, int currentIndex, double itemExtent) {
    return widget.delegate
        .getExtent(firstIndex, lastIndex, currentIndex, itemExtent);
  }

  @override
  int? get childCount => widget.delegate.childCount;

  @override
  void insertRenderObjectChild(
      covariant RenderObject child, covariant int slot) {
    renderObject.insert(child as RenderBox,
        after: _childElements[slot - 1]?.renderObject as RenderBox?);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant slot) {
    renderObject.remove(child as RenderBox);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    _childElements.forEach((int key, Element child) {
      visitor(child);
    });
  }

  @override
  void forgetChild(Element child) {
    _childElements.remove(child.slot);
    super.forgetChild(child);
  }
}

class ContentParentData extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {
  int? index;
}

class RenderContentViewPort extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, ContentParentData> {
  RenderContentViewPort({
    required this.childManager,
    required ContentViewController offset,
    double? itemExtent,
    List<RenderBox>? children,
  })  : _offset = offset,
        _itemExtent = itemExtent {
    addAll(children);
  }
  ContentChildManager childManager;
  double? _itemExtent;

  double get itemExtent => _itemExtent ?? viewPortExtent;
  set itemExtent(double? v) {
    if (_itemExtent == v) return;
    _itemExtent = v;
  }

  ContentViewController _offset;
  ContentViewController get offset => _offset;
  set offset(ContentViewController newOffset) {
    if (newOffset == _offset) return;
    if (attached) {
      offset.removeListener(_hasScrolled);
      _offset = newOffset;
      offset.addListener(_hasScrolled);
    }
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasScrolled);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ContentParentData) {
      child.parentData = ContentParentData();
    }
  }

  @override
  void detach() {
    _offset.removeListener(_hasScrolled);
    super.detach();
  }

  void _hasScrolled() {
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  double _getIntrinsicCrossAxis(double Function(RenderBox child) childSize) {
    double extent = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      child = childAfter(child);
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicCrossAxis(
      (RenderBox child) => child.getMinIntrinsicWidth(height),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicCrossAxis(
      (RenderBox child) => child.getMaxIntrinsicWidth(height),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (childManager.childCount == null) return 0.0;
    return childManager.childCount! * itemExtent;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (childManager.childCount == null) return 0.0;
    return childManager.childCount! * itemExtent;
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  int indexOf(RenderBox child) {
    final parentData = child.parentData as ContentParentData;
    return parentData.index!;
  }

  double indexToScrollOffset(int index) => index * itemExtent;

  void _createChild(int index, {RenderBox? after}) {
    invokeLayoutCallback<BoxConstraints>((BoxConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.createChild(index, after: after);
    });
  }

  void _destroyChild(RenderBox child) {
    invokeLayoutCallback<BoxConstraints>((BoxConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.removeChild(child);
    });
  }

  void _layoutChild(RenderBox child, BoxConstraints constraints, int index) {
    child.layout(constraints, parentUsesSize: true);
    final childParentData = child.parentData! as ContentParentData;
    childParentData.offset =
        computeAbsolutePaintOffset(indexToLayoutOffset(index), offset.pixels);
  }

  Offset computeAbsolutePaintOffset(double layoutOffset, double pixels) {
    switch (offset.axis) {
      case Axis.horizontal:
        return Offset(layoutOffset - pixels, 0.0);
      case Axis.vertical:
        return Offset(0.0, layoutOffset - pixels);
      default:
        return Offset.zero;
    }
  }

  double get viewPortExtent {
    if (offset.axis == Axis.horizontal) {
      return size.width;
    } else {
      return size.height;
    }
  }

  int getMinChildIndexForScrollOffset(double scrollOffset) {
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

  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return itemExtent > 0.0 ? (scrollOffset / itemExtent).ceil() - 1 : 0;
  }

  double indexToLayoutOffset(int index) => itemExtent * index;

  @override
  void performLayout() {
    BoxConstraints childConstraints = constraints;
    if (_itemExtent != null) {
      childConstraints = constraints.copyWith(
        minHeight: _itemExtent,
        maxHeight: _itemExtent,
        minWidth: 0.0,
      );
    }

    final pixels = offset.pixels;

    var _firstIndex = getMinChildIndexForScrollOffset(pixels);
    var _lastIndex = getMaxChildIndexForScrollOffset(pixels + viewPortExtent);

    while (
        !childManager.childExistsAt(_firstIndex) && _firstIndex <= _lastIndex) {
      _firstIndex++;
    }
    while (
        !childManager.childExistsAt(_lastIndex) && _firstIndex <= _lastIndex) {
      _lastIndex--;
    }

    if (_firstIndex > _lastIndex) {
      while (firstChild != null) {
        _destroyChild(firstChild!);
      }
    }

    if (childCount > 0 &&
        (indexOf(firstChild!) > _lastIndex ||
            indexOf(lastChild!) < _firstIndex)) {
      while (firstChild != null) {
        _destroyChild(firstChild!);
      }
    }
    if (childCount == 0) {
      _createChild(_firstIndex);
    }

    if (firstChild != null) {
      int currentFirstIndex = indexOf(firstChild!);
      int lastIndex = indexOf(lastChild!);
      while (currentFirstIndex < _firstIndex) {
        _destroyChild(firstChild!);
        currentFirstIndex++;
      }

      while (lastIndex > _lastIndex) {
        _destroyChild(lastChild!);
        lastIndex--;
      }
      while (currentFirstIndex > _firstIndex) {
        _createChild(currentFirstIndex - 1);
        --currentFirstIndex;
      }
      while (lastIndex < _lastIndex) {
        _createChild(lastIndex + 1, after: lastChild);
        ++lastIndex;
      }
    }
    RenderBox? child = firstChild;
    while (child != null) {
      _layoutChild(child, childConstraints, indexOf(child));
      child = childAfter(child);
    }

    _offset.applyViewPortDimension(viewPortExtent);

    Extent scrollExtent;
    if (firstChild != null) {
      scrollExtent = childManager.getExtent(indexOf(firstChild!),
          indexOf(lastChild!), _offset.page.round(), itemExtent);
    } else {
      final currentIndex = _offset.page.round();
      scrollExtent = childManager.getExtent(
          currentIndex, currentIndex, currentIndex, itemExtent);
    }
    if (scrollExtent != Extent.none)
      _offset.applyContentDimension(
          minExtent: scrollExtent.minExtent, maxExtent: scrollExtent.maxExtent);
  }

  final _clipRectLayer = LayerHandle<ClipRectLayer>();
  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount != 0)
      _clipRectLayer.layer = context.pushClipRect(
          needsCompositing, offset, Offset.zero & size, defaultPaint,
          oldLayer: _clipRectLayer.layer);
  }

  void defaultPaint(PaintingContext context, Offset offset) {
    RenderBox? childToPaint = firstChild;
    while (childToPaint != null) {
      context.paintChild(
          childToPaint, offset + childScrollOffset(childToPaint)!);
      childToPaint = childAfter(childToPaint);
    }
  }

  Offset? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final childParentData = child.parentData as ContentParentData;
    return childParentData.offset;
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      false;
}
