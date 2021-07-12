import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class ListItemBuilder extends StatelessWidget {
  const ListItemBuilder({
    Key? key,
    required this.child,
    this.onLongPress,
    this.onTap,
    this.background = true,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool background;
  final bgColor = const Color.fromRGBO(250, 250, 250, 1);
  final spalColor = const Color.fromRGBO(225, 225, 225, 1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
      child: btn1(
          onTap: onTap,
          background: background,
          onLongPress: onLongPress,
          radius: 6.0,
          bgColor: bgColor,
          splashColor: spalColor,
          child: child),
    );
  }
}

class ListViewBuilder extends StatelessWidget {
  const ListViewBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.primary,
    this.cacheExtent,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final bool? primary;
  final double? cacheExtent;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color.fromRGBO(242, 242, 242, 1),

      child: ListView.builder(
          primary: primary,
          itemExtent: itemExtent,
          itemCount: itemCount,
          cacheExtent: cacheExtent,
          padding: padding,
          itemBuilder: itemBuilder),
    );
  }
}
