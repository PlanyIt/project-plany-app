// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['_id'] as String?,
      content: json['content'] as String,
      userId: json['userId'] as String?,
      planId: json['planId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      responses: (json['responses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      parentId: json['parentId'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'content': instance.content,
      'userId': instance.userId,
      'planId': instance.planId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'likes': instance.likes,
      'responses': instance.responses,
      'parentId': instance.parentId,
      'imageUrl': instance.imageUrl,
    };
