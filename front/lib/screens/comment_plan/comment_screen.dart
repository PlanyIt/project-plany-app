import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/services/comment_service.dart';
import 'package:front/models/comment.dart';

class CommentScreen extends StatefulWidget {
  final String planId;

  const CommentScreen({super.key, required this.planId});

  @override
  CommentScreenState createState() => CommentScreenState();
}

class CommentScreenState extends State<CommentScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() async {
    try {
      final comments = await _commentService.getComments(widget.planId);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des commentaires : $e');
      }
    }
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final newComment = Comment(
        id: '', // L'ID sera généré par le backend
        content: _commentController.text,
        userId: 'currentUserId', // Remplacez par l'ID de l'utilisateur actuel
        planId: widget.planId,
      );

      try {
        await _commentService.createComment(widget.planId, newComment);
        _commentController.clear();
        _loadComments(); // Rechargez les commentaires après l'ajout
      } catch (e) {
        if (kDebugMode) {
          print('Erreur lors de l\'ajout du commentaire : $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/background.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commentaires',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('${_comments.length} commentaires',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/user.png'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Ajouter un commentaire',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _addComment,
                        child: const Text('Ajouter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${_commentController.text.length}/50'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_comments.length} commentaires',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return ListTile(
                        leading: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user.png')),
                        title: Text(comment.content),
                        subtitle: Text('Auteur: ${comment.userId}'),
                        trailing: const Icon(Icons.more_vert),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
