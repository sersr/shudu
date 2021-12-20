// main.dart
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ctg_pattern.freezed.dart';

@freezed
class DataResolve<T> with _$DataResolve<T> {
  const factory DataResolve(T? data, int index) = Data<T>;
  const factory DataResolve.loading(T? data, int index) = Loading<T>;
  const factory DataResolve.failed(T? data, int index) = Failed<T>;
  const factory DataResolve.done(T? data, int index) = Done<T>;
}
