import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_auth_utils/googleapis_auth_utils.dart';
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  group(
    'Storage credential integration tests',
    () {
      test('should create Storage with explicit credentials', () async {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        final projectId = serviceAccountJson['project_id'] as String;

        final credentials = Credentials(
          clientEmail: serviceAccountJson['client_email'] as String,
          privateKey: serviceAccountJson['private_key'] as String,
        );

        final storage = Storage(
          StorageOptions(credentials: credentials, projectId: projectId),
        );

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        final pid = await client.getProjectId();
        expect(pid, isNotEmpty);

        client.close();
      });

      test('should create Storage with keyFilename', () async {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        final projectId = serviceAccountJson['project_id'] as String;

        final storage = Storage(
          StorageOptions(keyFilename: credPath, projectId: projectId),
        );

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        final pid = await client.getProjectId();
        expect(pid, isNotEmpty);

        client.close();
      });

      test('should prioritize credentials over keyFilename', () async {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        final projectId = serviceAccountJson['project_id'] as String;

        final credentials = Credentials(
          clientEmail: serviceAccountJson['client_email'] as String,
          privateKey: serviceAccountJson['private_key'] as String,
        );

        final storage = Storage(
          StorageOptions(
            credentials: credentials,
            keyFilename: credPath,
            projectId: projectId,
          ),
        );

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        final pid = await client.getProjectId();
        expect(pid, isNotEmpty);

        client.close();
      });

      test('should fall back to ADC when no credentials provided', () async {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        final projectId = serviceAccountJson['project_id'] as String;

        final storage = Storage(StorageOptions(projectId: projectId));

        final client = await storage.authClient;
        expect(client, isA<auth.AuthClient>());

        final pid = await client.getProjectId();
        expect(pid, isNotEmpty);

        client.close();
      });

      test('should respect explicit authClient over credentials', () async {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        final projectId = serviceAccountJson['project_id'] as String;

        final explicitClient = await auth
            .clientViaApplicationDefaultCredentials(
              scopes: ['https://www.googleapis.com/auth/cloud-platform'],
            );

        final credentials = Credentials(
          clientEmail: serviceAccountJson['client_email'] as String,
          privateKey: serviceAccountJson['private_key'] as String,
        );

        final storage = Storage(
          StorageOptions(
            authClient: explicitClient,
            credentials: credentials,
            keyFilename: credPath,
            projectId: projectId,
          ),
        );

        final client = await storage.authClient;
        expect(client, same(explicitClient));

        final pid = await client.getProjectId();
        expect(pid, isNotEmpty);

        client.close();
      });

      test('should create working Storage instance with credentials', () async {
        await runZoned(() async {
          final serviceAccountFile = File(credPath!);
          final serviceAccountJson = json.decode(
            serviceAccountFile.readAsStringSync(),
          );
          final projectId = serviceAccountJson['project_id'] as String;

          final credentials = Credentials(
            clientEmail: serviceAccountJson['client_email'] as String,
            privateKey: serviceAccountJson['private_key'] as String,
          );

          final storage = Storage(
            StorageOptions(credentials: credentials, projectId: projectId),
          );

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
