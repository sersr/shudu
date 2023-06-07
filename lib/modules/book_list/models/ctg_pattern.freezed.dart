// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ctg_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DataResolve<T> {
  T? get data => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(T? data, int index) $default, {
    required TResult Function(T? data, int index) loading,
    required TResult Function(T? data, int index) failed,
    required TResult Function(T? data, int index) done,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(T? data, int index)? $default, {
    TResult? Function(T? data, int index)? loading,
    TResult? Function(T? data, int index)? failed,
    TResult? Function(T? data, int index)? done,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data<T> value) $default, {
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Done<T> value) done,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data<T> value)? $default, {
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Done<T> value)? done,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DataResolveCopyWith<T, DataResolve<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataResolveCopyWith<T, $Res> {
  factory $DataResolveCopyWith(
          DataResolve<T> value, $Res Function(DataResolve<T>) then) =
      _$DataResolveCopyWithImpl<T, $Res, DataResolve<T>>;
  @useResult
  $Res call({T? data, int index});
}

/// @nodoc
class _$DataResolveCopyWithImpl<T, $Res, $Val extends DataResolve<T>>
    implements $DataResolveCopyWith<T, $Res> {
  _$DataResolveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? index = null,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory _$$DataCopyWith(_$Data<T> value, $Res Function(_$Data<T>) then) =
      __$$DataCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, int index});
}

