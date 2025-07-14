import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/models/comment/comment.dart';
import '../../widgets/content/comments/widgets/response_input.dart';
import 'comment_input_viewmodel.dart';
import 'comment_list_viewmodel.dart';

class CommentSectionViewModel extends ChangeNotifier {
  final CommentListViewModel commentListViewModel;
  final CommentInputViewModel commentInputViewModel;

  final TextEditingController parentController = TextEditingController();
  final FocusNode parentFocusNode = FocusNode();

  final Map<String, TextEditingController> responseControllers = {};
  final Map<String, FocusNode> responseFocusNodes = {};
  final Map<String, File?> responseImages = {};
  final Map<String, bool> responseUploading = {};
  final Map<String, bool> responseSubmitting = {};

  final ValueNotifier<String?> respondingToCommentId = ValueNotifier(null);

  File? parentImage;
  bool isParentSubmitting = false;

  CommentSectionViewModel({
    required this.commentListViewModel,
    required this.commentInputViewModel,
  });

  @override
  void dispose() {
    parentController.dispose();
    parentFocusNode.dispose();
    for (final c in responseControllers.values) {
      c.dispose();
    }
    for (final f in responseFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void setParentImage(File file) {
    parentImage = file;
    notifyListeners();
  }

  void clearParentImage() {
    parentImage = null;
    notifyListeners();
  }

  Future<void> saveComment() async {
    if (parentController.text.trim().isEmpty && parentImage == null) return;

    isParentSubmitting = true;
    notifyListeners();

    final inputVM = commentInputViewModel;
    String? imageUrl;
    if (parentImage != null) {
      imageUrl = await inputVM.uploadImage(parentImage!);
    }

    final comment = await inputVM.createComment(
      parentController.text,
      overrideImageUrl: imageUrl,
    );

    isParentSubmitting = false;
    notifyListeners();

    if (comment != null) {
      parentController.clear();
      parentFocusNode.unfocus();
      inputVM.clear();
      clearParentImage();
      await commentListViewModel.loadComments(reset: true);
    }
  }

  void startRespondingTo(String commentId) {
    respondingToCommentId.value = commentId;
    commentListViewModel.startRespondingTo(commentId);
    responseFocusNodes.putIfAbsent(commentId, () => FocusNode()).requestFocus();
    notifyListeners();
  }

  void cancelResponding() {
    respondingToCommentId.value = null;
    commentListViewModel.cancelResponding();
    notifyListeners();
  }

  void setResponseImage(String commentId, File file) {
    responseImages[commentId] = file;
    notifyListeners();
  }

  void clearResponseImage(String commentId) {
    responseImages.remove(commentId);
    notifyListeners();
  }

  Widget buildResponseInput(
    BuildContext context,
    Comment comment,
    Color categoryColor,
  ) {
    final inputVM = commentInputViewModel;
    final listVM = commentListViewModel;

    final responseController = responseControllers.putIfAbsent(
        comment.id!, () => TextEditingController());
    final responseFocusNode =
        responseFocusNodes.putIfAbsent(comment.id!, () => FocusNode());

    final selectedImage = responseImages[comment.id];
    final isSubmitting = responseSubmitting[comment.id] ?? false;
    final isUploading = responseUploading[comment.id] ?? false;

    return ResponseInput(
      parentComment: comment,
      controller: responseController,
      focusNode: responseFocusNode,
      categoryColor: categoryColor,
      selectedImage: selectedImage,
      existingImageUrl: null,
      isUploadingImage: isUploading || inputVM.state.value.isUploadingImage,
      isSubmitting: isSubmitting,
      onPickImage: (file) => setResponseImage(comment.id!, file),
      onRemoveImage: () => clearResponseImage(comment.id!),
      onCancel: () {
        responseFocusNode.unfocus();
        cancelResponding();
        responseController.clear();
        responseImages.remove(comment.id);
        responseSubmitting.remove(comment.id);
        responseUploading.remove(comment.id);
        notifyListeners();
      },
      onSubmit: (commentId) async {
        responseUploading[commentId] = true;
        notifyListeners();

        String? imageUrl;
        final selectedFile = responseImages[commentId];
        if (selectedFile != null) {
          final result = await inputVM.uploadImage(selectedFile);
          if (result != null) {
            imageUrl = result;
          }
        }

        responseUploading[commentId] = false;
        responseSubmitting[commentId] = true;
        notifyListeners();

        final commentResponse = await inputVM.createComment(
          responseController.text,
          parentCommentId: commentId,
          overrideImageUrl: imageUrl,
        );

        responseSubmitting[commentId] = false;
        responseImages.remove(commentId);
        notifyListeners();

        if (commentResponse != null) {
          responseFocusNode.unfocus();
          listVM.addResponse(commentId, commentResponse);
          responseController.clear();
          cancelResponding();
        }
      },
    );
  }
}
