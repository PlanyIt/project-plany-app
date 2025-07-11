
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'step_data.freezed.dart';
part 'step_data.g.dart';

@freezed
class StepData with _$StepData {
  const factory StepData({
    required String title,
    required String description,
    required String imageUrl,
    int? duration,
    String? durationUnit,
    double? cost,
    LatLng? location,
    String? locationName,
  }) = _StepData;

  factory StepData.fromJson(Map<String, Object?> json) =>
      _$StepDataFromJson(json);
}
