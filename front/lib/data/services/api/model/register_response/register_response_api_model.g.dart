// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterResponseApiModelImpl _$$RegisterResponseApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterResponseApiModelImpl(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$$RegisterResponseApiModelImplToJson(
        _$RegisterResponseApiModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user_id': instance.userId,
    };
