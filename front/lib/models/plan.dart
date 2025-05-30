import 'package:firebase_auth/firebase_auth.dart';

class Plan {
  final String? id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final String? userId;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> steps;
  final List<String>? favorites; 
  final bool isFavorite; 

  Plan({
    this.id,
    required this.title,
    required this.description,
    this.userId,
    required this.steps,
    required this.category,
    this.tags = const [],
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
    this.favorites, 
    this.isFavorite = false, 
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final List<String> favoritesFromJson = List<String>.from(json['favorites'] ?? []);
    
    return Plan(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      steps: List<String>.from(json['steps'] ?? []),
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      favorites: favoritesFromJson, 
      isFavorite: currentUserId != null && favoritesFromJson.contains(currentUserId), 
    );
  }

  get rating => null;

  get totalCost => null;
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'category': category,
      'tags': tags,
      'isPublic': isPublic,
      'steps': steps,
      'favorites': favorites, 
    };
  }
}
