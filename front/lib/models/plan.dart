import 'package:firebase_auth/firebase_auth.dart';

class Plan {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String? userId;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> steps;
  final List<String>? favorites;
  final bool isFavorite;
  final double? estimatedCost;

  Plan({
    this.id,
    required this.title,
    required this.description,
    this.userId,
    required this.steps,
    required this.category,
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
    this.favorites,
    this.isFavorite = false,
    this.estimatedCost, // Added to constructor
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final List<String> favoritesFromJson =
        List<String>.from(json['favorites'] ?? []);

    return Plan(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      steps: List<String>.from(json['steps'] ?? []),
      category: json['category'],
      isPublic: json['isPublic'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      favorites: favoritesFromJson,
      isFavorite:
          currentUserId != null && favoritesFromJson.contains(currentUserId),
      estimatedCost: json['estimatedCost']?.toDouble(), // Parse from JSON
    );
  }

  get rating => null;

  get totalCost => null;

  Map<String, dynamic> toJson() {
    final map = {
      'title': title,
      'description': description,
      'userId': userId,
      'category': category,
      'isPublic': isPublic,
      'steps': steps,
      'favorites': favorites,
    };

    if (estimatedCost != null) {
      map['estimatedCost'] = estimatedCost;
    }

    return map;
  }
}
