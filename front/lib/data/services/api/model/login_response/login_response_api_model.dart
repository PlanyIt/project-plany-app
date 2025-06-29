import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response_api_model.freezed.dart';
part 'login_response_api_model.g.dart';

@freezed
class LoginResponseApiModel with _$LoginResponseApiModel {
  const factory LoginResponseApiModel({
    String? accessToken,
    String? refreshToken,
    @JsonKey(name: 'token') String? token,
    @JsonKey(name: 'user_id') required String userId,
  }) = _LoginResponseApiModel;

  factory LoginResponseApiModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseApiModelFromJson(json);
}
