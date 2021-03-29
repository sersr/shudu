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
    onTap: onTap,
    onLongPress: onLongPress,
    onTapCancel: onTapCancel,
    onTapDown: onTapDown,
    highlightColor: splashColor!.withAlpha(190),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: child,
    ),
  );

  return background
      ? Material(
          borderRadius: BorderRadius.circular(radius),
          color: bgColor ?? Colors.grey[200],
          type: MaterialType.button,
          child: child,
        )
      : child;
}

Widget btn2({VoidCallback? onTap, required String text, required IconData icon}) {
  return InkWell(
    borderRadius: BorderRadius.circular(4.0),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 36,
            color: Colors.grey.shade600,
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
