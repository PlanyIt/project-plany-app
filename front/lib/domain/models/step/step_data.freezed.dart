// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StepData _$StepDataFromJson(Map<String, dynamic> json) {
  return _StepData.fromJson(json);
}

/// @nodoc
mixin _$StepData {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  String? get durationUnit => throw _privateConstructorUsedError;
  double? get cost => throw _privateConstructorUsedError;
  LatLng? get location => throw _privateConstructorUsedError;
  String? get locationName => throw _privateConstructorUsedError;

  /// Serializes this StepData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StepDataCopyWith<StepData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StepDataCopyWith<$Res> {
  factory $StepDataCopyWith(StepData value, $Res Function(StepData) then) =
      _$StepDataCopyWithImpl<$Res, StepData>;
  @useResult
  $Res call(
      {String title,
      String description,
      String imageUrl,
      int? duration,
      String? durationUnit,
      double? cost,
      LatLng? location,
      String? locationName});
}

/// @nodoc
class _$StepDataCopyWithImpl<$Res, $Val extends StepData>
    implements $StepDataCopyWith<$Res> {
  _$StepDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? duration = freezed,
    Object? durationUnit = freezed,
    Object? cost = freezed,
    Object? location = freezed,
    Object? locationName = freezed,
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      durationUnit: freezed == durationUnit
          ? _value.durationUnit
          : durationUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StepDataImplCopyWith<$Res>
    implements $StepDataCopyWith<$Res> {
  factory _$$StepDataImplCopyWith(
          _$StepDataImpl value, $Res Function(_$StepDataImpl) then) =
      __$$StepDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      String imageUrl,
      int? duration,
      String? durationUnit,
      double? cost,
      LatLng? location,
      String? locationName});
}

/// @nodoc
class __$$StepDataImplCopyWithImpl<$Res>
    extends _$StepDataCopyWithImpl<$Res, _$StepDataImpl>
    implements _$$StepDataImplCopyWith<$Res> {
  __$$StepDataImplCopyWithImpl(
      _$StepDataImpl _value, $Res Function(_$StepDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of StepData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? duration = freezed,
    Object? durationUnit = freezed,
    Object? cost = freezed,
    Object? location = freezed,
    Object? locationName = freezed,
  }) {
    return _then(_$StepDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      durationUnit: freezed == durationUnit
          ? _value.durationUnit
          : durationUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StepDataImpl implements _StepData {
  const _$StepDataImpl(
      {required this.title,
      required this.description,
      required this.imageUrl,
      this.duration,
      this.durationUnit,
      this.cost,
      this.location,
      this.locationName});

  factory _$StepDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StepDataImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final int? duration;
  @override
  final String? durationUnit;
  @override
  final double? cost;
  @override
  final LatLng? location;
  @override
  final String? locationName;

  @override
  String toString() {
    return 'StepData(title: $title, description: $description, imageUrl: $imageUrl, duration: $duration, durationUnit: $durationUnit, cost: $cost, location: $location, locationName: $locationName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StepDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.durationUnit, durationUnit) ||
                other.durationUnit == durationUnit) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, description, imageUrl,
      duration, durationUnit, cost, location, locationName);

  /// Create a copy of StepData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StepDataImplCopyWith<_$StepDataImpl> get copyWith =>
      __$$StepDataImplCopyWithImpl<_$StepDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StepDataImplToJson(
      this,
    );
  }
}

abstract class _StepData implements StepData {
  const factory _StepData(
      {required final String title,
      required final String description,
      required final String imageUrl,
      final int? duration,
      final String? durationUnit,
      final double? cost,
      final LatLng? location,
      final String? locationName}) = _$StepDataImpl;

  factory _StepData.fromJson(Map<String, dynamic> json) =
      _$StepDataImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  int? get duration;
  @override
  String? get durationUnit;
  @override
  double? get cost;
  @override
  LatLng? get location;
  @override
  String? get locationName;

  /// Create a copy of StepData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StepDataImplCopyWith<_$StepDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
