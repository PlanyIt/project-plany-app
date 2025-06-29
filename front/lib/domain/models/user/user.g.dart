// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      description: json['description'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String?,
      role: json['role'] as String? ?? 'user',
      isActive: json['isActive'] as bool? ?? true,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      plansCount: (json['plansCount'] as num?)?.toInt(),
      favoritesCount: (json['favoritesCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'description': instance.description,
      'isPremium': instance.isPremium,
      'photoUrl': instance.photoUrl,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': instance.gender,
      'role': instance.role,
      'isActive': instance.isActive,
      'followers': instance.followers,
      'following': instance.following,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'plansCount': instance.plansCount,
      'favoritesCount': instance.favoritesCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
