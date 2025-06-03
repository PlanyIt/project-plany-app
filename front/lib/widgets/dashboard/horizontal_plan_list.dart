import 'package:flutter/material.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/widgets/card/compact_plan_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:front/services/step_service.dart';

class HorizontalPlanList extends StatelessWidget {
  final List<Plan> plans;
  final bool isLoading;
  final Function(dynamic) getCategoryById;
  final Function(Plan) onPlanTap;
  final String emptyMessage;
  final double height;
  final double cardWidth;

  const HorizontalPlanList({
    super.key,
    required this.plans,
    required this.isLoading,
    required this.getCategoryById,
    required this.onPlanTap,
    required this.emptyMessage,
    this.height = 250,
    this.cardWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (plans.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Container(
            width: cardWidth,
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            child: FutureBuilder<List<String>>(
              future: _getStepImages(plan),
              builder: (context, snapshot) {
                // Use only the first image if available
                final firstImage = snapshot.data?.isNotEmpty == true
                    ? [snapshot.data!.first]
                    : null;

                return CompactPlanCard(
                  title: plan.title,
                  description: plan.description,
                  category: getCategoryById(plan.category),
                  stepsCount: plan.steps.length,
                  imageUrls: firstImage, // Pass only the first image
                  onTap: () => onPlanTap(plan),
                  borderRadius: BorderRadius.circular(16),
                  // Calculate total cost and duration
                  totalCost: _calculateTotalCost(plan),
                  totalDuration: _calculateTotalDuration(plan),
                );
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
            }),
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

  // Méthode pour récupérer les images de toutes les étapes
  Future<List<String>> _getStepImages(Plan plan) async {
    final stepService = StepService();
    final List<String> images = [];

    // Limiter à 5 étapes maximum pour éviter trop de requêtes
    final stepsToFetch =
        plan.steps.length > 5 ? plan.steps.sublist(0, 5) : plan.steps;

    for (final stepId in stepsToFetch) {
      try {
        final step = await stepService.getStepById(stepId);
        if (step != null && step.image != null && step.image!.isNotEmpty) {
          images.add(step.image!);
        }
      } catch (e) {
        // Ignorer les erreurs de chargement d'images
      }
    }
    return images;
  }

  // Nouvelle méthode pour calculer le coût total d'un plan
  double _calculateTotalCost(Plan plan) {
    // Cette méthode est simplifiée pour un exemple - dans une vraie application,
    // vous récupéreriez probablement ces données depuis une source externe
    double totalCost = 0;
    try {
      // Nous utilisons une valeur fictive ici, puisque nous n'avons pas accès aux vraies données
      totalCost = plan.steps.length * 10.0; // Estimation basique: 10€ par étape
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
    return totalCost;
  }

  // Modifié pour retourner des minutes comme int, pas une Duration
  int _calculateTotalDuration(Plan plan) {
    // Cette méthode est simplifiée pour un exemple
    int totalMinutes = 0;
    try {
      // Nous utilisons une valeur fictive ici
      totalMinutes = plan.steps.length *
          60; // Estimation basique: 1 heure (60 min) par étape
    } catch (e) {
      // Gérer les erreurs silencieusement
    }
    return totalMinutes;
  }
}
