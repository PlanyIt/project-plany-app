import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../widgets/card/compact_plan_card.dart';

/// Un HorizontalPlanList générique qui affiche des CompactPlanCard prêtes à l'affichage
class HorizontalPlanList extends StatelessWidget {
  /// Les cartes déjà construites (CompactPlanCard)
  final List<CompactPlanCard> cards;

  /// Affiche un skeleton tant que [isLoading] est vrai
  final bool isLoading;

  /// Callback déclenché lors du tap sur une carte, reçoit l'index
  final void Function(int index) onPressed;

  /// Hauteur du widget
  final double height;

  /// Largeur de chaque carte
  final double cardWidth;

  const HorizontalPlanList({
    super.key,
    required this.cards,
    required this.isLoading,
    required this.onPressed,
    this.height = 250,
    this.cardWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingSkeleton();

    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onPressed(index),
            child: Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 16, bottom: 8),
              child: cards[index],
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
}
