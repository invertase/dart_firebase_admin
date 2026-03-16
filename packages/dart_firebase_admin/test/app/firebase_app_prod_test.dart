// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/auth.dart';
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
        skip: hasProdEnv
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
        skip: hasProdEnv
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
        skip: hasProdEnv
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
        skip: hasProdEnv
            ? false
            : 'Requires GOOGLE_APPLICATION_CREDENTIALS to be set',
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('Workload Identity Federation tests', () {
      late FirebaseApp app;

      setUpAll(() async {
        // Initialize via WIF (ADC)
        app = FirebaseApp.initializeApp(
          options: AppOptions(
            credential: Credential.fromApplicationDefaultCredentials(
              serviceAccountId:
                  'firebase-adminsdk-fbsvc@dart-firebase-admin.iam.gserviceaccount.com',
            ),
            projectId: 'dart-firebase-admin',
          ),
        );
      });

      test(
        'should initializeApp via WIF (ADC)',
        () {
          expect(app, isNotNull);
        },
        skip: hasWifEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'should test Auth (getUsers)',
        () async {
          final auth = app.auth();
          expect(auth, isNotNull);

          final listUsersResult = await auth.listUsers(maxResults: 1);
          expect(listUsersResult.users, isA<List<UserRecord>>());
        },
        skip: hasWifEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );

      test(
        'should test Firestore (write + read)',
        () async {
          final db = app.firestore();
          expect(db, isNotNull);

          final docRef = db.collection('wif-demo').doc('test-connection');
          const testMessage = 'Hello from GitHub Actions WIF!';

          await docRef.set({
            'timestamp': DateTime.now().toIso8601String(),
            'message': testMessage,
          });

          final doc = await docRef.get();
          expect(doc.exists, isTrue);
          expect(doc.data()?['message'], equals(testMessage));
          expect(doc.data()?['timestamp'], isNotNull);
        },
        skip: hasWifEnv ? false : 'Requires GOOGLE_APPLICATION_CREDENTIALS',
      );
    });
  });
}
