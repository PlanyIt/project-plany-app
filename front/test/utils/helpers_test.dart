import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/step/step.dart' as step_model;
import 'package:front/utils/helpers.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('calculateTotalStepsCost', () {
    test('returns sum of costs', () {
      final steps = [
        step_model.Step(
            cost: 10.0,
            title: 'Step 1',
            description: 'First step',
            order: 1,
            image: '',
            latitude: null,
            longitude: null),
        step_model.Step(
            cost: 20.0,
            title: 'Step 2',
            description: 'Second step',
            order: 2,
            image: '',
            latitude: null,
            longitude: null),
        step_model.Step(
            cost: null,
            title: 'Step 3',
            description: 'Third step',
            order: 3,
            image: '',
            latitude: null,
            longitude: null),
      ];
      expect(calculateTotalStepsCost(steps), 30.0);
    });
  });

  group('formatDurationToString', () {
    test('formats minutes to string', () {
      expect(formatDurationToString(0), '0 minutes');
      expect(formatDurationToString(45), '45 minutes');
      expect(formatDurationToString(60), '1 heures');
      expect(formatDurationToString(1500), '1 jours 1 heures');
      expect(formatDurationToString(1501), '1 jours 1 heures 1 minutes');
    });
  });

  group('formatDurationToMinutes', () {
    test('parses duration string to minutes', () {
      expect(formatDurationToMinutes(''), 0);
      expect(formatDurationToMinutes('1 jours 2 heures 3 minutes'),
          1 * 24 * 60 + 2 * 60 + 3);
      expect(formatDurationToMinutes('2heures'), 120);
      expect(formatDurationToMinutes('15minutes'), 15);
      expect(formatDurationToMinutes('1jours'), 1440);
    });
  });

  group('calculateDistanceBetween', () {
    test('calculates distance between two points', () {
      final d = calculateDistanceBetween(48.8566, 2.3522, 48.857, 2.353);
      expect(d, greaterThan(0));
    });
  });

  group('latLngFromDoubles', () {
    test('returns LatLng or null', () {
      expect(latLngFromDoubles(1.0, 2.0), LatLng(1.0, 2.0));
      expect(latLngFromDoubles(null, 2.0), null);
      expect(latLngFromDoubles(1.0, null), null);
    });
  });

  group('colorFromHex', () {
    test('converts hex to Color', () {
      expect(colorFromHex('#FF5733').value, Color(0xFFFF5733).value);
      expect(colorFromHex('FF5733').value, Color(0xFFFF5733).value);
    });
  });

  group('convertDurationToMinutes', () {
    test('converts units to minutes', () {
      expect(convertDurationToMinutes(2, 'minutes'), 2);
      expect(convertDurationToMinutes(2, 'heures'), 120);
      expect(convertDurationToMinutes(1, 'jours'), 1440);
    });
  });

  group('convertMinutesToUnit', () {
    test('converts minutes to unit', () {
      expect(convertMinutesToUnit(120, 'heures'), 2);
      expect(convertMinutesToUnit(1440, 'jours'), 1);
      expect(convertMinutesToUnit(60, 'minutes'), 60);
    });
  });

  group('formatDistance', () {
    test('formats distance', () {
      expect(formatDistance(500), '500 m');
      expect(formatDistance(1500), '1.5 km');
      expect(formatDistance(10500), '11 km');
      expect(formatDistance(null), 'Distance inconnue');
    });
  });

  group('calculateDistanceBetweenLatLng', () {
    test('calculates distance between LatLng', () {
      final d = calculateDistanceBetweenLatLng(
          LatLng(48.8566, 2.3522), LatLng(48.857, 2.353));
      expect(d, greaterThan(0));
    });
  });

  group('colorFromPlanCategory', () {
    test('returns Color or null', () {
      expect(colorFromPlanCategory('#FF5733')?.value, Color(0xFFFF5733).value);
      expect(colorFromPlanCategory(''), null);
      expect(colorFromPlanCategory('badhex'), null);
    });
  });

  group('formatTimeAgo', () {
    test('formats time ago', () {
      final now = DateTime.now();
      expect(formatTimeAgo(now.subtract(Duration(minutes: 1))), '1m');
      expect(formatTimeAgo(now.subtract(Duration(hours: 1))), '1h');
      expect(formatTimeAgo(now.subtract(Duration(days: 1))), '1j');
      expect(
          formatTimeAgo(now.subtract(Duration(days: 10))).contains('/'), true);
    });
  });

  group('capitalize', () {
    test('capitalizes first letter', () {
      expect(capitalize('hello'), 'Hello');
      expect(capitalize(''), '');
    });
  });

  group('formatDate', () {
    test('formats date', () {
      final date = DateTime(2023, 5, 7);
      expect(formatDate(date), '07/05/2023');
    });
  });
}
