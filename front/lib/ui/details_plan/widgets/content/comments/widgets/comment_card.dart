import 'package:flutter/material.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/domain/models/user/user.dart';
import 'package:front/ui/details_plan/widgets/content/comments/widgets/response_card.dart';

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
    final bool isLiked = widget.comment.likes.contains(widget.currentUserId);
    final bool isOwner = widget.comment.userId == widget.currentUserId;

    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: widget.isResponse ? 32 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(isOwner),

          // Contenu du commentaire
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              widget.comment.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),

          // Image du commentaire si présente
          if (widget.comment.imageUrl != null &&
              widget.comment.imageUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.comment.imageUrl!),
                  fit: BoxFit.cover,
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
        // Avatar avec image de profil ou initiales
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.categoryColor.withOpacity(0.1),
            border: Border.all(
                color: widget.categoryColor.withOpacity(0.2), width: 2),
          ),
          child: _isLoadingProfile
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.categoryColor),
                  ),
                )
              : _userProfile?.photoUrl != null &&
                      _userProfile!.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _userProfile!.photoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback();
                        },
                      ),
                    )
                  : _buildAvatarFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _userProfile?.username ?? 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  if (_userProfile?.isPremium == true) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (widget.comment.createdAt != null)
                Text(
                  widget.formatTimeAgo(widget.comment.createdAt!),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_vert,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          )
        else
          const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    final username = _userProfile?.username ?? 'U';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.categoryColor, widget.categoryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentActions(bool isLiked) {
    return Row(
      children: [
        // Bouton like avec animation
        InkWell(
          onTap: () async {
            final success = await widget.onLikeToggle(widget.comment, isLiked);
            if (success && mounted) {
              // Animation de like
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isLiked
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLiked
                    ? Colors.red.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
                if (widget.comment.likes.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${widget.comment.likes.length}',
                    style: TextStyle(
                      color: isLiked ? Colors.red : Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Bouton répondre
        InkWell(
          onTap: () => widget.onReplyTap(widget.comment.id!),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.categoryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.reply,
                  size: 16,
                  color: widget.categoryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Répondre',
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsesSection() {
    if (!widget.responses.containsKey(widget.comment.id) ||
        widget.responses[widget.comment.id]!.isEmpty) {
      // Afficher un bouton pour charger les réponses si elles existent
      if (widget.comment.responses.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: InkWell(
            onTap: () => widget.loadResponses(widget.comment.id!),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: widget.categoryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 14,
                    color: widget.categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Voir ${widget.comment.responses.length} réponse${widget.comment.responses.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final commentResponses = widget.responses[widget.comment.id]!;
    final showAll = widget.showAllResponsesMap[widget.comment.id] ?? false;
    final responsesToShow =
        showAll ? commentResponses : commentResponses.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                size: 16,
                color: widget.categoryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Réponses (${commentResponses.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.categoryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: responsesToShow.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final response = responsesToShow[index];
              return ResponseCard(
                parentComment: widget.comment,
                response: response,
                currentUserId: widget.currentUserId,
                categoryColor: widget.categoryColor,
                onShowOptions: widget.onShowOptions,
                onLikeToggle: widget.onLikeToggle,
                formatTimeAgo: widget.formatTimeAgo,
                getUserProfile: widget.getUserProfile,
              );
            },
          ),
          if (commentResponses.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () => widget.onToggleResponses(widget.comment.id!),
                child: Text(
                  showAll
                      ? 'Masquer les réponses'
                      : 'Voir toutes les réponses (${commentResponses.length})',
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
