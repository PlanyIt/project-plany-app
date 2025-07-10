import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'step.freezed.dart';
part 'step.g.dart';

@freezed
class Step with _$Step {
  const factory Step({
    @JsonKey(name: '_id') String? id,
    required String title,
    required String description,
    LatLng? position,
    required int order,
    required String image,
    String? duration,
    double? cost,
    DateTime? createdAt,
    String? userId,
  }) = _Step;

  factory Step.fromJson(Map<String, Object?> json) => _$StepFromJson(json);
}
