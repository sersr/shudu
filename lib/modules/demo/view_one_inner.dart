import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nop/utils.dart';
import 'package:flutter_nop/change_notifier.dart';

import '../../widgets/app_bar.dart';

typedef ScrollBuilder = Widget Function(
    BuildContext context, ScrollPhysics? physics);

class ViewOne extends StatefulWidget {
  const ViewOne({
    Key? key,
    this.minHeight = 88,
    this.child,
    this.backgroundChild,
    this.appColor,
    this.leading,
    required this.title,
    this.bodyColor,
    required this.body,
    this.initMax = true,
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.scrollController,
  }) : super(key: key);

  final double minHeight;
  final Widget? child;
  final Widget? backgroundChild;
  final Color? appColor;
  final Widget title;
  final Widget? leading;
  final BorderRadius? radius;
  final Color? bodyColor;
  final Widget body;
  final bool initMax;
  final ScrollController? scrollController;
  @override
  _ViewOneState createState() => _ViewOneState();
}

class _ViewOneState extends State<ViewOne> {
  final topOffset = ValueNotifier(0.0);
  late ValueListenable<double> appHideValue;
  late double min;
  late double max;
  late double range;

  bool _initFirst = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    update();
  }

  @override
  void didUpdateWidget(covariant ViewOne oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initMax != oldWidget.initMax ||
        widget.minHeight != oldWidget.minHeight) {
      _initFirst = false;
      update();
    }
  }

  void update() {
    double extent;
    final data = MediaQuery.of(context);
    if (data.orientation == Orientation.portrait) {
      extent = data.size.height;
    } else {
      extent = data.size.width;
    }
    double? oldMin, oldMax;
    if (_initFirst) {
      oldMin = min;
      oldMax = max;
    } else {
      _initFirst = true;
    }

    min = kToolbarHeight + data.padding.top;
    min = math.min(min, extent);
    max = (extent - widget.minHeight - data.padding.bottom).clamp(min, extent);
    range = max - min;

    if (min != oldMin || max != oldMax) {
      topOffset.value = widget.initMax ? max : min;
    }

    appHideValue =
        topOffset.select((parent) => (max - parent.value).clamp(0.0, range));
  }

  void onChanged(offset) => topOffset.value = offset;

  @override
  Widget build(BuildContext context) {
    Widget? background = widget.backgroundChild;

    assert(() {
      final theme = Theme.of(context);
      final dark = theme.brightness == Brightness.dark;

      background ??= ColoredBox(
        color: dark
            ? Color.fromARGB(255, 66, 66, 66)
            : Color.fromARGB(255, 180, 180, 180),
        child: Center(child: Text('background')),
      );
      return true;
    }());

    if (background != null) {
      background = Positioned.fill(child: RepaintBoundary(child: background!));
    }

    Widget? headChild;
    if (widget.child != null) {
      headChild = Container(
        constraints: BoxConstraints(maxHeight: widget.minHeight),
        child: widget.child,
      );
    }

    Widget appBar = AppBarHide(
      begincolor: widget.appColor,
      title: widget.title,
      max: range,
      values: appHideValue,
    );

    final body = ShrinkWidget(
      min: min,
      max: max,
      onChanged: onChanged,
      body: widget.body,
      initMax: widget.initMax,
      initOffset: topOffset.value,
      controller: widget.scrollController,
      child: headChild,
    );
    return SafeArea(
      top: false,
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null) background!,
            body,
            Positioned(top: 0, left: 0, right: 0, child: appBar),
          ],
        ),
      ),
    );
  }
}

class ShrinkWidget extends StatefulWidget {
  const ShrinkWidget({
    Key? key,
    required this.min,
    required this.max,
    required this.body,
    this.backgroundColor,
    required this.onChanged,
    this.initMax = true,
    this.initOffset,
    this.radius = const BorderRadius.vertical(top: Radius.circular(20)),
    this.useBodyBackground = true,
    this.clipBehavior = Clip.hardEdge,
    this.controller,
    this.child,
  }) : super(key: key);
  final double min;
  final double max;

