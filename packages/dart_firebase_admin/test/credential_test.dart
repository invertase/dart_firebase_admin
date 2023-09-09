import 'dart:io';

import 'package:dart_firebase_admin/src/dart_firebase_admin.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

void main() {
  group(Credential, () {
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
        fs.file('service-account.json').writeAsStringSync(r'''
{
  "type": "service_account",
  "client_id": "id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCUD3KKtJk6JEDA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n4h3z8UdjAgMBAAECggEAR5HmBO2CygufLxLzbZ/jwN7Yitf0v/nT8LRjDs1WFux9\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nPPZaRPjBWvdqg4QttSSBKGm5FnhFPrpEFvOjznNBoQKBgQDJpRvDTIkNnpYhi/ni\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\ndLSYULRW1DBgakQd09NRvPBoQwKBgQC7+KGhoXw5Kvr7qnQu+x0Gb+8u8CHT0qCG\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nvpTRZN3CYQKBgFBc/DaWnxyNcpoGFl4lkBy/G9Q2hPf5KRsqS0CDL7BXCpL0lCyz\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nOcltaAFaTptzmARfj0Q2d7eEzemABr9JHdyCdY0RXgJe96zHijXOTiXPAoGAfe+C\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\npEmuauUytUaZ16G8/T8qh/ndPcqslwHQqsmtWYECgYEAwpvpZvvh7LXH5/OeLRjs\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nKhg2WH+bggdnYug+oRFauQs=\n-----END PRIVATE KEY-----",
  "client_email": "email"
}
''');

        // Should not throw.
        Credential.fromServiceAccount(fs.file('service-account.json'));
      });
    });
  });
}
