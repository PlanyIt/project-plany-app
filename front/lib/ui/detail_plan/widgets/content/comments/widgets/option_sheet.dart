import 'package:flutter/material.dart';
import 'package:front/domain/models/comment.dart';

class CommentOptionSheet extends StatelessWidget {
  final Comment comment;
  final Color categoryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isResponse;

  const CommentOptionSheet({
    Key? key,
    required this.comment,
    required this.categoryColor,
    required this.onEdit,
    required this.onDelete,
    this.isResponse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildOptionButton(
            icon: Icons.edit_outlined,
            label:
                isResponse ? 'Modifier la réponse' : 'Modifier le commentaire',
            color: categoryColor,
            onTap: onEdit,
          ),
          const SizedBox(height: 12),
          _buildOptionButton(
            icon: Icons.delete_outline,
            label: isResponse
                ? 'Supprimer la réponse'
                : 'Supprimer le commentaire',
            color: Colors.redAccent,
            onTap: onDelete,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCommentOptions({
  required BuildContext context,
  required Comment comment,
  required Color categoryColor,
  required Function(String) onEdit,
  required Function(String, String?) onDelete,
}) {
  bool isResponse = comment.parentId != null;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CommentOptionSheet(
        comment: comment,
        categoryColor: categoryColor,
        onEdit: () {
          Navigator.pop(context);
          onEdit(comment.id!);
        },
        onDelete: () {
          Navigator.pop(context);
          onDelete(comment.id!, comment.parentId);
        },
        isResponse: isResponse,
      );
    },
  );
}
