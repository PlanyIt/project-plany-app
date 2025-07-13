import 'package:flutter/material.dart';
import '../../../../../domain/models/comment/comment.dart';
import '../../../../../utils/helpers.dart';
import '../../../view_models/comment/comment_list_viewmodel.dart';
import '../../../view_models/comment/comment_section_viewmodel.dart';
import '../../../view_models/plan_details_viewmodel.dart';
import 'widgets/comment_card.dart';
import 'widgets/comment_input.dart';
import 'widgets/edit_comment_dialog.dart';
import 'widgets/empty_state.dart';
import 'widgets/option_sheet.dart';

class CommentSection extends StatelessWidget {
  final PlanDetailsViewModel planDetailsViewModel;
  final CommentSectionViewModel viewModel;
  final bool isEmbedded;

  const CommentSection({
    super.key,
    required this.planDetailsViewModel,
    required this.viewModel,
    this.isEmbedded = false,
  });

  Color get categoryColor =>
      planDetailsViewModel.planCategoryColor ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final listVM = planDetailsViewModel.commentListViewModel;
    final inputVM = planDetailsViewModel.commentInputViewModel;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return ValueListenableBuilder(
          valueListenable: listVM.state,
          builder: (context, state, _) {
            return Column(
              children: [
                _buildCommentInput(),
                if (inputVM.state.value.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      inputVM.state.value.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                if (!state.isLoading && state.comments.isEmpty)
                  const EmptyCommentsMessage(),
                if (!state.isLoading && state.comments.isNotEmpty)
                  ..._buildCommentList(
                      context, state, viewModel.respondingToCommentId.value),
                if (!state.isLoading && state.hasMoreComments)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextButton(
                      onPressed: () => planDetailsViewModel.commentListViewModel
                          .loadMoreComments(),
                      child: const Text('Charger plus de commentaires'),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    final inputVM = planDetailsViewModel.commentInputViewModel;

    return ValueListenableBuilder(
      valueListenable: inputVM.state,
      builder: (context, state, _) {
        return CommentInput(
          controller: viewModel.parentController,
          focusNode: viewModel.parentFocusNode,
          categoryColor: categoryColor,
          isUploadingImage: inputVM.state.value.isUploadingImage,
          isSubmitting: viewModel.isParentSubmitting,
          selectedImage: viewModel.parentImage,
          existingImageUrl: null,
          onPickImage: viewModel.setParentImage,
          onRemoveImage: viewModel.clearParentImage,
          onClearExistingImage: () {},
          onSubmit: () => viewModel.saveComment(planDetailsViewModel),
        );
      },
    );
  }

  List<Widget> _buildCommentList(
      BuildContext context, CommentListState state, String? respondingId) {
    final displayComments = state.comments;

    return displayComments
        .map(
          (comment) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommentCard(
                  key: ValueKey('${comment.id}_${comment.user?.id}'),
                  comment: comment,
                  categoryColor: categoryColor,
                  onShowOptions: (comment) =>
                      _showCommentOptions(context, comment),
                  onLikeToggle: (comment) => planDetailsViewModel
                      .commentListViewModel
                      .toggleLike(comment),
                  onReplyTap: viewModel.startRespondingTo,
                  loadResponses:
                      planDetailsViewModel.commentListViewModel.loadResponses,
                  responses: state.responses,
                  respondingToCommentId: state.respondingToCommentId,
                  responseInputWidget: null,
                  formatTimeAgo: (dt) => formatTimeAgo(dt),
                  listViewModel: planDetailsViewModel.commentListViewModel,
                  inputViewModel: planDetailsViewModel.commentInputViewModel,
                  showAllResponsesMap: state.showAllResponsesMap,
                  onToggleResponses: planDetailsViewModel
                      .commentListViewModel.toggleShowAllResponses,
                ),
                if (respondingId == comment.id)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 8),
                    child: viewModel.buildResponseInput(
                      context,
                      planDetailsViewModel,
                      comment,
                      categoryColor,
                    ),
                  ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _showCommentOptions(BuildContext context, Comment comment) {
    final listVM = planDetailsViewModel.commentListViewModel;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CommentOptionSheet(
          comment: comment,
          categoryColor: categoryColor,
          onEdit: () async {
            Navigator.pop(context);
            await showDialog(
              context: context,
              builder: (context) {
                return EditCommentDialog(
                  comment: comment,
                  inputViewModel: planDetailsViewModel.commentInputViewModel,
                  categoryColor: categoryColor,
                  onSuccess: () async {
                    if (comment.parentId != null) {
                      await listVM.loadResponses(comment.parentId!);
                    } else {
                      await listVM.loadComments(reset: true);
                    }
                  },
                );
              },
            );
          },
          onDelete: () async {
            Navigator.pop(context);
            if (comment.parentId != null) {
              await listVM.deleteResponse(comment.parentId!, comment.id!);
            } else {
              await listVM.deleteComment(comment.id!);
            }
          },
          isResponse: comment.parentId != null,
        );
      },
    );
  }
}
