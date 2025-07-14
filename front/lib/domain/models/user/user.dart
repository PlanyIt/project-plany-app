import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') String? id,
    required String username,
    required String email,
    String? description,
    @Default(false) bool isPremium,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    DateTime? createdAt,
    int? followersCount,
    int? followingCount,
    int? plansCount,
    int? favoritesCount,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
