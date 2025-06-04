import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Color categoryColor;
  final bool isUploadingImage;
  final bool isSubmitting;
  final File? selectedImage;
  final String? existingImageUrl;
  final Function(File) onPickImage;
  final Function() onRemoveImage;
  final Function() onClearExistingImage;
  final Function() onSubmit;
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

  Future<bool> checkAndRequestPermissions() async {
    if (await Permission.photos.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    if (await Permission.photos.status.isGranted) {
      return true;
    }

    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<void> _directImagePicker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        onPickImage(imageFile);
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          if (selectedImage != null)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemoveImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (selectedImage == null && existingImageUrl != null)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(existingImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onClearExistingImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: categoryColor,
                ),
                onPressed:
                    isUploadingImage ? null : () => _directImagePicker(context),
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
              isUploadingImage
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isSubmitting ? Colors.grey : categoryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: isSubmitting ? null : onSubmit,
                        padding: EdgeInsets.zero,
                        splashRadius: 16,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
