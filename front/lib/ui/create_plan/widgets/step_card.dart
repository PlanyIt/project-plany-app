import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'info_chip.dart';

class StepCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final int? duration;
  final String? durationUnit;
  final double? cost;
  final LatLng? location;
  final String? locationName;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
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
    this.onEdit,
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
                color: Colors.black.withValues(alpha: 0.04),
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
                if (imageUrl.isNotEmpty) _buildImageSection(),

                // Contenu
                Expanded(
                  child: _buildContentSection(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: SizedBox(
        width: 100,
        height: double.infinity,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
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
              // Actions pour éditer et supprimer
              if (onEdit != null || onDelete != null)
                Row(
                  children: [
                    if (onEdit != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.edit,
                          color: Colors.blue,
                          tooltip: 'Modifier cette étape',
                          onTap: onEdit!,
                        ),
                      ),
                    if (onDelete != null)
                      _buildActionButton(
                        context: context,
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        tooltip: 'Supprimer cette étape',
                        onTap: () => _showDeleteConfirmation(context),
                      ),
                  ],
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
                  label: ('$duration ${durationUnit ?? 'min'}').toLowerCase(),
                  color: themeColor,
                ),
              if (cost != null)
                InfoChip(
                  icon: Icons.euro_outlined,
                  label: "$cost€",
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
    );
  }

  // Méthode pour montrer une boîte de dialogue de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cette étape'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer cette étape ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete?.call();
              },
            ),
          ],
        );
      },
    );
  }

  // Créer un bouton d'action réutilisable (éditer/supprimer)
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              icon,
              size: 16,
              color: color,
              semanticLabel: tooltip,
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
