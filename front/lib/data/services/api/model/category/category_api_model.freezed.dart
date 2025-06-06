// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CategoryApiModel _$CategoryApiModelFromJson(Map<String, dynamic> json) {
  return _CategoryApiModel.fromJson(json);
}

/// @nodoc
mixin _$CategoryApiModel {
  /// Unique identifier for the category.
  int get id => throw _privateConstructorUsedError;

  /// Name of the category.
  String get name => throw _privateConstructorUsedError;

  /// Icon associated with the category.
  String get icon => throw _privateConstructorUsedError;

  /// Color associated with the category in hex format.
  String get color => throw _privateConstructorUsedError;

  /// Serializes this CategoryApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryApiModelCopyWith<CategoryApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryApiModelCopyWith<$Res> {
  factory $CategoryApiModelCopyWith(
          CategoryApiModel value, $Res Function(CategoryApiModel) then) =
      _$CategoryApiModelCopyWithImpl<$Res, CategoryApiModel>;
  @useResult
  $Res call({int id, String name, String icon, String color});
}

/// @nodoc
class _$CategoryApiModelCopyWithImpl<$Res, $Val extends CategoryApiModel>
    implements $CategoryApiModelCopyWith<$Res> {
  _$CategoryApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryApiModelImplCopyWith<$Res>
    implements $CategoryApiModelCopyWith<$Res> {
  factory _$$CategoryApiModelImplCopyWith(_$CategoryApiModelImpl value,
          $Res Function(_$CategoryApiModelImpl) then) =
      __$$CategoryApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String icon, String color});
}

/// @nodoc
class __$$CategoryApiModelImplCopyWithImpl<$Res>
    extends _$CategoryApiModelCopyWithImpl<$Res, _$CategoryApiModelImpl>
    implements _$$CategoryApiModelImplCopyWith<$Res> {
  __$$CategoryApiModelImplCopyWithImpl(_$CategoryApiModelImpl _value,
      $Res Function(_$CategoryApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_$CategoryApiModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryApiModelImpl implements _CategoryApiModel {
  const _$CategoryApiModelImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color});

  factory _$CategoryApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryApiModelImplFromJson(json);

  /// Unique identifier for the category.
  @override
  final int id;

  /// Name of the category.
  @override
  final String name;

  /// Icon associated with the category.
  @override
  final String icon;

  /// Color associated with the category in hex format.
  @override
  final String color;

  @override
  String toString() {
    return 'CategoryApiModel(id: $id, name: $name, icon: $icon, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryApiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon, color);

  /// Create a copy of CategoryApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryApiModelImplCopyWith<_$CategoryApiModelImpl> get copyWith =>
      __$$CategoryApiModelImplCopyWithImpl<_$CategoryApiModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryApiModelImplToJson(
      this,
    );
  }
}

abstract class _CategoryApiModel implements CategoryApiModel {
  const factory _CategoryApiModel(
      {required final int id,
      required final String name,
      required final String icon,
      required final String color}) = _$CategoryApiModelImpl;

  factory _CategoryApiModel.fromJson(Map<String, dynamic> json) =
      _$CategoryApiModelImpl.fromJson;

  /// Unique identifier for the category.
  @override
  int get id;

  /// Name of the category.
  @override
  String get name;

  /// Icon associated with the category.
  @override
  String get icon;

  /// Color associated with the category in hex format.
  @override
  String get color;

  /// Create a copy of CategoryApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryApiModelImplCopyWith<_$CategoryApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
