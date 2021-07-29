import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ListQueue: 通过位运算突破0边界，当 _head == _tail 时，_table 满了，进行扩充', () {
    final queue = ListQueueTest<String>();
    queue.add('a');
    expect(queue._head, 0);
    expect(queue._tail, 1);
    queue.add('haha');
    expect(queue._head, 0);
    expect(queue._tail, 2);
    queue.addFirst('nihal');
    expect(queue._head, 7);
    expect(queue._tail, 2);
  });
}

extension Li<E> on ListQueueTest<E> {
  void prin() {
    print('head: $_head');
    print('tail: $_tail');
  }
}

class ListQueueTest<E> extends ListQueue<E> {
  static const int _INITIAL_CAPACITY = 8;
  List<E?> _table;
  int _head;
  int _tail;
  int _modificationCount = 0;

  /// Create an empty queue.
  ///
  /// If [initialCapacity] is given, prepare the queue for at least that many
  /// elements.
  ListQueueTest([int? initialCapacity])
      : _head = 0,
        _tail = 0,
        _table = List<E?>.filled(_calculateCapacity(initialCapacity), null);

  static int _calculateCapacity(int? initialCapacity) {
    if (initialCapacity == null || initialCapacity < _INITIAL_CAPACITY) {
      return _INITIAL_CAPACITY;
    } else if (!_isPowerOf2(initialCapacity)) {
      return _nextPowerOf2(initialCapacity);
    }
    assert(_isPowerOf2(initialCapacity));
    return initialCapacity;
  }

  /// Create a `ListQueue` containing all [elements].
  ///
  /// The elements are added to the queue, as by [addLast], in the order given
  /// by `elements.iterator`.
  ///
  /// All the [elements] should be instances of [E].
  /// The `elements` iterable itself may have any element type, so this
  /// constructor can be used to down-cast a `Queue`, for example as:
  /// ```dart
  /// Queue<SuperType> superQueue = ...;
  /// Queue<SubType> subQueue =
  ///     ListQueue<SubType>.from(superQueue.whereType<SubType>());
  /// ```
  // factory ListQueueTest.from(Iterable<dynamic> elements) {
  //   if (elements is List<dynamic>) {
  //     int length = elements.length;
  //     ListQueueTest<E> queue = ListQueueTest<E>(length + 1);
  //     assert(queue._table.length > length);
  //     for (int i = 0; i < length; i++) {
  //       queue._table[i] = elements[i] as E;
  //     }
  //     queue._tail = length;
  //     return queue;
  //   } else {
  //     int capacity = _INITIAL_CAPACITY;
  //     if (elements is EfficientLengthIterable) {
  //       capacity = elements.length;
  //     }
  //     ListQueueTest<E> result = ListQueueTest<E>(capacity);
  //     for (final element in elements) {
  //       result.addLast(element as E);
  //     }
  //     return result;
  //   }
  // }

  /// Create a `ListQueue` from [elements].
  ///
  /// The elements are added to the queue, as by [addLast], in the order given
  /// by `elements.iterator`.
  factory ListQueueTest.of(Iterable<E> elements) =>
      ListQueueTest<E>()..addAll(elements);

  // Iterable interface.

  @override
  Queue<R> cast<R>() => Queue.castFrom<E, R>(this);
  @override
  Iterator<E> get iterator => _ListQueueIterator<E>(this);

  @override
  void forEach(void Function(E element) f) {
    var modificationCount = _modificationCount;
    for (var i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
      f(_table[i] as E);
      _checkModification(modificationCount);
    }
  }

  @override
  bool get isEmpty => _head == _tail;

  @override
  int get length => (_tail - _head) & (_table.length - 1);

  @override
  E get first {
    if (_head == _tail) throw IterableElementError.noElement();
    return _table[_head] as E;
  }

  @override
  E get last {
    if (_head == _tail) throw IterableElementError.noElement();
    return _table[(_tail - 1) & (_table.length - 1)] as E;
  }

  @override
  E get single {
    if (_head == _tail) throw IterableElementError.noElement();
    if (length > 1) throw IterableElementError.tooMany();
    return _table[_head] as E;
  }

