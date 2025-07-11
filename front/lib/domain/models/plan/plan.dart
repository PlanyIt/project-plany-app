import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    String? id,
    required String title,
    required String description,
    required String category,
    String? userId,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    required List<String> steps,
    List<String>? favorites,
    @Default(false) bool isFavorite,
    double? estimatedCost,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
