import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
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
