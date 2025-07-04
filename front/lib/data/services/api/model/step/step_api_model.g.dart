// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StepApiModelImpl _$$StepApiModelImplFromJson(Map<String, dynamic> json) =>
    _$StepApiModelImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      order: (json['order'] as num).toInt(),
      image: json['image'] as String,
      duration: json['duration'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$StepApiModelImplToJson(_$StepApiModelImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'order': instance.order,
      'image': instance.image,
      'duration': instance.duration,
      'cost': instance.cost,
      'userId': instance.userId,
    };
