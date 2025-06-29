// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_request_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginRequestApiModel _$LoginRequestApiModelFromJson(Map<String, dynamic> json) {
  return _LoginRequestApiModel.fromJson(json);
}

/// @nodoc
mixin _$LoginRequestApiModel {
  /// Email address.
  String get email => throw _privateConstructorUsedError;

  /// Plain text password.
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequestApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestApiModelCopyWith<LoginRequestApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestApiModelCopyWith<$Res> {
  factory $LoginRequestApiModelCopyWith(LoginRequestApiModel value,
          $Res Function(LoginRequestApiModel) then) =
      _$LoginRequestApiModelCopyWithImpl<$Res, LoginRequestApiModel>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestApiModelCopyWithImpl<$Res,
        $Val extends LoginRequestApiModel>
    implements $LoginRequestApiModelCopyWith<$Res> {
  _$LoginRequestApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestApiModelImplCopyWith<$Res>
    implements $LoginRequestApiModelCopyWith<$Res> {
  factory _$$LoginRequestApiModelImplCopyWith(_$LoginRequestApiModelImpl value,
          $Res Function(_$LoginRequestApiModelImpl) then) =
      __$$LoginRequestApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestApiModelImplCopyWithImpl<$Res>
    extends _$LoginRequestApiModelCopyWithImpl<$Res, _$LoginRequestApiModelImpl>
    implements _$$LoginRequestApiModelImplCopyWith<$Res> {
  __$$LoginRequestApiModelImplCopyWithImpl(_$LoginRequestApiModelImpl _value,
      $Res Function(_$LoginRequestApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginRequestApiModelImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestApiModelImpl implements _LoginRequestApiModel {
  const _$LoginRequestApiModelImpl(
      {required this.email, required this.password});

  factory _$LoginRequestApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestApiModelImplFromJson(json);

  /// Email address.
  @override
  final String email;

  /// Plain text password.
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequestApiModel(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestApiModelImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  /// Create a copy of LoginRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestApiModelImplCopyWith<_$LoginRequestApiModelImpl>
      get copyWith =>
          __$$LoginRequestApiModelImplCopyWithImpl<_$LoginRequestApiModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestApiModelImplToJson(
      this,
    );
  }
}

abstract class _LoginRequestApiModel implements LoginRequestApiModel {
  const factory _LoginRequestApiModel(
      {required final String email,
      required final String password}) = _$LoginRequestApiModelImpl;

  factory _LoginRequestApiModel.fromJson(Map<String, dynamic> json) =
      _$LoginRequestApiModelImpl.fromJson;

  /// Email address.
  @override
  String get email;

  /// Plain text password.
  @override
  String get password;

  /// Create a copy of LoginRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestApiModelImplCopyWith<_$LoginRequestApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
