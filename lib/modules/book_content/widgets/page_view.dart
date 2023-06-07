import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nop/nop.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../book_index/providers/book_index_notifier.dart';
import '../../constants.dart';
import '../providers/content_notifier.dart';
import '../text_data.dart';
import 'battery_view.dart';
import 'content_view.dart';
import 'delegate.dart';
import 'page_view_controller.dart';
// ignore: unused_import
import 'page_view_port.dart';
// ignore: unused_import
import 'page_view_port_container.dart';
import 'pannel.dart';

class ContentPageView extends StatefulWidget {
  const ContentPageView({Key? key}) : super(key: key);

  @override
  ContentPageViewState createState() => ContentPageViewState();
}

class ContentPageViewState extends State<ContentPageView>
    with TickerProviderStateMixin {
  late ContentViewController offsetPosition;
  ContentNotifier? _bloc;
  ContentNotifier get bloc => _bloc!;
  late BookIndexNotifier indexBloc;

  @override
  void initState() {
    super.initState();
    offsetPosition = ContentViewController(
      vsync: this,
      onScrollingChanged: onScrollingChanged,
    );
  }

  final lKey = Object();

  void onshow() async {
    indexBloc.addRegisterKey(lKey);

    if (bloc.config.value.orientation! && bloc.inBook) {
      bloc.uiOverlayShow = true;
      return uiOverlay(hide: false);
    }
  }

  void onhide() async {
    indexBloc.removeRegisterKey(lKey);

    if (bloc.config.value.orientation! && bloc.inBook) {
      bloc.uiOverlayShow = false;
      return uiOverlay();
    }
  }

  OverlayVerticalPannels? _pannels;

  OverlayVerticalPannels get pannels {
    if (_pannels != null) return _pannels!;
    late OverlayVerticalPannels pannel;
    return _pannels = pannel = OverlayVerticalPannels(
      onShowEnd: onshow,
      onHideEnd: onhide,
      builders: [
        (context) {
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PannelTransition(
              controller: pannel.controller,
              begin: const Offset(0, 1),
              child: Pannel(controller: offsetPosition),
            ),
          );
        },
        (context) {
          return Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PannelTransition(
              controller: pannel.controller,
              begin: const Offset(0, -1),
              child: const TopPannel(),
            ),
          );
        }
      ],
    );
  }

  OverlayMixinDelegate? _delegate;
  OverlayMixinDelegate get delegate {
    if (_delegate != null) {
      if (!_delegate!.closed) return _delegate!;
    }

    bloc.runner.whenComplete(() {
      indexBloc.loadIndexs(bloc.bookId, bloc.cid, api: bloc.api);
    });

    return _delegate =
        OverlayMixinDelegate(pannels, const Duration(milliseconds: 350))
          ..overlay = context.getType<OverlayObserver>();
  }

  void toggle() {
    delegate.showStatus ? hide() : show();
  }

  void show() {
    EventQueue.pushOne(toggle, delegate.show);
  }

  void hide() {
    EventQueue.pushOne(toggle, delegate.hide);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc?.handle.removeListener(update);
    _bloc = context.getType<ContentNotifier>()..controller = offsetPosition;
    _bloc!.handle.addListener(update);
    indexBloc = context.getType<BookIndexNotifier>();
    update();
  }

  void update() {
    final axis = bloc.config.value.axis;
    assert(axis != null);
    if (axis != null) {
      offsetPosition.axis = axis;
    }
    setState(() {});
  }

  void onScrollingChanged(bool isScrolling) {
    bloc.scheduleTask();
    if (isScrolling) {
      bloc.stopSave();
    } else {
      // bloc.reduceController();
      bloc.stopAutoRun();
    }
  }

  Widget batteryView() {
    return FutureBuilder<int>(
      future: bloc.repository.getBatteryLevel,
      builder: (context, snaps) {
        final v = snaps.hasData ? snaps.data! : bloc.repository.level;
        return BatteryView(
          progress: (v / 100).clamp(0.0, 1.0),
          color: bloc.config.value.fontColor!,
        );
      },
    );
  }

  Widget? childBuild(_, ContentMetrics? mes) {
    if (mes == null) return null;
    final isHorizontal = offsetPosition.axis == Axis.horizontal;
    Widget? battery;
    if (isHorizontal) {
      battery = batteryView();
    }

    return ContentView(contentMetrics: mes, battery: battery);
  }

  Widget verticalLayout(Widget child) {
    final header = AnimatedBuilder(
      animation: bloc.header,
      builder: (__, _) {
        return Text(
          bloc.header.value,
          style: bloc.secstyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        );
      },
    );

    final footer = AnimatedBuilder(
      animation: bloc.footer,
      builder: (__, _) {
        final time = DateTime.now();
        final footerLeftBattery = batteryView();
        final footerLeft = Text(
          time.hourAndMinuteFormat,
          style: bloc.secstyle,
          maxLines: 1,
        );

        final footerRight = Text(
          bloc.footer.value,
          style: bloc.secstyle,
          textAlign: TextAlign.right,
          maxLines: 1,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            footerLeftBattery,
            footerLeft,
            const Expanded(child: SizedBox()),
            footerRight,
          ],
        );
      },
    );

    return _ContentVerticalWidget(
      contentLayoutPadding: bloc.contentLayoutPadding,
      header: RepaintBoundary(child: header),
      body: RepaintBoundary(child: child),
      footer: RepaintBoundary(child: footer),
    );
  }

  Widget wrapChild() {
    // final child = NopPageView(
    //     offsetPosition: offsetPosition,
    //     delegate: ContentBuildDelegate(bloc, getChild));
    final child = NopPageView(
        offsetPosition: offsetPosition,
        delegate: ContentPageBuildDelegate(
            content: bloc.handle, builder: childBuild));

    if (offsetPosition.axis == Axis.horizontal) {
      return child;
    } else {
      return verticalLayout(child);
    }
  }

  bool onTap(Size size, Offset g) {
    final halfH = size.height / 2;
    final halfW = size.width / 2;
    final minHeight = size.height / 5;
    final minWidth = size.width / 5;
    final x = g.dx - halfW;
    final y = g.dy - halfH;
    return x.abs() < minWidth && y.abs() < minHeight;
  }

  void _nextPage() {
    if (!bloc.autoRunActive) {
      offsetPosition.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final halfHeight = size.height / 2;
    final halfWidth = size.width / 2;
    final minHeight = size.height / 5;
    final minWidth = size.width / 5;

    final empty = GestureDetector(
      onTap: toggle,
      child: ColoredBox(
          color: Colors.transparent, child: reloadBotton(bloc.reload)),
    );

    final contentView = GestureDetector(
      onTapUp: (details) {
        final g = details.globalPosition;
        final x = g.dx - halfWidth;
        final y = g.dy - halfHeight;
        final tapMiddle = x.abs() < minWidth && y.abs() < minHeight;

        tapMiddle ? toggle() : _nextPage();
      },
      child: wrapChild(),
    );

    return AnimatedBuilder(
      animation: bloc.notEmptyOrIgnore,
      builder: (context, child) {
        return bloc.notEmptyOrIgnore.value ? contentView : empty;
      },
    );
  }

  @override
  void dispose() {
    offsetPosition.dispose();
    _bloc?.handle.removeListener(update);
    bloc.controller = null;
    indexBloc.removeRegisterKey(lKey);
    super.dispose();
  }
}

