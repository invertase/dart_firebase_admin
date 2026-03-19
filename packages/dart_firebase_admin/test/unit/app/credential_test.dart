// Copyright 2024 Google LLC
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
import 'dart:convert';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import '../../fixtures/mock_service_account.dart';

const _fakeRSAKey =
    '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCUD3KKtJk6JEDA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n4h3z8UdjAgMBAAECggEAR5HmBO2CygufLxLzbZ/jwN7Yitf0v/nT8LRjDs1WFux9\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nPPZaRPjBWvdqg4QttSSBKGm5FnhFPrpEFvOjznNBoQKBgQDJpRvDTIkNnpYhi/ni\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\ndLSYULRW1DBgakQd09NRvPBoQwKBgQC7+KGhoXw5Kvr7qnQu+x0Gb+8u8CHT0qCG\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nvpTRZN3CYQKBgFBc/DaWnxyNcpoGFl4lkBy/G9Q2hPf5KRsqS0CDL7BXCpL0lCyz\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nOcltaAFaTptzmARfj0Q2d7eEzemABr9JHdyCdY0RXgJe96zHijXOTiXPAoGAfe+C\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\npEmuauUytUaZ16G8/T8qh/ndPcqslwHQqsmtWYECgYEAwpvpZvvh7LXH5/OeLRjs\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nKhg2WH+bggdnYug+oRFauQs=\n-----END PRIVATE KEY-----';

// TODO(demolaf): check if we have sufficient tests for credential
void main() {
  group(Credential, () {
    test('fromServiceAccountParams', () {
      expect(
        () => Credential.fromServiceAccountParams(
          clientId: 'id',
          privateKey: _fakeRSAKey,
          email: 'email',
          projectId: mockProjectId,
        ),
        returnsNormally,
      );
    });

    group('fromServiceAccount', () {
      test('throws if file is missing', () {
        final fs = MemoryFileSystem.test();

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('throws if file cannot be parsed', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('invalid');

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('throws if file is not correctly formatted', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('{}');

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsA(isA<FirebaseAppException>()),
        );
      });

      test('completes if file exists and is correctly formatted', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('''
{
  "type": "service_account",
  "project_id": "test-project",
  "client_id": "id",
  "private_key": ${jsonEncode(_fakeRSAKey)},
  "client_email": "email"
}
''');

        // Should not throw.
        Credential.fromServiceAccount(fs.file('service-account.json'));
      });
    });

    group('fromApplicationDefaultCredentials', () {
      test(
        'completes if `GOOGLE_APPLICATION_CREDENTIALS` environment-variable is valid service account JSON',
        () {
          final dir = Directory.current.createTempSync();
          addTearDown(() => dir.deleteSync(recursive: true));
          final file = File('${dir.path}/service-account.json');
          file.writeAsStringSync('''
{
  "type": "service_account",
  "client_id": "id",
  "private_key": ${jsonEncode(_fakeRSAKey)},
  "client_email": "foo@bar.com"
}
''');

          final fakeServiceAccount = {
            'GOOGLE_APPLICATION_CREDENTIALS': file.path,
          };
          final credential = runZoned(
            Credential.fromApplicationDefaultCredentials,
            zoneValues: {envSymbol: fakeServiceAccount},
          );
          expect(credential, isA<ApplicationDefaultCredential>());
          expect(credential.serviceAccountCredentials, isNull);
        },
      );

      test(
        'does nothing if `GOOGLE_APPLICATION_CREDENTIALS` environment-variable is not valid service account JSON',
        () {
          final credential = runZoned(
            Credential.fromApplicationDefaultCredentials,
            zoneValues: {
              envSymbol: {'GOOGLE_APPLICATION_CREDENTIALS': ''},
            },
          );
          expect(credential.serviceAccountCredentials, isNull);
        },
      );
    });
  });
}
