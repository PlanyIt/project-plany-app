import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class Step {
  final String? id;
  final String title;
  final String description;
  final LatLng? position;
  final int order;
  final String image;
  final String? duration;
  final double? cost;
  final DateTime? createdAt;
  final String userId;

  Step({
    this.id,
    required this.title,
    required this.description,
    this.position,
    required this.order,
    required this.image,
    this.duration,
    this.cost,
    this.createdAt,
    required this.userId,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    LatLng? position;

    if (json['latitude'] != null && json['longitude'] != null) {
      try {
        final double latitude = (json['latitude'] is int)
            ? (json['latitude'] as int).toDouble()
            : json['latitude'];

        final double longitude = (json['longitude'] is int)
            ? (json['longitude'] as int).toDouble()
            : json['longitude'];

        position = LatLng(latitude, longitude);
      } catch (e) {
        if (kDebugMode) {
          print("Erreur position: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Coordonnées non trouvées dans le JSON");
      }
    }

    double? cost;
    if (json['cost'] != null) {
      cost =
          json['cost'] is int ? (json['cost'] as int).toDouble() : json['cost'];
    }

    return Step(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      position: position,
      order: json['order'],
      image: json['image'],
      duration: json['duration'],
      cost: cost,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'order': order,
      'image': image,
      'duration': duration,
      'cost': cost,
      'userId': userId,
    };

    // Envoyer latitude et longitude directement au niveau racine
    if (position != null) {
      data['latitude'] = position!.latitude;
      data['longitude'] = position!.longitude;
    }

    return data;
  }
}