/// [NopPageView]
///
/// 以 0 为起始点，端点由程序控制
/// 提供状态更改体制
/// 当 index 改变时，会发出通知
class NopPageView extends StatefulWidget {
  const NopPageView({
    Key? key,
    required this.offsetPosition,
    required this.delegate,
  }) : super(key: key);

  final ContentViewController offsetPosition;
  final ContentChildBuildDelegate delegate;
  @override
  _NopPageViewState createState() => _NopPageViewState();
}

class _NopPageViewState extends State<NopPageView> {
  Drag? drag;
  ScrollHoldController? hold;
  // final GlobalKey<RawGestureDetectorState> _gestureDetectorKey = GlobalKey<RawGestureDetectorState>();

  Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};
  @override
  void initState() {
    super.initState();
    updategest();
  }

  @override
  void didUpdateWidget(covariant NopPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updategest();
  }

  void updategest() {
    const dragStartBehavior = DragStartBehavior.start;
    if (widget.offsetPosition.axis == Axis.vertical) {
      gestures = <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (VerticalDragGestureRecognizer instance) {
            instance
              ..onDown = onDown
              ..onStart = onStart
              ..onUpdate = onUpdate
              ..onEnd = onEnd
              ..onCancel = onCancel
              // ..minFlingDistance = 8.0
              // ..minFlingVelocity = kMinFlingVelocity
              // ..maxFlingVelocity = kMaxFlingVelocity
              ..dragStartBehavior = dragStartBehavior;
            // ..velocityTrackerBuilder = (PointerEvent event) => VelocityTracker.withKind(event.kind);
          },
        )
      };
    } else {
      gestures = <Type, GestureRecognizerFactory>{
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(debugOwner: this),
          (HorizontalDragGestureRecognizer instance) {
            instance
              ..onDown = onDown
              ..onStart = onStart
              ..onUpdate = onUpdate
              ..onEnd = onEnd
              ..onCancel = onCancel
              ..minFlingDistance = 2.0
              // ..minFlingVelocity = kMinFlingVelocity
              // ..maxFlingVelocity = kMaxFlingVelocity
              ..dragStartBehavior = dragStartBehavior;
            // ..velocityTrackerBuilder = (PointerEvent event) => VelocityTracker.withKind(event.kind);
          },
        )
      };
    }
    // if (_gestureDetectorKey.currentState != null) {
    //   _gestureDetectorKey.currentState.replaceGestureRecognizers(gestures);
    // }
  }

  void onDown(DragDownDetails d) {
    hold = widget.offsetPosition.hold(removeHold);
  }

  void onStart(DragStartDetails d) {
    drag = widget.offsetPosition.drag(d, removeDrag);
  }

  void onUpdate(DragUpdateDetails d) {
    drag?.update(d);
  }

  void onEnd(DragEndDetails d) {
    drag?.end(d);
  }

  void removeHold() {
    hold = null;
  }

  void removeDrag() {
    drag = null;
  }

  void onCancel() {
    drag?.cancel();
    hold?.cancel();
    assert(drag == null);
    assert(hold == null);
  }

  void pointer(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final delta = event.scrollDelta;
      widget.offsetPosition.animateTo(
          500 * delta.dy.sign * math.max(1, delta.dy / 10),
          fac: 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: pointer,
      child: RawGestureDetector(
        gestures: gestures,
        // key: _gestureDetectorKey,
        child: ContentViewPortContainer(
          offset: widget.offsetPosition,
          delegate: widget.delegate,
          // itemExtent: 300,
        ),
      ),
    );
  }
}

