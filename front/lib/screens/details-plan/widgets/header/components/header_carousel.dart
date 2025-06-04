import 'package:flutter/material.dart';
import 'package:front/domain/models/step.dart' as custom;

class HeaderCarousel extends StatelessWidget {
  final List<custom.Step> steps;
  final int currentIndex;
  final PageController pageController;
  final Function(int) onStepSelected;
  final String? category;
  final Color categoryColor;

  const HeaderCarousel({
    Key? key,
    required this.steps,
    required this.currentIndex,
    required this.pageController,
    required this.onStepSelected,
    this.category,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    final double cardHeight = 80.0;
    final double cardWidth = 110.0;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: ListView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: steps.length,
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                itemExtent: 90,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isSelected = index == currentIndex;

                  return GestureDetector(
                    onTap: () => onStepSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuint,
                      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      height: isSelected ? cardHeight * 1.15 : cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isSelected ? 0.25 : 0.1),
                            blurRadius: isSelected ? 10 : 4,
                            spreadRadius: isSelected ? 1 : 0,
                            offset: isSelected
                                ? const Offset(0, 3)
                                : const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Carte avec image
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    )
                                  : Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Image de l'étape
                                  step.image.isNotEmpty
                                      ? Image.network(
                                          step.image,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return _defaultStepImage(step);
                                          },
                                        )
                                      : _defaultStepImage(step),

                                  // Overlay pour l'effet sélectionné
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.1),
                                          Colors.black.withValues(alpha: 0.5),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Badge de numéro
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? categoryColor
                                            : Colors.black
                                                .withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Titre en bas
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black
                                                .withValues(alpha: 0.7)
                                            : Colors.black
                                                .withValues(alpha: 0.5),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        step.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSelected ? 12 : 10,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  // Indicateur de sélection
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: categoryColor.withValues(
                                                  alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Petit indicateur de position en bas
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withValues(alpha: 0.05),
            ),
            child: Text(
              "${currentIndex + 1}/${steps.length}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                shadows: [
                  Shadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Image par défaut simplifiée pour les étapes sans image
  Widget _defaultStepImage(custom.Step step) {
    return Container(
      color: categoryColor.withValues(alpha: 0.8),
      child: Center(
        child: Text(
          step.title.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
