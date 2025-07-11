import 'package:flutter/material.dart';

class EmptyCommentsMessage extends StatelessWidget {
  const EmptyCommentsMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Soyez le premier à partager votre avis !",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les commentaires aident d'autres voyageurs à préparer leur sortie." ,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}