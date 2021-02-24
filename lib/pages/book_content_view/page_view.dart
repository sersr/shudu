import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';

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
  }) : super(key: key);

  final ValueNotifier<bool> show;
  final Future<bool> Function() willPop;
  final ValueNotifier<SettingView> showSettings;
  final ValueNotifier<bool> showCname;

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
      bloc
        ..completercanCompute()
        ..dump();
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
          return Text(
            '${bloc.footer.value}',
            style: bloc.secstyle,
            textAlign: TextAlign.right,
          );
        },
      );
      return SlideWidget(
        esize: bloc.size,
        epadding: bloc.padding,
        header: RepaintBoundary(child: head),
        body: RepaintBoundary(child: child),
        leftFooter: RepaintBoundary(child: footleft),
        rightFooter: RepaintBoundary(child: footright),
      );
      // return Stack(
      //   children: [
      //     Positioned(top: 8.0 + bloc.padding.top, left: 16.0, child: head),
      //     Positioned(bottom: 4.0 + bloc.padding.bottom, left: 16.0, child: footleft),
      //     Positioned(bottom: 4.0 + bloc.padding.bottom, right: 16.0, child: footright),
      //     Positioned.fill(top: 33 + bloc.padding.top, bottom: 33 + bloc.padding.bottom, right: 16.0, child: child),
      //   ],
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final child = AnimatedBuilder(
        animation: bloc.ignore,
        builder: (context, child) {
          return !bloc.ignore.value
              ? bloc.tData.contentIsNotEmpty
                  ? GestureDetector(
                      child: wrapChild(),
                      onTapUp: (d) {
                        if (offsetPosition.page == 0 ||
                            offsetPosition.page % offsetPosition.page.toInt() == 0 ||
                            !offsetPosition.isScrolling) {
                          final l = d.globalPosition;
                          final halfH = size.height / 2;
                          final halfW = size.width / 2;
                          final sixH = size.height / 5;
                          final sixW = size.width / 5;
                          final x = l.dx - halfW;
                          final y = l.dy - halfH;
                          if (x.abs() < sixW && y.abs() < sixH) {
                            // if (l.dx > halfW - sixW && l.dx < halfW + sixW && l.dy > halfH - sixH && l.dy < halfH + sixH) {
                            widget.show.value = !widget.show.value;
                            if (!widget.show.value) {
                              widget.showCname.value = false;
                            }
                          } else {
                            offsetPosition.nextPage();
                          }
                        }
                      },
                    )
                  : GestureDetector(
                      onTap: () {
                        if (widget.show.value) {
                          widget.showCname.value = false;
                        }
                        widget.show.value = !widget.show.value;
                      },
                      child: Container(
                        color: Colors.cyan.withAlpha(0),
                        child: Center(
                          child: btn1(
                              bgColor: Colors.blue,
                              splashColor: Colors.blue[200],
                              radius: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text('重新加载'),
                              onTap: () => bloc.add(PainterLoadEvent())),
                        ),
                      ))
              : GestureDetector(
                  onTap: () {
                    if (widget.show.value) {
                      widget.showCname.value = false;
                    }
                    widget.show.value = !widget.show.value;
                  },
                  child: Container(
                    color: Colors.cyan.withAlpha(0),
                  ),
                );
        });

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

class SlideWidget extends RenderObjectWidget {
  SlideWidget(
      {required this.esize,
      required this.epadding,
      required this.header,
      required this.body,
      required this.leftFooter,
      required this.rightFooter});
  final Widget header;
  final Widget body;
  final Widget leftFooter;
  final Widget rightFooter;
  final Size esize;
  final EdgeInsets epadding;

  @override
  SlideElement createElement() {
    return SlideElement(this);
  }

  @override
  SliderRenderObject createRenderObject(BuildContext context) {
    return SliderRenderObject(esize, epadding);
  }

  @override
  void updateRenderObject(BuildContext context, covariant SliderRenderObject renderObject) {
    renderObject
      ..epadding = epadding
      ..esize = esize;
  }
}

class SlideElement extends RenderObjectElement {
  SlideElement(RenderObjectWidget widget) : super(widget);

  @override
  SlideWidget get widget => super.widget as SlideWidget;
  @override
  SliderRenderObject get renderObject => super.renderObject as SliderRenderObject;
  Element? _header;
  Element? _body;
  Element? _leftFooter;
  Element? _rightFooter;
  @override
  void mount(Element? parent, newSlot) {
    super.mount(parent, newSlot);
    ud();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_leftFooter != null) {
      visitor(_leftFooter!);
    }
    if (_rightFooter != null) {
      visitor(_rightFooter!);
    }
  }

  @override
  void update(covariant SlideWidget newWidget) {
    super.update(newWidget);
    if (widget.body != newWidget.body ||
        widget.header != newWidget.header ||
        widget.leftFooter != newWidget.leftFooter ||
        widget.rightFooter != newWidget.rightFooter) {
      ud();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    ud();
  }

  void ud() {
    _header = updateChild(_header, widget.header, 'header');
    _body = updateChild(_body, widget.body, 'body');
    _leftFooter = updateChild(_leftFooter, widget.leftFooter, 'leftFooter');
    _rightFooter = updateChild(_rightFooter, widget.rightFooter, 'rightFooter');
  }

  @override
  void insertRenderObjectChild(RenderBox child, covariant slot) {
    renderObject.add(child, slot);
  }

  @override
  void removeRenderObjectChild(covariant RenderBox child, covariant slot) {
    renderObject.remove(child, slot);
  }
}

