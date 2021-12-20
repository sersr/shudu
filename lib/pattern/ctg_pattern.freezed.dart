// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'ctg_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$DataResolveTearOff {
  const _$DataResolveTearOff();

  Data<T> call<T>(T? data, int index) {
    return Data<T>(
      data,
      index,
    );
  }

  Loading<T> loading<T>(T? data, int index) {
    return Loading<T>(
      data,
      index,
    );
  }

  Failed<T> failed<T>(T? data, int index) {
    return Failed<T>(
      data,
      index,
    );
  }

  Done<T> done<T>(T? data, int index) {
    return Done<T>(
      data,
      index,
    );
  }
}

/// @nodoc
const $DataResolve = _$DataResolveTearOff();

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
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
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
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
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
      _$DataResolveCopyWithImpl<T, $Res>;
  $Res call({T? data, int index});
}

/// @nodoc
class _$DataResolveCopyWithImpl<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  _$DataResolveCopyWithImpl(this._value, this._then);

  final DataResolve<T> _value;
  // ignore: unused_field
  final $Res Function(DataResolve<T>) _then;

  @override
  $Res call({
    Object? data = freezed,
    Object? index = freezed,
  }) {
    return _then(_value.copyWith(
      data: data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index: index == freezed
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class $DataCopyWith<T, $Res> implements $DataResolveCopyWith<T, $Res> {
  factory $DataCopyWith(Data<T> value, $Res Function(Data<T>) then) =
      _$DataCopyWithImpl<T, $Res>;
  @override
  $Res call({T? data, int index});
}

/// @nodoc
class _$DataCopyWithImpl<T, $Res> extends _$DataResolveCopyWithImpl<T, $Res>
    implements $DataCopyWith<T, $Res> {
  _$DataCopyWithImpl(Data<T> _value, $Res Function(Data<T>) _then)
      : super(_value, (v) => _then(v as Data<T>));

  @override
  Data<T> get _value => super._value as Data<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? index = freezed,
  }) {
    return _then(Data<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index == freezed
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
            other is Data<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  $DataCopyWith<T, Data<T>> get copyWith =>
      _$DataCopyWithImpl<T, Data<T>>(this, _$identity);

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
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
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
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
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
  const factory Data(T? data, int index) = _$Data<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  $DataCopyWith<T, Data<T>> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoadingCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory $LoadingCopyWith(Loading<T> value, $Res Function(Loading<T>) then) =
      _$LoadingCopyWithImpl<T, $Res>;
  @override
  $Res call({T? data, int index});
}

/// @nodoc
class _$LoadingCopyWithImpl<T, $Res> extends _$DataResolveCopyWithImpl<T, $Res>
    implements $LoadingCopyWith<T, $Res> {
  _$LoadingCopyWithImpl(Loading<T> _value, $Res Function(Loading<T>) _then)
      : super(_value, (v) => _then(v as Loading<T>));

  @override
  Loading<T> get _value => super._value as Loading<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? index = freezed,
  }) {
    return _then(Loading<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index == freezed
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
            other is Loading<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  $LoadingCopyWith<T, Loading<T>> get copyWith =>
      _$LoadingCopyWithImpl<T, Loading<T>>(this, _$identity);

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
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
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
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
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
  const factory Loading(T? data, int index) = _$Loading<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  $LoadingCopyWith<T, Loading<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailedCopyWith<T, $Res>
    implements $DataResolveCopyWith<T, $Res> {
  factory $FailedCopyWith(Failed<T> value, $Res Function(Failed<T>) then) =
      _$FailedCopyWithImpl<T, $Res>;
  @override
  $Res call({T? data, int index});
}

/// @nodoc
class _$FailedCopyWithImpl<T, $Res> extends _$DataResolveCopyWithImpl<T, $Res>
    implements $FailedCopyWith<T, $Res> {
  _$FailedCopyWithImpl(Failed<T> _value, $Res Function(Failed<T>) _then)
      : super(_value, (v) => _then(v as Failed<T>));

  @override
  Failed<T> get _value => super._value as Failed<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? index = freezed,
  }) {
    return _then(Failed<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index == freezed
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
            other is Failed<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  $FailedCopyWith<T, Failed<T>> get copyWith =>
      _$FailedCopyWithImpl<T, Failed<T>>(this, _$identity);

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
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
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
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
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
  const factory Failed(T? data, int index) = _$Failed<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  $FailedCopyWith<T, Failed<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoneCopyWith<T, $Res> implements $DataResolveCopyWith<T, $Res> {
  factory $DoneCopyWith(Done<T> value, $Res Function(Done<T>) then) =
      _$DoneCopyWithImpl<T, $Res>;
  @override
  $Res call({T? data, int index});
}

/// @nodoc
class _$DoneCopyWithImpl<T, $Res> extends _$DataResolveCopyWithImpl<T, $Res>
    implements $DoneCopyWith<T, $Res> {
  _$DoneCopyWithImpl(Done<T> _value, $Res Function(Done<T>) _then)
      : super(_value, (v) => _then(v as Done<T>));

  @override
  Done<T> get _value => super._value as Done<T>;

  @override
  $Res call({
    Object? data = freezed,
    Object? index = freezed,
  }) {
    return _then(Done<T>(
      data == freezed
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      index == freezed
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
            other is Done<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), index);

  @JsonKey(ignore: true)
  @override
  $DoneCopyWith<T, Done<T>> get copyWith =>
      _$DoneCopyWithImpl<T, Done<T>>(this, _$identity);

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
    TResult Function(T? data, int index)? $default, {
    TResult Function(T? data, int index)? loading,
    TResult Function(T? data, int index)? failed,
    TResult Function(T? data, int index)? done,
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
    TResult Function(Data<T> value)? $default, {
    TResult Function(Loading<T> value)? loading,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Done<T> value)? done,
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
  const factory Done(T? data, int index) = _$Done<T>;

  @override
  T? get data;
  @override
  int get index;
  @override
  @JsonKey(ignore: true)
  $DoneCopyWith<T, Done<T>> get copyWith => throw _privateConstructorUsedError;
}
