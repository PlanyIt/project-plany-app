import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_api_model.freezed.dart';
part 'category_api_model.g.dart';

@freezed
class CategoryApiModel with _$CategoryApiModel {
  const factory CategoryApiModel({
    /// Unique identifier for the category.
    required int id,

    /// Name of the category.
    required String name,

    /// Icon associated with the category.
    required String icon,

    /// Color associated with the category in hex format.
    required String color,
  }) = _CategoryApiModel;

  factory CategoryApiModel.fromJson(Map<String, Object> json) =>
      _$CategoryApiModelFromJson(json);
}
