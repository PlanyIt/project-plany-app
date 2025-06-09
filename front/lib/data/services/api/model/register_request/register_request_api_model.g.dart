// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterRequestApiModelImpl _$$RegisterRequestApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterRequestApiModelImpl(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$RegisterRequestApiModelImplToJson(
        _$RegisterRequestApiModelImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'description': instance.description,
      'photoUrl': instance.photoUrl,
    };
