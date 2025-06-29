import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/utils/icon_utils.dart';
import 'package:shimmer/shimmer.dart';

class CategoryCards extends StatelessWidget {
  final List<Category> categories;
  final bool isLoading;
  final Function(Category) onCategoryTap;

  const CategoryCards({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildCategoryShimmer();
    }
    return _buildCategoryCarousel(context);
  }

  Widget _buildCategoryCarousel(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Aucune catégorie disponible'),
        ),
      );
    }

    // Palette de couleurs harmonisées avec le thème existant
    final List<List<Color>> categoryGradients = [
      [const Color(0xFF6C63FF), const Color(0xFF837DFF)], // Secondaire
      [const Color(0xFFFF7B9C), const Color(0xFFFF5C84)], // Accent
      [const Color(0xFF3F8CFF), const Color(0xFF1F78FF)], // Bleu vif
      [const Color(0xFF7250DE), const Color(0xFF5E41C2)], // Violet royal
      [const Color(0xFF3AB6BC), const Color(0xFF2DA0A6)], // Turquoise
      [const Color(0xFFFF6B6B), const Color(0xFFFF5252)], // Rouge vif
      [const Color(0xFF9C42F5), const Color(0xFF8333E1)], // Violet électrique
      [const Color(0xFF00B8A9), const Color(0xFF00A396)], // Vert menthe
      [const Color(0xFFFF8A48), const Color(0xFFFF7730)], // Orange moderne
      [const Color(0xFF6A0572), const Color(0xFF4E0058)], // Violet sombre
    ];

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final category = categories[index];
          final gradientColors =
              categoryGradients[index % categoryGradients.length];

          return GestureDetector(
            onTap: () => onCategoryTap(category),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -15,
                    right: -15,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  // Contenu principal avec meilleur contraste
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            getIconData(category.icon),
                            color: gradientColors[0],
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemBuilder: (context, index) {
            return Container(
              width: 110,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            );
          },
        ),
      ),
    );
  }
}
