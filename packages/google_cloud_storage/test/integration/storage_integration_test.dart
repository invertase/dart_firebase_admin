import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;

import 'package:google_cloud_storage/google_cloud_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  group(
    'Storage credential integration tests',
    () {
      test('should create Storage with explicit credentials', () async {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        final storage = Storage(StorageOptions(credential: credentials));

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        client.close();
      });

      test('should create Storage with keyFilename', () async {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        final storage = Storage(StorageOptions(credential: credentials));

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        client.close();
      });

      test('should prioritize credentials over keyFilename', () async {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        final storage = Storage(StorageOptions(credential: credentials));

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        client.close();
      });

      test('should fall back to ADC when no credentials provided', () async {
        final storage = Storage(StorageOptions());

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        client.close();
      });

      test('should respect explicit authClient over credentials', () async {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        final explicitClient = await auth
            .clientViaApplicationDefaultCredentials(
              scopes: ['https://www.googleapis.com/auth/cloud-platform'],
            );

        final testEnv = <String, String>{
          'GOOGLE_APPLICATION_CREDENTIALS': credPath,
        };

        await runZoned(() async {
          final storage = Storage(
            StorageOptions(authClient: explicitClient, credential: credentials),
          );

          final client = await storage.authClient;
          expect(client, same(explicitClient));

          client.close();
        }, zoneValues: {envSymbol: testEnv});
      });

      test('should create working Storage instance with credentials', () async {
        await runZoned(() async {
          final credentials = Credential.fromServiceAccount(File(credPath!));

          final storage = Storage(StorageOptions(credential: credentials));

          final serviceAccount = await storage.getServiceAccount();

          expect(serviceAccount, isNotNull);
          expect(serviceAccount.emailAddress, isNotEmpty);

          final client = await storage.authClient;
          client.close();
        }, zoneValues: {envSymbol: <String, String>{}});
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
