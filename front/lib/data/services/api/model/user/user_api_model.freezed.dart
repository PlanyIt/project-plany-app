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
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  String? get profilePicture => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  List<String> get followers => throw _privateConstructorUsedError;
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
      String? profilePicture,
      DateTime? birthDate,
      String? gender,
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
    Object? profilePicture = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
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
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String? profilePicture,
      DateTime? birthDate,
      String? gender,
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
    Object? profilePicture = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
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
      profilePicture: freezed == profilePicture
          ? _value.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.profilePicture,
      this.birthDate,
      this.gender,
      final List<String> followers = const [],
      final List<String> following = const []})
      : _followers = followers,
        _following = following;

  factory _$UserApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserApiModelImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String email;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  final String? profilePicture;
  @override
  final DateTime? birthDate;
  @override
  final String? gender;
  final List<String> _followers;
  @override
  @JsonKey()
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  final List<String> _following;
  @override
  @JsonKey()
  List<String> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  @override
  String toString() {
    return 'UserApiModel(id: $id, username: $username, email: $email, description: $description, isPremium: $isPremium, profilePicture: $profilePicture, birthDate: $birthDate, gender: $gender, followers: $followers, following: $following)';
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
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.gender, gender) || other.gender == gender) &&
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
      profilePicture,
      birthDate,
      gender,
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
      final String? profilePicture,
      final DateTime? birthDate,
      final String? gender,
      final List<String> followers,
      final List<String> following}) = _$UserApiModelImpl;

  factory _UserApiModel.fromJson(Map<String, dynamic> json) =
      _$UserApiModelImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String get email;
  @override
  String? get description;
  @override
  bool get isPremium;
  @override
  String? get profilePicture;
  @override
  DateTime? get birthDate;
  @override
  String? get gender;
  @override
  List<String> get followers;
  @override
  List<String> get following;

  /// Create a copy of UserApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserApiModelImplCopyWith<_$UserApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
