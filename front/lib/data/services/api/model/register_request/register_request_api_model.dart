import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_api_model.freezed.dart';
part 'register_request_api_model.g.dart';

@freezed
abstract class RegisterRequestApiModel with _$RegisterRequestApiModel {
  const factory RegisterRequestApiModel({
    /// The user's username.
    required String username,

    /// The user's email.
    required String email,

    /// The user's password.
    required String password,

    /// The user's description.
    String? description,

    /// The user's profile picture URL.
    String? photoUrl,
  }) = _RegisterRequestApiModel;

  factory RegisterRequestApiModel.fromJson(Map<String, Object?> json) =>
      _$RegisterRequestApiModelFromJson(json);
}
