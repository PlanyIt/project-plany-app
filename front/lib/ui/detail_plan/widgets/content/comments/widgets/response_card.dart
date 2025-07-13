import 'package:flutter/material.dart';
import '../../../../../../domain/models/comment/comment.dart';
import '../../../../../../domain/models/user/user.dart';
import '../../../../view_models/comment_viewmodel.dart';

class ResponseCard extends StatefulWidget {
  final Comment parentComment;
  final Comment response;
  final String? currentUserId;
  final Color categoryColor;
  final Function(Comment) onShowOptions;
  final Function(Comment, bool) onLikeToggle;
  final String Function(DateTime) formatTimeAgo;
  final CommentViewModel viewModel;

  const ResponseCard({
    super.key,
    required this.parentComment,
    required this.response,
    required this.currentUserId,
    required this.categoryColor,
    required this.onShowOptions,
    required this.onLikeToggle,
    required this.formatTimeAgo,
    required this.viewModel,
  });

  @override
  ResponseCardState createState() => ResponseCardState();
}

class ResponseCardState extends State<ResponseCard> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  User? _userProfile;
  bool _isLoadingProfile = true;

  Future<void> _loadUserProfile() async {
    try {
      if (widget.response.user?.id == null) {
        setState(() {
          _userProfile = User(
            id: 'unknown',
            username: 'Utilisateur inconnu',
            email: '',
            photoUrl: null,
            description: null,
            isPremium: false,
            followers: [],
            following: [],
          );
          _isLoadingProfile = false;
        });
        return;
      }

      final userProfile =
          await widget.viewModel.getUserProfile(widget.response.user!.id!);

      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userProfile = User(
            id: widget.response.user?.id ?? 'unknown',
            username: 'Utilisateur inconnu',
            email: '',
            photoUrl: null,
            description: null,
            isPremium: false,
            followers: [],
            following: [],
          );
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = widget.response.user?.id == widget.currentUserId;
    final bool isLiked =
        widget.response.likes?.contains(widget.currentUserId) ?? false;

    return GestureDetector(
      onLongPress: isOwner ? () => widget.onShowOptions(widget.response) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _isLoadingProfile
                  ? Center(
                      child: SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.categoryColor,
                          )),
                    )
                  : (_userProfile?.photoUrl != null &&
                          _userProfile!.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _userProfile!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person,
                                  size: 16, color: Colors.grey[600]);
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 16, color: Colors.grey[600])),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _isLoadingProfile
                              ? 'Chargement...'
                              : (_userProfile?.username ??
                                  'Utilisateur inconnu'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.response.createdAt != null
                            ? widget.formatTimeAgo(widget.response.createdAt!)
                            : 'Il y a 1h',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      if (isOwner)
                        GestureDetector(
                          onTap: () => widget.onShowOptions(widget.response),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  widget.categoryColor.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color:
                                  widget.categoryColor.withValues(alpha: 0.8),
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.response.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (widget.response.imageUrl != null &&
                      widget.response.imageUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6, bottom: 6),
                      height: 100,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.response.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () => widget.onLikeToggle(widget.response, isLiked),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (widget.response.likes?.length ?? 0).toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
