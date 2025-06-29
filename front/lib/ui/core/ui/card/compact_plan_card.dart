import 'dart:io';
import 'package:flutter/material.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/theme/app_theme.dart';
import 'package:front/utils/icon_utils.dart';

class CompactPlanCard extends StatelessWidget {
  final List<String>? imageUrls;
  final String? imageUrl;
  final String title;
  final String description;
  final Category? category;
  final int stepsCount;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double? totalCost;
  final int? totalDuration;

  const CompactPlanCard({
    super.key,
    this.imageUrls,
    this.imageUrl,
    required this.title,
    required this.description,
    this.category,
    this.stepsCount = 0,
    this.onTap,
    this.borderRadius,
    this.totalCost,
    this.totalDuration,
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
            // Image section avec hauteur fixe
            SizedBox(
              height: 120,
              child: _buildImageSection(),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildContentSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return _ImageCarousel(imageUrls: imageUrls!);
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
        if (category != null) _buildCategoryBadge(context),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.format_list_numbered,
                size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              "$stepsCount étapes",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (totalCost != null) ...[
              const SizedBox(width: 8),
              Text(
                "${totalCost!.toStringAsFixed(0)} €",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (totalDuration != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _formatDuration(totalDuration!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Helper method to format duration in minutes to a readable format
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getIconData(category?.icon),
            size: 12,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            category?.name ?? '',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarousel({required this.imageUrls});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page view des images
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = widget.imageUrls[index];
            return _buildImageItem(imageUrl);
          },
        ),

        // Indicateurs de pagination simplifiés
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _currentPage == index ? 12 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),

        // Compteur d'images
        if (widget.imageUrls.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildErrorImage(),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildErrorImage(),
      );
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(Icons.broken_image, size: 30, color: Colors.grey.shade400),
      ),
    );
  }
}
