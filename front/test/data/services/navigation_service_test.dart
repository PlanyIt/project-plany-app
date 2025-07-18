import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/navigation_service.dart';
import 'package:front/domain/models/step/step.dart' as custom;
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

// Fake GeolocatorPlatform pour contourner l'implémentation native
class FakeGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<Position> getCurrentPosition(
      {LocationSettings? locationSettings}) async {
    return Position(
      latitude: 48.0,
      longitude: 2.0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
    );
  }
}

void main() {
  late FakeGeolocatorPlatform fakeGeolocator;

  setUp(() {
    fakeGeolocator = FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fakeGeolocator;
  });

  testWidgets('navigateToStep shows error snackbar if coordinates missing',
      (WidgetTester tester) async {
    final step = custom.Step(
      id: '1',
      title: 'Test Step',
      description: 'desc',
      order: 1,
      image: '',
      latitude: null,
      longitude: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // <-- Ajout du Scaffold
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    NavigationService.navigateToStep(context, step),
                child: const Text('Navigate'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Navigate'));
    await tester.pump();

    expect(find.textContaining('coordonnées manquantes'), findsOneWidget);
  });

  testWidgets('navigateTo shows snackbar and calls geolocator',
      (WidgetTester tester) async {
    final step = custom.Step(
      id: '2',
      title: 'Test Step',
      description: 'desc',
      order: 1,
      image: '',
      latitude: 50.0,
      longitude: 3.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // <-- Ajout du Scaffold
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    NavigationService.navigateToStep(context, step),
                child: const Text('Navigate'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Navigate'));
    await tester.pump();

    expect(find.textContaining('Préparation de l\'itinéraire'), findsOneWidget);
  });
}
