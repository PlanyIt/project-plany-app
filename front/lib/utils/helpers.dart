import 'dart:math';
import 'dart:ui';

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

/// Calculates the total duration of steps from a list of Step objects.
/// Calculates the total duration in minutes from a list of Step objects.
/// Handles "minute", "heure", "jour", and "semaine" units.
/// 1 jour = 8 heures, 1 semaine = 5 jours (work week).
int calculateTotalDuration(List<step_model.Step> steps) {
  var total = 0;
  final regex = RegExp(r'(\d+)\s*(minute|heure|jour|semaine)');

  for (final step in steps) {
    final match = regex.firstMatch(step.duration ?? '');
    if (match != null) {
      final value = int.tryParse(match.group(1)!);
      final unit = match.group(2);
      if (value != null && unit != null) {
        switch (unit) {
          case 'minute':
            total += value;
            break;
          case 'heure':
            total += value * 60;
            break;
          case 'jour':
            total += value * 8 * 60;
            break;
          case 'semaine':
            total += value * 5 * 8 * 60;
            break;
        }
      }
    }
  }

  return total;
}

/// Handles durations in the format "X minutes", "X heures", "X jours", etc.
/// Returns a formatted string representing the total duration.
String calculateTotalStepsDuration(List<step_model.Step> steps) {
  // Convert all durations to minutes for easy calculation
  var totalMinutes = 0;

  for (final step in steps) {
    if (step.duration == null || step.duration!.isEmpty) continue;
    totalMinutes += _parseDurationToMinutes(step.duration!);
  }

  // Convert total minutes back to a readable format
  return _formatDuration(totalMinutes);
}

/// Parses a duration string like "2 minutes", "6 heures", or "2 heures et 30 minutes" to minutes.
int _parseDurationToMinutes(String durationStr) {
  if (durationStr.isEmpty) return 0;

  var totalMinutes = 0;

  // Split by "et" to handle complex durations like "2 heures et 30 minutes"
  final segments = durationStr.split(' et ');

  for (final segment in segments) {
    final parts = segment.trim().split(' ');
    if (parts.length < 2) continue;

    int value;
    try {
      value = int.parse(parts[0]);
    } catch (e) {
      continue; // Skip invalid segments
    }

    final unit = parts[1].toLowerCase();

    if (unit.contains('seconde')) {
      totalMinutes +=
          (value / 60).ceil(); // Convert seconds to minutes, rounding up
    } else if (unit.contains('minute')) {
      totalMinutes += value;
    } else if (unit.contains('heure')) {
      totalMinutes += value * 60; // Convert hours to minutes
    } else if (unit.contains('jour')) {
      totalMinutes += value * 24 * 60; // Convert days to minutes
    }
  }

  return totalMinutes;
}

/// Formats minutes into a readable duration string.
String _formatDuration(int totalMinutes) {
  if (totalMinutes == 0) return "0 minute";

  final days = totalMinutes ~/ (24 * 60);
  totalMinutes %= (24 * 60);

  final hours = totalMinutes ~/ 60;
  totalMinutes %= 60;

  final minutes = totalMinutes;

  final parts = <String>[];

  if (days > 0) {
    parts.add('$days ${days == 1 ? "jour" : "jours"}');
  }

  if (hours > 0) {
    parts.add('$hours ${hours == 1 ? "heure" : "heures"}');
  }

  if (minutes > 0) {
    parts.add('$minutes ${minutes == 1 ? "minute" : "minutes"}');
  }

  // Join the parts with commas and 'et' for the last part if there are multiple parts
  if (parts.length > 1) {
    final lastPart = parts.removeLast();
    return '${parts.join(', ')} et $lastPart';
  }
  return parts.first;
}

/// Converts a formatted duration string back to minutes
/// Used when you have a duration like "2 heures et 30 minutes" and need to convert it back to minutes
int parseDurationStringToMinutes(String durationStr) {
  if (durationStr.isEmpty || durationStr == "0 minute") return 0;

  var totalMinutes = 0;

  // Remove common words and split by different separators
  final cleanStr =
      durationStr.replaceAll(',', ' ').replaceAll('  ', ' ').trim();

  // Split by "et" first
  final segments = cleanStr.split(' et ');

  for (final segment in segments) {
    // Then split each segment by spaces
    final words = segment.trim().split(' ');

    for (var i = 0; i < words.length - 1; i++) {
      final valueStr = words[i];
      final unit = words[i + 1].toLowerCase();

      int value;
      try {
        value = int.parse(valueStr);
      } catch (e) {
        continue; // Skip invalid numbers
      }

      if (unit.contains('jour')) {
        totalMinutes += value * 24 * 60;
      } else if (unit.contains('heure')) {
        totalMinutes += value * 60;
      } else if (unit.contains('minute')) {
        totalMinutes += value;
      }
    }
  }

  return totalMinutes;
}

String formatDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  } else {
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${remainingMinutes}min';
    }
  }
}

String? formatDistance(double? meters) {
  if (meters == null || meters < 0) return null;

  if (meters < 1000) {
    return '${meters.toStringAsFixed(0)} m';
  } else {
    final kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(2)} km';
  }
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
