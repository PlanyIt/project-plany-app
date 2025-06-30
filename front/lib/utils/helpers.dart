import 'package:front/domain/models/step/step.dart' as step_model;

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
///
/// Handles durations in the format "X minutes", "X heures", "X jours", etc.
/// Returns a formatted string representing the total duration.
String calculateTotalStepsDuration(List<step_model.Step> steps) {
  // Convert all durations to minutes for easy calculation
  int totalMinutes = 0;

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

  int totalMinutes = 0;

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

  final List<String> parts = [];

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

  int totalMinutes = 0;

  // Remove common words and split by different separators
  final cleanStr =
      durationStr.replaceAll(',', ' ').replaceAll('  ', ' ').trim();

  // Split by "et" first
  final segments = cleanStr.split(' et ');

  for (final segment in segments) {
    // Then split each segment by spaces
    final words = segment.trim().split(' ');

    for (int i = 0; i < words.length - 1; i++) {
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
