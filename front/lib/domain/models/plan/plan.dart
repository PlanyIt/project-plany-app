import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    @JsonKey(name: '_id') String? id,
    required String title,
    required String description,
    required String category,
    String? userId,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> steps,
    @Default([]) List<String> favorites,
    @Default(false) bool isFavorite,
    double? estimatedCost,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
