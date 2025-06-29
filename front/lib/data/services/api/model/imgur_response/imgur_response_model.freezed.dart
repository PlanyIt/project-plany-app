// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imgur_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImgurResponseModel _$ImgurResponseModelFromJson(Map<String, dynamic> json) {
  return _ImgurResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ImgurResponseModel {
  String get link => throw _privateConstructorUsedError;

  /// Serializes this ImgurResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImgurResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImgurResponseModelCopyWith<ImgurResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImgurResponseModelCopyWith<$Res> {
  factory $ImgurResponseModelCopyWith(
          ImgurResponseModel value, $Res Function(ImgurResponseModel) then) =
      _$ImgurResponseModelCopyWithImpl<$Res, ImgurResponseModel>;
  @useResult
  $Res call({String link});
}

/// @nodoc
class _$ImgurResponseModelCopyWithImpl<$Res, $Val extends ImgurResponseModel>
    implements $ImgurResponseModelCopyWith<$Res> {
  _$ImgurResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImgurResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = null,
  }) {
    return _then(_value.copyWith(
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImgurResponseModelImplCopyWith<$Res>
    implements $ImgurResponseModelCopyWith<$Res> {
  factory _$$ImgurResponseModelImplCopyWith(_$ImgurResponseModelImpl value,
          $Res Function(_$ImgurResponseModelImpl) then) =
      __$$ImgurResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String link});
}

/// @nodoc
class __$$ImgurResponseModelImplCopyWithImpl<$Res>
    extends _$ImgurResponseModelCopyWithImpl<$Res, _$ImgurResponseModelImpl>
    implements _$$ImgurResponseModelImplCopyWith<$Res> {
  __$$ImgurResponseModelImplCopyWithImpl(_$ImgurResponseModelImpl _value,
      $Res Function(_$ImgurResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImgurResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = null,
  }) {
    return _then(_$ImgurResponseModelImpl(
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImgurResponseModelImpl implements _ImgurResponseModel {
  const _$ImgurResponseModelImpl({required this.link});

  factory _$ImgurResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImgurResponseModelImplFromJson(json);

  @override
  final String link;

  @override
  String toString() {
    return 'ImgurResponseModel(link: $link)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImgurResponseModelImpl &&
            (identical(other.link, link) || other.link == link));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, link);

  /// Create a copy of ImgurResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImgurResponseModelImplCopyWith<_$ImgurResponseModelImpl> get copyWith =>
      __$$ImgurResponseModelImplCopyWithImpl<_$ImgurResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImgurResponseModelImplToJson(
      this,
    );
  }
}

abstract class _ImgurResponseModel implements ImgurResponseModel {
  const factory _ImgurResponseModel({required final String link}) =
      _$ImgurResponseModelImpl;

  factory _ImgurResponseModel.fromJson(Map<String, dynamic> json) =
      _$ImgurResponseModelImpl.fromJson;

  @override
  String get link;

  /// Create a copy of ImgurResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImgurResponseModelImplCopyWith<_$ImgurResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
