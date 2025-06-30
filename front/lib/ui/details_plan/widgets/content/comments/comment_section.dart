import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'package:front/providers/providers.dart';
import 'package:front/utils/result.dart';
import 'dart:io';

// Providers pour l'état des commentaires
final commentsProvider =
    StateProvider.family<List<Comment>, String>((ref, planId) => []);
final selectedImageProvider = StateProvider<File?>((ref) => null);
final isUploadingImageProvider = StateProvider<bool>((ref) => false);
final respondingToCommentProvider = StateProvider<String?>((ref) => null);

class CommentSection extends ConsumerStatefulWidget {
  final String planId;
  final Function(int)? onCommentCountChanged;
  final bool isEmbedded;
  final Color categoryColor;

  const CommentSection({
    super.key,
    required this.planId,
    this.onCommentCountChanged,
    this.isEmbedded = false,
    this.categoryColor = const Color(0xFF3425B5),
  });

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _hasInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasInitialized) {
        await _initializeComments();
        _hasInitialized = true;
      }
    });
  }

  Future<void> _initializeComments() async {
    if (_hasInitialized) return;

    try {
      final commentRepository = ref.read(commentRepositoryProvider);
      final result = await commentRepository.getCommentsByPlanId(widget.planId);
      if (result is Ok<List<Comment>>) {
        ref.read(commentsProvider(widget.planId).notifier).state = result.value;
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des commentaires: $e');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.planId));
    final selectedImage = ref.watch(selectedImageProvider);
    final isUploadingImage = ref.watch(isUploadingImageProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec style moderne
          _buildModernHeader(comments),

          const SizedBox(height: 20),

          // Input moderne pour les commentaires
          _buildModernCommentInput(selectedImage, isUploadingImage),

          const SizedBox(height: 24),

          // Liste des commentaires avec design moderne
          _buildModernCommentsList(comments),
        ],
      ),
    );
  }

  Widget _buildModernHeader(List<Comment> comments) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: widget.categoryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commentaires',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${comments.length} ${comments.length <= 1 ? 'commentaire' : 'commentaires'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernCommentInput(File? selectedImage, bool isUploadingImage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (selectedImage != null)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(selectedImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(selectedImageProvider.notifier).state = null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: widget.categoryColor,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: isUploadingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: _handleCommentSubmitted,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: widget.categoryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Publier',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCommentsList(List<Comment> comments) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun commentaire pour le moment',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez le premier à commenter !',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildModernCommentCard(comment);
      },
    );
  }

  Widget _buildModernCommentCard(Comment comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header du commentaire avec avatar et infos utilisateur
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: widget.categoryColor.withOpacity(0.1),
                backgroundImage:
                    comment.userId != null && comment.userId!.isNotEmpty
                        ? NetworkImage(comment.userId!)
                        : null,
                child: comment.userId == null || comment.userId!.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        color: widget.categoryColor,
                        size: 24,
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Infos utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userId ?? 'Utilisateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Si c'est le propriétaire du commentaire, afficher une étiquette "Vous"
                        if (comment.userId == 'current-user-id') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Vous',
                              style: TextStyle(
                                color: widget.categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.createdAt != null
                          ? _formatTimeAgo(comment.createdAt!)
                          : 'Maintenant',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu options pour le propriétaire
              if (comment.userId == 'current-user-id')
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteComment(comment.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Contenu du commentaire
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),

          // Image du commentaire (si présente)
          if (comment.imageUrl != null && comment.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                comment.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      ref.read(selectedImageProvider.notifier).state = File(image.path);
    }
  }

  Future<void> _handleCommentSubmitted() async {
    final content = _commentController.text.trim();
    final selectedImage = ref.read(selectedImageProvider);

    if (content.isEmpty && selectedImage == null) return;

    try {
      ref.read(isUploadingImageProvider.notifier).state = true;

      // Créer le commentaire
      final comment = Comment(
        content: content,
        planId: widget.planId,
        userId:
            'current-user-id', // À remplacer par l'ID de l'utilisateur actuel
        imageUrl: null, // L'upload d'image sera implémenté plus tard
        likes: [],
        responses: [],
        createdAt: DateTime.now(),
      );

      // Ajouter le commentaire à la liste
      final currentComments = ref.read(commentsProvider(widget.planId));
      ref.read(commentsProvider(widget.planId).notifier).state = [
        comment,
        ...currentComments
      ];

      // Nettoyer les champs
      _commentController.clear();
      ref.read(selectedImageProvider.notifier).state = null;
      _commentFocusNode.unfocus();

      widget.onCommentCountChanged?.call(currentComments.length + 1);
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
    } finally {
      ref.read(isUploadingImageProvider.notifier).state = false;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final commentRepository = ref.read(commentRepositoryProvider);
      final result = await commentRepository.deleteComment(commentId);

      if (result is Ok) {
        final currentComments = ref.read(commentsProvider(widget.planId));
        final updatedComments =
            currentComments.where((c) => c.id != commentId).toList();
        ref.read(commentsProvider(widget.planId).notifier).state =
            updatedComments;
        widget.onCommentCountChanged?.call(updatedComments.length);
      }
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
    }
  }
}
