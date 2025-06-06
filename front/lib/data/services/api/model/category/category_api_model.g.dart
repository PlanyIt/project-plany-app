// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryApiModelImpl _$$CategoryApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CategoryApiModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );

Map<String, dynamic> _$$CategoryApiModelImplToJson(
        _$CategoryApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };
