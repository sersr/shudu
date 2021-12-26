import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

abstract class PanSlideState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  late GlobalKey<PanOverlayState> _key;
  PanOverlayState? get _overlay => _key.currentState;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<PanOverlayState>();
  }

  bool isMounted(Widget child) {
    if (_overlay == null) return false;
    return _overlay!.childIsMounted(child);
  }

  final _entries = Queue<PanSlideController>();
  void _insert(PanSlideController controller) {
    if (_entries.contains(controller)) return;
    if (_overlay != null) {
      _overlay!.insert(controller._entry);
      if (_entries.isNotEmpty && controller.connect)
        _entries.last.next = controller;
      _entries.add(controller);
    }
  }

  void _remove(PanSlideController controller) {
    if (!_entries.contains(controller)) return;
    if (_overlay != null) {
      _entries.remove(controller);
      _overlay!.remove(controller._entry);
      assert(Log.i('remove #${controller.hashCode}'));
    }
  }

  void _removeGroups(PanSlideController controller) {
    if (!_entries.contains(controller)) return;
    if (_overlay != null) {
      for (final e in _entries.where((el) => el.groups == controller.groups)) {
        if (e == controller) continue;
        e._hide();
      }
    }
  }

  void hideAll() {
    for (var el in _entries) {
      el.dispose();
    }
  }

  int get entriesLength => _entries.length;
  Iterable<PanSlideController> get showEntries =>
      _entries.where((element) => !element.controller.isDismissed);

  // 立即删除已经隐藏的
  void removeHide() {
    _entries.removeWhere((element) {
      if (element.controller.isDismissed) {
        element._stop();
        _overlay!.remove(element._entry);
        return true;
      }
      return false;
    });
  }

  void hideLast() {
    removeHide();
    if (_entries.isNotEmpty) _entries.last.dispose();
  }

  Widget wrapOverlay(BuildContext context, Widget overlay);

  @override
  Widget build(context) => wrapOverlay(context, PanOverlay(key: _key));

  @override
  void dispose() {
    for (var el in _entries) {
      el._stop();
    }
    super.dispose();
  }
}

class PanOverlay extends StatefulWidget {
  const PanOverlay({Key? key}) : super(key: key);
  @override
  PanOverlayState createState() => PanOverlayState();
}

class PanOverlayState extends State<PanOverlay> {
  final _children = <Widget>[];

  bool childIsMounted(Widget child) => _children.contains(child);

  void insert(Widget child) {
    if (_children.contains(child)) return;
    setState(() {
      _children.add(child);
    });
  }

