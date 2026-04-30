// Copyright 2026 Google LLC
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

@Tags(['prod'])
library;

import 'dart:async';

import 'package:firebase_admin_sdk/app_check.dart';
import 'package:firebase_admin_sdk/src/app.dart';
import 'package:test/test.dart';

import '../../fixtures/helpers.dart';

const _testAppId = '1:559949546715:android:4268b2eabcd3124b0ab8fe';

void main() {
  group('AppCheck (Production)', () {
    group('createToken()', () {
      test('returns a token with a non-empty JWT string', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            final token = await appCheck.createToken(_testAppId);

            expect(token.token, isNotEmpty);
            // A JWT has exactly two dots
            expect(token.token.split('.').length, equals(3));
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });

      test('returns ttlMillis within the valid range (30min–7days)', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            final token = await appCheck.createToken(_testAppId);

            expect(
              token.ttlMillis,
              greaterThanOrEqualTo(const Duration(minutes: 30).inMilliseconds),
            );
            expect(
              token.ttlMillis,
              lessThanOrEqualTo(const Duration(days: 7).inMilliseconds),
            );
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });

      test('honours a custom ttlMillis option', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            const customTtl = Duration(hours: 2);
            final token = await appCheck.createToken(
              _testAppId,
              AppCheckTokenOptions(ttlMillis: customTtl),
            );

            expect(token.token, isNotEmpty);
            // Server rounds to the nearest second; allow ±1 second tolerance.
            expect(token.ttlMillis, closeTo(customTtl.inMilliseconds, 1000));
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });
    });

    group('verifyToken()', () {
      test('returns decoded token with correct claims structure', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            final token = await appCheck.createToken(_testAppId);
            final result = await appCheck.verifyToken(token.token);

            final decoded = result.token;
            expect(result.appId, equals(_testAppId));
            expect(decoded.sub, equals(_testAppId));
            expect(
              decoded.iss,
              startsWith('https://firebaseappcheck.googleapis.com/'),
            );
            expect(decoded.aud, isNotEmpty);
            expect(decoded.exp, greaterThan(decoded.iat));
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });

      test('sets alreadyConsumed to null when consume option is not set', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            final token = await appCheck.createToken(_testAppId);
            final result = await appCheck.verifyToken(token.token);

            expect(result.alreadyConsumed, isNull);
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });

      test(
        'sets alreadyConsumed to false on first consume, true on second',
        () {
          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final appCheck = AppCheck.internal(app);

            try {
              final token = await appCheck.createToken(_testAppId);

              final first = await appCheck.verifyToken(
                token.token,
                VerifyAppCheckTokenOptions()..consume = true,
              );
              expect(first.alreadyConsumed, isFalse);

              final second = await appCheck.verifyToken(
                token.token,
                VerifyAppCheckTokenOptions()..consume = true,
              );
              expect(second.alreadyConsumed, isTrue);
            } finally {
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv()});
        },
      );

      test('throws FirebaseAppCheckException for an invalid token', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            await expectLater(
              () => appCheck.verifyToken('invalid.token.value'),
              throwsA(isA<FirebaseAppCheckException>()),
            );
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });

      test('throws FirebaseAppCheckException for a tampered token', () {
        return runZoned(() async {
          final appName = 'prod-test-${DateTime.now().microsecondsSinceEpoch}';
          final app = FirebaseApp.initializeApp(name: appName);
          final appCheck = AppCheck.internal(app);

          try {
            final token = await appCheck.createToken(_testAppId);
            // Corrupt the signature portion of the JWT.
            final parts = token.token.split('.');
            final tampered = '${parts[0]}.${parts[1]}.invalidsignature';

            await expectLater(
              () => appCheck.verifyToken(tampered),
              throwsA(isA<FirebaseAppCheckException>()),
            );
          } finally {
            await app.close();
          }
        }, zoneValues: {envSymbol: prodEnv()});
      });
    });
  });
}
