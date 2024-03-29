import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppBarHide extends StatefulWidget {
  const AppBarHide(
      {Key? key,
      required this.values,
      this.begincolor,
      required this.title,
      this.max = 120})
      : super(key: key);
  final ValueListenable<double> values;
  final Color? begincolor;
  final Widget title;
  final double max;
  @override
  _AppBarHideState createState() => _AppBarHideState();
}

class _AppBarHideState extends State<AppBarHide> {
  late ColorTween tweenColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateColor();
  }

  @override
  void didUpdateWidget(covariant AppBarHide oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateColor();
  }

  void updateColor() {
    Color? begin = widget.begincolor;
    if (begin == null) {
      final data = Theme.of(context);
      final darkMode = data.brightness == Brightness.dark;
      begin = darkMode ? data.colorScheme.onPrimary : data.colorScheme.primary;
    }
    tweenColor = ColorTween(begin: begin, end: begin.withAlpha(0));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    Widget? leading;
    if (canPop) {
      leading = BackButton(color: Colors.grey.shade100);
    }
    final child = RepaintBoundary(
      child: NavigationToolbar(
        leading: leading,
        centerMiddle: true,
        middle: RepaintBoundary(
          child: AnimatedBuilder(
            animation: widget.values,
            builder: (context, child) {
              final value = (widget.values.value / widget.max).clamp(0.0, 1.0);
              return AnimatedOpacity(
                opacity: value,
                duration: const Duration(milliseconds: 100),
                child: RepaintBoundary(child: widget.title),
              );
            },
          ),
        ),
      ),
    );
    final theme = Theme.of(context);
    final background = theme.colorScheme.background;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.values,
        builder: (context, child) {
          final value = (widget.values.value / widget.max).clamp(0.0, 1.0);
          final color = tweenColor.lerp(1 - value);
          return Material(
              color: color ?? background,
              child: SafeArea(bottom: false, child: child!));
        },
        child: SizedBox(height: kToolbarHeight, child: child),
      ),
    );
  }
}
