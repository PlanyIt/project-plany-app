import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String email,
    String? description,
    @Default(false) bool isPremium,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    @Default('user') String role,
    @Default(true) bool isActive,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    int? followersCount,
    int? followingCount,
    int? plansCount,
    int? favoritesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
