// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'main.dart';

/// Staging config entry point.
/// Launch with `flutter run --target lib/main_staging.dart`.
/// Uses remote data from a server.
Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('Fichier .env chargé avec succès');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur lors du chargement du fichier .env: $e');
    }
  }
  Logger.root.level = Level.ALL;

  // Désactive la vérification Provider pour les types Listenable
  Provider.debugCheckInvalidValueType = null;

  runApp(MultiProvider(providers: unifiedProviders, child: const MainApp()));
}
