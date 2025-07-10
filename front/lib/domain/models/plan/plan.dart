import 'package:freezed_annotation/freezed_annotation.dart';

import '../category/category.dart';
import '../step/step.dart';
import '../user/user.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    @JsonKey(name: '_id') String? id,
    required String title,
    required String description,
    Category? category,
    User? user,
    @Default(true) bool isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Step> steps,
    @Default([]) List<String>? favorites,
    @Default(false) bool isFavorite,
    double? totalCost,
    int? totalDuration,
  }) = _Plan;

  factory Plan.fromJson(Map<String, Object?> json) => _$PlanFromJson(json);
}
