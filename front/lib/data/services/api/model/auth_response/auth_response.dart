import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/user_api_model.dart';

part 'auth_response.freezed.dart';

part 'auth_response.g.dart';

/// AuthResponse model.
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    /// The token to be used for authentication.
    required String token,
    required UserApiModel currentUser,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, Object?> json) =>
      _$AuthResponseFromJson(json);
}
