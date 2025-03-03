import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class Step {
  final String id;
  final String title;
  final String description;
  final GeoPoint position;

  Step({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      position:
          GeoPoint(latitude: json['latitude'], longitude: json['longitude']),
    );
  }
}
