import 'package:flutter/material.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/domain/models/user/user.dart';

class ResponseCard extends StatefulWidget {
  final Comment parentComment;
  final Comment response;
  final String? currentUserId;
  final Color categoryColor;
  final Function(Comment) onShowOptions;
  final Function(Comment, bool) onLikeToggle;
  final String Function(DateTime) formatTimeAgo;
  final Future<User?> Function(String userId) getUserProfile;

  const ResponseCard({
    super.key,
    required this.parentComment,
    required this.response,
    required this.currentUserId,
    required this.categoryColor,
    required this.onShowOptions,
    required this.onLikeToggle,
    required this.formatTimeAgo,
    required this.getUserProfile,
  });

  @override
  ResponseCardState createState() => ResponseCardState();
}

class ResponseCardState extends State<ResponseCard> {
  User? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await widget.getUserProfile(widget.response.userId!);
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
    final bool isLiked = widget.response.likes.contains(widget.currentUserId);
    final bool isOwner = widget.response.userId == widget.currentUserId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la réponse
          Row(
            children: [
              // Avatar plus petit pour les réponses
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.categoryColor.withOpacity(0.1),
                  border:
                      Border.all(color: widget.categoryColor.withOpacity(0.2)),
                ),
                child: _isLoadingProfile
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.categoryColor),
                        ),
                      )
                    : _userProfile?.photoUrl != null &&
                            _userProfile!.photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _userProfile!.photoUrl!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildAvatarFallback();
                              },
                            ),
                          )
                        : _buildAvatarFallback(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userProfile?.username ?? 'Utilisateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (_userProfile?.isPremium == true) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.response.createdAt != null)
                      Text(
                        widget.formatTimeAgo(widget.response.createdAt!),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (isOwner)
                GestureDetector(
                  onTap: () => widget.onShowOptions(widget.response),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                const SizedBox(width: 28),
            ],
          ),

          const SizedBox(height: 8),

          // Contenu de la réponse
          Text(
            widget.response.content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),

          // Image de la réponse si présente
          if (widget.response.imageUrl != null &&
              widget.response.imageUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.response.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Actions de la réponse
          Row(
            children: [
              InkWell(
                onTap: () => widget.onLikeToggle(widget.response, isLiked),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLiked
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isLiked ? Colors.red : Colors.grey[600],
                      ),
                      if (widget.response.likes.isNotEmpty) ...[
                        const SizedBox(width: 3),
                        Text(
                          '${widget.response.likes.length}',
                          style: TextStyle(
                            color: isLiked ? Colors.red : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    final username = _userProfile?.username ?? 'U';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.categoryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
