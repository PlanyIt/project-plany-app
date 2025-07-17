// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlanImpl _$$PlanImplFromJson(Map<String, dynamic> json) => _$PlanImpl(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      isPublic: json['isPublic'] as bool? ?? true,
      isAccessible: json['isAccessible'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => Step.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      favorites: (json['favorites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      totalDuration: (json['totalDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PlanImplToJson(_$PlanImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'user': instance.user,
      'isPublic': instance.isPublic,
      'isAccessible': instance.isAccessible,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'steps': instance.steps,
      'favorites': instance.favorites,
      'isFavorite': instance.isFavorite,
      'totalCost': instance.totalCost,
      'totalDuration': instance.totalDuration,
    };
