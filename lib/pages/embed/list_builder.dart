import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../widgets/list_key.dart';

class ListItemBuilder extends StatelessWidget {
  const ListItemBuilder({
    Key? key,
    required this.child,
    this.onLongPress,
    this.onTap,
    this.background = true,
    this.height,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool background;
  final double? height;

  final bgColor = const Color.fromRGBO(250, 250, 250, 1);
  final spalColor = const Color.fromRGBO(225, 225, 225, 1);

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
          splashColor: spalColor,
          child: child),
    );
  }
}

class ListViewBuilder extends StatefulWidget {
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
  State<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder>
    with TickerProviderStateMixin {
  // late NopPageViewController offsetPosition;

  // @override
  // void initState() {
  //   super.initState();
  //   offsetPosition = NopPageViewController(
  //     vsync: this,
  //     scrollingNotify: (_) {},
  //     getBounds: isBoundary,
  //   );
  // }

  // int isBoundary() {
  //   var _r = 0;
  //   if (currentIndex > 0) _r |= ContentBounds.addLeft;
  //   if (currentIndex < widget.itemCount - 1) _r |= ContentBounds.addRight;

  //   return _r;
  // }

  // int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final delegate = MyDelegate(widget.itemBuilder,
        childCount: widget.itemCount, finishLayout: widget.finishLayout);
    return ColoredBox(
      color: const Color.fromRGBO(242, 242, 242, 1),
      child: RepaintBoundary(
        child: ListView.custom(
          physics: ScrollConfiguration.of(context)
              .getScrollPhysics(context)
              .applyTo(const MyScrollPhysics()),
          primary: widget.primary,
          cacheExtent: widget.cacheExtent,
          controller: widget.scrollController,
          childrenDelegate: delegate,
          itemExtent: widget.itemExtent,
        ),
      ),
    );
  }
}

typedef FinishLayout = void Function(int firstIndex, int lstIndex);

class MyDelegate extends SliverChildBuilderDelegate {
  MyDelegate(NullableIndexedWidgetBuilder builder,
      {this.key, this.finishLayout, int? childCount})
      : super(builder, childCount: childCount);

  final ListKey? key;
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
    // final maxPhysicalPixels =
    //     WidgetsBinding.instance!.window.physicalSize.longestSide;
    return velocity.abs() > 10;
    // return false;
  }

  @override
  MyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyScrollPhysics(parent: buildParent(ancestor));
  }
}
