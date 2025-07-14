import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../domain/models/comment/comment.dart';
import '../../../../view_models/comment/comment_input_viewmodel.dart';

class EditCommentDialog extends StatefulWidget {
  final Comment comment;
  final CommentInputViewModel inputViewModel;
  final Color categoryColor;
  final VoidCallback onSuccess;

  const EditCommentDialog({
    super.key,
    required this.comment,
    required this.inputViewModel,
    required this.categoryColor,
    required this.onSuccess,
  });

  @override
  State<EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<EditCommentDialog> {
  final TextEditingController _controller = TextEditingController();
  File? _newImageFile;
  bool _removeImage = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.comment.content;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImageFile = File(picked.path);
        _removeImage = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    await widget.inputViewModel.editComment(
      widget.comment,
      _controller.text,
      newImageFile: _newImageFile,
      removeImage: _removeImage,
    );

    setState(() => _isSubmitting = false);
    widget.onSuccess();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existingImage = widget.comment.imageUrl;

    final ImageProvider<Object>? imageProvider = _newImageFile != null
        ? FileImage(_newImageFile!) as ImageProvider<Object>
        : existingImage != null
            ? NetworkImage(existingImage)
            : null;

    return AlertDialog(
      title: const Text('Modifier le commentaire'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Ton commentaire',
              ),
            ),
            const SizedBox(height: 12),
            if (!_removeImage && imageProvider != null)
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _newImageFile = null;
                          _removeImage = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Changer l\'image'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.categoryColor,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
