// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseApiModelImpl _$$LoginResponseApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginResponseApiModelImpl(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      token: json['token'] as String?,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$$LoginResponseApiModelImplToJson(
        _$LoginResponseApiModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'token': instance.token,
      'user_id': instance.userId,
    };
