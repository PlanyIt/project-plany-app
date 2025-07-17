import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/category/category.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/helpers.dart';
import '../../../../utils/icon_utils.dart';
import '../../themes/app_theme.dart';
import '../caroussel/image_caroussel.dart';

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
  final String? distance;

  final double aspectRatio;

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
    this.aspectRatio = 16 / 9,
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
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: _buildImageSection(),
            ),
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
      return ImageCarousel(imageUrls: imageUrls!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildSingleImage(imageUrl!);
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildSingleImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        const SizedBox(height: 8),
        // Ligne avec distance et nombre d'étapes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (distance != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    distance!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            _buildMetadataItem(
              icon: Icons.format_list_numbered,
              text: "$stepsCount étapes",
            ),
          ],
        ),
        if (totalCost != null || totalDuration != null) ...[
          const SizedBox(height: 2),
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
                  text: formatDurationToString(totalDuration!),
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
            color: Colors.black.withAlpha(25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: user!.photoUrl != null && user!.photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user!.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.primaryColor.withAlpha(25),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.primaryColor.withAlpha(25),
                  child: Icon(
                    Icons.person,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : Container(
                color: AppTheme.primaryColor.withAlpha(25),
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
        color: AppTheme.primaryColor.withAlpha(25),
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
