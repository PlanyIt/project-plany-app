import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/models/step/step.dart' as custom;

class NavigationService {
  static Future<void> navigateTo(BuildContext context,
      {required double latitude,
      required double longitude,
      String? title}) async {
    try {
      final hasPermission = await _handleLocationPermission(context);
      if (!hasPermission) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(title != null
              ? "Préparation de l'itinéraire vers $title..."
              : "Préparation de l'itinéraire...")));

      final position = await Geolocator.getCurrentPosition();

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
            action: 'action_view',
            data:
                'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$latitude,$longitude&travelmode=driving',
            package: 'com.google.android.apps.maps');
        await intent.launch();
      } else {
        //A tester
        // Pour iOS
        final url =
            'https://maps.apple.com/?saddr=${position.latitude},${position.longitude}&daddr=$latitude,$longitude&dirflg=d';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw Exception("Impossible d'ouvrir la navigation");
        }
      }
    } catch (e) {
      print("Erreur lors de la navigation: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Problème lors de l'ouverture de l'itinéraire: $e")));
    }
  }

  static Future<void> navigateToStep(
      BuildContext context, custom.Step step) async {
    if (step.position == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Impossible de naviguer: coordonnées manquantes")));
      return;
    }

    await navigateTo(
      context,
      latitude: step.position!.latitude,
      longitude: step.position!.longitude,
      title: step.title,
    );
  }

  static Future<bool> _handleLocationPermission(BuildContext context) async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permission de localisation refusée définitivement')),
      );
      return false;
    }

    return true;
  }
}
