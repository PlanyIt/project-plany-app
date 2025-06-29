// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoginResponseApiModel _$LoginResponseApiModelFromJson(
    Map<String, dynamic> json) {
  return _LoginResponseApiModel.fromJson(json);
}

/// @nodoc
mixin _$LoginResponseApiModel {
  String? get accessToken => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'token')
  String? get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this LoginResponseApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseApiModelCopyWith<LoginResponseApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseApiModelCopyWith<$Res> {
  factory $LoginResponseApiModelCopyWith(LoginResponseApiModel value,
          $Res Function(LoginResponseApiModel) then) =
      _$LoginResponseApiModelCopyWithImpl<$Res, LoginResponseApiModel>;
  @useResult
  $Res call(
      {String? accessToken,
      String? refreshToken,
      @JsonKey(name: 'token') String? token,
      @JsonKey(name: 'user_id') String userId});
}

/// @nodoc
class _$LoginResponseApiModelCopyWithImpl<$Res,
        $Val extends LoginResponseApiModel>
    implements $LoginResponseApiModelCopyWith<$Res> {
  _$LoginResponseApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? token = freezed,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginResponseApiModelImplCopyWith<$Res>
    implements $LoginResponseApiModelCopyWith<$Res> {
  factory _$$LoginResponseApiModelImplCopyWith(
          _$LoginResponseApiModelImpl value,
          $Res Function(_$LoginResponseApiModelImpl) then) =
      __$$LoginResponseApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? accessToken,
      String? refreshToken,
      @JsonKey(name: 'token') String? token,
      @JsonKey(name: 'user_id') String userId});
}

/// @nodoc
class __$$LoginResponseApiModelImplCopyWithImpl<$Res>
    extends _$LoginResponseApiModelCopyWithImpl<$Res,
        _$LoginResponseApiModelImpl>
    implements _$$LoginResponseApiModelImplCopyWith<$Res> {
  __$$LoginResponseApiModelImplCopyWithImpl(_$LoginResponseApiModelImpl _value,
      $Res Function(_$LoginResponseApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoginResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? token = freezed,
    Object? userId = null,
  }) {
    return _then(_$LoginResponseApiModelImpl(
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseApiModelImpl implements _LoginResponseApiModel {
  const _$LoginResponseApiModelImpl(
      {this.accessToken,
      this.refreshToken,
      @JsonKey(name: 'token') this.token,
      @JsonKey(name: 'user_id') required this.userId});

  factory _$LoginResponseApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseApiModelImplFromJson(json);

  @override
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  @JsonKey(name: 'token')
  final String? token;
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  String toString() {
    return 'LoginResponseApiModel(accessToken: $accessToken, refreshToken: $refreshToken, token: $token, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseApiModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, token, userId);

  /// Create a copy of LoginResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseApiModelImplCopyWith<_$LoginResponseApiModelImpl>
      get copyWith => __$$LoginResponseApiModelImplCopyWithImpl<
          _$LoginResponseApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseApiModelImplToJson(
      this,
    );
  }
}

abstract class _LoginResponseApiModel implements LoginResponseApiModel {
  const factory _LoginResponseApiModel(
          {final String? accessToken,
          final String? refreshToken,
          @JsonKey(name: 'token') final String? token,
          @JsonKey(name: 'user_id') required final String userId}) =
      _$LoginResponseApiModelImpl;

  factory _LoginResponseApiModel.fromJson(Map<String, dynamic> json) =
      _$LoginResponseApiModelImpl.fromJson;

  @override
  String? get accessToken;
  @override
  String? get refreshToken;
  @override
  @JsonKey(name: 'token')
  String? get token;
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Create a copy of LoginResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseApiModelImplCopyWith<_$LoginResponseApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
