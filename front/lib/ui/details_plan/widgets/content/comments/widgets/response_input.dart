import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/domain/models/comment/comment.dart';

class ResponseInput extends StatelessWidget {
  final Comment parentComment;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color categoryColor;
  final bool isUploadingImage;
  final bool isSubmitting;
  final File? selectedImage;
  final Function(File) onPickImage;
  final Function() onRemoveImage;
  final Function(String) onSubmit;
  final Function() onCancel;

  const ResponseInput({
    super.key,
    required this.parentComment,
    required this.controller,
    required this.focusNode,
    required this.categoryColor,
    required this.isUploadingImage,
    required this.isSubmitting,
    this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
    required this.onCancel,
  });

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with cancel button
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: categoryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Répondre à un commentaire',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Selected image preview
          if (selectedImage != null)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
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
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: categoryColor,
                  size: 20,
                ),
                onPressed:
                    isUploadingImage ? null : () => _directImagePicker(context),
                splashRadius: 16,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Votre réponse...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              isUploadingImage
                  ? const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
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
                          size: 14,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => onSubmit(controller.text.trim()),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
