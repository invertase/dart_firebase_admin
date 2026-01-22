import 'dart:convert';
import 'dart:io';

import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  group(
    'File.getSignedUrl integration tests',
    () {
      late Storage storage;
      late String projectId;
      const bucketName = 'test-bucket';
      const fileName = 'test-file.txt';

      setUp(() {
        final serviceAccountFile = File(credPath!);
        final serviceAccountJson = json.decode(
          serviceAccountFile.readAsStringSync(),
        );
        projectId = serviceAccountJson['project_id'] as String;

        final credentials = Credentials(
          clientEmail: serviceAccountJson['client_email'] as String,
          privateKey: serviceAccountJson['private_key'] as String,
        );

        storage = Storage(
          StorageOptions(credentials: credentials, projectId: projectId),
        );
      });

      tearDown(() async {
        final client = await storage.authClient;
        client.close();
      });

      test('should generate v2 signed URL for file GET', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            version: SignedUrlVersion.v2,
          ),
        );

        expect(url, isNotEmpty);
        expect(url, contains('GoogleAccessId='));
        expect(url, contains('Expires='));
        expect(url, contains('Signature='));
        expect(url, contains(bucketName));
        expect(url, contains(fileName));
      });

      test('should generate v4 signed URL for file GET', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            version: SignedUrlVersion.v4,
          ),
        );

        expect(url, isNotEmpty);
        expect(url, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));
        expect(url, contains('X-Goog-Credential='));
        expect(url, contains('X-Goog-Date='));
        expect(url, contains('X-Goog-Expires='));
        expect(url, contains('X-Goog-SignedHeaders='));
        expect(url, contains('X-Goog-Signature='));
        expect(url, contains(bucketName));
        expect(url, contains(fileName));
      });

      test(
        'should generate signed URL for file PUT with contentType',
        () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          final expires = DateTime.now().add(const Duration(minutes: 30));

          final url = await file.getSignedUrl(
            GetFileSignedUrlOptions(
              action: 'write',
              expires: expires,
              version: SignedUrlVersion.v4,
              contentType: 'text/plain',
            ),
          );

          expect(url, isNotEmpty);
          expect(url, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));
        },
      );

      test('should generate signed URL with query parameters', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            queryParams: {
              'response-content-disposition':
                  'attachment; filename="download.txt"',
            },
          ),
        );

        expect(url, contains('response-content-disposition='));
      });

      test('should generate virtual-hosted-style URL for file', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            version: SignedUrlVersion.v4,
            virtualHostedStyle: true,
          ),
        );

        expect(url, contains('$bucketName.storage.googleapis.com'));
      });

      test('should generate signed URL with custom cname for file', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            cname: 'https://cdn.example.com',
          ),
        );

        expect(url, startsWith('https://cdn.example.com'));
      });

      test('should generate signed URL for file DELETE', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await file.getSignedUrl(
          GetFileSignedUrlOptions(action: 'delete', expires: expires),
        );

        expect(url, isNotEmpty);
        expect(url, contains(bucketName));
        expect(url, contains(fileName));
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
