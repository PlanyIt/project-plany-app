import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../data/repositories/comment/comment_repository.dart';
import '../../../../domain/models/comment/comment.dart';
import '../../../../domain/models/user/user.dart';
import '../../../../utils/result.dart';

/// -------------------------
/// STATE
/// -------------------------
class CommentInputState {
  final File? selectedImage;
  final String? existingImageUrl;
  final bool isSubmitting;
  final bool isUploadingImage;
  final String? errorMessage;

  const CommentInputState({
    this.selectedImage,
    this.existingImageUrl,
    this.isSubmitting = false,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  CommentInputState copyWith({
    File? selectedImage,
    String? existingImageUrl,
    bool? isSubmitting,
    bool? isUploadingImage,
    String? errorMessage,
  }) {
    return CommentInputState(
      selectedImage: selectedImage ?? this.selectedImage,
      existingImageUrl: existingImageUrl ?? this.existingImageUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage,
    );
  }
}

class CommentInputViewModel {
  final CommentRepository _commentRepository;
  final String planId;
  final User? _currentUser;

  final ValueNotifier<CommentInputState> state =
      ValueNotifier(const CommentInputState());

  CommentInputViewModel({
    required AuthRepository authRepository,
    required CommentRepository commentRepository,
    required this.planId,
  })  : _commentRepository = commentRepository,
        _currentUser = authRepository.currentUser;

  void setSelectedImage(File file) {
    state.value = state.value.copyWith(selectedImage: file);
  }

  void removeSelectedImage() {
    state.value = state.value.copyWith(selectedImage: null);
  }

  void setExistingImageUrl(String? url) {
    state.value = state.value.copyWith(existingImageUrl: url);
  }

  void clearExistingImageUrl() {
    state.value = state.value.copyWith(existingImageUrl: null);
  }

  Future<Comment?> createComment(String content,
      {String? parentCommentId, String? overrideImageUrl}) async {
    if (state.value.isSubmitting) return null;

    final hasText = content.trim().isNotEmpty;
    final hasImage = overrideImageUrl != null ||
        state.value.selectedImage != null ||
        state.value.existingImageUrl != null;
    if (!hasText && !hasImage) {
      state.value = state.value
          .copyWith(errorMessage: "Veuillez ajouter du texte ou une image.");
      return null;
    }

    state.value = state.value.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final imageUrl = overrideImageUrl ?? await _uploadImageIfNeeded();
      final newComment = Comment(
        content: content.trim(),
        planId: planId,
        parentId: parentCommentId,
        imageUrl: imageUrl,
        user: _currentUser,
      );

      final result = parentCommentId == null
          ? await _commentRepository.createComment(planId, newComment)
          : await _commentRepository.respondToComment(
              parentCommentId, newComment);

      if (result is Ok<Comment>) {
        clear();
        return result.value;
      } else if (result is Error<Comment>) {
        state.value =
            state.value.copyWith(errorMessage: "Erreur : ${result.error}");
        return null;
      }
    } finally {
      state.value = state.value.copyWith(isSubmitting: false);
    }
    return null;
  }

  Future<Comment?> editComment(Comment commentToEdit, String content,
      {File? newImageFile, bool removeImage = false}) async {
    if (state.value.isSubmitting) return null;

    state.value = state.value.copyWith(isSubmitting: true, errorMessage: null);

    try {
      String? imageUrl;

      if (removeImage) {
        imageUrl = null;
      } else if (newImageFile != null) {
        imageUrl = await uploadImage(newImageFile);
      } else {
        imageUrl = commentToEdit.imageUrl;
      }

      final updatedComment =
          commentToEdit.copyWith(content: content.trim(), imageUrl: imageUrl);

      final result = await _commentRepository.editComment(
          commentToEdit.id!, updatedComment);

      if (result is Ok<void>) {
        clear();
        return updatedComment;
      } else if (result is Error<void>) {
        state.value =
            state.value.copyWith(errorMessage: "Erreur : ${result.error}");
        return null;
      }
    } finally {
      state.value = state.value.copyWith(isSubmitting: false);
    }
    return null;
  }

  Future<String?> _uploadImageIfNeeded() async {
    if (state.value.selectedImage != null) {
      state.value = state.value.copyWith(isUploadingImage: true);

      try {
        final result =
            await _commentRepository.uploadImage(state.value.selectedImage!);
        if (result is Ok<String>) {
          return result.value;
        } else if (result is Error<String>) {
          throw Exception("Erreur lors de l'upload : ${result.error}");
        }
      } finally {
        state.value = state.value.copyWith(isUploadingImage: false);
      }
    }
    return state.value.existingImageUrl;
  }

  Future<String?> uploadImage(File file) async {
    state.value = state.value.copyWith(isUploadingImage: true);

    try {
      final result = await _commentRepository.uploadImage(file);
      if (result is Ok<String>) {
        return result.value;
      }
    } finally {
      state.value = state.value.copyWith(isUploadingImage: false);
    }
    return null;
  }

  void clear() {
    state.value = const CommentInputState();
  }
}
