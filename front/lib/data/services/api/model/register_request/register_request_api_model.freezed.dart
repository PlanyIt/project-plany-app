// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RegisterRequestApiModel _$RegisterRequestApiModelFromJson(
    Map<String, dynamic> json) {
  return _RegisterRequestApiModel.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequestApiModel {
  /// The user's username.
  String get username => throw _privateConstructorUsedError;

  /// The user's email.
  String get email => throw _privateConstructorUsedError;

  /// The user's password.
  String get password => throw _privateConstructorUsedError;

  /// The user's description.
  String? get description => throw _privateConstructorUsedError;

  /// The user's profile picture URL.
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequestApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestApiModelCopyWith<RegisterRequestApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestApiModelCopyWith<$Res> {
  factory $RegisterRequestApiModelCopyWith(RegisterRequestApiModel value,
          $Res Function(RegisterRequestApiModel) then) =
      _$RegisterRequestApiModelCopyWithImpl<$Res, RegisterRequestApiModel>;
  @useResult
  $Res call(
      {String username,
      String email,
      String password,
      String? description,
      String? photoUrl});
}

/// @nodoc
class _$RegisterRequestApiModelCopyWithImpl<$Res,
        $Val extends RegisterRequestApiModel>
    implements $RegisterRequestApiModelCopyWith<$Res> {
  _$RegisterRequestApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
    Object? description = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterRequestApiModelImplCopyWith<$Res>
    implements $RegisterRequestApiModelCopyWith<$Res> {
  factory _$$RegisterRequestApiModelImplCopyWith(
          _$RegisterRequestApiModelImpl value,
          $Res Function(_$RegisterRequestApiModelImpl) then) =
      __$$RegisterRequestApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String username,
      String email,
      String password,
      String? description,
      String? photoUrl});
}

/// @nodoc
class __$$RegisterRequestApiModelImplCopyWithImpl<$Res>
    extends _$RegisterRequestApiModelCopyWithImpl<$Res,
        _$RegisterRequestApiModelImpl>
    implements _$$RegisterRequestApiModelImplCopyWith<$Res> {
  __$$RegisterRequestApiModelImplCopyWithImpl(
      _$RegisterRequestApiModelImpl _value,
      $Res Function(_$RegisterRequestApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
    Object? description = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(_$RegisterRequestApiModelImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestApiModelImpl implements _RegisterRequestApiModel {
  const _$RegisterRequestApiModelImpl(
      {required this.username,
      required this.email,
      required this.password,
      this.description,
      this.photoUrl});

  factory _$RegisterRequestApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestApiModelImplFromJson(json);

  /// The user's username.
  @override
  final String username;

  /// The user's email.
  @override
  final String email;

  /// The user's password.
  @override
  final String password;

  /// The user's description.
  @override
  final String? description;

  /// The user's profile picture URL.
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'RegisterRequestApiModel(username: $username, email: $email, password: $password, description: $description, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestApiModelImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, username, email, password, description, photoUrl);

  /// Create a copy of RegisterRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestApiModelImplCopyWith<_$RegisterRequestApiModelImpl>
      get copyWith => __$$RegisterRequestApiModelImplCopyWithImpl<
          _$RegisterRequestApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestApiModelImplToJson(
      this,
    );
  }
}

abstract class _RegisterRequestApiModel implements RegisterRequestApiModel {
  const factory _RegisterRequestApiModel(
      {required final String username,
      required final String email,
      required final String password,
      final String? description,
      final String? photoUrl}) = _$RegisterRequestApiModelImpl;

  factory _RegisterRequestApiModel.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestApiModelImpl.fromJson;

  /// The user's username.
  @override
  String get username;

  /// The user's email.
  @override
  String get email;

  /// The user's password.
  @override
  String get password;

  /// The user's description.
  @override
  String? get description;

  /// The user's profile picture URL.
  @override
  String? get photoUrl;

  /// Create a copy of RegisterRequestApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestApiModelImplCopyWith<_$RegisterRequestApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
