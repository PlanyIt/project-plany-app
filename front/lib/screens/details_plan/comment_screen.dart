import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front/services/comment_service.dart';
import 'package:front/models/comment.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommentScreen extends StatefulWidget {
  final String planId;
  final Function(int) onCommentCountChanged;

  const CommentScreen({super.key, required this.planId, required this.onCommentCountChanged});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final FocusNode _responseFocusNode = FocusNode();
  List<Comment> _comments = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  String? _editingCommentId;
  String? _respondingToCommentId;
  Map<String, bool> _expandedComments = {}; // Carte pour suivre l'état d'expansion de chaque commentaire
  Map<String, bool> _likedComments = {}; // Carte pour suivre l'état des likes de chaque commentaire
  Map<String, List<Comment>> _responses = {}; // Carte pour stocker les réponses de chaque commentaire
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables pour la pagination
  int _currentPage = 1;
  final int _pageLimit = 10;
  bool _hasMoreComments = true;
  bool _isLoading = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadComments(reset: true);
  }

  void _loadComments({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _comments = [];
        _isInitialLoad = true;
      });
    }

    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final commentsData = await _commentService.getComments(
        widget.planId, 
        page: _currentPage, 
        limit: _pageLimit
      );
      
      // Si on reçoit moins de commentaires que la limite, il n'y en a plus à charger
      if (commentsData.length < _pageLimit) {
        _hasMoreComments = false;
      }
      
      setState(() {
        if (reset) {
          _comments = commentsData;
        } else {
          _comments.addAll(commentsData);
        }
        _isInitialLoad = false;
        widget.onCommentCountChanged(_comments.length);
      });
      
      // Insérer les items dans la liste animée
      if (_listKey.currentState != null) {
        final int startIndex = reset ? 0 : _comments.length - commentsData.length;
        for (int i = 0; i < commentsData.length; i++) {
          _listKey.currentState!.insertItem(startIndex + i);
        }
      }
      
      // Charger les réponses pour chaque nouveau commentaire
      for (final comment in commentsData) {
        if (comment.id != null && comment.responses.isNotEmpty) {
          _loadResponses(comment.id!);
        }
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des commentaires : $e')),
      );
      print('Erreur lors du chargement des commentaires : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMoreComments() {
    _currentPage++;
    _loadComments();
  }

  void _loadResponses(String commentId) async {
    try {
      // Vérifier si les réponses ont déjà été chargées
      if (_responses.containsKey(commentId)) return;
      
      // Trouver le commentaire pour obtenir les IDs de réponse
      final comment = _comments.firstWhere((c) => c.id == commentId);
      if (comment.responses.isEmpty) {
        _responses[commentId] = [];
        return;
      }
      
      List<Comment> responses = [];
      for (String responseId in comment.responses) {
        try {
          final response = await _commentService.getCommentById(responseId);
          responses.add(response);
        } catch (e) {
          print('Erreur lors du chargement de la réponse $responseId : $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _responses[commentId] = responses;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des réponses pour $commentId : $e');
    }
  }

  void _saveComment() async {
    if (_commentController.text.isNotEmpty) {
      if (_editingCommentId == null) {
        final newComment = Comment(
          content: _commentController.text,
          planId: widget.planId,
        );

        try {
          final createdComment = await _commentService.createComment(widget.planId, newComment);
          setState(() {
            _comments.insert(0, createdComment);
            widget.onCommentCountChanged(_comments.length); // Mettre à jour le nombre de commentaires
            _listKey.currentState?.insertItem(0);
          });
          _commentController.clear();
          _commentFocusNode.unfocus(); // Enlever le focus du champ de texte
          Fluttertoast.showToast(msg: 'Commentaire ajouté avec succès');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout du commentaire : $e')),
          );
        }
      } else {
        final index = _comments.indexWhere((c) => c.id == _editingCommentId);
        if (index == -1) return;
        final updatedComment = Comment(
          id: _editingCommentId!,
          content: _commentController.text,
          userId: _comments[index].userId,
          planId: widget.planId,
          createdAt: _comments[index].createdAt,
          likes: _comments[index].likes,
          responses: _comments[index].responses,
          parentId: _comments[index].parentId,
        );

        try {
          await _commentService.editComment(_editingCommentId!, updatedComment);
          setState(() {
            _comments[index] = updatedComment;
            _editingCommentId = null;
          });
          _commentController.clear();
          _commentFocusNode.unfocus(); // Enlever le focus du champ de texte
          Fluttertoast.showToast(msg: 'Commentaire modifié avec succès');
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la modification : $e')),
          );
        }
      }
    }
  }

  void _saveResponse(String commentId) async {
    if (_responseController.text.isNotEmpty) {
      final newResponse = Comment(
        content: _responseController.text,
        planId: widget.planId,
        parentId: commentId, // Identifie qu'il s'agit d'une réponse
      );

      try {
        final createdResponse = await _commentService.respondToComment(commentId, newResponse);
        
        setState(() {
          // Ajouter l'ID de la réponse au commentaire parent
          final index = _comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _comments[index].responses.add(createdResponse.id!);
          }
          
          // Ajouter la réponse à la liste des réponses
          if (!_responses.containsKey(commentId)) {
            _responses[commentId] = [];
          }
          _responses[commentId]!.add(createdResponse);
          
          _respondingToCommentId = null;
        });
        
        _responseController.clear();
        _responseFocusNode.unfocus(); // Enlever le focus du champ de texte
        Fluttertoast.showToast(msg: 'Réponse ajoutée avec succès');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la réponse : $e')),
        );
      }
    }
  }

