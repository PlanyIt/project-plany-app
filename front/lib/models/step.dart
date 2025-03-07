import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class Step {
  final String? id;
  final String title;
  final String description;
  final GeoPoint? position;
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
    GeoPoint? position;
    if (json['latitude'] != null && json['longitude'] != null) {
      double latitude = json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'];
      double longitude = json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'];

      position = GeoPoint(latitude: latitude, longitude: longitude);
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
    return {
      'title': title,
      'description': description,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'order': order,
      'image': image,
      'duration': duration,
      'cost': cost,
      'userId': userId,
    };
  }
}
