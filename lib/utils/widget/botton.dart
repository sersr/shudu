import 'package:flutter/material.dart';

Widget btn1(
    {VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onTapCancel,
    void Function(TapDownDetails details)? onTapDown,
    Widget? child,
    Color? bgColor,
    Color? splashColor,
    double? radius,
    EdgeInsets? padding,
    bool background = true}) {
  splashColor ??= Colors.grey[300];
  radius ??= 0.0;

  child = InkWell(
    splashColor: splashColor,
    borderRadius: BorderRadius.circular(radius),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: child,
    ),
    onTap: onTap,
    onLongPress: onLongPress,
    onTapCancel: onTapCancel,
    onTapDown: onTapDown,
    highlightColor: splashColor!.withAlpha(190),
  );

  return background
      ? Material(
          borderRadius: BorderRadius.circular(radius),
          color: bgColor ?? Colors.grey[200],
          child: child,
          type: MaterialType.button,
        )
      : child;
}