  void remove(Widget child) {
    if (_children.contains(child)) {
      setState(() {
        _children.remove(child);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _children,
    );
  }
}

typedef StatusCallback = void Function(AnimationStatus status);
typedef FutureOrVoidCallback = Future<void> Function();

class PanSlideController {
  PanSlideController({
    required PanSlideState state,
    required Function(BuildContext, PanSlideController) builder,
    this.groups = 'default',
    this.connect = false,
    Duration duration = const Duration(milliseconds: 280),
    this.onhideEnd,
    this.onshowEnd,
    this.onanimating,
    this.onshow,
    this.onhide,
  })  : _pan = state,
        _controller = AnimationController(vsync: state, duration: duration) {
    _controller.addStatusListener(statusListen);
    _entry = Builder(builder: (context) => builder(context, this));
  }

  VoidCallback? onhideEnd;
  VoidCallback? onshowEnd;
  VoidCallback? onanimating;
  FutureOrVoidCallback? onhide;
  FutureOrVoidCallback? onshow;
  late Widget _entry;

  bool get mounted => _pan.isMounted(_entry);

  final PanSlideState _pan;
  PanSlideState get state => _pan;

  final AnimationController _controller;
  AnimationController get controller => _controller;

  bool connect;
  final String groups;
  PanSlideController? next;

  static PanSlideController showPan(State state,
      {VoidCallback? onhideEnd,
      VoidCallback? onshowEnd,
      VoidCallback? onanimating,
      FutureOrVoidCallback? onhide,
      FutureOrVoidCallback? onshow,
      required Widget Function(BuildContext, PanSlideController) builder}) {
    final _state = state is PanSlideState
        ? state
        : state.context.findAncestorStateOfType<PanSlideState>();
    assert(_state != null, 'PanSlideState == null');
    return PanSlideController(
        state: _state!,
        builder: builder,
        onhide: onhide,
        onshow: onshow,
        onanimating: onanimating,
        onhideEnd: onhideEnd,
        onshowEnd: onshowEnd);
  }

  void statusListen(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _hideCallback?.call();
      _hideCallback = null;

      if (destory) {
        _destory();
      } else {
        onhideEnd?.call();
      }
    } else if (status == AnimationStatus.completed) {
      onshowEnd?.call();
    } else {
      onanimating?.call();
    }
  }

  bool get isShowing =>
      controller.status == AnimationStatus.completed ||
      controller.status == AnimationStatus.forward;
  bool get isAnimating =>
      controller.status == AnimationStatus.forward ||
      controller.status == AnimationStatus.reverse ||
      controller.isAnimating;

  void _removeAfter(bool destory) {
    var child = next;
    if (child != null) {
      if (destory) {
        next = null;
        child.dispose();
      } else {
        child._hide();
      }
    }
  }

  void hide({bool destory = false}) async {
    _hide();
    _removeAfter(destory);
  }

  void _hide() {
    if (!isShowing) return;
    controller.reverse();
  }

  void hideGroup() {
    if (!isShowing) return;
    _hide();
    _pan._removeGroups(this);
  }

  // 注册单次动画完成后回调
  void hideOnCallback([VoidCallback? callback]) {
    _hideCallback ??= callback;
    hide();
  }

  VoidCallback? _hideCallback;

  void init() {
    if (!mounted) _pan._insert(this);
  }

  void show() async {
    if (isShowing || _hideCallback != null || destory) return;
    init();
    controller.forward();
  }

  void trigger({bool immediate = true}) {
    if (isAnimating && !immediate || destory) return;
    if (isShowing) {
      hide();
    } else {
      show();
    }
  }

  bool get close => _state == closeState;
  bool get destory => _state <= destoryState;

  // 已经释放
  static const int closeState = 0;

  // 表示将要释放资源，当前对象将不再可用
  static const int destoryState = 1;

  // 存活
  static const int activeState = 2;

  int _state = activeState;

  /// 释放资源
  void _stop() {
    if (_state != closeState) {
      _state = closeState;
      onhideEnd?.call();
      controller.dispose();
    }
  }

  void _destory() {
    _stop();
    _pan._remove(this);
  }

  // 当前 [State] 结束生命周期时，调用
  void dispose() {
    if (destory) return;
    if (controller.isDismissed) {
      _destory();
    } else {
      // 动画完成之后释放
      hide(destory: true);
      _state = destoryState;
    }
  }

  /// controll state
  void hideAll() => _pan.hideAll();
}

typedef ChildBuilder = Widget Function(
    BuildContext, Animation<double>, _PannelSlideState);

class PannelSlide extends StatefulWidget {
  const PannelSlide(
      {Key? key,
      this.middleChild,
      this.botChild,
      this.topChild,
      this.leftChild,
      this.rightChild,
      this.modal = false,
      this.ignoreBottomHeight = 0.0,
      required this.controller,
      this.useDefault = true})
      : assert(botChild != null ||
            topChild != null ||
            leftChild != null ||
            rightChild != null ||
            middleChild != null),
        super(key: key);
  final bool modal;
  final double ignoreBottomHeight;
  final PanSlideController controller;
  final ChildBuilder? botChild;
  final ChildBuilder? topChild;
  final ChildBuilder? leftChild;
  final ChildBuilder? rightChild;
  final ChildBuilder? middleChild;
  final bool useDefault;
  @override
  _PannelSlideState createState() => _PannelSlideState();
}

class _PannelSlideState extends State<PannelSlide> {
  late PanSlideController panSlideController;
  CurvedAnimation? curvedAnimation;

