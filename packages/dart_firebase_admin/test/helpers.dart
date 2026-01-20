import 'dart:async';
import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as googleapis_auth;
import 'package:googleapis_firestore/googleapis_firestore.dart'
    as googleapis_firestore;
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Mock Firestore settings that use emulator override to avoid ADC loading.
/// Use this in tests that need to initialize Firestore without real credentials.
const mockFirestoreSettings = googleapis_firestore.Settings(
  projectId: projectId,
  environmentOverride: {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
);

/// Creates mock Firestore settings with a custom database ID.
googleapis_firestore.Settings mockFirestoreSettingsWithDb(String databaseId) =>
    googleapis_firestore.Settings(
      projectId: projectId,
      databaseId: databaseId,
      environmentOverride: const {'FIRESTORE_EMULATOR_HOST': 'localhost:8080'},
    );

/// Whether Google Application Default Credentials are available.
/// Used to skip tests that require production Firebase access.
final hasGoogleEnv =
    Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] != null;

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
}) {
  final app = FirebaseApp.initializeApp(
    name: name,
    options: AppOptions(projectId: projectId, httpClient: client),
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
