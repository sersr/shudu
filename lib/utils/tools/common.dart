import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> uiOverlay({bool hide = true}) async {
  return SystemChrome.setEnabledSystemUIOverlays(hide ? const [] : SystemUiOverlay.values);
}

void uiStyle({bool dark = true}) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: Colors.white,
  ));
}

Future<void> orientation(bool portrait) async {
  if (portrait) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

class ZoomTransition extends PageTransitionsBuilder {
  const ZoomTransition();

  static const curve = Cubic(0.44, 0.12, 0.47, 0.73);
  static const curve2 = Cubic(0.24, 0.1, 0.47, 0.73);

  static final firstScale = Tween<double>(begin: 0.875, end: 1.0);

  static final secondaryScale = Tween<double>(begin: 1.0, end: 1.0725);
  static final secondaryScaleReverse = Tween<double>(begin: 1.0, end: 1.0525);

  // reverse
  static final firstCurveReverse = CurveTween(curve: const Interval(0.867, 1.0, curve: curve));
  static final secondaryCurveReverse = CurveTween(curve: const Interval(0.625, 1.0, curve: curve2));
  static final intervalCurve = CurveTween(curve: const Interval(0.0, 0.525, curve: curve));

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final reverseOutter = animation.status == AnimationStatus.reverse;
    final reverseInner = secondaryAnimation.status == AnimationStatus.reverse;

    final opacity = reverseOutter ? kAlwaysDismissedAnimation : intervalCurve.animate(animation);

    final scaleFirst = reverseOutter ? kAlwaysDismissedAnimation : intervalCurve.animate(animation).drive(firstScale);

    final scaleSecondary = reverseInner
        ? secondaryCurveReverse.animate(secondaryAnimation).drive(secondaryScale)
        : intervalCurve.animate(secondaryAnimation).drive(secondaryScale);

    return RepaintBoundary(
      child: FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: scaleFirst,
          child: ScaleTransition(
            scale: scaleSecondary,
            child: child,
          ),
        ),
      ),
    );
  }
}

const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate forward
// if the user releases a page mid swipe.
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

// Offset from fully on screen to 1/3 offscreen to the left.
final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(-1.0 / 3.0, 0.0),
);

// Offset from offscreen below to fully on screen.
final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

class SlidePageTransition extends PageTransitionsBuilder {
  const SlidePageTransition();

  static const curve = Cubic(0.44, 0.12, 0.47, 0.73);
  static const curve2 = Cubic(0.24, 0.1, 0.47, 0.73);

  static final firstPosition = Tween<Offset>(begin: Offset(1, 0.0), end: Offset.zero);
  static final firstOpacity = Tween<double>(begin: 0.75, end: 1.0);
  static final secondaryPosition = Tween<Offset>(begin: Offset.zero, end: Offset(-0.165, 0.0));

