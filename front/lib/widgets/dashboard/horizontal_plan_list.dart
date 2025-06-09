import 'package:flutter/material.dart';
import 'package:front/domain/models/category.dart';
import 'package:front/domain/models/plan.dart';
import 'package:front/utils/result.dart';
import 'package:front/widgets/card/compact_plan_card.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalPlanList extends StatelessWidget {
  final List<Plan> plans;
  final bool isLoading;
  final Function(dynamic) getCategoryById;
  final Function(Plan) onPlanTap;
  final String emptyMessage;
  final double height;
  final double cardWidth;
  final List<String>? stepImages;

  const HorizontalPlanList({
    super.key,
    required this.plans,
    required this.isLoading,
    required this.getCategoryById,
    required this.onPlanTap,
    required this.emptyMessage,
    this.height = 250,
    this.cardWidth = 200,
    this.stepImages,
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
              future: stepImages != null
                  ? Future.value(stepImages)
                  : getCategoryById(plan.category).then((result) {
                      if (result is Ok<List<String>>) {
                        return result.value;
                      } else {
                        return [];
                      }
                    }),
              builder: (context, snapshot) {
                // Use only the first image if available
                final firstImage = snapshot.data?.isNotEmpty == true
                    ? [snapshot.data!.first]
                    : null;

                // Wrap category loading in a FutureBuilder
                return FutureBuilder<Result<Category>>(
                  future: getCategoryById(plan.category),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingCard(plan);
                    }

                    if (categorySnapshot.hasError ||
                        !categorySnapshot.hasData) {
                      return _buildErrorCard(plan);
                    }

                    final result = categorySnapshot.data;
                    if (result is Ok<Category>) {
                      final category = result.value;
                      return CompactPlanCard(
                        title: plan.title,
                        description: plan.description,
                        category: category,
                        stepsCount: plan.steps.length,
                        imageUrls: firstImage,
                        onTap: () => onPlanTap(plan),
                        borderRadius: BorderRadius.circular(16),
                        totalCost: _calculateTotalCost(plan),
                        totalDuration: _calculateTotalDuration(plan),
                      );
                    } else {
                      return _buildErrorCard(plan);
                    }
                  },
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

  // Helper method to show a loading placeholder card
  Widget _buildLoadingCard(Plan plan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
            Text(
              plan.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
