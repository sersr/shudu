import 'dart:async';

import 'package:flutter/material.dart';

mixin PageAnimationMixin<T extends StatefulWidget> on State<T> {
  Animation? animation;

  final _callbacks = <VoidCallback>[];

  bool get isCompleted => animation == null || animation!.isCompleted;

  bool _done = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animation?.removeStatusListener(_listenAnimationStatus);
    animation = ModalRoute.of(context)?.animation;
    animation?.addStatusListener(_listenAnimationStatus);
    addListener(initOnceTask);
    // 初始时status == AnimationStatus.completed
    // 延迟判断
    Timer.run(() => isCompleted ? _run() : null);
  }

  void addListener(VoidCallback callback) {
    _callbacks.add(callback);
  }

  void removeListener(VoidCallback callback) {
    _callbacks.remove(callback);
  }

  @mustCallSuper
  void initOnceTask() {
    removeListener(initOnceTask);
  }

  void _run() {
    if (_done) return;
    _done = true;
    if (_callbacks.isEmpty) return;
    if (mounted) {
      final callbacks = List.of(_callbacks);
      for (var callback in callbacks) {
        callback();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    animation?.removeStatusListener(_listenAnimationStatus);
  }

  void _listenAnimationStatus(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _run();
        break;
      default:
    }
  }
}
