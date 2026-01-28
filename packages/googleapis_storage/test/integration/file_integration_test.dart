import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      const fileName = 'test-file.txt';

      setUp(() {
        final credentials = GoogleCredential.fromServiceAccount(
          File(credPath!),
        );

        runZoned(() {
          storage = Storage(StorageOptions(credentials: credentials));
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
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      const fileName = 'e2e-test-file.txt';
      const fileContent = 'Hello from signed URL E2E test!';

      setUp(() {
        final credentials = GoogleCredential.fromServiceAccount(
          File(credPath!),
        );

        runZoned(() {
          storage = Storage(StorageOptions(credentials: credentials));
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
          await Future<void>.delayed(const Duration(seconds: 5));

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

  group(
    'File operations integration tests',
    () {
      late Storage storage;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      late Bucket bucket;
      const testContent = 'Hello from Dart integration tests!';

      setUp(() {
        final credentials = GoogleCredential.fromServiceAccount(
          File(credPath!),
        );

        runZoned(() {
          storage = Storage(StorageOptions(credentials: credentials));
        }, zoneValues: {envSymbol: testEnv});

        bucket = storage.bucket(bucketName);
      });

      tearDown(() async {
        final client = await storage.authClient;
        client.close();
      });

      test('should save and download file with String data', () async {
        const fileName = 'integration-test-string.txt';
        final file = bucket.file(fileName);

        try {
          // Save file with String data (gzip enabled)
          await file.save(testContent, SaveOptions(gzip: true));

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Download and verify
          final downloadedBytes = await file.download();
          final downloadedContent = utf8.decode(downloadedBytes);

          expect(downloadedContent, testContent);
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should save and download file with List<int> data', () async {
        const fileName = 'integration-test-list.txt';
        final file = bucket.file(fileName);
        final data = [72, 101, 108, 108, 111]; // "Hello"

        try {
          // Save file with List<int> data
          await file.save(data);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Download and verify
          final downloadedBytes = await file.download();

          expect(downloadedBytes, data);
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should save and download file with Uint8List data', () async {
        const fileName = 'integration-test-uint8list.txt';
        final file = bucket.file(fileName);
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);

        try {
          // Save file with Uint8List data
          await file.save(data);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Download and verify
          final downloadedBytes = await file.download();

          expect(downloadedBytes, data);
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should save and download file with Stream data', () async {
        const fileName = 'integration-test-stream.txt';
        final file = bucket.file(fileName);
        final dataStream = Stream<List<int>>.fromIterable([
          [72, 101, 108, 108, 111], // "Hello"
          [32, 87, 111, 114, 108, 100], // " World"
        ]);

        try {
          // Save file with Stream data
          await file.save(dataStream);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Download and verify
          final downloadedBytes = await file.download();
          final downloadedContent = utf8.decode(downloadedBytes);

          expect(downloadedContent, 'Hello World');
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should get metadata for a file', () async {
        const fileName = 'integration-test-metadata.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Get metadata
          final metadata = await file.getMetadata();

          expect(metadata.name, fileName);
          expect(metadata.bucket, bucketName);
          expect(metadata.size, isNotNull);
          expect(metadata.contentType, isNotNull);
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should set metadata for a file', () async {
        const fileName = 'integration-test-set-metadata.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Set custom metadata
          final newMetadata = await file.setMetadata(
            FileMetadata(
              metadata: {
                'customKey': 'customValue',
                'description': 'Test file description',
              },
            ),
          );

          expect(newMetadata.metadata?['customKey'], 'customValue');
          expect(newMetadata.metadata?['description'], 'Test file description');

          // Verify metadata persisted
          final retrievedMetadata = await file.getMetadata();
          expect(retrievedMetadata.metadata?['customKey'], 'customValue');
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should copy a file', () async {
        const sourceFileName = 'integration-test-copy-source.txt';
        const destFileName = 'integration-test-copy-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Copy file
          await sourceFile.copy(CopyDestination.file(destFile));

          // Verify destination exists and has same content
          final downloadedBytes = await destFile.download();
          final downloadedContent = utf8.decode(downloadedBytes);

          expect(downloadedContent, testContent);
        } finally {
          await sourceFile.delete().catchError((_) {});
          await destFile.delete().catchError((_) {});
        }
      });

      test('should move a file', () async {
        const sourceFileName = 'integration-test-move-source.txt';
        const destFileName = 'integration-test-move-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Move file
          await sourceFile.move(CopyDestination.file(destFile));

          // Verify destination exists and source doesn't
          final destDownloaded = await destFile.download();
          final destContent = utf8.decode(destDownloaded);
          expect(destContent, testContent);

          final sourceExists = await sourceFile.exists();
          expect(sourceExists, false);
        } finally {
          await sourceFile.delete().catchError((_) {});
          await destFile.delete().catchError((_) {});
        }
      });

      test('should rename a file', () async {
        const oldFileName = 'integration-test-old-name.txt';
        const newFileName = 'integration-test-new-name.txt';
        final oldFile = bucket.file(oldFileName);
        final newFile = bucket.file(newFileName);

        try {
          // Upload file with old name
          await oldFile.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Rename file
          await oldFile.rename(CopyDestination.path(newFileName));

          // Verify new name exists and old doesn't
          final newFileDownloaded = await newFile.download();
          final newFileContent = utf8.decode(newFileDownloaded);
          expect(newFileContent, testContent);

          final oldFileExists = await oldFile.exists();
          expect(oldFileExists, false);
        } finally {
          await oldFile.delete().catchError((_) {});
          await newFile.delete().catchError((_) {});
        }
      });

      test('should delete a file', () async {
        const fileName = 'integration-test-delete.txt';
        final file = bucket.file(fileName);

        // Upload file
        await file.save(testContent);

        // Brief delay to handle eventual consistency
        await Future<void>.delayed(const Duration(seconds: 5));

        // Verify it exists
        var exists = await file.exists();
        expect(exists, true);

        // Delete file
        await file.delete();

        // Verify it's gone
        exists = await file.exists();
        expect(exists, false);
      });

      test('should check if file exists', () async {
        const existingFileName = 'integration-test-exists.txt';
        const nonExistingFileName = 'integration-test-does-not-exist.txt';
        final existingFile = bucket.file(existingFileName);
        final nonExistingFile = bucket.file(nonExistingFileName);

        try {
          // Upload a file
          await existingFile.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Check existing file
          final existsTrue = await existingFile.exists();
          expect(existsTrue, true);

          // Check non-existing file
          final existsFalse = await nonExistingFile.exists();
          expect(existsFalse, false);
        } finally {
          await existingFile.delete().catchError((_) {});
        }
      });

      test('should make a file public', () async {
        const fileName = 'integration-test-make-public.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Make file public
          await file.makePublic();

          // Verify ACL has allUsers with READER role
          final aclEntry = await file.acl.get(entity: 'allUsers');
          expect(aclEntry.entity, 'allUsers');
          expect(aclEntry.role, 'READER');
        } finally {
          await file.acl.delete(entity: 'allUsers').catchError((_) {});
          await file.delete().catchError((_) {});
        }
      });

      test('should make a file private', () async {
        const fileName = 'integration-test-make-private.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // First make public, then private
          await file.makePublic();
          await file.makePrivate();

          // Verify allUsers ACL no longer exists (throws 404)
          expect(
            () => file.acl.get(entity: 'allUsers'),
            throwsA(isA<ApiError>()),
          );
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should return correct public URL format', () async {
        const fileName = 'integration-test-public-url.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Get public URL
          final url = file.publicUrl();

          // Verify URL format
          expect(url, contains(bucketName));
          expect(url, contains(fileName));
          expect(url, contains('storage.googleapis.com'));

          // Make file public and verify URL is accessible
          await file.makePublic();

          final httpClient = HttpClient();
          try {
            final request = await httpClient.getUrl(Uri.parse(url));
            final response = await request.close();

            expect(response.statusCode, 200);

            final body = await response.transform(utf8.decoder).join();
            expect(body, testContent);
          } finally {
            httpClient.close();
          }
        } finally {
          await file.acl.delete(entity: 'allUsers').catchError((_) {});
          await file.delete().catchError((_) {});
        }
      });

      test('should get file and return instance with metadata', () async {
        const fileName = 'integration-test-get.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Brief delay to handle eventual consistency
          await Future<void>.delayed(const Duration(seconds: 5));

          // Get file - should fetch metadata and return file instance
          final returnedFile = await file.get();

          // Verify it returns the same file instance
          expect(returnedFile, same(file));

          // Verify metadata was populated
          expect(file.metadata, isNotNull);
          expect(file.metadata.name, fileName);
          expect(file.metadata.bucket, bucketName);
          expect(file.metadata.size, isNotNull);
          expect(int.parse(file.metadata.size!), greaterThan(0));
        } finally {
          await file.delete().catchError((_) {});
        }
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