  final Widget? child;
  final Color? backgroundColor;
  final BorderRadius? radius;
  final Widget body;
  final bool useBodyBackground;
  final Clip clipBehavior;
  final ScrollController? controller;
  final void Function(double offset) onChanged;
  final bool initMax;
  final double? initOffset;
  @override
  _ShrinkWidgetState createState() => _ShrinkWidgetState();
}

class _ShrinkWidgetState extends State<ShrinkWidget>
    with TickerProviderStateMixin {
  late ClampedPosition position;
  late _ScrollController _scrollController;

  Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};

  @override
  void initState() {
    super.initState();
    position = ClampedPosition(
      min: widget.min,
      max: widget.max,
      vsync: this,
      syncPixels: setPixels,
      initMax: widget.initMax,
    );
    if (widget.initOffset != null) {
      position.resetPixels(widget.initOffset!);
    }

    _scrollController = _ScrollController(position, widget.controller);
    updateController();

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
            // ..minFlingDistance = 2.0
            ..dragStartBehavior = DragStartBehavior.start;
        },
      )
    };
  }

  void updateController() {
    final controller = widget.controller;
    if (controller is ClampedScrollController) {
      controller._position = position;
    }
  }

  void removeController() {
    final controller = widget.controller;
    if (controller is ClampedScrollController) {
      controller._position = null;
    }
  }

  @override
  void didUpdateWidget(covariant ShrinkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      position.dispose();
      final oldOffset = position.pixels;
      position = ClampedPosition(
        min: widget.min,
        max: widget.max,
        vsync: this,
        syncPixels: setPixels,
        initMax: widget.initMax,
      );
      position.resetPixels(oldOffset);
      _scrollController = _ScrollController(position, widget.controller);
    } else if (widget.controller != oldWidget.controller) {
      _scrollController.updateParent(widget.controller);
    }
    updateController();
    if (widget.initOffset != null &&
        widget.initOffset != oldWidget.initOffset) {
      position.resetPixels(widget.initOffset!);
    }
  }

  void setPixels(double pixels) {
    widget.onChanged(pixels);
  }

  @override
  void dispose() {
    position.dispose();
    removeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.body;
    if (widget.child != null) {
      body = Column(
        children: [widget.child!, Flexible(child: body)],
      );
    }
    if (widget.useBodyBackground) {
      body = Material(
        color: widget.backgroundColor,
        borderRadius: widget.radius,
        clipBehavior: widget.clipBehavior,
        child: body,
      );
    }

    var child = PrimaryScrollController(
      controller: _scrollController,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: position,
            builder: (context, double offset, child) {
              return Positioned(
                top: offset,
                right: 0,
                left: 0,
                bottom: 0,
                child: child!,
              );
            },
            child: RawGestureDetector(
              gestures: gestures,
              child: RepaintBoundary(child: body),
            ),
          ),
        ],
      ),
    );

    return child;
  }

  Drag? drag;
  ScrollHoldController? hold;
  void onDown(DragDownDetails d) {
    hold = position.hold(removeHold);
  }

  void onStart(DragStartDetails d) {
    drag = position.drag(d, removeDrag);
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
}

class ClampedScrollController extends ScrollController {
  ClampedPosition? _position;
  void expand() {
    if (_position != null) {
      final vel = _position!.max - _position!.min;
      _position?._go(vel);
    }
  }

  void shrink() {
    if (_position != null) {
      final vel = _position!.max - _position!.min;
      _position?._go(-vel);
    }
  }

  bool get isExpanded => _position?.extentBefore == 0;

  void auto() {
    if (_position != null) {
      if (_position!.extentBefore > 0) {
        expand();
      } else {
        shrink();
      }
    }
  }
}

