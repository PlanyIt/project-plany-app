import 'package:flutter/material.dart';
import '../../../../../../domain/models/comment/comment.dart';
import '../../../../../../domain/models/user/user.dart';
import '../../../../view_models/comment/comment_input_viewmodel.dart';
import '../../../../view_models/comment/comment_list_viewmodel.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final Color categoryColor;
  final bool isResponse;
  final Function(Comment) onShowOptions;
  final Function(Comment) onLikeToggle;
  final Function(String) onReplyTap;
  final Function(String) loadResponses;
  final Map<String, List<Comment>> responses;
  final Map<String, bool> showAllResponsesMap;
  final Function(String) onToggleResponses;
  final String? respondingToCommentId;
  final Widget? responseInputWidget;
  final String Function(DateTime) formatTimeAgo;
  final CommentListViewModel listViewModel;
  final CommentInputViewModel inputViewModel;

  const CommentCard({
    super.key,
    required this.comment,
    required this.categoryColor,
    this.isResponse = false,
    required this.onShowOptions,
    required this.onLikeToggle,
    required this.onReplyTap,
    required this.loadResponses,
    required this.responses,
    required this.showAllResponsesMap,
    required this.onToggleResponses,
    required this.respondingToCommentId,
    this.responseInputWidget,
    required this.formatTimeAgo,
    required this.listViewModel,
    required this.inputViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = comment.user?.id == listViewModel.currentUser?.id;
    final isLiked =
        comment.likes?.contains(listViewModel.currentUser?.id) ?? false;
    final user = comment.user;
    final hasImage = comment.imageUrl?.isNotEmpty ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 8, left: isResponse ? 32 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user, isOwner),
          if (comment.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment.content, style: const TextStyle(fontSize: 14)),
          ],
          if (hasImage) _buildImage(comment.imageUrl!),
          _buildActions(isLiked),
          _buildResponses(),
          if (responseInputWidget != null) ...[
            const SizedBox(height: 8),
            responseInputWidget!,
          ]
        ],
      ),
    );
  }

  Widget _buildHeader(User? user, bool isOwner) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 20,
          backgroundImage:
              user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
          child: user?.photoUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.username ?? "Utilisateur inconnu",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(formatTimeAgo(comment.createdAt ?? DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        if (isOwner)
          IconButton(
            icon: Icon(Icons.more_vert, color: categoryColor),
            onPressed: () => onShowOptions(comment),
          )
      ],
    );
  }

  Widget _buildImage(String url) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 10),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, _) => Container(
          color: Colors.grey[200],
          child:
              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildActions(bool isLiked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min, // Important : garde le bloc compact
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isLiked ? categoryColor : Colors.grey,
              ),
              onPressed: () => onLikeToggle(comment),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
            Text('${comment.likes?.length ?? 0}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 22),
        if (!isResponse)
          TextButton.icon(
            onPressed: () => onReplyTap(comment.id!),
            icon:
                Icon(Icons.chat_bubble_outline, size: 16, color: categoryColor),
            label: Text(
              'Répondre',
              style: TextStyle(fontSize: 12, color: categoryColor),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Widget _buildResponses() {
    final responsesList = responses[comment.id];
    final showAll = showAllResponsesMap[comment.id] ?? false;
    final nbResponses = comment.responses.length;

    if (nbResponses == 0) return const SizedBox();

    if (responsesList == null || responsesList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TextButton(
          onPressed: () async {
            await loadResponses(comment.id!);
            onToggleResponses(comment.id!);
          },
          child: Text(
            'Voir $nbResponses réponse${nbResponses > 1 ? "s" : ""}',
            style: TextStyle(fontSize: 12, color: categoryColor),
          ),
        ),
      );
    }

    final responsesToShow = showAll ? responsesList : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...responsesToShow.map((response) => CommentCard(
              key: ValueKey(response.id),
              comment: response,
              categoryColor: categoryColor,
              isResponse: true,
              onShowOptions: onShowOptions,
              onLikeToggle: onLikeToggle,
              onReplyTap: onReplyTap,
              loadResponses: loadResponses,
              responses: responses,
              showAllResponsesMap: showAllResponsesMap,
              onToggleResponses: onToggleResponses,
              respondingToCommentId: respondingToCommentId,
              responseInputWidget: null,
              formatTimeAgo: formatTimeAgo,
              listViewModel: listViewModel,
              inputViewModel: inputViewModel,
            )),
        if (!isResponse)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () => onToggleResponses(comment.id!),
              child: Text(
                showAll
                    ? 'Réduire'
                    : 'Voir ${responsesList.length} réponse${responsesList.length > 1 ? "s" : ""}',
                style: TextStyle(fontSize: 12, color: categoryColor),
              ),
            ),
          ),
      ],
    );
  }
}
