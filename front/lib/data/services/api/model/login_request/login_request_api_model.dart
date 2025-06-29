import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_api_model.freezed.dart';
part 'login_request_api_model.g.dart';

/// Simple data class to hold login request data.
@freezed
class LoginRequestApiModel with _$LoginRequestApiModel {
  const factory LoginRequestApiModel({
    /// Email address.
    required String email,

    /// Plain text password.
    required String password,
  }) = _LoginRequestApiModel;

  factory LoginRequestApiModel.fromJson(Map<String, Object> json) =>
      _$LoginRequestApiModelFromJson(json);
}
