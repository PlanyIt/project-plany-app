// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentRequestImpl _$$CommentRequestImplFromJson(Map<String, dynamic> json) =>
    _$CommentRequestImpl(
      id: json['_id'] as String?,
      content: json['content'] as String,
      user: json['user'] as String,
      planId: json['planId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      responses: (json['responses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      parentId: json['parentId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$CommentRequestImplToJson(
        _$CommentRequestImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'content': instance.content,
      'user': instance.user,
      'planId': instance.planId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'likes': instance.likes,
      'responses': instance.responses,
      'parentId': instance.parentId,
      'imageUrl': instance.imageUrl,
    };
