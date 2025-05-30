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

    if (json['position'] != null) {
      final double latitude = json['position']['latitude'];
      final double longitude = json['position']['longitude'];
      position = LatLng(latitude, longitude);
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

    if (position != null) {
      data['position'] = {
        'latitude': position!.latitude,
        'longitude': position!.longitude,
      };
    }

    return data;
  }
}
