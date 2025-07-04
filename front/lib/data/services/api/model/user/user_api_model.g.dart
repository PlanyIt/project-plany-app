// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserApiModelImpl _$$UserApiModelImplFromJson(Map<String, dynamic> json) =>
    _$UserApiModelImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      description: json['description'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      profilePicture: json['profilePicture'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String?,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      following: (json['following'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserApiModelImplToJson(_$UserApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'description': instance.description,
      'isPremium': instance.isPremium,
      'profilePicture': instance.profilePicture,
      'birthDate': instance.birthDate?.toIso8601String(),
      'gender': instance.gender,
      'followers': instance.followers,
      'following': instance.following,
    };