class _ContentVerticalWidget extends RenderObjectWidget {
  const _ContentVerticalWidget({
    required this.contentLayoutPadding,
    required this.header,
    required this.body,
    required this.footer,
    // required this.rightFooter
  });
  final Widget header;
  final Widget body;
  final Widget footer;

  final EdgeInsets contentLayoutPadding;
  @override
  _SlideElement createElement() {
    return _SlideElement(this);
  }

  @override
  _SlideRenderObject createRenderObject(BuildContext context) {
    return _SlideRenderObject(contentLayoutPadding);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _SlideRenderObject renderObject) {
    renderObject.contentLayoutPadding = contentLayoutPadding;
  }
}

class _SlideElement extends RenderObjectElement {
  _SlideElement(_ContentVerticalWidget widget) : super(widget);

  @override
  _ContentVerticalWidget get widget => super.widget as _ContentVerticalWidget;
  @override
  _SlideRenderObject get renderObject =>
      super.renderObject as _SlideRenderObject;
  Element? _header;
  Element? _body;
  Element? _footer;

  @override
  void mount(Element? parent, newSlot) {
    super.mount(parent, newSlot);
    _rebuild();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_footer != null) {
      visitor(_footer!);
    }
  }

  @override
  void update(covariant _ContentVerticalWidget newWidget) {
    super.update(newWidget);
    _rebuild();
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _rebuild();
  }

  void _rebuild() {
    _header = updateChild(_header, widget.header, 'header');
    _body = updateChild(_body, widget.body, 'body');
    _footer = updateChild(_footer, widget.footer, 'leftFooter');
  }

  @override
  void insertRenderObjectChild(RenderBox child, covariant slot) {
    renderObject.add(child, slot);
  }

  @override
  void removeRenderObjectChild(covariant RenderBox child, covariant slot) {
    renderObject.remove(child, slot);
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child,
      covariant Object? oldSlot, covariant Object? newSlot) {}
}

