import 'package:flutter/material.dart';

import '../../../provider/export.dart';
import '../../../provider/text_data.dart';

class Extent {
  const Extent({required this.maxExtent, required this.minExtent});
  final double minExtent;
  final double maxExtent;
  static const none = Extent(minExtent: 0, maxExtent: 1);
}

abstract class ContentChildBuildDelegate {
  Widget? build(BuildContext context, int index);
  bool childExistsAt(int index);
  Extent getExtent(
      int firstIndex, int lastIndex, int currentIndex, double itemExtent);

  int? get childCount => null;
}

class ContentPageBuildDelegate extends ContentChildBuildDelegate {
  final Widget? Function(BuildContext context, ContentMetrics? mes) builder;

  ContentPageBuildDelegate({required this.builder, required this.content});
  final ContentGetter content;
  @override
  Widget? build(BuildContext context, int index) {
    final contentMes = content.getContentMes(index);
    return builder(context, contentMes);
  }

  @override
  bool childExistsAt(int index) {
    final innerIndex = content.innerIndex;
    final minLength = -content.preLength + innerIndex;
    final maxLength = content.nextLength + innerIndex;
    return index >= minLength && index <= maxLength;
  }

  @override
  Extent getExtent(
      int firstIndex, int lastIndex, int currentIndex, double itemExtent) {
    content.getContentMes(currentIndex, changeState: true);
    if (!content.needUpdate) return Extent.none;
    content.updated();
    final innerIndex = content.innerIndex;
    final minLength = -content.preLength + innerIndex;
    final maxLength = content.nextLength + innerIndex;
    return Extent(
        minExtent: minLength * itemExtent, maxExtent: maxLength * itemExtent);
  }
}

abstract class ContentChildManager {
  void removeChild(RenderBox child);
  void createChild(int index, {RenderBox? after});
  bool childExistsAt(int index);
  int? get childCount => null;
  Extent getExtent(
      int firstIndex, int lastIndex, int currentIndex, double itemExtent);
}
