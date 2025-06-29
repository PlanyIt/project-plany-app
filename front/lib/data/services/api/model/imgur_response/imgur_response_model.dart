import 'package:freezed_annotation/freezed_annotation.dart';

part 'imgur_response_model.freezed.dart';
part 'imgur_response_model.g.dart';

/// Simple data class to hold login request data.
@freezed
class ImgurResponseModel with _$ImgurResponseModel {
  const factory ImgurResponseModel({
    required String link,
  }) = _ImgurResponseModel;

  factory ImgurResponseModel.fromJson(Map<String, dynamic> json) =>
      ImgurResponseModel(
        link: json['data']['link'] as String,
      );
}
