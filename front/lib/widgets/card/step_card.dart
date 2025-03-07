import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:front/widgets/tag/info_chip.dart';

class StepCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String? duration;
  final String? durationUnit;
  final double? cost;
  final GeoPoint? location;
  final String? locationName;
  final VoidCallback? onDelete;
  final Color? themeColor;

  const StepCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.duration,
    this.durationUnit,
    this.cost,
    this.location,
    this.locationName,
    this.onDelete,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'step_card_${title.hashCode}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: 100,
                      height: double.infinity,
                      child: _buildImage(),
                    ),
                  ),

                // Contenu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                semanticsLabel: 'Étape: $title',
                              ),
                            ),
                            if (onDelete != null)
                              Container(
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Tooltip(
                                  message: 'Supprimer cette étape',
                                  child: InkWell(
                                    onTap: onDelete,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.red[700],
                                      semanticLabel:
                                          'Supprimer l\'étape ${title}',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Description
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (duration != null)
                              InfoChip(
                                icon: Icons.access_time_outlined,
                                label: "$duration".toLowerCase() +
                                    (durationUnit != null
                                        ? ' $durationUnit'.toLowerCase()
                                        : ''),
                                color: themeColor,
                              ),
                            if (cost != null)
                              InfoChip(
                                icon: Icons.euro_outlined,
                                label: "${cost}€",
                                color: themeColor,
                              ),
                            if (locationName != null)
                              InfoChip(
                                icon: Icons.place_outlined,
                                label: _truncateLocationName(locationName!),
                                color: themeColor,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: _buildErrorImage,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: _buildErrorImage,
      );
    }
  }

  Widget _buildErrorImage(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  String _truncateLocationName(String locationName) {
    if (locationName.length > 20) {
      return '${locationName.substring(0, 18)}...';
    }
    return locationName;
  }
}
