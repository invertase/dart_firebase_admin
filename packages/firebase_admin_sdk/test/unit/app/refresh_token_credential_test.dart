// Copyright 2026 Firebase
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

import 'dart:convert';

import 'package:file/memory.dart';
import 'package:firebase_admin_sdk/src/app.dart';
import 'package:test/test.dart';

void main() {
  group('Credential.fromRefreshToken', () {
    test('throws if file is missing', () {
      final fs = MemoryFileSystem.test();
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if file content is not valid JSON', () {
      final fs = MemoryFileSystem.test();
      fs.file('refresh_token.json').writeAsStringSync('not-json');
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if client_id is missing', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_secret': 'secret',
              'refresh_token': 'token',
              'type': 'authorized_user',
            }),
          );
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if client_secret is missing', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_id': 'id',
              'refresh_token': 'token',
              'type': 'authorized_user',
            }),
          );
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if refresh_token is missing', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_id': 'id',
              'client_secret': 'secret',
              'type': 'authorized_user',
            }),
          );
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if type is missing', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_id': 'id',
              'client_secret': 'secret',
              'refresh_token': 'token',
            }),
          );
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if any field is an empty string', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_id': '',
              'client_secret': 'secret',
              'refresh_token': 'token',
              'type': 'authorized_user',
            }),
          );
      expect(
        () => Credential.fromRefreshToken(fs.file('refresh_token.json')),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('returns RefreshTokenCredential for valid file', () {
      final fs = MemoryFileSystem.test();
      fs
          .file('refresh_token.json')
          .writeAsStringSync(
            jsonEncode({
              'client_id': 'test-id',
              'client_secret': 'test-secret',
              'refresh_token': 'test-refresh-token',
              'type': 'authorized_user',
            }),
          );

      final credential = Credential.fromRefreshToken(
        fs.file('refresh_token.json'),
      );

      expect(credential, isA<RefreshTokenCredential>());
      final rt = credential as RefreshTokenCredential;
      expect(rt.clientId, 'test-id');
      expect(rt.clientSecret, 'test-secret');
      expect(rt.refreshToken, 'test-refresh-token');
      expect(rt.serviceAccountCredentials, isNull);
      expect(rt.serviceAccountId, isNull);
    });
  });

  group('Credential.fromRefreshTokenParams', () {
    test('throws if clientId is empty', () {
      expect(
        () => Credential.fromRefreshTokenParams(
          clientId: '',
          clientSecret: 'secret',
          refreshToken: 'token',
          type: 'authorized_user',
        ),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if clientSecret is empty', () {
      expect(
        () => Credential.fromRefreshTokenParams(
          clientId: 'id',
          clientSecret: '',
          refreshToken: 'token',
          type: 'authorized_user',
        ),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if refreshToken is empty', () {
      expect(
        () => Credential.fromRefreshTokenParams(
          clientId: 'id',
          clientSecret: 'secret',
          refreshToken: '',
          type: 'authorized_user',
        ),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('throws if type is empty', () {
      expect(
        () => Credential.fromRefreshTokenParams(
          clientId: 'id',
          clientSecret: 'secret',
          refreshToken: 'token',
          type: '',
        ),
        throwsA(isA<FirebaseAppException>()),
      );
    });

    test('returns RefreshTokenCredential for valid params', () {
      final credential = Credential.fromRefreshTokenParams(
        clientId: 'my-client-id',
        clientSecret: 'my-client-secret',
        refreshToken: 'my-refresh-token',
        type: 'authorized_user',
      );

      expect(credential, isA<RefreshTokenCredential>());
      final rt = credential as RefreshTokenCredential;
      expect(rt.clientId, 'my-client-id');
      expect(rt.clientSecret, 'my-client-secret');
      expect(rt.refreshToken, 'my-refresh-token');
      expect(rt.serviceAccountCredentials, isNull);
      expect(rt.serviceAccountId, isNull);
    });
  });
}
