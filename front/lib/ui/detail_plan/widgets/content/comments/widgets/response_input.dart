import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../domain/models/comment/comment.dart';

class ResponseInput extends StatelessWidget {
  final Comment parentComment;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color categoryColor;
  final File? selectedImage;
  final String? existingImageUrl;
  final bool isUploadingImage;
  final bool isSubmitting;
  final Function(File) onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onCancel;
  final Function(String) onSubmit;

  const ResponseInput({
    super.key,
    required this.parentComment,
    required this.controller,
    required this.focusNode,
    required this.categoryColor,
    this.selectedImage,
    this.existingImageUrl,
    required this.isUploadingImage,
    required this.isSubmitting,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onCancel,
    required this.onSubmit,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        onPickImage(imageFile);
      }
    } catch (e) {
      debugPrint('Erreur image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = categoryColor.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            _buildImagePreview(NetworkImage(existingImageUrl!), onRemoveImage),
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
                  cursorColor: categoryColor,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    fillColor: Colors.white,
                    hintText: 'Répondre à ce commentaire...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: categoryColor),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              _buildSubmitButton(),
              const SizedBox(width: 4),
              _buildCancelButton(),
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
          height: 140,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
      width: 36,
      height: 36,
      child: isSubmitting
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () => onSubmit(parentComment.id!),
              padding: EdgeInsets.zero,
              splashRadius: 18,
            ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      width: 36,
      height: 36,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 18),
        onPressed: onCancel,
        padding: EdgeInsets.zero,
        splashRadius: 18,
      ),
    );
  }
}
