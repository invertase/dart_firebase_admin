import 'dart:convert';
import 'dart:io';

import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  group(
    'Bucket.getSignedUrl integration tests',
    () {
      late Storage storage;
      late String projectId;
      const bucketName = 'test-bucket';

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

      test('should generate v2 signed URL for bucket', () async {
        final bucket = storage.bucket(bucketName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
            expires: expires,
            version: SignedUrlVersion.v2,
          ),
        );

        expect(url, isNotEmpty);
        expect(url, contains('GoogleAccessId='));
        expect(url, contains('Expires='));
        expect(url, contains('Signature='));
        expect(url, contains(bucketName));
      });

      test('should generate v4 signed URL for bucket', () async {
        final bucket = storage.bucket(bucketName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
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
      });

      test('should generate signed URL with custom cname', () async {
        final bucket = storage.bucket(bucketName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
            expires: expires,
            cname: 'https://cdn.example.com',
          ),
        );

        expect(url, startsWith('https://cdn.example.com'));
      });

      test('should generate virtual-hosted-style URL', () async {
        final bucket = storage.bucket(bucketName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final url = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
            expires: expires,
            version: SignedUrlVersion.v4,
            virtualHostedStyle: true,
          ),
        );

        expect(url, contains('$bucketName.storage.googleapis.com'));
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
