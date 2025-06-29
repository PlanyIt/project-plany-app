// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestApiModelImpl _$$LoginRequestApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginRequestApiModelImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestApiModelImplToJson(
        _$LoginRequestApiModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };
