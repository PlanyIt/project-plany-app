import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/core/utils/result.dart';
import 'package:front/ui/core/ui/card/compact_plan_card.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class HorizontalPlanList extends StatelessWidget {
  final List<Plan> plans;
  final Map<String, List<step_model.Step>> planSteps;
  final bool isLoading;
  final Future<Result<Category>> Function(String) getCategoryById;
  final Function(Plan) onPlanTap;
  final String emptyMessage;
  final double height;
  final double cardWidth;
  final double? userLatitude;
  final double? userLongitude;

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
    this.userLatitude,
    this.userLongitude,
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

          // Calculate distance to first step if user location is available
          double? distanceToFirstStep;
          if (userLatitude != null &&
              userLongitude != null &&
              steps.isNotEmpty) {
            // TODO: Replace with actual step coordinates when Step model has latitude/longitude
            // For now, simulate with random Paris area coordinates
            final firstStep = steps.first;
            final stepLat = 48.8566 + (math.Random().nextDouble() - 0.5) * 0.1;
            final stepLon = 2.3522 + (math.Random().nextDouble() - 0.5) * 0.1;
            distanceToFirstStep = _calculateDistance(
                userLatitude!, userLongitude!, stepLat, stepLon);
          }

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
                    totalCost: _calculateTotalCost(steps),
                    totalDuration: _calculateTotalDuration(steps),
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

  double _calculateTotalCost(List<step_model.Step> steps) {
    return steps.fold(0.0, (sum, step) => sum + (step.cost ?? 0.0));
  }

  int _calculateTotalDuration(List<step_model.Step> steps) {
    int total = 0;
    final regex = RegExp(r'(\d+)\s*(minute|heure|jour|semaine)');

    for (final step in steps) {
      final match = regex.firstMatch(step.duration ?? '');
      if (match != null) {
        final value = int.tryParse(match.group(1)!);
        final unit = match.group(2);
        if (value != null && unit != null) {
          switch (unit) {
            case 'minute':
              total += value;
              break;
            case 'heure':
              total += value * 60;
              break;
            case 'jour':
              total += value * 8 * 60;
              break;
            case 'semaine':
              total += value * 5 * 8 * 60;
              break;
          }
        }
      }
    }

    return total;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
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
