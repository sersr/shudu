import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:useful_tools/useful_tools.dart';

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
        topOffset.selector((parent) => (max - parent.value).clamp(0.0, range));
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
      child: headChild,
      body: widget.body,
      initMax: widget.initMax,
      initOffset: topOffset.value,
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
  ScrollDirection? direction;
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
      _scrollController = _ScrollController(position);
    } else if (widget.controller != oldWidget.controller) {
      _scrollController.updateParent(widget.controller);
    }
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
      child: RepaintBoundary(
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

class ClampedPosition extends ChangeNotifier
    implements ValueListenable<double>, ScrollActivityDelegate {
  final double min;
  final double max;

  ClampedPosition({
    required this.min,
    required this.max,
    required this.vsync,
    required this.syncPixels,
    bool initMax = true,
  }) : _pixels = initMax ? max : min;

  bool get extentInside => pixels > min && pixels < max;
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
        _pixels = min;
        delta -= 1;
      } else if (extentAfter <= 1) {
        _pixels = max;
        delta -= 1;
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
    double to = pixels;

    if (velocity < 0) {
      to = max;
    } else if (velocity > 0) {
      to = min;
    } else {
      if (_lastDelta > 0) {
        to = max;
      } else {
        to = min;
      }
    }

    if (pixels == min || pixels == max) {
      goIdle();
    } else {
      velocity = -velocity;
      beginActivity(BallisticScrollActivity(
          this, getSpringSimulation(velocity, to), vsync));
    }
  }

  double _lastDelta = 1;
  @override
  void applyUserOffset(double delta) {
    if (delta == 0.0) return;
    _lastDelta = delta;

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
    if (delta < 0) {
      if (outerPosition.extentBefore > 0.0) {
        delta = applyOuterPositionOffset(delta);
      }
    } else {
      if (extentBefore == 0.0) {
        delta = applyOuterPositionOffset(delta);
      }
    }
    super.applyUserOffset(delta);
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
