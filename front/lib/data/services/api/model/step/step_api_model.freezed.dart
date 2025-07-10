// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StepApiModel _$StepApiModelFromJson(Map<String, dynamic> json) {
  return _StepApiModel.fromJson(json);
}

/// @nodoc
mixin _$StepApiModel {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;

  /// Serializes this StepApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StepApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StepApiModelCopyWith<StepApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StepApiModelCopyWith<$Res> {
  factory $StepApiModelCopyWith(
          StepApiModel value, $Res Function(StepApiModel) then) =
      _$StepApiModelCopyWithImpl<$Res, StepApiModel>;
  @useResult
  $Res call(
      {String title,
      String description,
      double? latitude,
      double? longitude,
      int order,
      String image,
      String? duration,
      double? cost});
}

/// @nodoc
class _$StepApiModelCopyWithImpl<$Res, $Val extends StepApiModel>
    implements $StepApiModelCopyWith<$Res> {
  _$StepApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StepApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? order = null,
    Object? image = null,
    Object? duration = freezed,
    Object? cost = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StepApiModelImplCopyWith<$Res>
    implements $StepApiModelCopyWith<$Res> {
  factory _$$StepApiModelImplCopyWith(
          _$StepApiModelImpl value, $Res Function(_$StepApiModelImpl) then) =
      __$$StepApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      double? latitude,
      double? longitude,
      int order,
      String image,
      String? duration,
      double? cost});
}

/// @nodoc
class __$$StepApiModelImplCopyWithImpl<$Res>
    extends _$StepApiModelCopyWithImpl<$Res, _$StepApiModelImpl>
    implements _$$StepApiModelImplCopyWith<$Res> {
  __$$StepApiModelImplCopyWithImpl(
      _$StepApiModelImpl _value, $Res Function(_$StepApiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StepApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? order = null,
    Object? image = null,
    Object? duration = freezed,
    Object? cost = freezed,
  }) {
    return _then(_$StepApiModelImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StepApiModelImpl implements _StepApiModel {
  const _$StepApiModelImpl(
      {required this.title,
      required this.description,
      this.latitude,
      this.longitude,
      required this.order,
      required this.image,
      this.duration,
      this.cost});

  factory _$StepApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StepApiModelImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final int order;
  @override
  final String image;
  @override
  final String? duration;
  @override
  final double? cost;

  @override
  String toString() {
    return 'StepApiModel(title: $title, description: $description, latitude: $latitude, longitude: $longitude, order: $order, image: $image, duration: $duration, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StepApiModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, latitude,
      longitude, order, image, duration, cost);

  /// Create a copy of StepApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StepApiModelImplCopyWith<_$StepApiModelImpl> get copyWith =>
      __$$StepApiModelImplCopyWithImpl<_$StepApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StepApiModelImplToJson(
      this,
    );
  }
}

abstract class _StepApiModel implements StepApiModel {
  const factory _StepApiModel(
      {required final String title,
      required final String description,
      final double? latitude,
      final double? longitude,
      required final int order,
      required final String image,
      final String? duration,
      final double? cost}) = _$StepApiModelImpl;

  factory _StepApiModel.fromJson(Map<String, dynamic> json) =
      _$StepApiModelImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int get order;
  @override
  String get image;
  @override
  String? get duration;
  @override
  double? get cost;

  /// Create a copy of StepApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StepApiModelImplCopyWith<_$StepApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
