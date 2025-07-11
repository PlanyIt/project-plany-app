import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../domain/models/step/step.dart';
import '../../../../services/location_service.dart';
import '../../../../utils/helpers.dart';
import '../../../search_plan/view_models/search_view_model.dart';
import '../card/compact_plan_card.dart';

class VerticalPlanList extends StatelessWidget {
  final List<PlanWithMetrics> plans;
  final bool isLoading;

  const VerticalPlanList({
    super.key,
    required this.plans,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (plans.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final planWithMetrics = plans[index];
        final plan = planWithMetrics.plan;

        // Calculer la distance si le plan a des coordonnées
        String? distance;
        if (plan.steps.isNotEmpty) {
          final firstStep = plan.steps.first;
          if (firstStep.position != null) {
            final distanceInMeters = LocationService().calculateDistanceToPoint(
              firstStep.position!.latitude,
              firstStep.position!.longitude,
            );
            distance = formatDistance(distanceInMeters);
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: CompactPlanCard(
            title: plan.title,
            description: plan.description,
            stepsCount: plan.steps.length,
            totalCost: planWithMetrics.totalCost > 0
                ? planWithMetrics.totalCost
                : null,
            totalDuration: planWithMetrics.totalDuration.inMinutes > 0
                ? planWithMetrics.totalDuration.inMinutes
                : null,
            imageUrls: plan.steps.map((step) => step.image).toList(),
            category: plan.category,
            user: plan.user,
            distance: distance,
            aspectRatio: 2.5, // More compact for vertical display
            onTap: () {
              context.pushNamed(
                'planDetails',
                pathParameters: {'planId': plan.id ?? ''},
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun plan trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez d\'ajuster vos filtres de recherche',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
