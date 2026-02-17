// Firebase App Production Tests
//
// Covers code paths in FirebaseApp that require real Google credentials:
//   - _createDefaultClient() ADC path      (lines 122-124)
//   - _createDefaultClient() SA path       (lines 110-118)
//   - close() SDK-client shutdown          (line 270)
//   - getProjectId() → computeProjectId() (line 152)
//
// Tests are skipped automatically when GOOGLE_APPLICATION_CREDENTIALS is not
// set. They can run alongside emulator tests because each test builds a
// prodEnv zone that strips emulator environment variables.
//
// Run standalone:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
//   dart test test/app/firebase_app_prod_test.dart
//
// Run as part of the full suite:
//   FIRESTORE_EMULATOR_HOST=localhost:8080 \
//   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \
//   dart test

import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  Map<String, String> prodEnv() {
    final env = Map<String, String>.from(Platform.environment);
    env.remove(Environment.firebaseAuthEmulatorHost);
    env.remove(Environment.firestoreEmulatorHost);
    env.remove(Environment.firebaseStorageEmulatorHost);
    env.remove(Environment.cloudTasksEmulatorHost);
    return env;
  }

  group('FirebaseApp (Production)', () {
    group('_createDefaultClient – ADC path', () {
      test(
        'creates an authenticated client via Application Default Credentials',
        () {
          return runZoned(() async {
            final app = FirebaseApp.initializeApp(
              name: 'adc-client-${DateTime.now().microsecondsSinceEpoch}',
              options: const AppOptions(projectId: projectId),
            );

            try {
              final client = await app.client;
              expect(client, isNotNull);
            } finally {
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv()});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS to be set',
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'SDK-created ADC client is closed when app.close() is called',
        () {
          return runZoned(() async {
            final app = FirebaseApp.initializeApp(
              name: 'adc-close-${DateTime.now().microsecondsSinceEpoch}',
              options: const AppOptions(projectId: projectId),
            );

            await app.client;
            await app.close();

            expect(app.isDeleted, isTrue);
          }, zoneValues: {envSymbol: prodEnv()});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS to be set',
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('_createDefaultClient – service account path', () {
      test(
        'creates an authenticated client via service account credential',
        () {
          return runZoned(() async {
            final saFile = File(
              Platform.environment['GOOGLE_APPLICATION_CREDENTIALS']!,
            );
            final credential = Credential.fromServiceAccount(saFile);

            final app = FirebaseApp.initializeApp(
              name: 'sa-client-${DateTime.now().microsecondsSinceEpoch}',
              options: AppOptions(projectId: projectId, credential: credential),
            );

            try {
              final client = await app.client;
              expect(client, isNotNull);
            } finally {
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv()});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS to be set',
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('getProjectId – computeProjectId fallback', () {
      test(
        'falls back to computeProjectId() when no projectId source is configured',
        () {
          // envSymbol is set to null so Zone.current[envSymbol] == null inside
          // getProjectId(), causing env == null and skipping the env-var loop.
          // With no projectIdOverride and no options.projectId the method must
          // call computeProjectId(), which reads GCP project env vars from
          // Platform.environment (e.g. GOOGLE_CLOUD_PROJECT).
          return runZoned(() async {
            final app = FirebaseApp.initializeApp(
              name: 'compute-project-${DateTime.now().microsecondsSinceEpoch}',
              options: const AppOptions(),
            );

            try {
              final resolved = await app.getProjectId();
              expect(resolved, isNotEmpty);
            } finally {
              await app.close();
            }
          }, zoneValues: {envSymbol: null});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS to be set',
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });
  });
}
