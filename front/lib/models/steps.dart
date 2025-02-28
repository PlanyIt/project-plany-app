import 'package:google_maps_flutter/google_maps_flutter.dart';

class Steps {
  final String id;
  final String title;
  final String description;
  final LatLng position;

  Steps({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
  });

  factory Steps.fromJson(Map<String, dynamic> json) {
    return Steps(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      position: LatLng(json['latitude'], json['longitude']),
    );
  }
}