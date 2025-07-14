// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommentRequest _$CommentRequestFromJson(Map<String, dynamic> json) {
  return _CommentRequest.fromJson(json);
}

/// @nodoc
mixin _$CommentRequest {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<String>? get likes => throw _privateConstructorUsedError;
  List<String> get responses => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this CommentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentRequestCopyWith<CommentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentRequestCopyWith<$Res> {
  factory $CommentRequestCopyWith(
          CommentRequest value, $Res Function(CommentRequest) then) =
      _$CommentRequestCopyWithImpl<$Res, CommentRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String content,
      String user,
      String planId,
      DateTime? createdAt,
      List<String>? likes,
      List<String> responses,
      String? parentId,
      String? imageUrl});
}

/// @nodoc
class _$CommentRequestCopyWithImpl<$Res, $Val extends CommentRequest>
    implements $CommentRequestCopyWith<$Res> {
  _$CommentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? content = null,
    Object? user = null,
    Object? planId = null,
    Object? createdAt = freezed,
    Object? likes = freezed,
    Object? responses = null,
    Object? parentId = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likes: freezed == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      responses: null == responses
          ? _value.responses
          : responses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentRequestImplCopyWith<$Res>
    implements $CommentRequestCopyWith<$Res> {
  factory _$$CommentRequestImplCopyWith(_$CommentRequestImpl value,
          $Res Function(_$CommentRequestImpl) then) =
      __$$CommentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      String content,
      String user,
      String planId,
      DateTime? createdAt,
      List<String>? likes,
      List<String> responses,
      String? parentId,
      String? imageUrl});
}

/// @nodoc
class __$$CommentRequestImplCopyWithImpl<$Res>
    extends _$CommentRequestCopyWithImpl<$Res, _$CommentRequestImpl>
    implements _$$CommentRequestImplCopyWith<$Res> {
  __$$CommentRequestImplCopyWithImpl(
      _$CommentRequestImpl _value, $Res Function(_$CommentRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? content = null,
    Object? user = null,
    Object? planId = null,
    Object? createdAt = freezed,
    Object? likes = freezed,
    Object? responses = null,
    Object? parentId = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$CommentRequestImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      planId: null == planId
          ? _value.planId
          : planId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likes: freezed == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      responses: null == responses
          ? _value._responses
          : responses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentRequestImpl implements _CommentRequest {
  const _$CommentRequestImpl(
      {@JsonKey(name: '_id') this.id,
      required this.content,
      required this.user,
      required this.planId,
      this.createdAt,
      final List<String>? likes,
      final List<String> responses = const [],
      this.parentId,
      this.imageUrl})
      : _likes = likes,
        _responses = responses;

  factory _$CommentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentRequestImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String content;
  @override
  final String user;
  @override
  final String planId;
  @override
  final DateTime? createdAt;
  final List<String>? _likes;
  @override
  List<String>? get likes {
    final value = _likes;
    if (value == null) return null;
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _responses;
  @override
  @JsonKey()
  List<String> get responses {
    if (_responses is EqualUnmodifiableListView) return _responses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_responses);
  }

  @override
  final String? parentId;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'CommentRequest(id: $id, content: $content, user: $user, planId: $planId, createdAt: $createdAt, likes: $likes, responses: $responses, parentId: $parentId, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality()
                .equals(other._responses, _responses) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      user,
      planId,
      createdAt,
      const DeepCollectionEquality().hash(_likes),
      const DeepCollectionEquality().hash(_responses),
      parentId,
      imageUrl);

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentRequestImplCopyWith<_$CommentRequestImpl> get copyWith =>
      __$$CommentRequestImplCopyWithImpl<_$CommentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentRequestImplToJson(
      this,
    );
  }
}

abstract class _CommentRequest implements CommentRequest {
  const factory _CommentRequest(
      {@JsonKey(name: '_id') final String? id,
      required final String content,
      required final String user,
      required final String planId,
      final DateTime? createdAt,
      final List<String>? likes,
      final List<String> responses,
      final String? parentId,
      final String? imageUrl}) = _$CommentRequestImpl;

  factory _CommentRequest.fromJson(Map<String, dynamic> json) =
      _$CommentRequestImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String get content;
  @override
  String get user;
  @override
  String get planId;
  @override
  DateTime? get createdAt;
  @override
  List<String>? get likes;
  @override
  List<String> get responses;
  @override
  String? get parentId;
  @override
  String? get imageUrl;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentRequestImplCopyWith<_$CommentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
