// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_response_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RegisterResponseApiModel _$RegisterResponseApiModelFromJson(
    Map<String, dynamic> json) {
  return _RegisterResponseApiModel.fromJson(json);
}

/// @nodoc
mixin _$RegisterResponseApiModel {
  /// The user's access token.
  String? get accessToken => throw _privateConstructorUsedError;

  /// The user's refresh token.
  String? get refreshToken => throw _privateConstructorUsedError;

  /// The user ID
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this RegisterResponseApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterResponseApiModelCopyWith<RegisterResponseApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterResponseApiModelCopyWith<$Res> {
  factory $RegisterResponseApiModelCopyWith(RegisterResponseApiModel value,
          $Res Function(RegisterResponseApiModel) then) =
      _$RegisterResponseApiModelCopyWithImpl<$Res, RegisterResponseApiModel>;
  @useResult
  $Res call(
      {String? accessToken,
      String? refreshToken,
      @JsonKey(name: 'user_id') String userId});
}

/// @nodoc
class _$RegisterResponseApiModelCopyWithImpl<$Res,
        $Val extends RegisterResponseApiModel>
    implements $RegisterResponseApiModelCopyWith<$Res> {
  _$RegisterResponseApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterResponseApiModelImplCopyWith<$Res>
    implements $RegisterResponseApiModelCopyWith<$Res> {
  factory _$$RegisterResponseApiModelImplCopyWith(
          _$RegisterResponseApiModelImpl value,
          $Res Function(_$RegisterResponseApiModelImpl) then) =
      __$$RegisterResponseApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? accessToken,
      String? refreshToken,
      @JsonKey(name: 'user_id') String userId});
}

/// @nodoc
class __$$RegisterResponseApiModelImplCopyWithImpl<$Res>
    extends _$RegisterResponseApiModelCopyWithImpl<$Res,
        _$RegisterResponseApiModelImpl>
    implements _$$RegisterResponseApiModelImplCopyWith<$Res> {
  __$$RegisterResponseApiModelImplCopyWithImpl(
      _$RegisterResponseApiModelImpl _value,
      $Res Function(_$RegisterResponseApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? userId = null,
  }) {
    return _then(_$RegisterResponseApiModelImpl(
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
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
class _$RegisterResponseApiModelImpl implements _RegisterResponseApiModel {
  const _$RegisterResponseApiModelImpl(
      {this.accessToken,
      this.refreshToken,
      @JsonKey(name: 'user_id') required this.userId});

  factory _$RegisterResponseApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterResponseApiModelImplFromJson(json);

  /// The user's access token.
  @override
  final String? accessToken;

  /// The user's refresh token.
  @override
  final String? refreshToken;

  /// The user ID
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  String toString() {
    return 'RegisterResponseApiModel(accessToken: $accessToken, refreshToken: $refreshToken, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterResponseApiModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, userId);

  /// Create a copy of RegisterResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterResponseApiModelImplCopyWith<_$RegisterResponseApiModelImpl>
      get copyWith => __$$RegisterResponseApiModelImplCopyWithImpl<
          _$RegisterResponseApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterResponseApiModelImplToJson(
      this,
    );
  }
}

abstract class _RegisterResponseApiModel implements RegisterResponseApiModel {
  const factory _RegisterResponseApiModel(
          {final String? accessToken,
          final String? refreshToken,
          @JsonKey(name: 'user_id') required final String userId}) =
      _$RegisterResponseApiModelImpl;

  factory _RegisterResponseApiModel.fromJson(Map<String, dynamic> json) =
      _$RegisterResponseApiModelImpl.fromJson;

  /// The user's access token.
  @override
  String? get accessToken;

  /// The user's refresh token.
  @override
  String? get refreshToken;

  /// The user ID
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Create a copy of RegisterResponseApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterResponseApiModelImplCopyWith<_$RegisterResponseApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
