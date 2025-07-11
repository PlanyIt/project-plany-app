import 'package:flutter/material.dart';
import 'package:front/domain/models/comment.dart';
import 'package:front/domain/models/user.dart';
import 'package:front/services/user_service.dart';

class ResponseCard extends StatefulWidget {
  final Comment parentComment;
  final Comment response;
  final String? currentUserId;
  final Color categoryColor;
  final Function(Comment) onShowOptions;
  final Function(Comment, bool) onLikeToggle;
  final String Function(DateTime) formatTimeAgo;

  const ResponseCard({
    super.key,
    required this.parentComment,
    required this.response,
    required this.currentUserId,
    required this.categoryColor,
    required this.onShowOptions,
    required this.onLikeToggle,
    required this.formatTimeAgo,
  });

  @override
  _ResponseCardState createState() => _ResponseCardState();
}

class _ResponseCardState extends State<ResponseCard> {
  final UserService _userService = UserService();
  User? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      if (widget.response.userId == null) {
        throw Exception('User ID is null');
      }
      final userProfile =
          await _userService.getUserProfile(widget.response.userId!);

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
    final bool isOwner = widget.response.userId == widget.currentUserId;
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
