import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front/domain/models/step/latlng_converter.dart';
import 'package:latlong2/latlong.dart';

part 'step.freezed.dart';
part 'step.g.dart';

@freezed
class Step with _$Step {
  const factory Step({
    @JsonKey(name: '_id') String? id,
    required String title,
    required String description,
    @LatLngConverter() LatLng? position,
    required int order,
    required String image,
    String? duration,
    double? cost,
    DateTime? createdAt,
    required String userId,
  }) = _Step;

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
}