  static final intervalCurve = CurveTween(curve: Curves.fastOutSlowIn);
  static final intervalCurveReverse = CurveTween(curve: Curves.ease);
  static final tweenSequence = TweenSequence<double>(<TweenSequenceItem<double>>[
    TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.5), weight: 0.4),
    TweenSequenceItem(tween: Tween<double>(begin: 0.222, end: 1.0), weight: 0.6)
  ]);

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final reverseOutter = animation.status == AnimationStatus.reverse;
    final reverseInner = secondaryAnimation.status == AnimationStatus.reverse;
    final linearTransition = CupertinoRouteTransitionMixin.isPopGestureInProgress(route);
    if (route.fullscreenDialog) {
      return RepaintBoundary(
        child: CupertinoFullscreenDialogTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: linearTransition,
          reverse: reverseOutter,
          reverseSecondary: reverseInner,
          child: child,
        ),
      );
    } else {
      return RepaintBoundary(
        child: CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: linearTransition,
          reverse: reverseOutter,
          reverseSecondary: reverseInner,
          child: _CupertinoBackGestureDetector<T>(
            enabledCallback: () => _isPopGestureEnabled<T>(route),
            onStartPopGesture: () => _startPopGesture<T>(route),
            child: child,
          ),
        ),
      );
    }
    // final scaleFirst = reverseOutter
    //     ? intervalCurveReverse.animate(animation).drive(firstPosition)
    //     : intervalCurve.animate(animation).drive(firstPosition);

    // final scaleSecondary = reverseInner
    //     ? intervalCurveReverse.animate(secondaryAnimation).drive(secondaryPosition)
    //     : intervalCurve.animate(secondaryAnimation).drive(secondaryPosition);

    // final _primaryPositionAnimation = reverseOutter
    //     ? _easeTolinear.animate(animation).drive(_kRightMiddleTween)
    //     : _linearTofast.animate(animation).drive(_kRightMiddleTween);
    // final _secondaryPositionAnimation = reverseInner
    //     ? _easeTolinear.animate(secondaryAnimation).drive(_kMiddleLeftTween)
    //     : _linearTofast.animate(secondaryAnimation).drive(_kMiddleLeftTween);

    // final linearTransition = CupertinoRouteTransitionMixin.isPopGestureInProgress(route);
    // if (route.fullscreenDialog) {
    //   final _positionAnimation = reverseOutter
    //       ? _linearTofastflipped.animate(animation).drive(_kBottomUpTween)
    //       : _linearTofast.animate(animation).drive(_kBottomUpTween);
    //   final _secondaryPositionAnimation = reverseInner
    //       ? _linearTofast.animate(secondaryAnimation).drive(_kMiddleLeftTween)
    //       : _easeTolinear.animate(secondaryAnimation).drive(_kMiddleLeftTween);

    //   return SlideTransition(
    //     position: _secondaryPositionAnimation,
    //     transformHitTests: false,
    //     child: SlideTransition(
    //       position: _positionAnimation,
    //       child: child,
    //     ),
    //   );
    // } else {
    //   return SlideTransition(
    //     position: _secondaryPositionAnimation,
    //     child: SlideTransition(
    //       position: _primaryPositionAnimation,
    //       child: child,
    //     ),
    //   );
    // }

    //  final _primaryShadowAnimation =

    // final isLineTransition = CupertinoRouteTransitionMixin.isPopGestureInProgress(route);
    // return CupertinoPageTransition(
    //   primaryRouteAnimation: animation,
    //   secondaryRouteAnimation: secondaryAnimation,
    //   linearTransition: false,
    //   child: child,
    // );
    // return RepaintBoundary(
    //   child: SlideTransition(
    //     position: scaleFirst,
    //     child: Container(
    //       // color: Colors.white,
    //       child: SlideTransition(
    //         position: scaleSecondary,
    //         child: child,
    //       ),
    //     ),
    //   ),
    // );
  }

  static bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    if (route.isFirst) return false;

    if (route.willHandlePopInternally) return false;

    // ignore: invalid_use_of_protected_member
    if (route.hasScopedWillPopCallback) return false;
    if (route.fullscreenDialog) return false;
    if (route.animation!.status != AnimationStatus.completed) return false;
    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) return false;
    if (isPopGestureInProgress(route)) return false;

    return true;
  }

  static bool isPopGestureInProgress(PageRoute<dynamic> route) {
    return route.navigator!.userGestureInProgress;
  }

  static _CupertinoBackGestureController<T> _startPopGesture<T>(PageRoute<T> route) {
    assert(_isPopGestureEnabled(route));

    return _CupertinoBackGestureController<T>(
      navigator: route.navigator!,
      // ignore: invalid_use_of_protected_member
      controller: route.controller!, // protected access
    );
  }
}

