// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Plan _$PlanFromJson(Map<String, dynamic> json) {
  return _Plan.fromJson(json);
}

/// @nodoc
mixin _$Plan {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get steps => throw _privateConstructorUsedError;
  List<String>? get favorites => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  double? get estimatedCost => throw _privateConstructorUsedError;

  /// Serializes this Plan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanCopyWith<Plan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanCopyWith<$Res> {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) then) =
      _$PlanCopyWithImpl<$Res, Plan>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String title,
      String description,
      String category,
      String? userId,
      bool isPublic,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<String> steps,
      List<String>? favorites,
      bool isFavorite,
      double? estimatedCost});
}

/// @nodoc
class _$PlanCopyWithImpl<$Res, $Val extends Plan>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? userId = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? steps = null,
    Object? favorites = freezed,
    Object? isFavorite = null,
    Object? estimatedCost = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favorites: freezed == favorites
          ? _value.favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlanImplCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$$PlanImplCopyWith(
          _$PlanImpl value, $Res Function(_$PlanImpl) then) =
      __$$PlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String title,
      String description,
      String category,
      String? userId,
      bool isPublic,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<String> steps,
      List<String>? favorites,
      bool isFavorite,
      double? estimatedCost});
}

/// @nodoc
class __$$PlanImplCopyWithImpl<$Res>
    extends _$PlanCopyWithImpl<$Res, _$PlanImpl>
    implements _$$PlanImplCopyWith<$Res> {
  __$$PlanImplCopyWithImpl(_$PlanImpl _value, $Res Function(_$PlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? userId = freezed,
    Object? isPublic = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? steps = null,
    Object? favorites = freezed,
    Object? isFavorite = null,
    Object? estimatedCost = freezed,
  }) {
    return _then(_$PlanImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favorites: freezed == favorites
          ? _value._favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanImpl implements _Plan {
  const _$PlanImpl(
      {@JsonKey(name: '_id') this.id,
      required this.title,
      required this.description,
      required this.category,
      this.userId,
      this.isPublic = true,
      this.createdAt,
      this.updatedAt,
      required final List<String> steps,
      final List<String>? favorites,
      this.isFavorite = false,
      this.estimatedCost})
      : _steps = steps,
        _favorites = favorites;

  factory _$PlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final String? userId;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final List<String> _steps;
  @override
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  final List<String>? _favorites;
  @override
  List<String>? get favorites {
    final value = _favorites;
    if (value == null) return null;
    if (_favorites is EqualUnmodifiableListView) return _favorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final double? estimatedCost;

  @override
  String toString() {
    return 'Plan(id: $id, title: $title, description: $description, category: $category, userId: $userId, isPublic: $isPublic, createdAt: $createdAt, updatedAt: $updatedAt, steps: $steps, favorites: $favorites, isFavorite: $isFavorite, estimatedCost: $estimatedCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality()
                .equals(other._favorites, _favorites) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      userId,
      isPublic,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_steps),
      const DeepCollectionEquality().hash(_favorites),
      isFavorite,
      estimatedCost);

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanImplCopyWith<_$PlanImpl> get copyWith =>
      __$$PlanImplCopyWithImpl<_$PlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanImplToJson(
      this,
    );
  }
}

abstract class _Plan implements Plan {
  const factory _Plan(
      {@JsonKey(name: '_id') final String? id,
      required final String title,
      required final String description,
      required final String category,
      final String? userId,
      final bool isPublic,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      required final List<String> steps,
      final List<String>? favorites,
      final bool isFavorite,
      final double? estimatedCost}) = _$PlanImpl;

  factory _Plan.fromJson(Map<String, dynamic> json) = _$PlanImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  String? get userId;
  @override
  bool get isPublic;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  List<String> get steps;
  @override
  List<String>? get favorites;
  @override
  bool get isFavorite;
  @override
  double? get estimatedCost;

  /// Create a copy of Plan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanImplCopyWith<_$PlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