class _SlideRenderObject extends RenderBox {
  _SlideRenderObject(EdgeInsets epadding) : _contentLayoutPadding = epadding;
  RenderBox? _header;
  RenderBox? _body;
  RenderBox? _footer;

  void add(RenderBox child, slot) {
    if (slot == 'header') {
      if (_header != null) dropChild(_header!);
      adoptChild(child);
      _header = child;
    } else if (slot == 'body') {
      if (_body != null) dropChild(_body!);
      adoptChild(child);
      _body = child;
    } else if (slot == 'leftFooter') {
      if (_footer != null) dropChild(_footer!);
      adoptChild(child);
      _footer = child;
    }
  }

  void remove(RenderBox child, slot) {
    if (slot == 'header') {
      if (_header != null) {
        dropChild(_header!);
        _header = null;
      }
    } else if (slot == 'body') {
      if (_body != null) {
        dropChild(_body!);
        _body = null;
      }
    } else if (slot == 'leftFooter') {
      if (_footer != null) {
        dropChild(_footer!);
        _footer = null;
      }
    }
  }

  EdgeInsets _contentLayoutPadding;
  EdgeInsets get contentLayoutPadding => _contentLayoutPadding;
  set contentLayoutPadding(EdgeInsets v) {
    if (_contentLayoutPadding == v) return;
    _contentLayoutPadding = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    var height = contentFontSize;
    final _constraints = BoxConstraints.tightFor(
        width: size.width - contentLayoutPadding.horizontal, height: height);

    if (_header != null) {
      final _height = contentLayoutPadding.top + contentTopPad;
      _header!.layout(_constraints);
      final parentdata = _header!.parentData as BoxParentData;
      parentdata.offset = Offset(contentLayoutPadding.left, _height);
    }

    final _bottomHeight = size.height - contentBotttomPad;

    if (_footer != null) {
      _footer!.layout(_constraints);
      final parentdata = _footer!.parentData as BoxParentData;
      parentdata.offset =
          Offset(contentLayoutPadding.left, _bottomHeight - height);
    }

    if (_body != null) {
      final _constraints = BoxConstraints.tightFor(
          width: size.width,
          height:
              size.height - contentWhiteHeight - contentLayoutPadding.vertical);
      _body!.layout(_constraints);

      final parentdata = _body!.parentData as BoxParentData;
      parentdata.offset = Offset(.0,
          contentPadding + contentLayoutPadding.top + contentTopPad + height);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_header != null) {
      context.paintChild(_header!, childOffset(_header!) + offset);
    }

    if (_body != null) {
      context.paintChild(_body!, childOffset(_body!) + offset);
    }

    if (_footer != null) {
      context.paintChild(_footer!, childOffset(_footer!) + offset);
    }
  }

  Offset childOffset(RenderObject child) {
    final parendata = child.parentData as BoxParentData;
    return parendata.offset;
  }

  @override
  void redepthChildren() {
    if (_header != null) {
      redepthChild(_header!);
    }
    if (_body != null) {
      redepthChild(_body!);
    }
    if (_footer != null) {
      redepthChild(_footer!);
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _header?.attach(owner);
    _body?.attach(owner);
    _footer?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _header?.detach();
    _body?.detach();
    _footer?.detach();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_body != null) {
      final o = position - childOffset(_body!);
      return _body!.hitTest(result, position: o);
    }
    return true;
  }

  @override
  void visitChildren(visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_footer != null) {
      visitor(_footer!);
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_footer != null) {
      visitor(_footer!);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
