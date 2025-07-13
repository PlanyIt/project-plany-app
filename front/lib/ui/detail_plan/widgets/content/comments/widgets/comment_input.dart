import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Color categoryColor;
  final bool isUploadingImage;
  final bool isSubmitting;
  final File? selectedImage;
  final String? existingImageUrl;
  final Function(File) onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onClearExistingImage;
  final VoidCallback onSubmit;
  final String hintText;

  const CommentInput({
    super.key,
    required this.controller,
    this.focusNode,
    required this.categoryColor,
    required this.isUploadingImage,
    this.selectedImage,
    this.existingImageUrl,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onClearExistingImage,
    required this.onSubmit,
    this.hintText = 'Ajouter un commentaire...',
    required this.isSubmitting,
  });

  Future<bool> _checkAndRequestPermissions() async {
    if (await Permission.photos.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    if (await Permission.photos.status.isGranted) return true;
    return (await Permission.photos.request()).isGranted;
  }

  Future<void> _pickImage(BuildContext context) async {
    if (!await _checkAndRequestPermissions()) return;

    final picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) onPickImage(File(pickedFile.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          if (selectedImage != null)
            _buildImagePreview(FileImage(selectedImage!), onRemoveImage)
          else if (existingImageUrl != null)
            _buildImagePreview(
                NetworkImage(existingImageUrl!), onClearExistingImage),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: categoryColor),
                onPressed: isUploadingImage ? null : () => _pickImage(context),
                splashRadius: 20,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
      ImageProvider imageProvider, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 120,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final color = isSubmitting ? Colors.grey : categoryColor;
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: 32,
      height: 32,
      child: isSubmitting
          ? const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 16),
              onPressed: onSubmit,
              padding: EdgeInsets.zero,
              splashRadius: 16,
            ),
    );
  }
}
