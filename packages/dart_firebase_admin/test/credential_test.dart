import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

const _fakeRSAKey =
    '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCUD3KKtJk6JEDA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n4h3z8UdjAgMBAAECggEAR5HmBO2CygufLxLzbZ/jwN7Yitf0v/nT8LRjDs1WFux9\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nPPZaRPjBWvdqg4QttSSBKGm5FnhFPrpEFvOjznNBoQKBgQDJpRvDTIkNnpYhi/ni\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\ndLSYULRW1DBgakQd09NRvPBoQwKBgQC7+KGhoXw5Kvr7qnQu+x0Gb+8u8CHT0qCG\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nvpTRZN3CYQKBgFBc/DaWnxyNcpoGFl4lkBy/G9Q2hPf5KRsqS0CDL7BXCpL0lCyz\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nOcltaAFaTptzmARfj0Q2d7eEzemABr9JHdyCdY0RXgJe96zHijXOTiXPAoGAfe+C\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\npEmuauUytUaZ16G8/T8qh/ndPcqslwHQqsmtWYECgYEAwpvpZvvh7LXH5/OeLRjs\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nKhg2WH+bggdnYug+oRFauQs=\n-----END PRIVATE KEY-----';

void main() {
  group(Credential, () {
    test('fromServiceAccountParams', () {
      expect(
        () => Credential.fromServiceAccountParams(
          clientId: 'id',
          privateKey: _fakeRSAKey,
          email: 'email',
        ),
        returnsNormally,
      );
    });

    group('fromServiceAccount', () {
      test('throws if file is missing', () {
        final fs = MemoryFileSystem.test();

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('throws if file cannot be parsed', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('invalid');

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsFormatException,
        );
      });

      test('throws if file is not correctly formatted', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('{}');

        expect(
          () => Credential.fromServiceAccount(fs.file('service-account.json')),
          throwsArgumentError,
        );
      });

      test('completes if file exists and is correctly formatted', () {
        final fs = MemoryFileSystem.test();
        fs.file('service-account.json').writeAsStringSync('''
{
  "type": "service_account",
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
        final fakeServiceAccount = {
          'GOOGLE_APPLICATION_CREDENTIALS': '''
{
  "type": "service_account",
  "client_id": "id",
  "private_key": ${jsonEncode(_fakeRSAKey)},
  "client_email": "foo@bar.com"
}
''',
        };
        final credential = runZoned(
          Credential.fromApplicationDefaultCredentials,
          zoneValues: {envSymbol: fakeServiceAccount},
        );
        expect(credential.serviceAccountCredentials, isNotNull);

        // Verify if service account is actually being used
        expect(
          credential.serviceAccountCredentials!.email,
          'foo@bar.com',
        );
      });

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
      });
    });
  });
}
