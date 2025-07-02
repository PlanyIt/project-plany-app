import 'package:freezed_annotation/freezed_annotation.dart';

part 'step_api_model.freezed.dart';
part 'step_api_model.g.dart';

@freezed
class StepApiModel with _$StepApiModel {
  const factory StepApiModel({
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    required int order,
    required String image,
    String? duration,
    double? cost,
    required String userId,
  }) = _StepApiModel;

  factory StepApiModel.fromJson(Map<String, dynamic> json) =>
      _$StepApiModelFromJson(json);
}
