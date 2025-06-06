// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserApiModel _$UserApiModelFromJson(Map<String, dynamic> json) {
  return _UserApiModel.fromJson(json);
}

/// @nodoc
mixin _$UserApiModel {
  /// The user's ID.
  String get id => throw _privateConstructorUsedError;

  /// The user's username.
  String get username => throw _privateConstructorUsedError;

  /// The user's email.
  String get email => throw _privateConstructorUsedError;

  /// The user's description.
  String? get description => throw _privateConstructorUsedError;

  /// Whether the user has premium status.
  bool get isPremium => throw _privateConstructorUsedError;

  /// The user's photo URL.
  String? get photoUrl => throw _privateConstructorUsedError;

  /// The user's birth date.
  DateTime? get birthDate => throw _privateConstructorUsedError;

  /// The user's gender.
  String? get gender => throw _privateConstructorUsedError;

  /// The user's role.
  String get role => throw _privateConstructorUsedError;

  /// Whether the user is active.
  bool get isActive => throw _privateConstructorUsedError;

  /// The user's registration date.
  DateTime get registrationDate => throw _privateConstructorUsedError;

  /// List of user IDs who follow this user.
  List<String> get followers => throw _privateConstructorUsedError;

  /// List of user IDs this user follows.
  List<String> get following => throw _privateConstructorUsedError;

  /// Serializes this UserApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserApiModelCopyWith<UserApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserApiModelCopyWith<$Res> {
  factory $UserApiModelCopyWith(
          UserApiModel value, $Res Function(UserApiModel) then) =
      _$UserApiModelCopyWithImpl<$Res, UserApiModel>;
  @useResult
  $Res call(
      {String id,
      String username,
      String email,
      String? description,
      bool isPremium,
      String? photoUrl,
      DateTime? birthDate,
      String? gender,
      String role,
      bool isActive,
      DateTime registrationDate,
      List<String> followers,
      List<String> following});
}

/// @nodoc
class _$UserApiModelCopyWithImpl<$Res, $Val extends UserApiModel>
    implements $UserApiModelCopyWith<$Res> {
  _$UserApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = null,
    Object? description = freezed,
    Object? isPremium = null,
    Object? photoUrl = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
    Object? role = null,
    Object? isActive = null,
    Object? registrationDate = null,
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationDate: null == registrationDate
          ? _value.registrationDate
          : registrationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserApiModelImplCopyWith<$Res>
    implements $UserApiModelCopyWith<$Res> {
  factory _$$UserApiModelImplCopyWith(
          _$UserApiModelImpl value, $Res Function(_$UserApiModelImpl) then) =
      __$$UserApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      String email,
      String? description,
      bool isPremium,
      String? photoUrl,
      DateTime? birthDate,
      String? gender,
      String role,
      bool isActive,
      DateTime registrationDate,
      List<String> followers,
      List<String> following});
}

/// @nodoc
class __$$UserApiModelImplCopyWithImpl<$Res>
    extends _$UserApiModelCopyWithImpl<$Res, _$UserApiModelImpl>
    implements _$$UserApiModelImplCopyWith<$Res> {
  __$$UserApiModelImplCopyWithImpl(
      _$UserApiModelImpl _value, $Res Function(_$UserApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = null,
    Object? description = freezed,
    Object? isPremium = null,
    Object? photoUrl = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
    Object? role = null,
    Object? isActive = null,
    Object? registrationDate = null,
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_$UserApiModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      registrationDate: null == registrationDate
          ? _value.registrationDate
          : registrationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      followers: null == followers
          ? _value._followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _value._following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserApiModelImpl implements _UserApiModel {
  const _$UserApiModelImpl(
      {required this.id,
      required this.username,
      required this.email,
      this.description,
      this.isPremium = false,
      this.photoUrl,
      this.birthDate,
      this.gender,
      this.role = 'user',
      this.isActive = true,
      required this.registrationDate,
      final List<String> followers = const [],
      final List<String> following = const []})
      : _followers = followers,
        _following = following;

  factory _$UserApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserApiModelImplFromJson(json);

  /// The user's ID.
  @override
  final String id;

  /// The user's username.
  @override
  final String username;

  /// The user's email.
  @override
  final String email;

  /// The user's description.
  @override
  final String? description;

  /// Whether the user has premium status.
  @override
  @JsonKey()
  final bool isPremium;

  /// The user's photo URL.
  @override
  final String? photoUrl;

  /// The user's birth date.
  @override
  final DateTime? birthDate;

  /// The user's gender.
  @override
  final String? gender;

  /// The user's role.
  @override
  @JsonKey()
  final String role;

  /// Whether the user is active.
  @override
  @JsonKey()
  final bool isActive;

  /// The user's registration date.
  @override
  final DateTime registrationDate;

  /// List of user IDs who follow this user.
  final List<String> _followers;

  /// List of user IDs who follow this user.
  @override
  @JsonKey()
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  /// List of user IDs this user follows.
  final List<String> _following;

  /// List of user IDs this user follows.
  @override
  @JsonKey()
  List<String> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  @override
  String toString() {
    return 'UserApiModel(id: $id, username: $username, email: $email, description: $description, isPremium: $isPremium, photoUrl: $photoUrl, birthDate: $birthDate, gender: $gender, role: $role, isActive: $isActive, registrationDate: $registrationDate, followers: $followers, following: $following)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserApiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.registrationDate, registrationDate) ||
                other.registrationDate == registrationDate) &&
            const DeepCollectionEquality()
                .equals(other._followers, _followers) &&
            const DeepCollectionEquality()
                .equals(other._following, _following));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      username,
      email,
      description,
      isPremium,
      photoUrl,
      birthDate,
      gender,
      role,
      isActive,
      registrationDate,
      const DeepCollectionEquality().hash(_followers),
      const DeepCollectionEquality().hash(_following));

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserApiModelImplCopyWith<_$UserApiModelImpl> get copyWith =>
      __$$UserApiModelImplCopyWithImpl<_$UserApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserApiModelImplToJson(
      this,
    );
  }
}

abstract class _UserApiModel implements UserApiModel {
  const factory _UserApiModel(
      {required final String id,
      required final String username,
      required final String email,
      final String? description,
      final bool isPremium,
      final String? photoUrl,
      final DateTime? birthDate,
      final String? gender,
      final String role,
      final bool isActive,
      required final DateTime registrationDate,
      final List<String> followers,
      final List<String> following}) = _$UserApiModelImpl;

  factory _UserApiModel.fromJson(Map<String, dynamic> json) =
      _$UserApiModelImpl.fromJson;

  /// The user's ID.
  @override
  String get id;

  /// The user's username.
  @override
  String get username;

  /// The user's email.
  @override
  String get email;

  /// The user's description.
  @override
  String? get description;

  /// Whether the user has premium status.
  @override
  bool get isPremium;

  /// The user's photo URL.
  @override
  String? get photoUrl;

  /// The user's birth date.
  @override
  DateTime? get birthDate;

  /// The user's gender.
  @override
  String? get gender;

  /// The user's role.
  @override
  String get role;

  /// Whether the user is active.
  @override
  bool get isActive;

  /// The user's registration date.
  @override
  DateTime get registrationDate;

  /// List of user IDs who follow this user.
  @override
  List<String> get followers;

  /// List of user IDs this user follows.
  @override
  List<String> get following;

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserApiModelImplCopyWith<_$UserApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
