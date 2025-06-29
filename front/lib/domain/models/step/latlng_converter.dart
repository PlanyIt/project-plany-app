import 'package:latlong2/latlong.dart';
import 'package:json_annotation/json_annotation.dart';

class LatLngConverter implements JsonConverter<LatLng?, Map<String, dynamic>?> {
  const LatLngConverter();

  @override
  LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final lat = json['latitude'];
    final lng = json['longitude'];
    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(LatLng? latLng) {
    if (latLng == null) return null;
    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }
}
