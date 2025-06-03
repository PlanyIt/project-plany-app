import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/domain/models/user_profile.dart';
import 'package:front/screens/details-plan/widgets/content/comments/widgets/comment_input.dart';
import 'package:front/screens/details-plan/widgets/content/comments/widgets/empty_state.dart';
import 'package:front/screens/details-plan/widgets/content/comments/widgets/option_sheet.dart';
import 'package:front/screens/details-plan/widgets/content/comments/widgets/response_input.dart';
import 'package:front/domain/models/comment.dart';
import 'dart:math';
import 'package:front/screens/details-plan/widgets/content/comments/widgets/comment_card.dart';
import 'package:front/screens/details-plan/widgets/content/comments/controller/comment_controller.dart';
import 'package:front/services/user_service.dart';

class CommentSection extends StatefulWidget {
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
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late CommentController _controller;
  late final UserService _userService = UserService();
  
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _responseFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  String? _respondingToCommentId;
  String? _editingCommentId;  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentPage = 1;
  final int _pageLimit = 10;
  bool _isLoading = false;
  bool _isInitialLoad = true;
  bool _showAllComments = false;
  final int _initialCommentsToShow = 2;
  bool _isSubmittingComment = false;
  bool _isSubmittingResponse = false;

  final Map<String, UserProfile> _userProfilesCache = {};

  @override
  void initState() {
    super.initState();
    
    _controller = CommentController(
      planId: widget.planId,
      context: context,
      onCommentCountChanged: widget.onCommentCountChanged,
      currentUserId: _auth.currentUser?.uid,
    );
    
    _loadComments(reset: true);
  }

  void _loadComments({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _isInitialLoad = true;
      });
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _controller.loadComments(
        reset: reset,
        currentPage: _currentPage,
        pageLimit: _pageLimit
      );
      
      setState(() {
        _isInitialLoad = false;
      });

