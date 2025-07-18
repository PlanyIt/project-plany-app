import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/user_api_model.dart';

part 'auth_response.freezed.dart';

part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    /// Jeton court (≈15 min) à mettre dans l’Authorization header.
    // ignore: invalid_annotation_target
    @JsonKey(name: 'accessToken') required String accessToken,

    /// Jeton long (≈30 j) à garder en SecureStorage pour demander un
    /// nouvel accessToken.
    // ignore: invalid_annotation_target
    @JsonKey(name: 'refreshToken') required String refreshToken,
    required UserApiModel currentUser,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, Object?> json) =>
      _$AuthResponseFromJson(json);
}
