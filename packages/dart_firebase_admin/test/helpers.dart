import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:google_cloud_firestore/google_cloud_firestore.dart'
    as google_cloud_firestore;
import 'package:googleapis_auth/googleapis_auth.dart' as googleapis_auth;
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Mock Firestore settings that use emulator override to avoid ADC loading.
/// Use this in tests that need to initialize Firestore without real credentials.
const mockFirestoreSettings = google_cloud_firestore.Settings(
  projectId: projectId,
  environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
);

/// Creates mock Firestore settings with a custom database ID.
google_cloud_firestore.Settings mockFirestoreSettingsWithDb(
  String databaseId,
) => google_cloud_firestore.Settings(
  projectId: projectId,
  databaseId: databaseId,
  environmentOverride: const {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
);

/// Whether Google Application Default Credentials are available.
/// Used to skip tests that require production Firebase access.
final hasGoogleEnv =
    Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] != null;

/// Returns a copy of [Platform.environment] with all emulator host variables
/// removed, so tests can connect to production Firebase even when emulators
/// are configured in the outer environment.
Map<String, String> prodEnv() {
  final env = Map<String, String>.from(Platform.environment);
  env.remove(Environment.firebaseAuthEmulatorHost);
  env.remove(Environment.firestoreEmulatorHost);
  env.remove(Environment.firebaseStorageEmulatorHost);
  env.remove(Environment.cloudTasksEmulatorHost);
  return env;
}

/// Creates a FirebaseApp for testing.
///
/// Note: Tests should be run with the following environment variables set:
/// - FIRESTORE_EMULATOR_HOST=localhost:8080
/// - FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
///
/// The emulator will be auto-detected from these environment variables.
FirebaseApp createApp({
  FutureOr<void> Function()? tearDown,
  googleapis_auth.AuthClient? client,
  String? name,
  Credential? credential,
}) {
  final app = FirebaseApp.initializeApp(
    name: name,
    options: AppOptions(
      projectId: projectId,
      httpClient: client,
      credential: credential,
    ),
  );

  addTearDown(() async {
    if (tearDown != null) {
      await tearDown();
    }
    await app.close();
  });

  return app;
}

Matcher isArgumentError({String? message}) {
  var matcher = isA<ArgumentError>();
  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return matcher;
}

Matcher throwsArgumentError({String? message}) {
  return throwsA(isArgumentError(message: message));
}
