import 'package:flutter/material.dart';
import 'package:front/domain/models/comment.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/ui/detail_plan/widgets/content/comments/widgets/response_card.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final String? currentUserId;
  final Color categoryColor;
  final bool isResponse;
  final Function(Comment) onShowOptions;
  final Function(Comment, bool) onLikeToggle;
  final Function(String) onReplyTap;
  final Function(String) loadResponses;
  final Map<String, List<Comment>> responses;
  final Map<String, bool> showAllResponsesMap;
  final Function(String) onToggleResponses;
  final String? respondingToCommentId;
  final Widget? responseInputWidget;
  final String Function(DateTime) formatTimeAgo;
  final Future<User?> Function(String userId) getUserProfile;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserId,
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
    required this.getUserProfile,
  });

  @override
  CommentCardState createState() => CommentCardState();
}

class CommentCardState extends State<CommentCard> {
  User? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await widget.getUserProfile(widget.comment.userId!);

      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLiked =
        widget.comment.likes?.contains(widget.currentUserId) ?? false;
    final bool isOwner = widget.comment.userId == widget.currentUserId;

    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: widget.isResponse ? 32 : 0,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(isOwner),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.comment.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (widget.comment.imageUrl != null &&
              widget.comment.imageUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 10),
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.comment.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: widget.categoryColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Erreur de chargement d'image: $error");
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          _buildCommentActions(isLiked),
          _buildResponsesSection(),
          if (widget.respondingToCommentId == widget.comment.id &&
              widget.responseInputWidget != null)
            widget.responseInputWidget!,
        ],
      ),
    );
  }

  Widget _buildCommentHeader(bool isOwner) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isLoadingProfile
              ? const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : (_userProfile?.photoUrl != null &&
                      _userProfile!.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _userProfile!.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Erreur de chargement de photo: $error");
                          return Icon(Icons.person,
                              size: 22, color: Colors.grey[600]);
                        },
                        headers: const {"cache-control": "no-cache"},
                      ),
                    )
                  : Icon(Icons.person, size: 22, color: Colors.grey[600])),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isLoadingProfile
                          ? 'Chargement...'
                          : (_userProfile?.username ?? 'Utilisateur inconnu'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.comment.createdAt != null
                        ? widget.formatTimeAgo(widget.comment.createdAt!)
                        : 'Il y a 2h',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (isOwner)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Vous',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isOwner)
          GestureDetector(
            onTap: () => widget.onShowOptions(widget.comment),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_vert,
                color: widget.categoryColor.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
          )
        else
          SizedBox(width: 36),
      ],
    );
  }

  Widget _buildCommentActions(bool isLiked) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => widget.onLikeToggle(widget.comment, isLiked),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  (widget.comment.likes?.length ?? 0).toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isLiked ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => widget.onReplyTap(widget.comment.id!),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              backgroundColor: widget.respondingToCommentId == widget.comment.id
                  ? widget.categoryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: widget.respondingToCommentId == widget.comment.id
                      ? widget.categoryColor
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Répondre',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.respondingToCommentId == widget.comment.id
                        ? widget.categoryColor
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesSection() {
    if (!widget.responses.containsKey(widget.comment.id) ||
        widget.responses[widget.comment.id]!.isEmpty) {
      return Container();
    }

    final commentResponses = widget.responses[widget.comment.id]!;
    final showAll = widget.showAllResponsesMap[widget.comment.id] ?? false;

    if (widget.comment.responses.isNotEmpty &&
        (!widget.responses.containsKey(widget.comment.id) ||
            widget.responses[widget.comment.id]!.isEmpty)) {
      return TextButton.icon(
        onPressed: () => widget.loadResponses(widget.comment.id!),
        icon: Icon(Icons.forum_outlined, size: 14, color: widget.categoryColor),
        label: Text(
          "Voir ${widget.comment.responses.length} réponses",
          style: TextStyle(color: widget.categoryColor),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.forum_outlined,
                    size: 14, color: widget.categoryColor),
                const SizedBox(width: 4),
                Text(
                  "Réponses (${commentResponses.length})",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.categoryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: commentResponses.length,
            itemBuilder: (context, index) {
              final response = commentResponses[index];
              return ResponseCard(
                key: ValueKey('${response.id}_${response.userId}'),
                parentComment: widget.comment,
                response: response,
                currentUserId: widget.currentUserId,
                categoryColor: widget.categoryColor,
                onShowOptions: widget.onShowOptions,
                onLikeToggle: widget.onLikeToggle,
                formatTimeAgo: widget.formatTimeAgo,
              );
            },
          ),
          if (commentResponses.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () => widget.onToggleResponses(widget.comment.id!),
                child: Row(
                  children: [
                    Icon(
                      showAll
                          ? Icons.keyboard_arrow_up
                          : Icons.subdirectory_arrow_right,
                      size: 14,
                      color: widget.categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      showAll
                          ? 'Réduire les réponses'
                          : 'Voir ${commentResponses.length - 1} réponses de plus',
                      style: TextStyle(
                        color: widget.categoryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
