import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shudu/bloc/bloc.dart';

import '../../bloc/painter_bloc.dart';
import '../../utils/utils.dart';
import 'context_view.dart';
import 'page_view_controller.dart';
import 'pannel.dart';

class ContentPageView extends StatefulWidget {
  const ContentPageView({
    Key? key,
    required this.show,
    required this.willPop,
    required this.showCname,
    required this.showSettings,
    this.ignore = false,
  }) : super(key: key);

  final ValueNotifier<bool> show;
  final Future<bool> Function() willPop;
  final ValueNotifier<SettingView> showSettings;
  final ValueNotifier<bool> showCname;
  final bool? ignore;

  @override
  _ContentPageViewState createState() => _ContentPageViewState();
}

class _ContentPageViewState extends State<ContentPageView> with TickerProviderStateMixin {
  late NopPageViewController offsetPosition;
  late PainterBloc bloc;

  @override
  void initState() {
    super.initState();
    offsetPosition = NopPageViewController(
      vsync: this,
      scrollingNotify: isScrolling,
      getDragState: canDrag,
      hasContent: isBoundary,
    );
    bloc = context.read<PainterBloc>();
    bloc.controller = offsetPosition;
    resetState();
  }

  @override
  void didUpdateWidget(covariant ContentPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<PainterBloc>();
  }

  void resetState() {
    if (bloc.config.axis != null) {
      if (offsetPosition.axis != bloc.config.axis) {
        offsetPosition.axis = bloc.config.axis ?? Axis.horizontal;
      }
    }
  }

  bool isBoundary(int lr, int index) {
    return bloc.hasContent(lr, index);
  }

  void isScrolling(bool scrolling) {
    if (!scrolling) {
      if (bloc.canCompute != null && !bloc.canCompute!.isCompleted) {
        bloc
          ..canCompute!.complete()
          ..dump();
      }
    } else {
      if (bloc.canCompute == null || bloc.canCompute!.isCompleted) {
        bloc.canCompute = Completer();
      }
    }
  }

  bool canDrag() => bloc.computeCount == 0;

  Widget? getChild(int index, {required bool changeState}) {
    return bloc.getWidget(index, changeState: changeState);
    // return child;
  }

  Widget wrapChild() {
    final child = NopPageView(
      offsetPosition: offsetPosition,
      builder: getChild,
    );
    if (offsetPosition.axis == Axis.horizontal) {
      return child;
    } else {
      final head = AnimatedBuilder(
        animation: bloc.header,
        builder: (context, _) {
          return Text('${bloc.header.value}', style: bloc.secstyle);
        },
      );
      final footleft = AnimatedBuilder(
        animation: bloc.footer,
        builder: (context, _) {
          final time = DateTime.now();
          return Text('${time.hour.timePadLeft}:${time.minute.timePadLeft}', style: bloc.secstyle);
        },
      );
      final footright = AnimatedBuilder(
        animation: bloc.footer,
        builder: (context, _) {
          return Text('${bloc.footer.value}', style: bloc.secstyle);
        },
      );
      return Center(
        child: Stack(
          children: [
            Positioned(top: 8.0 + bloc.padding.top, left: 16.0, child: head),
            Positioned(bottom: 4.0 + bloc.padding.bottom, left: 16.0, child: footleft),
            Positioned(bottom: 4.0 + bloc.padding.bottom, right: 16.0, child: footright),
            Positioned.fill(top: 33 + bloc.padding.top, bottom: 33 + bloc.padding.bottom, right: 16.0, child: child),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final child = bloc.tData.contentIsNotEmpty
        ? GestureDetector(
            child: wrapChild(),
            onTapUp: (d) {
              if (offsetPosition.page == 0 ||
                  offsetPosition.page % offsetPosition.page.toInt() == 0 ||
                  !offsetPosition.isScrolling) {
                final l = d.globalPosition;
                final halfH = size.height / 2;
                final sixH = size.height / 5;
                final halfW = size.width / 2;
                final sixW = size.width / 5;
                if (l.dx > halfW - sixW && l.dx < halfW + sixW && l.dy > halfH - sixH && l.dy < halfH + sixH) {
                  // widget.show.value = !widget.show.value;
                  if (widget.show.value) {
                    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);
                    widget.showCname.value = false;

                    /// android: 保持底部不变；因为底部的显/隐 动画太难看了？？？
                    /// ios: 新版iPhone 可以隐藏，----- 不会触发changMetrics（bottom 不变）

                    widget.show.value = false;
                    // Future.delayed(Duration(milliseconds: 100), () {
                    if (!bloc.liuhai) {
                      SystemChrome.setEnabledSystemUIOverlays(
                          [if (defaultTargetPlatform == TargetPlatform.android) SystemUiOverlay.bottom]);
                      if (defaultTargetPlatform == TargetPlatform.android) {
                        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                          systemNavigationBarColor: Color(bloc.config.bgcolor!),
                        ));
                      }
                    } else {
                      if (defaultTargetPlatform == TargetPlatform.android) {
                        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                          systemNavigationBarColor: Color(bloc.config.bgcolor!),
                          statusBarColor: Color(0xFFFFFF),
                        ));
                      }
                    }
                    // });
                  } else {
                    if (defaultTargetPlatform == TargetPlatform.android) {
                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
                    }
                    if (!bloc.liuhai) {
                      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                    }
                    widget.show.value = true;

                    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                  }
                } else {
                  offsetPosition.nextPage();
                }
              }
            },
          )
        : GestureDetector(
            onTap: () {
              widget.show.value = !widget.show.value;
            },
            child: Container(
              color: Colors.cyan.withAlpha(0),
              child: widget.ignore!
                  ? null
                  : Center(
                      child: btn1(
                          bgColor: Colors.blue,
                          splashColor: Colors.blue[200],
                          radius: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text('重新加载'),
                          onTap: () => bloc.add(PainterLoadEvent())),
                    ),
            ),
          );
    ;
    return Stack(
      children: [
        child,
        Pannel(
          showPannel: widget.show,
          willPop: widget.willPop,
          controller: offsetPosition,
          showCname: widget.showCname,
          showSettings: widget.showSettings,
        )
      ],
    );
  }

  @override
  void dispose() {
    offsetPosition.dispose();
    bloc.controller = null;
    super.dispose();
  }
}