class SliderRenderObject extends RenderBox {
  SliderRenderObject(Size esize, EdgeInsets epadding)
      : _esize = esize,
        _epadding = epadding;
  RenderBox? _header;
  RenderBox? _body;
  RenderBox? _leftFooter;
  RenderBox? _rightFooter;
  void add(RenderBox child, slot) {
    if (slot == 'header') {
      if (_header != null) dropChild(_header!);
      adoptChild(child);
      _header = child;
    } else if (slot == 'body') {
      if (_body != null) dropChild(_body!);
      adoptChild(child);
      _body = child;
    } else if (slot == 'leftFooter') {
      if (_leftFooter != null) dropChild(_leftFooter!);
      adoptChild(child);
      _leftFooter = child;
    } else if (slot == 'rightFooter') {
      if (_rightFooter != null) dropChild(_rightFooter!);
      adoptChild(child);
      _rightFooter = child;
    }
  }

  void remove(RenderBox child, slot) {
    if (slot == 'header') {
      if (_header != null) {
        dropChild(_header!);
        _header = null;
      }
    } else if (slot == 'body') {
      if (_body != null) {
        dropChild(_body!);
        _body = null;
      }
    } else if (slot == 'leftFooter') {
      if (_leftFooter != null) {
        dropChild(_leftFooter!);
        _leftFooter = null;
      }
    } else if (slot == 'rightFooter') {
      if (_rightFooter != null) {
        dropChild(_rightFooter!);
        _rightFooter = null;
      }
    }
  }

  Size? _esize;
  Size? get esize => _esize;
  set esize(Size? v) {
    if (_esize == v) return;
    _esize = v;
    markNeedsLayout();
  }

  EdgeInsets? _epadding;
  EdgeInsets? get epadding => _epadding;
  set epadding(EdgeInsets? v) {
    if (_epadding == v) return;
    _epadding = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = esize!;
    final _height = size.height - 4.0 - epadding!.bottom;

    final _constraints = BoxConstraints.tight(esize!);
    if (_header != null) {
      _header!.layout(_constraints);
      final parendata = _header!.parentData as BoxParentData;
      parendata.offset = Offset(16.0, epadding!.top + 8.0);
    }
    if (_leftFooter != null) {
      _leftFooter!.layout(_constraints);
      final parendata = _leftFooter!.parentData as BoxParentData;
      parendata.offset = Offset(16.0, _height - 12.0);
    }
    if (_rightFooter != null) {
      _rightFooter!.layout(_constraints);
      final parendata = _rightFooter!.parentData as BoxParentData;
      parendata.offset = Offset(-16.0, _height - 12.0);
    }
    if (_body != null) {
      final _constraints =
          BoxConstraints.tight(Size(esize!.width, esize!.height - 66 - epadding!.top - epadding!.bottom));
      _body!.layout(_constraints);
      final parendata = _body!.parentData as BoxParentData;
      parendata.offset = Offset(.0, 33 + epadding!.top);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_header != null) {
      context.paintChild(_header!, childOffset(_header!));
    }
    if (_body != null) {
      context.paintChild(_body!, childOffset(_body!));
    }
    if (_leftFooter != null) {
      context.paintChild(_leftFooter!, childOffset(_leftFooter!));
    }
    if (_rightFooter != null) {
      context.paintChild(_rightFooter!, childOffset(_rightFooter!));
    }
  }

  Offset childOffset(RenderObject child) {
    final parendata = child.parentData as BoxParentData;
    return parendata.offset;
  }

  @override
  void redepthChildren() {
    if (_header != null) {
      redepthChild(_header!);
    }
    if (_body != null) {
      redepthChild(_body!);
    }
    if (_leftFooter != null) {
      redepthChild(_leftFooter!);
    }
    if (_rightFooter != null) {
      redepthChild(_rightFooter!);
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _header?.attach(owner);
    _body?.attach(owner);
    _leftFooter?.attach(owner);
    _rightFooter?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _header?.detach();
    _body?.detach();
    _leftFooter?.detach();
    _rightFooter?.detach();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_body != null) {
      return _body!.hitTestChildren(result, position: position) || _body!.hitTest(result, position: position);
    }
    return false;
  }

  @override
  void visitChildren(visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_leftFooter != null) {
      visitor(_leftFooter!);
    }
    if (_rightFooter != null) {
      visitor(_rightFooter!);
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_header != null) {
      visitor(_header!);
    }
    if (_body != null) {
      visitor(_body!);
    }
    if (_leftFooter != null) {
      visitor(_leftFooter!);
    }
    if (_rightFooter != null) {
      visitor(_rightFooter!);
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }
}
