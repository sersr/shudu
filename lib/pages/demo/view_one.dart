import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../widgets/app_bar.dart';
import 'dart:math' as math;

class ViewOne extends StatefulWidget {
  const ViewOne({Key? key}) : super(key: key);

  @override
  _ViewOneState createState() => _ViewOneState();
}

class _ViewOneState extends State<ViewOne> {
  late final topOffset = ValueNotifier(50.0);
  late ValueListenable<double> appHideValue;
  @override
  void initState() {
    super.initState();
  }

  late double min;
  late double max;
  late double extent;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = MediaQuery.of(context);
    if (data.orientation == Orientation.portrait) {
      extent = data.size.height;
    } else {
      extent = data.size.width;
    }

    extent = (extent - 180 + data.padding.bottom).clamp(0.0, extent);
    min = kToolbarHeight + (MediaQuery.maybeOf(context)?.padding.top ?? 0.0);

    max = min + extent;
    topOffset.value = max;
    appHideValue = topOffset
        .selector((parent) => (extent - parent.value + min).clamp(0.0, max));
  }

  @override
  Widget build(BuildContext context) {
    const background = ColoredBox(
      color: Colors.grey,
      child: Center(child: Text('background')),
    );

    Widget appBar = AppBarHide(
      begincolor: Color.fromARGB(255, 50, 151, 235),
      title: Text('title'),
      max: max,
      values: appHideValue,
    );

    final body = _BodyView(min: min, max: max, topOffset: topOffset);

    return Material(
      child: Stack(
        children: [
          background,
          body,
          Positioned(top: 0, left: 0, right: 0, child: appBar),
        ],
      ),
    );
  }
}

class _BodyView extends StatefulWidget {
  const _BodyView(
      {Key? key, required this.min, required this.max, required this.topOffset})
      : super(key: key);
  final double min;
  final double max;
  final ValueNotifier<double> topOffset;
  @override
  __BodyViewState createState() => __BodyViewState();
}

class __BodyViewState extends State<_BodyView> with TickerProviderStateMixin {
  final controller = ScrollController();

  set value(double v) {
    widget.topOffset.value = v.clamp(widget.min, widget.max);
  }

  double get value => widget.topOffset.value;
  AnimationController? animationController;
  @override
  void initState() {
    super.initState();
    value = widget.max;
    animationController = AnimationController(
        lowerBound: widget.min,
        upperBound: widget.max,
        vsync: this,
        duration: const Duration(milliseconds: 300));
    animationController!.addListener(i);
    animated();
  }

  void i() {
    value = animationController!.value;
  }

  void animated() {
    if (value > widget.min && value < widget.max) {
      final extentAfter = widget.max - value;
      final extent = widget.max - widget.min;

      animationController?.value = value;
      if (extentAfter < extent / 3) {
        final c = (widget.max - value).toInt() << 1;

        animationController?.animateTo(widget.max,
            duration: Duration(milliseconds: c.clamp(300, 600)));
      } else {
        final c = (value - widget.min).toInt() << 1;
        animationController?.animateTo(widget.min,
            duration: Duration(milliseconds: c.clamp(300, 600)));
      }
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  static final SpringDescription kDefaultSpring =
      SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100.0,
    ratio: 1.1,
  );
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: NotificationListener(
        onNotification: (n) {
          if (n is OverscrollIndicatorNotification) {
            if (n.leading) n.disallowIndicator();
          }
          if (n is OverscrollNotification) {
            if (n.metrics.pixels == n.metrics.minScrollExtent) {
              final delta = n.overscroll;
              value = value - delta;
            }
          } else if (n is ScrollUpdateNotification) {
            if (value > widget.min) {
              final delta = n.scrollDelta;
              if (delta != null) {
                Scrollable.of(n.context!)!.position.correctBy(-delta);
                value = value - delta;
              }
            }
          }
          if (n is ScrollStartNotification) {
            animationController?.stop();
          }
          if (n is ScrollEndNotification) {
            final velocity = n.dragDetails?.primaryVelocity;
            // Log.w('ss. $velocity', onlyDebug: false);
            if (velocity != null) {
              ScrollSpringSimulation sim;
              if (velocity > 300) {
                sim = ScrollSpringSimulation(
                    kDefaultSpring, value, widget.max, velocity);
              } else {
                sim = ScrollSpringSimulation(
                    kDefaultSpring, value, widget.min, velocity);
              }
              animationController?.animateWith(sim);
            } else {
              animated();
            }
          }
          return false;
        },
        child: AnimatedBuilder(
          animation: widget.topOffset,
          builder: (context, child) {
            return Positioned(
              top: value,
              right: 0,
              left: 0,
              bottom: 0,
              child: child!,
            );
          },
          child: Material(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.hardEdge,
            child: ListViewBuilder(
              padding: const EdgeInsets.all(8.0),
              itemCount: 200,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: Text('$index'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
