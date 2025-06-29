import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_response_api_model.freezed.dart';
part 'register_response_api_model.g.dart';

@freezed
abstract class RegisterResponseApiModel with _$RegisterResponseApiModel {
  const factory RegisterResponseApiModel({
    /// The user's access token.
    String? accessToken,

    /// The user's refresh token.
    String? refreshToken,

    /// The user ID
    @JsonKey(name: 'user_id') required String userId,
  }) = _RegisterResponseApiModel;

  factory RegisterResponseApiModel.fromJson(Map<String, Object?> json) =>
      _$RegisterResponseApiModelFromJson(json);
}
