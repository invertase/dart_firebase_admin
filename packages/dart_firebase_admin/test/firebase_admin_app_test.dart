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

import 'dart:async';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

void main() {
  group(FirebaseApp, () {
    test('initializeApp() creates a new FirebaseApp with options', () {
      final app = FirebaseApp.initializeApp();

      expect(app, isA<FirebaseApp>());
      expect(app.name, '[DEFAULT]');
    });
  });

  group('Environment emulator detection', () {
    test('isAuthEmulatorEnabled() returns true when env var is set', () async {
      const firebaseAuthEmulatorHost = '127.0.0.1:9000';
      final testEnv = <String, String>{
        Environment.firebaseAuthEmulatorHost: firebaseAuthEmulatorHost,
      };

      await runZoned(zoneValues: {envSymbol: testEnv}, () async {
        expect(Environment.isAuthEmulatorEnabled(), true);
        expect(Environment.isFirestoreEmulatorEnabled(), false);
      });
    });

    test(
      'isFirestoreEmulatorEnabled() returns true when env var is set',
      () async {
        const firestoreEmulatorHost = '127.0.0.1:8000';
        final testEnv = <String, String>{
          Environment.firestoreEmulatorHost: firestoreEmulatorHost,
        };

        await runZoned(zoneValues: {envSymbol: testEnv}, () async {
          expect(Environment.isFirestoreEmulatorEnabled(), true);
          expect(Environment.isAuthEmulatorEnabled(), false);
        });
      },
    );

    test(
      'both emulator detection methods work when both env vars are set',
      () async {
        const firebaseAuthEmulatorHost = '127.0.0.1:9000';
        const firestoreEmulatorHost = '127.0.0.1:8000';
        final testEnv = <String, String>{
          Environment.firebaseAuthEmulatorHost: firebaseAuthEmulatorHost,
          Environment.firestoreEmulatorHost: firestoreEmulatorHost,
        };

        await runZoned(zoneValues: {envSymbol: testEnv}, () async {
          expect(Environment.isAuthEmulatorEnabled(), true);
          expect(Environment.isFirestoreEmulatorEnabled(), true);
        });
      },
    );
  });
}
