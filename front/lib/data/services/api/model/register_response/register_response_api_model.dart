import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_response_api_model.freezed.dart';
part 'register_response_api_model.g.dart';

@freezed
abstract class RegisterResponseApiModel with _$RegisterResponseApiModel {
  const factory RegisterResponseApiModel({
    /// The user's access token.
    required String access_token,
  }) = _RegisterResponseApiModel;

  factory RegisterResponseApiModel.fromJson(Map<String, Object?> json) =>
      _$RegisterResponseApiModelFromJson(json);
}
