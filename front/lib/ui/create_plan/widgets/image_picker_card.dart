import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerCard extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final double height;
  final Color primaryColor;

  const ImagePickerCard({
    super.key,
    this.selectedImage,
    required this.onPickImage,
    this.onRemoveImage,
    this.height = 150.0,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedImage == null) {
      return _buildEmptyImagePicker();
    } else {
      return _buildSelectedImagePreview();
    }
  }

  Widget _buildEmptyImagePicker() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onPickImage,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                "Ajouter une image",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            if (onRemoveImage != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: onRemoveImage,
                    tooltip: "Supprimer l'image",
                    iconSize: 22,
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.6),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: onPickImage,
                  tooltip: "Modifier l'image",
                  iconSize: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
