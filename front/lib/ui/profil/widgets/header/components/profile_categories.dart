import 'package:flutter/material.dart';

import '../../../../../utils/icon_utils.dart';
import '../../../view_models/profile_viewmodel.dart';

class ProfileCategories extends StatelessWidget {
  final ProfileViewModel viewModel;
  const ProfileCategories({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final categories = viewModel.userCategories;
    final isLoading = viewModel.isLoadingCategories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.yellow[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Mes activités préférées",
                style: TextStyle(
                  color: Colors.grey[850],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (categories.isEmpty)
            Text(
              "Aucune catégorie utilisée pour l'instant",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                return _buildActivityTagWithIcon(
                  category.name,
                  category.icon,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTagWithIcon(String text, String? iconName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3425B5).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconData(iconName ?? "category"),
            size: 14,
            color: const Color(0xFF3425B5),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3425B5),
            ),
          ),
        ],
      ),
    );
  }
}
