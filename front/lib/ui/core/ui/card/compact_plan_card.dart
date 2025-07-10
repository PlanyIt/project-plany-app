import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../domain/models/category/category.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/helpers.dart';
import '../../../../utils/icon_utils.dart';
import '../../../create_plan/widgets/step_three_content.dart';
import '../../themes/app_theme.dart';

class CompactPlanCard extends StatelessWidget {
  final List<String>? imageUrls;
  final String? imageUrl;
  final String title;
  final String description;
  final Category? category;
  final User? user;
  final int stepsCount;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double? totalCost;
  final int? totalDuration;
  final double? distance;

  const CompactPlanCard({
    super.key,
    this.imageUrls,
    this.imageUrl,
    required this.title,
    required this.description,
    this.category,
    this.user,
    this.stepsCount = 0,
    this.onTap,
    this.borderRadius,
    this.totalCost,
    this.totalDuration,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImageSection(),
            ),
            // Content section
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildContentSection(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return ImageCarousel(images: imageUrls!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildSingleImage(imageUrl!);
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildSingleImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image,
          size: 30,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (category != null) Flexible(child: _buildCategoryBadge(context)),
            const Spacer(),
            if (user != null) _buildUserAvatar(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildMetadataSection(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Première ligne: étapes et distance
        Row(
          children: [
            _buildMetadataItem(
              icon: Icons.format_list_numbered,
              text: "$stepsCount étapes",
            ),
            if (distance != null) ...[
              const SizedBox(width: 12),
              _buildMetadataItem(
                icon: Icons.place,
                text: formatDistance(distance) ?? '',
              ),
            ],
          ],
        ),
        if (totalCost != null || totalDuration != null) ...[
          const SizedBox(height: 2),
          // Deuxième ligne: coût et durée
          Row(
            children: [
              if (totalCost != null)
                _buildMetadataItem(
                  icon: Icons.euro,
                  text: totalCost!.toStringAsFixed(0),
                ),
              if (totalCost != null && totalDuration != null)
                const SizedBox(width: 12),
              if (totalDuration != null)
                _buildMetadataItem(
                  icon: Icons.access_time,
                  text: formatDuration(totalDuration!),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: user!.photoUrl != null && user!.photoUrl!.isNotEmpty
            ? Image.network(
                user!.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : Container(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 14,
                  color: AppTheme.primaryColor,
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconData(category?.icon),
            size: 10,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              category?.name ?? '',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