/// viewport
/// ----------------------- top
///   space
///  --------------- => min
///   inner space
///
///  --------------- => max
///   space
/// ----------------------- bottom
class ClampedPosition extends ChangeNotifierBase
    implements ValueListenable<double>, ScrollActivityDelegate {
  final double min;
  final double max;

  ClampedPosition({
    required this.min,
    required this.max,
    required this.vsync,
    required this.syncPixels,
    bool initMax = true,
  }) : _pixels = initMax ? max : min {
    animatingUp = pixels == max;
  }

  bool get isExtentInside => pixels > min && pixels < max;
  double get extentBefore => pixels - min;
  double get extentAfter => max - pixels;

  TickerProvider vsync;

  ScrollActivity? _activity;
  void Function(double pixels) syncPixels;
  double _pixels = 0.0;

  @override
  double get value => _pixels;
  double get pixels => _pixels;

  void beginActivity(ScrollActivity activity) {
    _activity?.dispose();
    _activity = activity;
    _currentDrag?.dispose();
    _currentDrag = null;
  }

  static final SpringDescription kDefaultSpring =
      SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100.0,
    ratio: 1.1,
  );

  Simulation getSpringSimulation(double velocity, double end) {
    return ScrollSpringSimulation(kDefaultSpring, pixels, end, velocity);
  }

  bool get isScrolling {
    return _activity?.isScrolling ?? false;
  }

  @override
  void goIdle() {
    beginActivity(IdleScrollActivity(this));
  }

  void resetPixels(double newPixels) {
    _pixels = newPixels.clamp(min, max);
  }

  @override
  double setPixels(double newPixels) {
    if (pixels == newPixels) {
      return 0.0;
    }
    final pixelsClamp = newPixels.clamp(min, max);
    _pixels = pixelsClamp;
    double delta = newPixels - pixelsClamp;
    if (_activity is BallisticScrollActivity) {
      if (extentBefore <= 1) {
        delta -= min - _pixels;
        _pixels = min;
      } else if (extentAfter <= 1) {
        delta -= max - _pixels;
        _pixels = max;
      }
    }
    syncPixels(_pixels);
    notifyListeners();
    return delta;
  }

  bool get _onScrollDrag => _onScrollDragCount > 0;
  int _onScrollDragCount = 0;

  /// 如果有多个命中,以Scroll为主
  @override
  void goBallistic(double velocity, {bool scroll = false}) {
    if (_onScrollDrag && velocity == 0 && !scroll) {
      goIdle();
      return;
    }
    final to = getTo(velocity);

    if (pixels == min || pixels == max) {
      goIdle();
    } else {
      animationStart(velocity, to);
    }
  }

  double getTo(double velocity) {
    double to = pixels;

    if (velocity < 0) {
      to = max;
    } else if (velocity > 0) {
      to = min;
    } else {
      if (!animatingUp) {
        to = max;
      } else {
        to = min;
      }
    }
    return to;
  }

  void _go(double velocity) {
    final to = getTo(velocity);
    animationStart(velocity, to);
  }

  void animationStart(double velocity, double to) {
    // doing
    animatingUp = to == min;
    velocity = -velocity;
    beginActivity(BallisticScrollActivity(
      this,
      getSpringSimulation(velocity, to),
      vsync,
      _activity?.shouldIgnorePointer ?? true,
    ));
  }

  // 只有不在边界时可用,可能的出现打断动画的情况
  // 保存上一次动画的方向
  bool animatingUp = false;

  @override
  void applyUserOffset(double delta) {
    if (delta == 0.0) return;
    setPixels(pixels + delta);
  }

  ScrollDragController? _currentDrag;

  ScrollDragController drag(
      DragStartDetails details, VoidCallback cancelCallback) {
    final _drag = ScrollDragController(
        delegate: this, details: details, onDragCanceled: cancelCallback);
    beginActivity(DragScrollActivity(this, _drag));
    _currentDrag = _drag;

    return _drag;
  }

  ScrollHoldController hold(VoidCallback cancel) {
    final _hold = HoldScrollActivity(delegate: this, onHoldCanceled: cancel);
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

  @override
  AxisDirection get axisDirection => AxisDirection.down;
}

