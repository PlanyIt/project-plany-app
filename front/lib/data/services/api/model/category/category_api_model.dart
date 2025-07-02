import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_api_model.freezed.dart';
part 'category_api_model.g.dart';

@freezed
class CategoryApiModel with _$CategoryApiModel {
  const factory CategoryApiModel({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String icon,
    @Default("6C63FF") String color,
  }) = _CategoryApiModel;

  factory CategoryApiModel.fromJson(Map<String, Object?> json) =>
      _$CategoryApiModelFromJson(json);
}