/// [NopPageView]
/// 无端
/// 可以任意值为起始点，支持负增长；
/// 提供端点判定；
/// 无缓存，状态由用户管理
class NopPageView extends StatefulWidget {
  const NopPageView({
    Key? key,
    required this.offsetPosition,
    required this.builder,
  }) : super(key: key);

  final NopPageViewController offsetPosition;
  final WidgetCallback builder;
  @override
  _NopPageViewState createState() => _NopPageViewState();
}

class _NopPageViewState extends State<NopPageView> {
  Drag? drag;
  ScrollHoldController? hold;
  // final GlobalKey<RawGestureDetectorState> _gestureDetectorKey = GlobalKey<RawGestureDetectorState>();

  Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};
  @override
  void initState() {
    super.initState();
    updategest();
  }

  @override
  void didUpdateWidget(covariant NopPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updategest();
  }

  void updategest() {
    final dragStartBehavior = DragStartBehavior.start;
    if (widget.offsetPosition.axis == Axis.vertical) {
      gestures = <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (VerticalDragGestureRecognizer instance) {
            instance
              ..onDown = onDown
              ..onStart = onStart
              ..onUpdate = onUpdate
              ..onEnd = onEnd
              ..onCancel = onCancel
              ..dragStartBehavior = dragStartBehavior;
          },
        )
      };
    } else {
      gestures = <Type, GestureRecognizerFactory>{
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(debugOwner: this),
          (HorizontalDragGestureRecognizer instance) {
            instance
              ..onDown = onDown
              ..onStart = onStart
              ..onUpdate = onUpdate
              ..onEnd = onEnd
              ..onCancel = onCancel
              ..dragStartBehavior = dragStartBehavior;
          },
        )
      };
    }
    // if (_gestureDetectorKey.currentState != null) {
    //   _gestureDetectorKey.currentState.replaceGestureRecognizers(gestures);
    // }
  }

  void onDown(DragDownDetails d) {
    // SystemChrome.restoreSystemUIOverlays();
    hold = widget.offsetPosition.hold(() {
      hold = null;
    });
  }

  void onStart(DragStartDetails d) {
    drag = widget.offsetPosition.drag(d, () {
      drag = null;
    });
  }

  void onUpdate(DragUpdateDetails d) {
    if (drag != null) {
      drag!.update(d);
    }
  }

  void onEnd(DragEndDetails d) {
    widget.offsetPosition.goBallistic(-d.primaryVelocity!);
  }

  void onCancel() {
    drag?.cancel();
    hold?.cancel();
    drag = null;
    hold = null;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: gestures,
      // key: _gestureDetectorKey,
      child: ContentPreNextWidget(
        offset: widget.offsetPosition,
        builder: widget.builder,
      ),
    );
  }
}
