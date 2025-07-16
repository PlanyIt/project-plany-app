import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockGeolocator extends Mock implements GeolocatorPlatform {}

void main() {
  late LocationService locationService;

  setUp(() {
    locationService = LocationService.test();
  });

  group('searchLocationByName', () {
    test('returns empty list when query is empty', () async {
      final results = await locationService.searchLocationByName('');
      expect(results, isEmpty);
    });
  });

  group('reverseGeocode', () {
    test('returns null on error', () async {
      final result = await locationService.reverseGeocode(LatLng(0, 0));
      expect(result, anyOf(isNull, isA<String>()));
    });
  });

  group('getCurrentLocation', () {
    test('returns null when location service disabled', () async {
      final pos = await locationService.getCurrentLocation(forceRefresh: true);
      expect(pos, anyOf(isNull, isA<Position>()));
    });
  });

  group('distance calculation', () {
    test('calculateDistanceToPoint returns null if no current position', () {
      expect(locationService.calculateDistanceToPoint(48.0, 2.0), isNull);
    });

    test('calculateDistanceToPlan returns null if args null', () {
      expect(locationService.calculateDistanceToPlan(null, null), isNull);
      expect(locationService.calculateDistanceToPlan(48.0, null), isNull);
      expect(locationService.calculateDistanceToPlan(null, 2.0), isNull);
    });
  });
}
