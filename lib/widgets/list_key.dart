import 'package:collection/collection.dart';
import 'dart:ui';

class ListKey {
  ListKey(this.list);
  final List list;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ListKey &&
            const DeepCollectionEquality().equals(list, other.list);
  }

  @override
  int get hashCode => hashList(list);
}