class _CupertinoBackGestureController<T> {
  /// Creates a controller for an iOS-style back gesture.
  ///
  /// The [navigator] and [controller] arguments must not be null.
  _CupertinoBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [fractionalDelta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of
  /// [fractionalVelocity] as a fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity)
      animateForward = velocity <= 0;
    else
      animateForward = controller.value > 0.5;

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final droppedPageForwardAnimationTime = min(
        lerpDouble(_kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value)!.floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime), curve: animationCurve);
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final droppedPageBackAnimationTime =
            lerpDouble(0, _kMaxDroppedSwipePageForwardAnimationTime, controller.value)!.floor();
        controller.animateBack(0.0,
            duration: Duration(milliseconds: droppedPageBackAnimationTime), curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class _CupertinoBackGestureDetector<T> extends StatefulWidget {
  const _CupertinoBackGestureDetector({
    Key? key,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<_CupertinoBackGestureController<T>> onStartPopGesture;

  @override
  _CupertinoBackGestureDetectorState<T> createState() => _CupertinoBackGestureDetectorState<T>();
}

class _CupertinoBackGestureDetectorState<T> extends State<_CupertinoBackGestureDetector<T>> {
  _CupertinoBackGestureController<T>? _backGestureController;

  late HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragUpdate(_convertToLogical(details.primaryDelta! / context.size!.width));
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragEnd(_convertToLogical(details.velocity.pixelsPerSecond.dx / context.size!.width));
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down" event
    // that we don't consider here.
    _backGestureController?.dragEnd(0.0);
    _backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) _recognizer.addPointer(event);
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.
    var dragAreaWidth = Directionality.of(context) == TextDirection.ltr
        ? MediaQuery.of(context).padding.left
        : MediaQuery.of(context).padding.right;
    dragAreaWidth = max(dragAreaWidth, _kBackGestureWidth);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0.0,
          width: dragAreaWidth,
          top: 0.0,
          bottom: 0.0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

class _CupertinoEdgeShadowPainter extends BoxPainter {
  _CupertinoEdgeShadowPainter(
    this._decoration,
    VoidCallback? onChange,
  ) : super(onChange);

  final _CupertinoEdgeShadowDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final gradient = _decoration.edgeGradient;
    if (gradient == null) return;
    // The drawable space for the gradient is a rect with the same size as
    // its parent box one box width on the start side of the box.
    final textDirection = configuration.textDirection;
    assert(textDirection != null);
    final double deltaX;
    switch (textDirection!) {
      case TextDirection.rtl:
        deltaX = configuration.size!.width;
        break;
      case TextDirection.ltr:
        deltaX = -configuration.size!.width;
        break;
    }
    final rect = (offset & configuration.size!).translate(deltaX, 0.0);
    final paint = Paint()..shader = gradient.createShader(rect, textDirection: textDirection);

    canvas.drawRect(rect, paint);
  }
}

class _CupertinoEdgeShadowDecoration extends Decoration {
  const _CupertinoEdgeShadowDecoration({this.edgeGradient});

  // An edge shadow decoration where the shadow is null. This is used
  // for interpolating from no shadow.
  static const _CupertinoEdgeShadowDecoration none = _CupertinoEdgeShadowDecoration();

  // A gradient to draw to the left of the box being decorated.
  // Alignments are relative to the original box translated one box
  // width to the left.
  final LinearGradient? edgeGradient;

  // Linearly interpolate between two edge shadow decorations decorations.
  //
  // The `t` argument represents position on the timeline, with 0.0 meaning
  // that the interpolation has not started, returning `a` (or something
  // equivalent to `a`), 1.0 meaning that the interpolation has finished,
  // returning `b` (or something equivalent to `b`), and values in between
  // meaning that the interpolation is at the relevant point on the timeline
  // between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  // 1.0, so negative values and values greater than 1.0 are valid (and can
  // easily be generated by curves such as [Curves.elasticInOut]).
  //
  // Values for `t` are usually obtained from an [Animation<double>], such as
  // an [AnimationController].
  //
  // See also:
  //
  //  * [Decoration.lerp].
  static _CupertinoEdgeShadowDecoration? lerp(
    _CupertinoEdgeShadowDecoration? a,
    _CupertinoEdgeShadowDecoration? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    return _CupertinoEdgeShadowDecoration(
      edgeGradient: LinearGradient.lerp(a?.edgeGradient, b?.edgeGradient, t),
    );
  }

  @override
  _CupertinoEdgeShadowDecoration lerpFrom(Decoration? a, double t) {
    if (a is _CupertinoEdgeShadowDecoration) return _CupertinoEdgeShadowDecoration.lerp(a, this, t)!;
    return _CupertinoEdgeShadowDecoration.lerp(null, this, t)!;
  }

  @override
  _CupertinoEdgeShadowDecoration lerpTo(Decoration? b, double t) {
    if (b is _CupertinoEdgeShadowDecoration) return _CupertinoEdgeShadowDecoration.lerp(this, b, t)!;
    return _CupertinoEdgeShadowDecoration.lerp(this, null, t)!;
  }

  @override
  _CupertinoEdgeShadowPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CupertinoEdgeShadowPainter(this, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _CupertinoEdgeShadowDecoration && other.edgeGradient == edgeGradient;
  }

  @override
  int get hashCode => edgeGradient.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<LinearGradient>('edgeGradient', edgeGradient));
  }
}

final DecorationTween _kGradientShadowTween = DecorationTween(
  begin: _CupertinoEdgeShadowDecoration.none, // No decoration initially.
  end: const _CupertinoEdgeShadowDecoration(
    edgeGradient: LinearGradient(
      // Spans 5% of the page.
      begin: AlignmentDirectional(0.90, 0.0),
      end: AlignmentDirectional.centerEnd,
      // Eyeballed gradient used to mimic a drop shadow on the start side only.
      colors: <Color>[
        Color(0x00000000),
        Color(0x04000000),
        Color(0x12000000),
        Color(0x38000000),
      ],
      stops: <double>[0.0, 0.3, 0.6, 1.0],
    ),
  ),
);

class CupertinoPageTransition extends StatelessWidget {
  /// Creates an iOS-style page transition.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform the transitions linearly.
  ///    Used to precisely track back gesture drags.
  CupertinoPageTransition({
    Key? key,
    required Animation<double> primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required this.child,
    required bool linearTransition,
    bool reverse = false,
    bool reverseSecondary = false,
  })  : _primaryPositionAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurveTween(
                    curve: !reverse ? Curves.linearToEaseOut : Curves.easeInToLinear,
                  ).animate(primaryRouteAnimation))
            .drive(_kRightMiddleTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurveTween(
                    curve: !reverseSecondary ? Curves.linearToEaseOut : Curves.easeInToLinear,
                  ).animate(secondaryRouteAnimation))
            .drive(_kMiddleLeftTween),
        _primaryShadowAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurveTween(
                    curve: Curves.linearToEaseOut,
                  ).animate(primaryRouteAnimation))
            .drive(_kGradientShadowTween),
        super(key: key);

  // When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;
  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;
  final Animation<Decoration> _primaryShadowAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: DecoratedBoxTransition(
          decoration: _primaryShadowAnimation,
          child: child,
        ),
      ),
    );
  }
}

/// An iOS-style transition used for summoning fullscreen dialogs.
///
/// For example, used when creating a new calendar event by bringing in the next
/// screen from the bottom.
class CupertinoFullscreenDialogTransition extends StatelessWidget {
  /// Creates an iOS-style transition used for summoning fullscreen dialogs.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform the secondary transition linearly.
  ///    Used to precisely track back gesture drags.
  CupertinoFullscreenDialogTransition({
    Key? key,
    required Animation<double> primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required this.child,
    required bool linearTransition,
    bool reverse = false,
    bool reverseSecondary = false,
  })  : _positionAnimation = CurveTween(curve: !reverse ? Curves.linearToEaseOut : Curves.linearToEaseOut.flipped)
            .animate(primaryRouteAnimation)
            .drive(_kBottomUpTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurveTween(curve: !reverseSecondary ? Curves.linearToEaseOut : Curves.easeInToLinear)
                    .animate(secondaryRouteAnimation))
            .drive(_kMiddleLeftTween),
        super(key: key);

  final Animation<Offset> _positionAnimation;
  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _positionAnimation,
        child: child,
      ),
    );
  }
}
