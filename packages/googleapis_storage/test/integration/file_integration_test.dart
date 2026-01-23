import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  final testEnv = <String, String?>{'GOOGLE_APPLICATION_CREDENTIALS': credPath};

  group(
    'File.getSignedUrl integration tests',
    () {
      late Storage storage;
      late String projectId;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
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

        runZoned(() {
          storage = Storage(
            StorageOptions(credentials: credentials, projectId: projectId),
          );
        }, zoneValues: {envSymbol: testEnv});
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

  group(
    'File.getSignedUrl E2E tests',
    () {
      late Storage storage;
      late String projectId;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      const fileName = 'e2e-test-file.txt';
      const fileContent = 'Hello from signed URL E2E test!';

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

        runZoned(() {
          storage = Storage(
            StorageOptions(credentials: credentials, projectId: projectId),
          );
        }, zoneValues: {envSymbol: testEnv});
      });

      tearDown(() async {
        // Clean up: delete the test file
        try {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);
          await file.delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        final client = await storage.authClient;
        client.close();
      });

      test(
        'should upload file, generate signed URL, and download via URL',
        () async {
          final bucket = storage.bucket(bucketName);
          final file = bucket.file(fileName);

          // Step 1: Upload the file
          await file.save(utf8.encode(fileContent));

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(milliseconds: 500));

          // Step 2: Generate a signed URL for reading
          final expires = DateTime.now().add(const Duration(minutes: 5));
          final signedUrl = await file.getSignedUrl(
            GetFileSignedUrlOptions(
              action: 'read',
              expires: expires,
              version: SignedUrlVersion.v4,
            ),
          );

          expect(signedUrl, isNotEmpty);
          expect(signedUrl, contains('X-Goog-Algorithm=GOOG4-RSA-SHA256'));

          // Step 3: Use the signed URL to download the file via HTTP
          final httpClient = HttpClient();
          try {
            final request = await httpClient.getUrl(Uri.parse(signedUrl));
            final response = await request.close();

            expect(response.statusCode, 200);

            // Step 4: Verify the downloaded content matches
            final downloadedBytes = await response.fold<List<int>>(
              [],
              (previous, element) => previous..addAll(element),
            );
            final downloadedContent = utf8.decode(downloadedBytes);

            expect(downloadedContent, fileContent);
          } finally {
            httpClient.close();
          }
        },
      );

      test('should generate signed upload URL and upload via URL', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);
        const uploadContent = 'Uploaded via signed URL!';

        // Step 1: Generate a signed URL for writing
        final expires = DateTime.now().add(const Duration(minutes: 5));
        final signedUrl = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'write',
            expires: expires,
            version: SignedUrlVersion.v4,
            contentType: 'text/plain',
          ),
        );

        expect(signedUrl, isNotEmpty);

        // Step 2: Upload file using the signed URL
        final httpClient = HttpClient();
        try {
          final request = await httpClient.putUrl(Uri.parse(signedUrl));
          request.headers.set('Content-Type', 'text/plain');
          request.add(utf8.encode(uploadContent));
          final response = await request.close();

          expect(response.statusCode, 200);
          await response.drain();

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(milliseconds: 500));

          // Step 3: Verify the file was uploaded by downloading it normally
          final downloadedBytes = await file.download();
          final downloadedContent = utf8.decode(downloadedBytes);

          expect(downloadedContent, uploadContent);
        } finally {
          httpClient.close();
        }
      });

      test('should fail to access file after signed URL expires', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file(fileName);

        // Upload the file first
        await file.save(utf8.encode(fileContent));

        // Generate a signed URL that expires in 1 second
        final expires = DateTime.now().add(const Duration(seconds: 1));
        final signedUrl = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
            expires: expires,
            version: SignedUrlVersion.v4,
          ),
        );

        // Wait for the URL to expire (also ensures file is available)
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
