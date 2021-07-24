import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class ListItem extends StatelessWidget {
  ListItem({
    Key? key,
    required this.child,
    this.onLongPress,
    this.onTap,
    this.background = true,
    this.height,
    this.color = const Color.fromRGBO(242, 242, 242, 1),
    this.bgColor = const Color.fromRGBO(250, 250, 250, 1),
    this.splashColor = const Color.fromRGBO(225, 225, 225, 1),
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool background;
  final double? height;
  final Color color;
  final Color bgColor;
  final Color splashColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: height == null
          ? null
          : BoxConstraints(maxHeight: height!, minHeight: height!),
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
      child: btn1(
          onTap: onTap,
          background: background,
          onLongPress: onLongPress,
          radius: 6.0,
          bgColor: bgColor,
          splashColor: splashColor,
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
    this.scrollController,
    this.finishLayout,
  }) : super(key: key);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final bool? primary;
  final double? cacheExtent;
  final EdgeInsets padding;
  final ScrollController? scrollController;
  final FinishLayout? finishLayout;

  @override
  Widget build(BuildContext context) {
    final p = MediaQuery.of(context).padding;
    final _padding =
        p.bottom == 0.0 ? padding : padding.copyWith(bottom: p.bottom);
    final delegate = MyDelegate(itemBuilder,
        childCount: itemCount, finishLayout: finishLayout);
    return ColoredBox(
      color: const Color.fromRGBO(242, 242, 242, 1),
      child: RepaintBoundary(
        child: ListView.custom(
          physics:
              const MyScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          primary: primary,
          padding: _padding,
          cacheExtent: cacheExtent,
          controller: scrollController,
          childrenDelegate: delegate,
          itemExtent: itemExtent,
        ),
      ),
    );
  }
}

typedef FinishLayout = void Function(int firstIndex, int lstIndex);

class MyDelegate extends SliverChildBuilderDelegate {
  MyDelegate(NullableIndexedWidgetBuilder builder,
      {this.finishLayout, int? childCount})
      : super(builder, childCount: childCount);

  final FinishLayout? finishLayout;
  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    finishLayout?.call(firstIndex, lastIndex);
  }
}

class MyScrollPhysics extends ScrollPhysics {
  const MyScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);
  @override
  bool recommendDeferredLoading(
      double velocity, ScrollMetrics metrics, BuildContext context) {
    return velocity.abs() > 300;
  }

  @override
  MyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyScrollPhysics(parent: buildParent(ancestor));
  }
}