  @override
  E elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return _table[(_head + index) & (_table.length - 1)] as E;
  }

  @override
  List<E> toList({bool growable = true}) {
    var mask = _table.length - 1;
    var length = (_tail - _head) & mask;
    if (length == 0) return List<E>.empty(growable: growable);

    var list = List<E>.filled(length, first, growable: growable);
    for (var i = 0; i < length; i++) {
      list[i] = _table[(_head + i) & mask] as E;
    }
    return list;
  }

  // Collection interface.

  @override
  void add(E value) {
    _add(value);
  }

  @override
  void addAll(Iterable<E> elements) {
    if (elements is List<E>) {
      var list = elements;
      var addCount = list.length;
      var length = this.length;
      if (length + addCount >= _table.length) {
        _preGrow(length + addCount);
        // After preGrow, all elements are at the start of the list.
        _table.setRange(length, length + addCount, list, 0);
        _tail += addCount;
      } else {
        // Adding addCount elements won't reach _head.
        var endSpace = _table.length - _tail;
        if (addCount < endSpace) {
          _table.setRange(_tail, _tail + addCount, list, 0);
          _tail += addCount;
        } else {
          var preSpace = addCount - endSpace;
          _table.setRange(_tail, _tail + endSpace, list, 0);
          _table.setRange(0, preSpace, list, endSpace);
          _tail = preSpace;
        }
      }
      _modificationCount++;
    } else {
      for (var element in elements) _add(element);
    }
  }

  @override
  bool remove(Object? value) {
    for (var i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
      var element = _table[i];
      if (element == value) {
        _remove(i);
        _modificationCount++;
        return true;
      }
    }
    return false;
  }

  void _filterWhere(bool Function(E element) test, bool removeMatching) {
    var modificationCount = _modificationCount;
    var i = _head;
    while (i != _tail) {
      var element = _table[i] as E;
      var remove = identical(removeMatching, test(element));
      _checkModification(modificationCount);
      if (remove) {
        i = _remove(i);
        modificationCount = ++_modificationCount;
      } else {
        i = (i + 1) & (_table.length - 1);
      }
    }
  }

  /// Remove all elements matched by [test].
  ///
  /// This method is inefficient since it works by repeatedly removing single
  /// elements, each of which can take linear time.
  @override
  void removeWhere(bool Function(E element) test) {
    _filterWhere(test, true);
  }

  /// Remove all elements not matched by [test].
  ///
  /// This method is inefficient since it works by repeatedly removing single
  /// elements, each of which can take linear time.
  @override
  void retainWhere(bool Function(E element) test) {
    _filterWhere(test, false);
  }

  @override
  void clear() {
    if (_head != _tail) {
      for (var i = _head; i != _tail; i = (i + 1) & (_table.length - 1)) {
        _table[i] = null;
      }
      _head = _tail = 0;
      _modificationCount++;
    }
  }

  @override
  String toString() => IterableBase.iterableToFullString(this, '{', '}');

  // Queue interface.

  @override
  void addLast(E value) {
    _add(value);
  }

  @override
  void addFirst(E value) {
    _head = (_head - 1) & (_table.length - 1);
    _table[_head] = value;
    if (_head == _tail) _grow();
    _modificationCount++;
  }

  @override
  E removeFirst() {
    if (_head == _tail) throw IterableElementError.noElement();
    _modificationCount++;
    var result = _table[_head] as E;
    _table[_head] = null;
    _head = (_head + 1) & (_table.length - 1);
    return result;
  }

  @override
  E removeLast() {
    if (_head == _tail) throw IterableElementError.noElement();
    _modificationCount++;
    _tail = (_tail - 1) & (_table.length - 1);
    var result = _table[_tail] as E;
    _table[_tail] = null;
    return result;
  }

  // Internal helper functions.

  /// Whether [number] is a power of two.
  ///
  /// Only works for positive numbers.
  static bool _isPowerOf2(int number) => (number & (number - 1)) == 0;

  /// Rounds [number] up to the nearest power of 2.
  ///
  /// If [number] is a power of 2 already, it is returned.
  ///
  /// Only works for positive numbers.
  static int _nextPowerOf2(int number) {
    assert(number > 0);
    number = (number << 1) - 1;
    for (;;) {
      var nextNumber = number & (number - 1);
      if (nextNumber == 0) return number;
      number = nextNumber;
    }
  }

  /// Check if the queue has been modified during iteration.
  void _checkModification(int expectedModificationCount) {
    if (expectedModificationCount != _modificationCount) {
      throw ConcurrentModificationError(this);
    }
  }

  /// Adds element at end of queue. Used by both [add] and [addAll].
  void _add(E element) {
    _table[_tail] = element;
    _tail = (_tail + 1) & (_table.length - 1);
    if (_head == _tail) _grow();
    _modificationCount++;
  }

  /// Removes the element at [offset] into [_table].
  ///
  /// Removal is performed by linearly moving elements either before or after
  /// [offset] by one position.
  ///
  /// Returns the new offset of the following element. This may be the same
  /// offset or the following offset depending on how elements are moved
  /// to fill the hole.
  int _remove(int offset) {
    var mask = _table.length - 1;
    var startDistance = (offset - _head) & mask;
    var endDistance = (_tail - offset) & mask;
    if (startDistance < endDistance) {
      // Closest to start.
      var i = offset;
      while (i != _head) {
        var prevOffset = (i - 1) & mask;
        _table[i] = _table[prevOffset];
        i = prevOffset;
      }
      _table[_head] = null;
      _head = (_head + 1) & mask;
      return (offset + 1) & mask;
    } else {
      _tail = (_tail - 1) & mask;
      var i = offset;
      while (i != _tail) {
        var nextOffset = (i + 1) & mask;
        _table[i] = _table[nextOffset];
        i = nextOffset;
      }
      _table[_tail] = null;
      return offset;
    }
  }

  /// Grow the table when full.
  void _grow() {
    var newTable = List<E?>.filled(_table.length * 2, null);
    var split = _table.length - _head;
    newTable.setRange(0, split, _table, _head);
    newTable.setRange(split, split + _head, _table, 0);
    _head = 0;
    _tail = _table.length;
    _table = newTable;
  }

  int _writeToList(List<E?> target) {
    assert(target.length >= length);
    if (_head <= _tail) {
      var length = _tail - _head;
      target.setRange(0, length, _table, _head);
      return length;
    } else {
      var firstPartSize = _table.length - _head;
      target.setRange(0, firstPartSize, _table, _head);
      target.setRange(firstPartSize, firstPartSize + _tail, _table, 0);
      return _tail + firstPartSize;
    }
  }

  /// Grows the table even if it is not full.
  void _preGrow(int newElementCount) {
    assert(newElementCount >= length);

    // Add some extra room to ensure that there's room for more elements after
    // expansion.
    newElementCount += newElementCount >> 1;
    var newCapacity = _nextPowerOf2(newElementCount);
    var newTable = List<E?>.filled(newCapacity, null);
    _tail = _writeToList(newTable);
    _table = newTable;
    _head = 0;
  }
}

abstract class IterableElementError {
  /// Error thrown thrown by, e.g., [Iterable.first] when there is no result. */
  static StateError noElement() => StateError('No element');

  /// Error thrown by, e.g., [Iterable.single] if there are too many results. */
  static StateError tooMany() => StateError('Too many elements');

  /// Error thrown by, e.g., [List.setRange] if there are too few elements. */
  static StateError tooFew() => StateError('Too few elements');
}

class _ListQueueIterator<E> implements Iterator<E> {
  final ListQueueTest<E> _queue;
  final int _end;
  final int _modificationCount;
  int _position;
  E? _current;

  _ListQueueIterator(ListQueueTest<E> queue)
      : _queue = queue,
        _end = queue._tail,
        _modificationCount = queue._modificationCount,
        _position = queue._head;

  @override
  E get current => _current as E;

  @override
  bool moveNext() {
    _queue._checkModification(_modificationCount);
    if (_position == _end) {
      _current = null;
      return false;
    }
    _current = _queue._table[_position];
    _position = (_position + 1) & (_queue._table.length - 1);
    return true;
  }
}