  final _topInOffset =
      Tween<Offset>(begin: const Offset(0.0, -1), end: Offset.zero);
  final _botInOffset =
      Tween<Offset>(begin: const Offset(0.0, 1), end: Offset.zero);
  final _leftInOffset =
      Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero);
  final _rightInOffset =
      Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero);
  final modalTween = Tween<double>(begin: 0.0, end: 1.0);
  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  void didUpdateWidget(covariant PannelSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateState();
  }

  void updateState() {
    panSlideController = widget.controller;
    final controller = panSlideController.controller;
    // final _curve = CurvedAnimation(parent: controller, curve: Curves.ease);
    // final _curveAnimation = _curve;
    curvedAnimation?.dispose();
    curvedAnimation = CurvedAnimation(parent: controller, curve: Curves.ease);

    controller.removeStatusListener(statusListen);
    controller.addStatusListener(statusListen);
    statusListen(controller.status);
  }

  @override
  void dispose() {
    panSlideController.controller.removeStatusListener(statusListen);
    super.dispose();
  }

  void statusListen(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      hide.value = true;
    } else {
      hide.value = false;
    }
  }

  final debx =
      ColorTween(begin: Colors.transparent, end: Colors.black87.withAlpha(100));

  final hide = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final botPositions = curvedAnimation!.drive(_botInOffset);
    final topPositions = curvedAnimation!.drive(_topInOffset);
    final leftPositions = curvedAnimation!.drive(_leftInOffset);
    final rightPositions = curvedAnimation!.drive(_rightInOffset);
    final modalAnimation = curvedAnimation!.drive(modalTween);
    final colorsAnimation = debx.animate(modalAnimation);

    if (widget.modal) {
      children.add(Positioned.fill(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: colorsAnimation,
            builder: (context, child) {
              if (hide.value) return const SizedBox();

              return child!;
            },
            child: ColoredBox(
              color: colorsAnimation.value ?? Colors.transparent,
              child: widget.ignoreBottomHeight == 0.0
                  ? GestureDetector(
                      onTap: panSlideController.hideOnCallback,
                      child: const SizedBox.expand())
                  : Column(
                      children: [
                        GestureDetector(
                            onTap: panSlideController.hideOnCallback,
                            child: Expanded(child: const SizedBox())),
                        SizedBox(height: widget.ignoreBottomHeight)
                      ],
                    ),
            ),
          ),
        ),
      ));
    }
    if (widget.botChild != null) {
      var bot = widget.botChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        bot = SlideTransition(position: botPositions, child: bot);
      }
      children.add(Positioned(bottom: 0.0, left: 0.0, right: 0.0, child: bot));
    }
    if (widget.topChild != null) {
      var top = widget.topChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        top = SlideTransition(position: topPositions, child: top);
      }
      children.add(Positioned(top: 0.0, left: 0.0, right: 0.0, child: top));
    }
    if (widget.rightChild != null) {
      var right =
          widget.rightChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        right = SlideTransition(position: rightPositions, child: right);
      }
      children.add(Positioned(top: 0.0, bottom: 0.0, right: 0.0, child: right));
    }

    if (widget.leftChild != null) {
      var left =
          widget.leftChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        left = SlideTransition(position: leftPositions, child: left);
      }
      children.add(Positioned(top: 0.0, left: 0.0, bottom: 0.0, child: left));
    }
    if (widget.middleChild != null) {
      var milldle =
          widget.middleChild!(context, panSlideController.controller, this);
      if (widget.useDefault) {
        milldle = SlideTransition(position: leftPositions, child: milldle);
      }
      children.add(Positioned.fill(child: RepaintBoundary(child: milldle)));
    }
    return Stack(children: children);
  }
}

class ModalPart extends MultiChildLayoutDelegate {
  ModalPart(this.bottom);
  final double bottom;

  @override
  void performLayout(Size size) {
    const _body = 'body';
    const _bottom = 'bottom';
    final height = size.height;
    final width = size.width;

    final constraints =
        BoxConstraints.tightFor(width: width, height: height - bottom);
    layoutChild(_body, constraints);
    positionChild(_body, Offset.zero);
    final bottomConstraints =
        BoxConstraints.tightFor(width: width, height: bottom);
    layoutChild(_bottom, bottomConstraints);
    positionChild(_bottom, Offset(0, height - bottom));
  }

  @override
  bool shouldRelayout(covariant ModalPart oldDelegate) {
    return bottom != oldDelegate.bottom;
  }
}
