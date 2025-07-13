import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../domain/models/comment/comment.dart';
import '../../../view_models/comment_viewmodel.dart';
import 'widgets/comment_card.dart';
import 'widgets/comment_input.dart';
import 'widgets/empty_state.dart';
import 'widgets/option_sheet.dart';
import 'widgets/response_input.dart';

class CommentSection extends StatefulWidget {
  final String planId;
  final Function(int)? onCommentCountChanged;
  final bool isEmbedded;
  final Color categoryColor;
  final CommentViewModel viewModel;

  const CommentSection({
    super.key,
    required this.planId,
    this.onCommentCountChanged,
    this.isEmbedded = false,
    this.categoryColor = const Color(0xFF3425B5),
    required this.viewModel,
  });

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _responseFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  String? _respondingToCommentId;
  String? _editingCommentId;
  int _currentPage = 1;
  final int _pageLimit = 10;
  bool _isInitialLoad = true;
  bool _showAllComments = false;
  final int _initialCommentsToShow = 2;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndComments();
  }

  Future<void> _loadUserIdAndComments() async {
    try {
      _loadComments(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erreur de chargement des données utilisateur: $e')),
        );
      }
      _loadComments(reset: true);
    }
  }

  void _loadComments({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _isInitialLoad = true;
      });
    }

    try {
      await widget.viewModel.loadComments(
          reset: reset, currentPage: _currentPage, pageLimit: _pageLimit);

      setState(() {
        _isInitialLoad = false;
      });

      if (_listKey.currentState != null && !widget.isEmbedded) {
        final startIndex =
            reset ? 0 : widget.viewModel.comments.length - (_pageLimit);
        for (var i = 0; i < _pageLimit; i++) {
          if (i + startIndex < widget.viewModel.comments.length) {
            _listKey.currentState!.insertItem(startIndex + i);
          }
        }
      }
    } catch (e) {
      // Error handling is done in the ViewModel
    }
  }

  Future<void> _saveComment() async {
    try {
      if (_editingCommentId != null) {
        // Edit mode
        final updatedComment = await widget.viewModel.editComment(
            _editingCommentId!, _commentController.text,
            newImage: widget.viewModel.selectedImage);

        if (updatedComment != null) {
          _commentController.clear();
          widget.viewModel.removeImage();
          _commentFocusNode.unfocus();
          _editingCommentId = null;
          setState(() {});
        }
      } else {
        // Create mode
        final comment =
            await widget.viewModel.saveComment(_commentController.text);
        if (comment != null) {
          _commentController.clear();
          widget.viewModel.removeImage();
          _commentFocusNode.unfocus();

          if (!widget.isEmbedded) {
            _listKey.currentState?.insertItem(0);
          }

          setState(() {});
        }
      }
    } catch (e) {
      // Error handling is done in the ViewModel
    }
  }

  Future<void> _saveResponse(String commentId) async {
    try {
      if (_editingCommentId != null) {
        // Edit mode
        final updatedResponse = await widget.viewModel.editComment(
            _editingCommentId!, _responseController.text,
            newImage: widget.viewModel.selectedResponseImage);

        if (updatedResponse != null) {
          setState(() {
            _respondingToCommentId = null;
            _responseController.clear();
            _editingCommentId = null;
          });
          widget.viewModel.removeResponseImage();
        }
      } else {
        // Create mode
        final response = await widget.viewModel
            .saveResponse(commentId, _responseController.text);
        if (response != null) {
          setState(() {
            _respondingToCommentId = null;
            _responseController.clear();
          });
          widget.viewModel.removeResponseImage();
        }
      }
    } catch (e) {
      // Error handling is done in the ViewModel
    }
  }

  void _showCommentOptions(Comment comment) {
    final isResponse = comment.parentId != null;
    final parentCommentId = comment.parentId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentOptionSheet(
          categoryColor: widget.categoryColor,
          isResponse: isResponse,
          onEdit: () {
            Navigator.pop(context);
            _editComment(comment.id!);
          },
          onDelete: () {
            Navigator.pop(context);
            if (isResponse && parentCommentId != null) {
              _deleteResponse(parentCommentId, comment.id!);
            } else {
              _deleteComment(comment.id!);
            }
          },
          comment: comment,
        );
      },
    );
  }

  void _deleteComment(String commentId) async {
    try {
      final index = widget.viewModel.comments
          .indexWhere((comment) => comment.id == commentId);
      if (index == -1) return;

      final removedComment = widget.viewModel.comments[index];
      final success = await widget.viewModel.deleteComment(commentId);

      if (success) {
        setState(() {});

        if (!widget.isEmbedded) {
          _listKey.currentState?.removeItem(
            index,
            (context, animation) =>
                _buildCommentItem(removedComment, animation),
          );
        }
      }
    } catch (e) {
      // Error handling is done in the ViewModel
    }
  }

  void _deleteResponse(String commentId, String responseId) async {
    final success =
        await widget.viewModel.deleteResponse(commentId, responseId);
    if (success) {
      setState(() {});
    }
  }

  void _editComment(String commentId) {
    final result = widget.viewModel.findCommentById(commentId);
    if (result == null) return;

    final commentToEdit = result.comment;
    final isResponse = result.isResponse;
    final parentCommentId = result.parentCommentId;

    setState(() {
      if (isResponse) {
        _responseController.text = commentToEdit.content;
        _respondingToCommentId = parentCommentId;
        widget.viewModel.setExistingImageUrl(commentToEdit.imageUrl);
      } else {
        _commentController.text = commentToEdit.content;
        widget.viewModel.setExistingImageUrl(commentToEdit.imageUrl);
      }

      _editingCommentId = commentId;
    });

    if (isResponse) {
      _responseFocusNode.requestFocus();
    } else {
      _commentFocusNode.requestFocus();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Modification en cours..."),
        duration: Duration(seconds: 2),
        backgroundColor: widget.categoryColor,
      ),
    );
  }

  Widget _buildCommentInput() {
    return CommentInput(
      controller: _commentController,
      focusNode: _commentFocusNode,
      categoryColor: widget.categoryColor,
      isUploadingImage: widget.viewModel.isUploadingImage,
      isSubmitting: widget.viewModel.isSubmittingComment,
      selectedImage: widget.viewModel.selectedImage,
      existingImageUrl: widget.viewModel.existingImageUrl,
      onPickImage: (File imageFile) {
        widget.viewModel.setSelectedImage(imageFile);
      },
      onRemoveImage: () {
        widget.viewModel.removeImage();
      },
      onClearExistingImage: () {
        widget.viewModel.clearExistingImageUrl();
      },
      onSubmit: _saveComment,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display error messages
    if (widget.viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.viewModel.errorMessage!)),
        );
      });
    }

    if (widget.isEmbedded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCommentInput(),
          _isInitialLoad
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              : widget.viewModel.comments.isEmpty
                  ? const EmptyCommentsMessage()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                "${widget.viewModel.comments.length} commentaire${widget.viewModel.comments.length > 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              if (widget.viewModel.comments.length >
                                  _initialCommentsToShow)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showAllComments = !_showAllComments;
                                    });
                                  },
                                  icon: Icon(
                                    _showAllComments
                                        ? Icons.unfold_less
                                        : Icons.unfold_more,
                                    size: 16,
                                    color: widget.categoryColor,
                                  ),
                                  label: Text(
                                    _showAllComments ? 'Réduire' : 'Voir tout',
                                    style:
                                        TextStyle(color: widget.categoryColor),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _showAllComments
                              ? widget.viewModel.comments.length
                              : min(_initialCommentsToShow,
                                  widget.viewModel.comments.length),
                          itemBuilder: (context, index) {
                            return _buildCommentItem(
                                widget.viewModel.comments[index],
                                AlwaysStoppedAnimation(1.0));
                          },
                        ),
                      ],
                    ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires'),
      ),
      body: Column(
        children: [
          _buildCommentInput(),
          Expanded(
            child: _isInitialLoad
                ? const Center(child: CircularProgressIndicator())
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: widget.viewModel.comments.length,
                    itemBuilder: (context, index, animation) {
                      return _buildCommentItem(
                          widget.viewModel.comments[index], animation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CommentCard(
          key: ValueKey('${comment.id}_${comment.user?.id}'),
          comment: comment,
          viewModel: widget.viewModel,
          currentUserId: widget.viewModel.currentUser?.id,
          categoryColor: widget.categoryColor,
          onShowOptions: _showCommentOptions,
          onLikeToggle: (comment, isLiked) async {
            final success = await widget.viewModel.toggleLike(comment, isLiked);
            if (success) {
              setState(() {});
            }
          },
          onReplyTap: (commentId) {
            setState(() {
              _respondingToCommentId = commentId;
              Future.delayed(Duration.zero, () {
                _responseFocusNode.requestFocus();
              });
            });
          },
          loadResponses: (commentId) async {
            await widget.viewModel.loadResponses(commentId);
            setState(() {});
          },
          responses: widget.viewModel.responses,
          showAllResponsesMap: widget.viewModel.showAllResponsesMap,
          onToggleResponses: (commentId) {
            widget.viewModel.toggleShowAllResponses(commentId);
          },
          respondingToCommentId: _respondingToCommentId,
          responseInputWidget: _respondingToCommentId == comment.id
              ? ResponseInput(
                  parentComment: comment,
                  controller: _responseController,
                  focusNode: _responseFocusNode,
                  categoryColor: widget.categoryColor,
                  selectedImage: widget.viewModel.selectedResponseImage,
                  existingImageUrl: widget.viewModel.existingImageUrl,
                  isUploadingImage: widget.viewModel.isUploadingResponseImage,
                  isSubmitting: widget.viewModel.isSubmittingResponse,
                  onPickImage: (File imageFile) {
                    widget.viewModel.setSelectedResponseImage(imageFile);
                  },
                  onRemoveImage: () {
                    widget.viewModel.removeResponseImage();
                  },
                  onCancel: () {
                    setState(() {
                      _respondingToCommentId = null;
                      _responseController.clear();
                      widget.viewModel.removeResponseImage();
                    });
                  },
                  onSubmit: (commentId) => _saveResponse(commentId),
                )
              : null,
          formatTimeAgo: widget.viewModel.formatTimeAgo,
        ),
      ),
    );
  }
}