      if (_listKey.currentState != null && !widget.isEmbedded) {
        final int startIndex = reset ? 0 : _controller.comments.length - (_pageLimit);
        for (int i = 0; i < _pageLimit; i++) {
          if (i + startIndex < _controller.comments.length) {
            _listKey.currentState!.insertItem(startIndex + i);
          }
        }
      }
    } catch (e) {
      // Les messages d'erreur sont gérés par le contrôleur
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveComment() async {
    if (_isSubmittingComment) return;
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    try {
      if (_editingCommentId != null) {
        // Mode édition
        final updatedComment = await _controller.editComment(
          _editingCommentId!,
          _commentController.text,
          newImage: _controller.selectedImage
        );
        
        if (updatedComment != null) {
          _commentController.clear();
          _controller.removeImage();
          _commentFocusNode.unfocus();
          _editingCommentId = null;
          setState(() {});
        }
      } else {
        // Mode création
        final comment = await _controller.saveComment(_commentController.text);
        if (comment != null) {
          _commentController.clear();
          _controller.removeImage();
          _commentFocusNode.unfocus();
          
          if (!widget.isEmbedded) {
            _listKey.currentState?.insertItem(0);
          }
          
          setState(() {});
        }
      }
    } catch (e) {
      // Déjà géré par le contrôleur
    } finally {
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  Future<void> _saveResponse(String commentId) async {
    if (_isSubmittingResponse) return;
  
    setState(() {
      _isSubmittingResponse = true;
    });
  
    try {
      if (_editingCommentId != null) {
        // Mode édition
        final updatedResponse = await _controller.editComment(
          _editingCommentId!,
          _responseController.text,
          newImage: _controller.selectedResponseImage
        );
        
        if (updatedResponse != null) {
          setState(() {
            _respondingToCommentId = null;
            _responseController.clear();
            _editingCommentId = null;
          });
          _controller.removeResponseImage();
        }
      } else {
        // Mode création
        final response = await _controller.saveResponse(commentId, _responseController.text);
        if (response != null) {
          setState(() {
            _respondingToCommentId = null;
            _responseController.clear();
          });
          _controller.removeResponseImage();
        }
      }
    } catch (e) {
      // Déjà géré par le contrôleur
    } finally {
      setState(() {
        _isSubmittingResponse = false;
      });
    }
  }

  void _showCommentOptions(Comment comment) {
    bool isResponse = comment.parentId != null;
    String? parentCommentId = comment.parentId;

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
      final index = _controller.comments.indexWhere((comment) => comment.id == commentId);
      if (index == -1) return;
      
      final removedComment = _controller.comments[index];
      final success = await _controller.deleteComment(commentId);
      
      if (success) {
        setState(() {}); 
        
        if (!widget.isEmbedded) {
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => _buildCommentItem(removedComment, animation),
          );
        }
      }
    } catch (e) {
      // Déjà géré par le contrôleur
    }
  }

  void _deleteResponse(String commentId, String responseId) async {
    final success = await _controller.deleteResponse(commentId, responseId);
    if (success) {
      setState(() {}); 
    }
  }

  void _editComment(String commentId) {
    CommentResult? result = _controller.findCommentById(commentId);
    if (result == null) return;
    
    final Comment commentToEdit = result.comment;
    final bool isResponse = result.isResponse;
    final String? parentCommentId = result.parentCommentId;
    
    setState(() {
      if (isResponse) {
        _responseController.text = commentToEdit.content;
        _respondingToCommentId = parentCommentId;
        _controller.existingImageUrl = commentToEdit.imageUrl;
      } else {
        _commentController.text = commentToEdit.content;
        _controller.existingImageUrl = commentToEdit.imageUrl;
      }
      
      _editingCommentId = commentId;
      
      _controller.selectedImage = null;
      _controller.selectedResponseImage = null;
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
      isUploadingImage: _controller.isUploadingImage,
      isSubmitting: _isSubmittingComment,
      selectedImage: _controller.selectedImage,
      existingImageUrl: _controller.existingImageUrl,
      onPickImage: (File imageFile) {
        _controller.selectedImage = imageFile;
        setState(() {
          _controller.selectedImage = imageFile;
        });
      },
      onRemoveImage: () {
        _controller.removeImage();
        setState(() {});
      },
      onClearExistingImage: () {
        _controller.existingImageUrl = null;
        setState(() {}); 
      },
      onSubmit: _saveComment,
    );
  }

  Future<UserProfile?> _getUserProfile(String userId) async {
    if (_userProfilesCache.containsKey(userId)) {
      return _userProfilesCache[userId];
    }
    
    try {
      final profile = await _userService.getUserProfile(userId);
      _userProfilesCache[userId] = profile;
      return profile;
    } catch (e) {
      print('Erreur lors du chargement du profil $userId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              : _controller.comments.isEmpty
                  ? const EmptyCommentsMessage()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                "${_controller.comments.length} commentaire${_controller.comments.length > 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              if (_controller.comments.length > _initialCommentsToShow)
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
                                    style: TextStyle(
                                        color: widget
                                            .categoryColor), 
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
                              ? _controller.comments.length
                              : min(_initialCommentsToShow, _controller.comments.length),
                          itemBuilder: (context, index) {
                            return _buildCommentItem(
                                _controller.comments[index], AlwaysStoppedAnimation(1.0));
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
                    initialItemCount: _controller.comments.length,
                    itemBuilder: (context, index, animation) {
                      return _buildCommentItem(_controller.comments[index], animation);
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
          key: ValueKey('${comment.id}_${comment.userId}'), 
          comment: comment,
          currentUserId: _controller.currentUserId,
          categoryColor: widget.categoryColor,
          onShowOptions: _showCommentOptions,
          onLikeToggle: (comment, isLiked) async {
            final success = await _controller.toggleLike(comment, isLiked);
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
            await _controller.loadResponses(commentId);
            setState(() {});
          },
          responses: _controller.responses,
          showAllResponsesMap: _controller.showAllResponsesMap,
          onToggleResponses: (commentId) {
            setState(() {
              _controller.showAllResponsesMap[commentId] =
                  !(_controller.showAllResponsesMap[commentId] ?? false);
            });
          },
          respondingToCommentId: _respondingToCommentId,
          responseInputWidget: _respondingToCommentId == comment.id
              ? ResponseInput(
                  parentComment: comment,
                  controller: _responseController,
                  focusNode: _responseFocusNode,
                  categoryColor: widget.categoryColor,
                  selectedImage: _controller.selectedResponseImage,
                  existingImageUrl: _controller.existingImageUrl,
                  isUploadingImage: _controller.isUploadingResponseImage,
                  isSubmitting: _isSubmittingResponse,
                  onPickImage: (File imageFile) {
                    _controller.selectedResponseImage = imageFile;
                    setState(() {
                      _controller.selectedResponseImage = imageFile;
                    });
                  },
                  onRemoveImage: () {
                    _controller.removeResponseImage();
                    setState(() {}); 
                  },
                  onCancel: () {
                    setState(() {
                      _respondingToCommentId = null;
                      _responseController.clear();
                      _controller.removeResponseImage();
                    });
                  },
                  onSubmit: (commentId) => _saveResponse(commentId),
                )
              : null,
          formatTimeAgo: _controller.formatTimeAgo,
          getUserProfile: _getUserProfile,
        ),
      ),
    );
  }
}
