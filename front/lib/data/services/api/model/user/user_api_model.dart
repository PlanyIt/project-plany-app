import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_api_model.freezed.dart';
part 'user_api_model.g.dart';

@freezed
abstract class UserApiModel with _$UserApiModel {
  const factory UserApiModel({
    /// The user's ID.
    required String id,

    /// The user's username.
    required String username,

    /// The user's email.
    required String email,

    /// The user's description.
    String? description,

    /// Whether the user has premium status.
    @Default(false) bool isPremium,

    /// The user's photo URL.
    String? photoUrl,

    /// The user's birth date.
    DateTime? birthDate,

    /// The user's gender.
    String? gender,

    /// The user's role.
    @Default('user') String role,

    /// Whether the user is active.
    @Default(true) bool isActive,

    /// The user's registration date.
    required DateTime registrationDate,

    /// List of user IDs who follow this user.
    @Default([]) List<String> followers,

    /// List of user IDs this user follows.
    @Default([]) List<String> following,
  }) = _UserApiModel;

  factory UserApiModel.fromJson(Map<String, Object?> json) =>
      _$UserApiModelFromJson(json);
}
