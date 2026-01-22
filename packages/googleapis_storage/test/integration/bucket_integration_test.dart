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
      const bucketName = 'dart-firebase-admin.firebasestorage.app';

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

  group(
    'Bucket.getSignedUrl E2E tests',
    () {
      late Storage storage;
      late String projectId;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      const testFile1 = 'e2e-bucket-list-test-1.txt';
      const testFile2 = 'e2e-bucket-list-test-2.txt';

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
        // Clean up: delete test files
        try {
          final bucket = storage.bucket(bucketName);
          await bucket.file(testFile1).delete();
          await bucket.file(testFile2).delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        final client = await storage.authClient;
        client.close();
      });

      test('should list bucket objects via signed URL', () async {
        final bucket = storage.bucket(bucketName);

        // Step 1: Upload test files
        await bucket.file(testFile1).save(utf8.encode('test content 1'));
        await bucket.file(testFile2).save(utf8.encode('test content 2'));

        // Brief delay to handle eventual consistency
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Step 2: Generate a signed URL for listing
        final expires = DateTime.now().add(const Duration(minutes: 5));
        final signedUrl = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
            expires: expires,
            version: SignedUrlVersion.v4,
          ),
        );

        expect(signedUrl, isNotEmpty);
        expect(signedUrl, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));

        // Step 3: Use the signed URL to list objects via HTTP
        final httpClient = HttpClient();
        try {
          final request = await httpClient.getUrl(Uri.parse(signedUrl));
          final response = await request.close();

          expect(response.statusCode, 200);

          // Step 4: Verify response is XML and contains our test files
          final responseBody = await response.transform(utf8.decoder).join();
          expect(responseBody, contains('<?xml'));
          expect(responseBody, contains(testFile1));
          expect(responseBody, contains(testFile2));
        } finally {
          httpClient.close();
        }
      });

      test('should fail to list after signed URL expires', () async {
        final bucket = storage.bucket(bucketName);

        // Generate a signed URL that expires in 1 second
        final expires = DateTime.now().add(const Duration(seconds: 1));
        final signedUrl = await bucket.getSignedUrl(
          GetBucketSignedUrlOptions(
            action: 'list',
            expires: expires,
            version: SignedUrlVersion.v4,
          ),
        );

        // Wait for the URL to expire
        await Future<void>.delayed(const Duration(seconds: 2));

        // Try to access the expired URL
        final httpClient = HttpClient();
        try {
          final request = await httpClient.getUrl(Uri.parse(signedUrl));
          final response = await request.close();

          // Should get 400 Bad Request or 403 Forbidden for expired/invalid signature
          expect(response.statusCode, anyOf([400, 403]));
          await response.drain();
        } finally {
          httpClient.close();
        }
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
