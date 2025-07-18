import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_api_model.freezed.dart';
part 'user_api_model.g.dart';

@freezed
class UserApiModel with _$UserApiModel {
  const factory UserApiModel({
    // ignore: invalid_annotation_target
    @JsonKey(name: '_id') required String id,
    required String username,
    required String email,
    String? description,
    @Default(false) bool isPremium,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    int? followersCount,
    int? followingCount,
    int? plansCount,
    int? favoritesCount,
  }) = _UserApiModel;

  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);
}
