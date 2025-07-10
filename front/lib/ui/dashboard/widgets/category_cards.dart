import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/helpers.dart';
import '../../../utils/icon_utils.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/dashboard_viewmodel.dart';

class CategoryCards extends StatelessWidget {
  const CategoryCards({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.load.running && !viewModel.hasLoadedData) {
      return _buildCategoryShimmer();
    }
    return _buildCategoryCarousel(context);
  }

  Widget _buildCategoryCarousel(BuildContext context) {
    if (viewModel.categories.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('Aucune catégorie disponible'),
        ),
      );
    }

    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final gradientColors = [
            colorFromHex(category.color),
            colorFromHex(category.color).withValues(alpha: 0.8),
          ];

          return GestureDetector(
            onTap: () => viewModel.onCategoryTap(category),
            child: Container(
              width: 110,
              margin:
                  const EdgeInsets.only(right: 16, bottom: AppTheme.paddingM),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorFromHex(category.color),
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
