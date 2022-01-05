import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class NopPageViewController extends ChangeNotifier with ScrollActivityDelegate {
  NopPageViewController({
    required this.scrollingNotify,
    required this.vsync, // required this.getDragState,
    required this.getContentDimension,
  })  : _maxExtent = 1,
        _minExtent = 0;

  TickerProvider vsync;

  void Function(bool) scrollingNotify;
  void Function() getContentDimension;

  ScrollActivity? _activity;

  double _pixels = 0.0;
  double get pixels => _pixels;

  void beginActivity(ScrollActivity activity) {
    _activity?.dispose();
    _activity = activity;
    _currentDrag?.dispose();
    _currentDrag = null;
    scrollingnotifier();
  }

  Axis _axis = Axis.vertical;
  Axis get axis => _axis;
  set axis(Axis v) {
    if (v == _axis) return;
    _axis = v;
    if (_activity is! IdleScrollActivity) {
      goIdle();
    }
    notifyListeners();
  }

  double get page {
    return pixels / viewPortDimension!;
  }

  bool get atEdge => pixels == _minExtent || pixels == _maxExtent;

  double? _viewPortDimension;
  double? get viewPortDimension => _viewPortDimension;

  void applyViewPortDimension(double dimension) {
    if (_viewPortDimension != null && _viewPortDimension != dimension) {
      _pixels = page.toInt() * dimension;
    }
    _viewPortDimension = dimension;
    getContentDimension();
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
    if (!isScrolling && viewPortDimension != null) {
      if (_maxExtent > pixels) {
        setPixels(viewPortDimension! * (page + 0.51).round());
        goIdle();
      }
    }
  }

  void prePage() {
    if (!isScrolling && _minExtent < pixels) {
      setPixels(viewPortDimension! * (page - 0.51).round());
      goIdle();
    }
  }

  bool get isScrolling {
    return _activity?.isScrolling ?? false;
  }

  var _lastReportState = false;
  void scrollingnotifier() {
    final localIsScrolling = isScrolling;
    if (_lastReportState != localIsScrolling) {
      _lastReportState = localIsScrolling;
      scrollingNotify(localIsScrolling);
    }
  }

  @override
  void goIdle() {
    beginActivity(IdleScrollActivity(this));
    getContentDimension();
  }

  @override
  double setPixels(double v) {
    if (v == _pixels) return 0.0;
    v = v.clamp(minExtent, maxExtent);
    _pixels = v;
    notifyListeners();
    return 0.0;
  }

  void animateTo(double velocity ) {
    int to;
    if (pixels == minExtent || pixels == maxExtent) notifyListeners();

    if (velocity < -150.0) {
      to = page.round() -1 ;
    } else if (velocity > 150.0) {
      to = page.round() + 1;
    } else {
      to = page.round();
    }

    final end = (to * viewPortDimension!).clamp(minExtent, maxExtent);

    beginActivity(BallisticScrollActivity(
        this, getSpringSimulation(velocity, end), vsync));
  }

  @override
  void goBallistic(double velocity) {
    if (velocity == 0) {
      goIdle();
      return;
    }
    if (axis == Axis.horizontal) {
      animateTo(velocity );
    } else {
      beginActivity(
          BallisticScrollActivity(this, getSimulation(velocity), vsync));
    }
  }

  void correct(double v) {
    if (_pixels == v) return;
    _pixels = v.clamp(minExtent, maxExtent);
  }

  double _minExtent;
  double _maxExtent;

  double get minExtent => _minExtent;
  double get maxExtent => _maxExtent;

  void applyContentDimension({double? minExtent, double? maxExtent}) {
    if (minExtent != null) {
      _minExtent = minExtent;
    }
    if (maxExtent != null) {
      _maxExtent = maxExtent;
    }
    assert(_minExtent <= _maxExtent);
  }

  @override
  void applyUserOffset(double delta) {
    if (delta == 0.0) return;

    setPixels(pixels - delta);
  }

  ScrollDragController? _currentDrag;

  ScrollDragController? drag(
      DragStartDetails details, VoidCallback cancelCallback) {
    final _drag = ScrollDragController(
        delegate: this, details: details, onDragCanceled: cancelCallback);
    beginActivity(DragScrollActivity(this, _drag));
    _currentDrag = _drag;
    if (atEdge) getContentDimension();

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
  AxisDirection get axisDirection =>
      axis == Axis.vertical ? AxisDirection.down : AxisDirection.right;
}
