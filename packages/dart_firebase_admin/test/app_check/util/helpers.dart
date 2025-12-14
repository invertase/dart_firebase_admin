import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

/// Creates a FirebaseApp instance for production App Check tests.
///
/// Uses runZoned with zoneValues to temporarily disable emulator env vars.
/// This allows production tests to run even when emulator env vars are set,
/// which is necessary for the coverage script.
///
/// **IMPORTANT:** Only use this for tests that REQUIRE production Firebase.
FirebaseApp createProductionApp() {
  late FirebaseApp app;

  // Remove emulator env var from the zone environment (if any future emulator support)
  final prodEnv = Map<String, String>.from(Platform.environment);
  // App Check doesn't have emulator yet, but keep pattern consistent
  // prodEnv.remove(Environment.appCheckEmulatorHost);

  runZoned(() {
    final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
    app = FirebaseApp.initializeApp(name: appName);

    addTearDown(() async {
      await app.close();
    });
  }, zoneValues: {envSymbol: prodEnv});

  return app;
}