/// @nodoc
class __$$DataCopyWithImpl<T, $Res>
    extends _$DataResolveCopyWithImpl<T, $Res, _$Data<T>>
    implements _$$DataCopyWith<T, $Res> {
  __$$DataCopyWithImpl(_$Data<T> _value, $Res Function(_$Data<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? index = null,
  }) {
    return _then(_$Data<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$Data<T> with DiagnosticableTreeMixin implements Data<T> {
  const _$Data(this.data, this.index);

  @override
  final T? data;
  @override
  final int index;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DataResolve<$T>(data: $data, index: $index)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DataResolve<$T>'))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('index', index));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Data<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataCopyWith<T, _$Data<T>> get copyWith =>
      __$$DataCopyWithImpl<T, _$Data<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(T? data, int index) $default, {
    required TResult Function(T? data, int index) loading,
    required TResult Function(T? data, int index) failed,
    required TResult Function(T? data, int index) done,
  }) {
    return $default(data, index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(T? data, int index)? $default, {
    TResult? Function(T? data, int index)? loading,
    TResult? Function(T? data, int index)? failed,
    TResult? Function(T? data, int index)? done,
  }) {
    return $default?.call(data, index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(data, index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data<T> value) $default, {
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Done<T> value) done,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data<T> value)? $default, {
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Done<T> value)? done,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class Data<T> implements DataResolve<T> {
  const factory Data(final T? data, final int index) = _$Data<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  _$$DataCopyWith<T, _$Data<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadingCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory _$$LoadingCopyWith(
          _$Loading<T> value, $Res Function(_$Loading<T>) then) =
      __$$LoadingCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, int index});
}

/// @nodoc
class __$$LoadingCopyWithImpl<T, $Res>
    extends _$DataResolveCopyWithImpl<T, $Res, _$Loading<T>>
    implements _$$LoadingCopyWith<T, $Res> {
  __$$LoadingCopyWithImpl(
      _$Loading<T> _value, $Res Function(_$Loading<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? index = null,
  }) {
    return _then(_$Loading<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$Loading<T> with DiagnosticableTreeMixin implements Loading<T> {
  const _$Loading(this.data, this.index);

  @override
  final T? data;
  @override
  final int index;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DataResolve<$T>.loading(data: $data, index: $index)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DataResolve<$T>.loading'))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('index', index));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Loading<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingCopyWith<T, _$Loading<T>> get copyWith =>
      __$$LoadingCopyWithImpl<T, _$Loading<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(T? data, int index) $default, {
    required TResult Function(T? data, int index) loading,
    required TResult Function(T? data, int index) failed,
    required TResult Function(T? data, int index) done,
  }) {
    return loading(data, index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(T? data, int index)? $default, {
    TResult? Function(T? data, int index)? loading,
    TResult? Function(T? data, int index)? failed,
    TResult? Function(T? data, int index)? done,
  }) {
    return loading?.call(data, index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(data, index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data<T> value) $default, {
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Done<T> value) done,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data<T> value)? $default, {
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Done<T> value)? done,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class Loading<T> implements DataResolve<T> {
  const factory Loading(final T? data, final int index) = _$Loading<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  _$$LoadingCopyWith<T, _$Loading<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailedCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory _$$FailedCopyWith(
          _$Failed<T> value, $Res Function(_$Failed<T>) then) =
      __$$FailedCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, int index});
}

/// @nodoc
class __$$FailedCopyWithImpl<T, $Res>
    extends _$DataResolveCopyWithImpl<T, $Res, _$Failed<T>>
    implements _$$FailedCopyWith<T, $Res> {
  __$$FailedCopyWithImpl(_$Failed<T> _value, $Res Function(_$Failed<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? index = null,
  }) {
    return _then(_$Failed<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$Failed<T> with DiagnosticableTreeMixin implements Failed<T> {
  const _$Failed(this.data, this.index);

  @override
  final T? data;
  @override
  final int index;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DataResolve<$T>.failed(data: $data, index: $index)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DataResolve<$T>.failed'))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('index', index));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Failed<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailedCopyWith<T, _$Failed<T>> get copyWith =>
      __$$FailedCopyWithImpl<T, _$Failed<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(T? data, int index) $default, {
    required TResult Function(T? data, int index) loading,
    required TResult Function(T? data, int index) failed,
    required TResult Function(T? data, int index) done,
  }) {
    return failed(data, index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(T? data, int index)? $default, {
    TResult? Function(T? data, int index)? loading,
    TResult? Function(T? data, int index)? failed,
    TResult? Function(T? data, int index)? done,
  }) {
    return failed?.call(data, index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(data, index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data<T> value) $default, {
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Done<T> value) done,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data<T> value)? $default, {
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Done<T> value)? done,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class Failed<T> implements DataResolve<T> {
  const factory Failed(final T? data, final int index) = _$Failed<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  _$$FailedCopyWith<T, _$Failed<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DoneCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory _$$DoneCopyWith(_$Done<T> value, $Res Function(_$Done<T>) then) =
      __$$DoneCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, int index});
}

/// @nodoc
class __$$DoneCopyWithImpl<T, $Res>
    extends _$DataResolveCopyWithImpl<T, $Res, _$Done<T>>
    implements _$$DoneCopyWith<T, $Res> {
  __$$DoneCopyWithImpl(_$Done<T> _value, $Res Function(_$Done<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? index = null,
  }) {
    return _then(_$Done<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$Done<T> with DiagnosticableTreeMixin implements Done<T> {
  const _$Done(this.data, this.index);

  @override
  final T? data;
  @override
  final int index;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DataResolve<$T>.done(data: $data, index: $index)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DataResolve<$T>.done'))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('index', index));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Done<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DoneCopyWith<T, _$Done<T>> get copyWith =>
      __$$DoneCopyWithImpl<T, _$Done<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(T? data, int index) $default, {
    required TResult Function(T? data, int index) loading,
    required TResult Function(T? data, int index) failed,
    required TResult Function(T? data, int index) done,
  }) {
    return done(data, index);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(T? data, int index)? $default, {
    TResult? Function(T? data, int index)? loading,
    TResult? Function(T? data, int index)? failed,
    TResult? Function(T? data, int index)? done,
  }) {
    return done?.call(data, index);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(data, index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(Data<T> value) $default, {
    required TResult Function(Loading<T> value) loading,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Done<T> value) done,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(Data<T> value)? $default, {
    TResult? Function(Loading<T> value)? loading,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Done<T> value)? done,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class Done<T> implements DataResolve<T> {
  const factory Done(final T? data, final int index) = _$Done<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  _$$DoneCopyWith<T, _$Done<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
