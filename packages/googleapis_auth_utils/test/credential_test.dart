import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis_auth_utils/src/credential.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks
class MockAuthClient extends Mock implements auth_io.AuthClient {}

class MockAccessCredentials extends Mock implements auth.AccessCredentials {}

const _fakeRSAKey =
    '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCUD3KKtJk6JEDA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n4h3z8UdjAgMBAAECggEAR5HmBO2CygufLxLzbZ/jwN7Yitf0v/nT8LRjDs1WFux9\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nPPZaRPjBWvdqg4QttSSBKGm5FnhFPrpEFvOjznNBoQKBgQDJpRvDTIkNnpYhi/ni\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\ndLSYULRW1DBgakQd09NRvPBoQwKBgQC7+KGhoXw5Kvr7qnQu+x0Gb+8u8CHT0qCG\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nvpTRZN3CYQKBgFBc/DaWnxyNcpoGFl4lkBy/G9Q2hPf5KRsqS0CDL7BXCpL0lCyz\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nOcltaAFaTptzmARfj0Q2d7eEzemABr9JHdyCdY0RXgJe96zHijXOTiXPAoGAfe+C\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\npEmuauUytUaZ16G8/T8qh/ndPcqslwHQqsmtWYECgYEAwpvpZvvh7LXH5/OeLRjs\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nKhg2WH+bggdnYug+oRFauQs=\n-----END PRIVATE KEY-----';

void main() {
  group('GoogleCredential.getAccessToken', () {
    group('GoogleServiceAccountCredential', () {
      test('returns access token when authClient is provided', () async {
        final mockClient = MockAuthClient();
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'mock-token-data',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromServiceAccountParams(
          privateKey: _fakeRSAKey,
          email: 'test@example.com',
          projectId: 'test-project',
          authClient: mockClient,
        );

        final token = await credential.getAccessToken();

        expect(token.data, 'mock-token-data');
        expect(token.type, 'Bearer');
        expect(token.expiry.isAfter(DateTime.now().toUtc()), isTrue);
        verify(() => mockClient.credentials).called(1);
      });

      test('caches authClient and reuses it on subsequent calls', () async {
        final mockClient = MockAuthClient();
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'cached-token',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromServiceAccountParams(
          privateKey: _fakeRSAKey,
          email: 'test@example.com',
          projectId: 'test-project',
          authClient: mockClient,
        );

        // Call twice
        await credential.getAccessToken();
        await credential.getAccessToken();

        // Should use the same cached client
        verify(() => mockClient.credentials).called(2);
      });

      test('returns token with correct properties', () async {
        final mockClient = MockAuthClient();
        final expiryTime = DateTime.now().toUtc().add(const Duration(hours: 2));
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'test-token-12345',
          expiryTime,
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromServiceAccountParams(
          privateKey: _fakeRSAKey,
          email: 'test@example.com',
          projectId: 'test-project',
          authClient: mockClient,
        );

        final token = await credential.getAccessToken();

        expect(token.data, 'test-token-12345');
        expect(token.type, 'Bearer');
        expect(token.expiry, expiryTime);
      });
    });

    group('GoogleApplicationDefaultCredential', () {
      test('returns access token when authClient is provided', () async {
        final mockClient = MockAuthClient();
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'adc-mock-token',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromApplicationDefaultCredentials(
          authClient: mockClient,
        );

        final token = await credential.getAccessToken();

        expect(token.data, 'adc-mock-token');
        expect(token.type, 'Bearer');
        expect(token.expiry.isAfter(DateTime.now().toUtc()), isTrue);
        verify(() => mockClient.credentials).called(1);
      });

      test('caches authClient and reuses it on subsequent calls', () async {
        final mockClient = MockAuthClient();
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'adc-cached-token',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromApplicationDefaultCredentials(
          authClient: mockClient,
        );

        // Call twice
        await credential.getAccessToken();
        await credential.getAccessToken();

        // Should use the same cached client
        verify(() => mockClient.credentials).called(2);
      });

      test('works with service account from environment', () async {
        final dir = Directory.current.createTempSync();
        addTearDown(() => dir.deleteSync(recursive: true));
        final file = File('${dir.path}/service-account.json');
        file.writeAsStringSync(
          jsonEncode({
            'type': 'service_account',
            'project_id': 'test-project',
            'client_email': 'test@example.com',
            'private_key': _fakeRSAKey,
          }),
        );

        final mockClient = MockAuthClient();
        final mockAccessToken = auth.AccessToken(
          'Bearer',
          'sa-from-file-token',
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        );
        final mockCredentials = MockAccessCredentials();

        when(() => mockCredentials.accessToken).thenReturn(mockAccessToken);
        when(() => mockClient.credentials).thenReturn(mockCredentials);

        final credential = GoogleCredential.fromApplicationDefaultCredentials(
          environment: {'GOOGLE_APPLICATION_CREDENTIALS': file.path},
          authClient: mockClient,
        );

        final token = await credential.getAccessToken();

        expect(token.data, 'sa-from-file-token');
        expect(token.type, 'Bearer');
        verify(() => mockClient.credentials).called(1);
      });
    });
  });
}
