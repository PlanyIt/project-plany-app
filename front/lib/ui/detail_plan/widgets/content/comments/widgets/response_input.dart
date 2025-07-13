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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedImage != null) _buildSelectedImage(),
          if (selectedImage == null && existingImageUrl != null)
            _buildExistingImage(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Répondre à ce commentaire...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(Icons.camera_alt,
                      onTap: isUploadingImage
                          ? null
                          : () => _directImagePicker(context)),
                  isUploadingImage
                      ? _buildLoadingIndicator()
                      : _buildSubmitButton(),
                  _buildCancelButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
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
            child: _buildCloseIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 100,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
            onTap: onRemoveImage,
            child: _buildCloseIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.close,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: categoryColor, size: 16),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 16,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: categoryColor,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSubmitting ? Colors.grey[400] : categoryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white, size: 16),
        onPressed: isSubmitting ? null : () => onSubmit(parentComment.id!),
        padding: EdgeInsets.zero,
        splashRadius: 16,
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey, size: 16),
        onPressed: onCancel,
        padding: EdgeInsets.zero,
        splashRadius: 16,
      ),
    );
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
      debugPrint('Erreur lors de la sélection d\'image pour la réponse: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }
}
