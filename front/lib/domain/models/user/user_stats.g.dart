// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      plansCount: (json['plansCount'] as num).toInt(),
      favoritesCount: (json['favoritesCount'] as num).toInt(),
      followersCount: (json['followersCount'] as num).toInt(),
      followingCount: (json['followingCount'] as num).toInt(),
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'plansCount': instance.plansCount,
      'favoritesCount': instance.favoritesCount,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
    };