class _ScrollController extends ScrollController {
  _ScrollController(this.metries, [this._parent]);
  final ClampedPosition metries;
  ScrollController? _parent;
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return ShrinkScrollPosition(
        physics: physics,
        context: context,
        outerPosition: metries,
        oldPosition: oldPosition);
  }

  void updateParent(ScrollController? parent) {
    if (_parent != null && hasClients) {
      positions.forEach(_parent!.detach);
    }
    _parent = parent;
    if (_parent != null && hasClients) {
      positions.forEach(_parent!.attach);
    }
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    if (_parent != null) {
      _parent!.attach(position);
    }
  }

  @override
  void detach(ScrollPosition position) {
    super.detach(position);
    if (_parent != null) {
      _parent!.detach(position);
    }
  }
}

class ShrinkScrollPosition extends ScrollPositionWithSingleContext {
  ShrinkScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    required this.outerPosition,
    ScrollPosition? oldPosition,
  }) : super(physics: physics, context: context, oldPosition: oldPosition);

  final ClampedPosition outerPosition;

  @override
  void applyUserOffset(double delta) {
    // 如果内部存在空白区域(inner space)或者内部[ScrollView]滚动位置处于起点位置
    // 先处理outerPosition
    if (outerPosition.extentBefore > 0.0 || extentBefore == 0.0) {
      delta = applyOuterPositionOffset(delta);
      super.applyUserOffset(delta);
    } else {
      _userDrag = true;
      final oldPixels = pixels;
      super.applyUserOffset(delta);
      if (extentBefore == 0.0) {
        final useDelta = oldPixels - pixels;
        final extra = delta - useDelta;
        outerPosition.applyUserOffset(extra);
      }
      _userDrag = false;
    }
  }

  /// 如果是拖动状态,不显示超出滚动范围指示器
  bool _userDrag = false;
  @override
  void didOverscrollBy(double value) {
    if (_userDrag) return;
    super.didOverscrollBy(value);
  }

  double applyOuterPositionOffset(double delta) {
    final oldPixels = outerPosition.pixels;
    outerPosition.applyUserOffset(delta);
    final newDelta = outerPosition.pixels - oldPixels;
    return delta - newDelta;
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    _heldPreviousVelocity = 0.0;
    if (newActivity == null) return;
    assert(newActivity.delegate == this);
    super.beginActivity(newActivity);
    _currentDrag?.dispose();
    _currentDrag = null;
  }

  ScrollDragController? _currentDrag;
  late final delegate = DragDelegate(this, outerPosition);
  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final ScrollDragController drag = ScrollDragController(
      delegate: delegate,
      details: details,
      onDragCanceled: () {
        dragCancelCallback();
        outerPosition._onScrollDragCount--;
      },
      carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
      motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
    );
    beginActivity(DragScrollActivity(this, drag));
    assert(_currentDrag == null);
    _currentDrag = drag;
    outerPosition.goIdle();
    outerPosition._onScrollDragCount++;
    return drag;
  }

  double _heldPreviousVelocity = 0.0;
  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    final double previousVelocity = activity!.velocity;
    final HoldScrollActivity holdActivity = HoldScrollActivity(
      delegate: this,
      onHoldCanceled: holdCancelCallback,
    );
    beginActivity(holdActivity);
    _heldPreviousVelocity = previousVelocity;
    return super.hold(holdCancelCallback);
  }

  @override
  void dispose() {
    _currentDrag?.dispose();
    _currentDrag = null;
    super.dispose();
  }
}

class DragDelegate implements ScrollActivityDelegate {
  DragDelegate(this.delegate, this.metries);
  final ScrollActivityDelegate delegate;
  final ClampedPosition metries;
  @override
  void applyUserOffset(double delta) {
    delegate.applyUserOffset(delta);
  }

  @override
  AxisDirection get axisDirection => delegate.axisDirection;

  @override
  void goBallistic(double velocity) {
    assert(Log.w('go | $velocity'));
    metries.goBallistic(velocity, scroll: true);

    if (metries.extentBefore <= 0.0) {
      delegate.goBallistic(velocity);
    } else {
      goIdle();
    }
  }

  @override
  void goIdle() {
    delegate.goIdle();
  }

  @override
  double setPixels(double pixels) {
    return delegate.setPixels(pixels);
  }
}
