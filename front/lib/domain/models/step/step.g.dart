// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StepImpl _$$StepImplFromJson(Map<String, dynamic> json) => _$StepImpl(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      position: json['position'] == null
          ? null
          : LatLng.fromJson(json['position'] as Map<String, dynamic>),
      order: (json['order'] as num).toInt(),
      image: json['image'] as String,
      duration: json['duration'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$StepImplToJson(_$StepImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
      'order': instance.order,
      'image': instance.image,
      'duration': instance.duration,
      'cost': instance.cost,
      'createdAt': instance.createdAt?.toIso8601String(),
      'userId': instance.userId,
    };
