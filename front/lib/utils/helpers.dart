import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../domain/models/step/step.dart' as step_model;

/// Calculates the total cost of steps from a list of Step objects.
///
/// Use this when you have already loaded the Step objects.
double calculateTotalStepsCost(List<step_model.Step> steps) {
  return steps.fold(0.0, (total, step) {
    final stepCost = step.cost ?? 0.0;
    return total + stepCost;
  });
}

/// Calculates duration from minutes to a formatted string.
/// Returns a string in the format "X jours" ou "X heures" ou "X minutes".
/// If the duration is null or empty, returns "0 minutes".
String formatDurationToString(int minutes) {
  if (minutes <= 0) return '0 min';

  final days = minutes ~/ (24 * 60);
  final hours = (minutes % (24 * 60)) ~/ 60;
  final remainingMinutes = minutes % 60;

  final parts = <String>[];
  if (days > 0) parts.add('$days jours');
  if (hours > 0) parts.add('$hours h');
  if (remainingMinutes > 0) parts.add('$remainingMinutes min');

  return parts.join(' ');
}

/// Calculates duration String "X jours" "X heures" "X minutes" to Minutes.
/// If the duration is null or empty, returns "0 minutes".
int formatDurationToMinutes(String duration) {
  if (duration.isEmpty) return 0;

  final parts = duration.split(' ');
  var totalMinutes = 0;

  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];

    // Check if current part is a number and next part is a unit
    if (i + 1 < parts.length) {
      final number = int.tryParse(part);
      final unit = parts[i + 1];

      if (number != null) {
        if (unit == 'jours') {
          totalMinutes += number * 24 * 60;
          i++; // Skip the unit part
        } else if (unit == 'heures') {
          totalMinutes += number * 60;
          i++; // Skip the unit part
        } else if (unit == 'minutes') {
          totalMinutes += number;
          i++; // Skip the unit part
        }
      }
    }

    if (part.endsWith('jours')) {
      final days = int.tryParse(part.replaceAll('jours', '').trim()) ?? 0;
      totalMinutes += days * 24 * 60;
    } else if (part.endsWith('heures')) {
      final hours = int.tryParse(part.replaceAll('heures', '').trim()) ?? 0;
      totalMinutes += hours * 60;
    } else if (part.endsWith('minutes')) {
      final minutes = int.tryParse(part.replaceAll('minutes', '').trim()) ?? 0;
      totalMinutes += minutes;
    }
  }

  return totalMinutes;
}

/// Calcule la distance en mètres entre deux points GPS (Haversine)
double calculateDistanceBetween(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadius = 6371000;
  final dLat = (lat2 - lat1) * (3.141592653589793 / 180);
  final dLon = (lon2 - lon1) * (3.141592653589793 / 180);

  final a = (sin(dLat / 2) * sin(dLat / 2)) +
      cos(lat1 * (3.141592653589793 / 180)) *
          cos(lat2 * (3.141592653589793 / 180)) *
          (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

/// Convertit deux doubles (latitude, longitude) en objet LatLng.
/// Retourne null si l'un des deux est null.
LatLng? latLngFromDoubles(double? latitude, double? longitude) {
  if (latitude == null || longitude == null) return null;
  return LatLng(latitude, longitude);
}

/// Converts a hex color string (e.g., "#FF5733" or "FF5733") to a [Color] object.
/// Optionally, you can provide an [alpha] value (0.0 to 1.0) to override the opacity.
Color colorFromHex(String hexColor, {double? alpha}) {
  var hex = hexColor.replaceFirst('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex'; // Add full opacity if not specified
  }
  final colorInt = int.parse(hex, radix: 16);
  var color = Color(colorInt);
  if (alpha != null) {
    color = color.withValues(alpha: 0.3);
  }
  return color;
}

/// Convertit une durée en minutes selon l'unité
int convertDurationToMinutes(int value, String unit) {
  switch (unit.toLowerCase()) {
    case 'min':
    case 'minute':
    case 'minutes':
      return value;
    case 'h':
    case 'heure':
    case 'heures':
      return value * 60;
    case 'j':
    case 'jour':
    case 'jours':
      return value * 24 * 60; // 24 heures par jour au lieu de 8
    default:
      return value;
  }
}

/// Convertit des minutes en unité spécifiée
double convertMinutesToUnit(int minutes, String unit) {
  switch (unit.toLowerCase()) {
    case 'minutes':
      return minutes.toDouble();
    case 'heures':
      return minutes / 60;
    case 'jours':
      return minutes / (24 * 60);
    default:
      return minutes.toDouble();
  }
}

/// Formate une distance en mètres vers une chaîne lisible
String formatDistance(double? distanceInMeters) {
  if (distanceInMeters == null) return 'Distance inconnue';

  if (distanceInMeters < 1000) {
    return '${distanceInMeters.round()} m';
  } else {
    final kilometers = distanceInMeters / 1000;
    if (kilometers < 10) {
      return '${kilometers.toStringAsFixed(1)} km';
    } else {
      return '${kilometers.round()} km';
    }
  }
}

/// Calcule la distance en mètres entre deux points LatLng
double calculateDistanceBetweenLatLng(LatLng point1, LatLng point2) {
  return calculateDistanceBetween(
    point1.latitude,
    point1.longitude,
    point2.latitude,
    point2.longitude,
  );
}

Color? colorFromPlanCategory(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return null;
  var hex = hexColor.replaceFirst('#', '');
  if (hex.length == 6) hex = 'ff$hex';
  if (hex.length != 8) return null;

  try {
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return null;
  }
}

/// Returns a human-readable "time ago" string for a given [dateTime].
String formatTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 8) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays}j';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m';
  } else {
    return 'À l\'instant';
  }
}

/// Affiche un SnackBar avec le message donné dans le contexte fourni.
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