void _deleteComment(String commentId) async {
  final index = _comments.indexWhere((comment) => comment.id == commentId);
  if (index == -1) return;
  
  final removedComment = _comments[index];

  try {
    await _commentService.deleteComment(commentId);
    
    setState(() {
      // 1. Supprimer le commentaire de la liste
      _comments.removeAt(index);
      widget.onCommentCountChanged(_comments.length);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildCommentItem(removedComment, animation),
      );
      
      // 2. Supprimer les réponses de la carte _responses
      if (_responses.containsKey(commentId)) {
        _responses.remove(commentId);
      }
    });
    
    _commentFocusNode.unfocus();
    Fluttertoast.showToast(msg: 'Commentaire et ses réponses supprimés avec succès');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la suppression : $e')),
    );
  }
}

  void _deleteResponse(String commentId, String responseId) async {
    try {
      await _commentService.deleteResponse(commentId, responseId);
      
      setState(() {
        // Supprimer la réponse de la liste des réponses
        _responses[commentId]?.removeWhere((r) => r.id == responseId);
        
        // Supprimer l'ID de la réponse du commentaire parent
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index].responses.removeWhere((id) => id == responseId);
        }
      });
      
      Fluttertoast.showToast(msg: 'Réponse supprimée avec succès');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de la réponse : $e')),
      );
    }
  }

  void _editComment(String commentId) {
    final comment = _comments.firstWhere((comment) => comment.id == commentId);

    setState(() {
      _commentController.text = comment.content;
      _editingCommentId = commentId;
      _commentFocusNode.requestFocus();
    });
  }
  void _showResponseOptions(Comment parentComment, Comment response) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color.fromARGB(255, 82, 82, 82)),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _editComment(response.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color.fromARGB(255, 82, 82, 82)),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                if (response.id != null) {
                  _deleteResponse(parentComment.id!, response.id!);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
  void _showCommentOptions(Comment comment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color.fromARGB(255, 82, 82, 82)),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _editComment(comment.id!);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color.fromARGB(255, 82, 82, 82)),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteComment(comment.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 8) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}j';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }

  Widget _buildCommentItem(Comment comment, Animation<double> animation) {
    bool isLiked = _likedComments[comment.id] ?? false;
    bool isExpanded = _expandedComments[comment.id] ?? false;

    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onLongPress: () => _showCommentOptions(comment),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user.png'),
                  radius: 22,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.content,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      maxLines: isExpanded ? null : 2,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    if (comment.content.length > 100)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedComments[comment.id!] = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? 'Voir moins' : 'Voir plus',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(
                      comment.createdAt != null
                          ? _formatTimeAgo(comment.createdAt!)
                          : 'Il y a 2h',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _respondingToCommentId = comment.id;
                          _responseFocusNode.requestFocus();
                        });
                      },
                      child: const Text('Répondre'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[500],
                        disabledForegroundColor: Theme.of(context).primaryColor.withOpacity(0.38),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  onPressed: () async {
                    try {
                      if (isLiked) {
                        await _commentService.unlikeComment(comment.id!);
                      } else {
                        await _commentService.likeComment(comment.id!);
                      }
                      setState(() {
                        _likedComments[comment.id!] = !isLiked;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de la mise à jour du like : $e')),
                      );
                    }
                  },
                ),
              ),
              if (comment.responses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _responses.containsKey(comment.id)
                      ? Column(
                          children: comment.responses.map((responseId) {
                            final response = _responses[comment.id]?.firstWhere(
                              (r) => r.id == responseId,
                              orElse: () => Comment(
                                content: "Chargement...",
                                planId: widget.planId,
                              ),
                            );
                            
                            // Si la réponse n'est pas encore chargée, montrer un indicateur
                            if (response?.content == "Chargement...") {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            
                            return GestureDetector(
                              onLongPress: response!.userId == _auth.currentUser!.uid
                                  ? () => _showResponseOptions(comment, response)
                                  : null,
                              child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/user.png'),
                                radius: 16,
                              ),
                              title: Text(
                                response!.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                response.createdAt != null
                                    ? _formatTimeAgo(response.createdAt!)
                                    : 'Il y a 1h',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ));
                          }).toList(),
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                ),
              if (_respondingToCommentId == comment.id)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _responseController,
                          focusNode: _responseFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Ajouter une réponse...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: () => _saveResponse(comment.id!),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: _editingCommentId == null
                    ? 'Ajouter un commentaire...'
                    : 'Modifier le commentaire...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _saveComment,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: _isInitialLoad
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      // Détection de scroll vers le bas pour charger plus de commentaires
                      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                          _hasMoreComments &&
                          !_isLoading) {
                        _loadMoreComments();
                      }
                      return true;
                    },
                    child: Stack(
                      children: [
                        AnimatedList(
                          key: _listKey,
                          initialItemCount: _comments.length,
                          itemBuilder: (context, index, animation) {
                            return _buildCommentItem(_comments[index], animation);
                          },
                        ),
                        if (_isLoading && !_isInitialLoad)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }
}