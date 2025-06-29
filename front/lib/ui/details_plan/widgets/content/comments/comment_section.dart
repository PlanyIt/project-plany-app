import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/ui/details_plan/view_models/details_plan_viewmodel.dart';
import 'package:front/domain/models/comment/comment.dart';
import 'dart:io';

class CommentSection extends StatefulWidget {
  final String planId;
  final DetailsPlanViewModel viewModel;
  final Function(int)? onCommentCountChanged;
  final bool isEmbedded;
  final Color categoryColor;

  const CommentSection({
    super.key,
    required this.planId,
    required this.viewModel,
    this.onCommentCountChanged,
    this.isEmbedded = false,
    this.categoryColor = const Color(0xFF3425B5),
  });

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  late DetailsPlanViewModel _viewModel;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _hasInitialized = false;
  String? _respondingToCommentId;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasInitialized) {
        await _initializeComments();
        setState(() {
          _hasInitialized = true;
        });
      }
    });
  }

  Future<void> _initializeComments() async {
    if (_hasInitialized) return;

    try {
      await _viewModel.initializeComments();
      if (_viewModel.plan != null) {
        await _viewModel.loadComments(reset: true);
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
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec style moderne
              _buildModernHeader(),

              const SizedBox(height: 20),

              // Input moderne pour les commentaires
              _buildModernCommentInput(),

              const SizedBox(height: 24),

              // Liste des commentaires avec design moderne
              _buildModernCommentsList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernHeader() {
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
                '${_viewModel.comments.length} ${_viewModel.comments.length <= 1 ? 'commentaire' : 'commentaires'}',
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

  Widget _buildModernCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Zone de texte
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

          // Image sélectionnée (si présente)
          if (_viewModel.selectedImage != null)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_viewModel.selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _viewModel.clearSelectedImage(),
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

          // Barre d'actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Bouton photo
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

                // Bouton publier
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: _viewModel.isUploadingImage
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

  Widget _buildModernCommentsList() {
    if (_viewModel.comments.isEmpty) {
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
      itemCount: _viewModel.comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final comment = _viewModel.comments[index];
        return _buildModernCommentCard(comment);
      },
    );
  }

  Widget _buildModernCommentCard(Comment comment) {
    return FutureBuilder<dynamic>(
      future: _viewModel.getUserProfile(comment.userId!),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isOwner = comment.userId == _viewModel.currentUserId;
        final isLiked = comment.likes.contains(_viewModel.currentUserId);

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
                        user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child: user?.photoUrl == null || user!.photoUrl!.isEmpty
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
                              user?.username ?? 'Utilisateur',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (isOwner) ...[
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
                              ? _viewModel.formatTimeAgo(comment.createdAt!)
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
                  if (isOwner)
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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: widget.categoryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
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

              const SizedBox(height: 16),

              // Actions du commentaire
              Row(
                children: [
                  // Bouton like
                  GestureDetector(
                    onTap: () => _viewModel.toggleLike(comment, isLiked),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          if (comment.likes.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likes.length}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isLiked ? Colors.red : Colors.grey[600],
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
                  GestureDetector(
                    onTap: () => _toggleResponseInput(comment.id!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _respondingToCommentId == comment.id
                            ? widget.categoryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: 16,
                            color: _respondingToCommentId == comment.id
                                ? widget.categoryColor
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Répondre',
                            style: TextStyle(
                              fontSize: 13,
                              color: _respondingToCommentId == comment.id
                                  ? widget.categoryColor
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Input de réponse (si actif)
              if (_respondingToCommentId == comment.id)
                _buildResponseInput(comment.id!),

              // Réponses existantes
              if (_viewModel.responses.containsKey(comment.id) &&
                  _viewModel.responses[comment.id]!.isNotEmpty)
                _buildResponsesList(comment.id!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponseInput(String commentId) {
    final responseController = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: responseController,
            decoration: InputDecoration(
              hintText: 'Écrire une réponse...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: null,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _respondingToCommentId = null),
                child: const Text('Annuler'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _handleResponseSubmitted(
                    commentId, responseController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.categoryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Répondre'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList(String commentId) {
    final responses = _viewModel.responses[commentId]!;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: responses.map((response) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<dynamic>(
              future: _viewModel.getUserProfile(response.userId!),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              widget.categoryColor.withOpacity(0.1),
                          backgroundImage: user?.photoUrl != null &&
                                  user!.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child:
                              user?.photoUrl == null || user!.photoUrl!.isEmpty
                                  ? Icon(
                                      Icons.person_rounded,
                                      color: widget.categoryColor,
                                      size: 16,
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user?.username ?? 'Utilisateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          response.createdAt != null
                              ? _viewModel.formatTimeAgo(response.createdAt!)
                              : 'Maintenant',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      response.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _toggleResponseInput(String commentId) {
    setState(() {
      _respondingToCommentId =
          _respondingToCommentId == commentId ? null : commentId;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      _viewModel.setSelectedImage(File(image.path));
    }
  }

  Future<void> _handleCommentSubmitted() async {
    final content = _commentController.text.trim();
    if (content.isEmpty && _viewModel.selectedImage == null) return;

    await _viewModel.saveComment(content);
    _commentController.clear();
    _commentFocusNode.unfocus();

    widget.onCommentCountChanged?.call(_viewModel.comments.length);
  }

  Future<void> _handleResponseSubmitted(
      String commentId, String content) async {
    if (content.trim().isEmpty) return;

    await _viewModel.saveResponse(commentId, content);
    setState(() => _respondingToCommentId = null);
  }

  Future<void> _deleteComment(String commentId) async {
    final success = await _viewModel.deleteComment(commentId);
    if (success) {
      widget.onCommentCountChanged?.call(_viewModel.comments.length);
    }
  }
}
