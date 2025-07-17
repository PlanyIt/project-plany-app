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
    double? latitude,
    double? longitude,
    required int order,
    required String image,
    int? duration,
    double? cost,
    DateTime? createdAt,
  }) = _Step;

  factory Step.fromJson(Map<String, Object?> json) => _$StepFromJson(json);
}

extension StepExtension on Step {
  /// Retourne la position comme LatLng si latitude et longitude sont disponibles
  LatLng? get position {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  /// Vérifie si l'étape a une position valide
  bool get hasValidPosition => latitude != null && longitude != null;
}
