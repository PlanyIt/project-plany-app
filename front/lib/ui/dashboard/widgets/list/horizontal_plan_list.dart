import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/utils/helpers.dart';
import 'package:front/utils/result.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalPlanList extends StatelessWidget {
  final List<Plan> plans;
  final Map<String, List<step_model.Step>> planSteps;
  final bool isLoading;
  final Future<Result<Category>> Function(String) getCategoryById;
  final Function(Plan) onPlanTap;
  final String emptyMessage;
  final double height;
  final double cardWidth;
  final String? distance;

  const HorizontalPlanList({
    super.key,
    required this.plans,
    required this.planSteps,
    required this.isLoading,
    required this.getCategoryById,
    required this.onPlanTap,
    required this.emptyMessage,
    this.height = 250,
    this.cardWidth = 200,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingSkeleton();
    if (plans.isEmpty) return _buildEmptyState();

    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          final steps = planSteps[plan.id] ?? [];
          final List<String> firstImage =
              steps.isNotEmpty ? [steps.first.image] : [];

          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            child: FutureBuilder<Result<Category>>(
              future: getCategoryById(plan.category),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingCard(plan);
                }

                final result = snapshot.data;
                if (result is Ok<Category>) {
                  final category = result.value;
                  return CompactPlanCard(
                    title: plan.title,
                    description: plan.description,
                    category: category,
                    stepsCount: steps.length,
                    imageUrls: firstImage,
                    onTap: () => onPlanTap(plan),
                    borderRadius: BorderRadius.circular(16),
                    totalCost: calculateTotalStepsCost(steps),
                    totalDuration: calculateTotalDuration(steps),
                    distance: distance,
                  );
                } else {
                  return _buildErrorCard(plan);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      height: height,
      margin: const EdgeInsets.only(top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemBuilder: (context, index) {
            return Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(emptyMessage),
      ),
    );
  }

  Widget _buildLoadingCard(Plan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(plan.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(Plan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(plan.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Center(
              child: Text(
                'Erreur de chargement',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
