import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_cloud_storage/google_cloud_storage.dart';
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
        final credentials = Credential.fromServiceAccount(File(credPath!));

        runZoned(() {
          storage = Storage(StorageOptions(credential: credentials));
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
        final credentials = Credential.fromServiceAccount(File(credPath!));

        runZoned(() {
          storage = Storage(StorageOptions(credential: credentials));
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

          // Wait for file to be available
          final exists = await waitForFileExists(file);
          expect(exists, isTrue, reason: 'File should exist after upload');

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

          // Wait for file to be available
          final fileExists = await waitForFileExists(file);
          expect(fileExists, isTrue, reason: 'File should exist after upload');

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

        // Wait for file to be available
        expect(await waitForFileExists(file), isTrue);

        // Generate a signed URL that expires in 1 second
        final expires = DateTime.now().add(const Duration(seconds: 1));
        final signedUrl = await file.getSignedUrl(
          GetFileSignedUrlOptions(
            action: 'read',
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

  group(
    'File operations integration tests',
    () {
      late Storage storage;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';
      late Bucket bucket;
      const testContent = 'Hello from Dart integration tests!';

      setUp(() {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        runZoned(() {
          storage = Storage(StorageOptions(credential: credentials));
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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

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

      test('should moveFileAtomic a file', () async {
        const sourceFileName = 'integration-test-moveatomic-source.txt';
        const destFileName = 'integration-test-moveatomic-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

          // Move file atomically
          final movedFile = await sourceFile.moveFileAtomic(
            PathMoveFileAtomicDestination(destFileName),
          );

          // Verify returned file is correct
          expect(movedFile.name, destFileName);
          expect(movedFile.bucket.id, bucket.id);

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

      test('should moveFileAtomic to nested path', () async {
        const sourceFileName = 'integration-test-moveatomic-nested-source.txt';
        const destFileName = 'nested/path/integration-test-moveatomic-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

          // Move file atomically to nested path
          final movedFile = await sourceFile.moveFileAtomic(
            PathMoveFileAtomicDestination(destFileName),
          );

          // Verify returned file is correct
          expect(movedFile.name, destFileName);
          expect(movedFile.bucket.id, bucket.id);

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

      test('should moveFileAtomic with File destination object', () async {
        const sourceFileName = 'integration-test-moveatomic-file-source.txt';
        const destFileName = 'integration-test-moveatomic-file-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

          // Move file atomically using File destination object
          final movedFile = await sourceFile.moveFileAtomic(
            FileMoveFileAtomicDestination(destFile),
          );

          // Verify returned file is the same File object
          expect(movedFile, destFile);
          expect(movedFile.name, destFileName);
          expect(movedFile.bucket.id, bucket.id);

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

      test(
        'should moveFileAtomic with gs:// URI destination (same bucket)',
        () async {
          const sourceFileName = 'integration-test-moveatomic-gs-source.txt';
          const destFileName = 'integration-test-moveatomic-gs-dest.txt';
          final sourceFile = bucket.file(sourceFileName);
          final destFile = bucket.file(destFileName);
          final gsUri = 'gs://${bucket.id}/$destFileName';

          try {
            // Upload source file
            await sourceFile.save(testContent);

            // Wait for file to be available
            expect(await waitForFileExists(sourceFile), isTrue);

            // Move file atomically using gs:// URI
            final movedFile = await sourceFile.moveFileAtomic(
              PathMoveFileAtomicDestination(gsUri),
            );

            // Verify returned file is correct
            expect(movedFile.name, destFileName);
            expect(movedFile.bucket.id, bucket.id);

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
        },
      );

      test('should moveFileAtomic with precondition options', () async {
        const sourceFileName =
            'integration-test-moveatomic-precondition-source.txt';
        const destFileName =
            'integration-test-moveatomic-precondition-dest.txt';
        final sourceFile = bucket.file(sourceFileName);
        final destFile = bucket.file(destFileName);

        try {
          // Upload source file
          await sourceFile.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(sourceFile), isTrue);

          // Add a delay to ensure file is fully committed and metadata is consistent
          await Future<void>.delayed(const Duration(seconds: 2));

          // Verify destination file doesn't exist (it shouldn't for this test)
          final destExists = await destFile.exists();
          expect(
            destExists,
            isFalse,
            reason: 'Destination file should not exist',
          );

          // Move file atomically with ifGenerationMatch precondition
          // For a destination that doesn't exist, use ifGenerationMatch: 0
          // This prevents overwriting an existing file that might have been created
          // between checking and moving
          final movedFile = await sourceFile.moveFileAtomic(
            PathMoveFileAtomicDestination(destFileName),
            options: MoveOptions(
              preconditionOpts: PreconditionOptions(
                ifGenerationMatch: 0, // 0 means destination must not exist
              ),
            ),
          );

          // Verify returned file is correct
          expect(movedFile.name, destFileName);
          expect(movedFile.bucket.id, bucket.id);

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

          // Wait for file to be available
          expect(await waitForFileExists(oldFile), isTrue);

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

        // Wait for file to be available
        expect(await waitForFileExists(file), isTrue);

        // Verify it exists
        var exists = await file.exists();
        expect(exists, true);

        // Delete file
        await file.delete();

        // Verify it's gone
        exists = await file.exists();
        expect(exists, false);
      });

      test('should restore a soft-deleted file', () async {
        const fileName = 'integration-test-restore.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

          // Get metadata to retrieve generation
          final metadata = await file.getMetadata();
          final generation = metadata.generation != null
              ? int.parse(metadata.generation!)
              : null;

          expect(
            generation,
            isNotNull,
            reason: 'File should have a generation',
          );

          // Delete file (soft delete)
          await file.delete();

          // Verify file is deleted
          final existsAfterDelete = await file.exists();
          expect(existsAfterDelete, isFalse);

          // Restore the file using the generation
          final restoredFile = await file.restore(
            RestoreFileOptions(generation: generation!),
          );

          // Verify restored file is the same instance
          expect(restoredFile, same(file));

          // Wait a bit for restore to propagate
          await Future<void>.delayed(const Duration(seconds: 2));

          // Verify file exists again
          final existsAfterRestore = await file.exists();
          expect(existsAfterRestore, isTrue);

          // Verify content is restored
          final restoredContent = await file.download();
          final restoredText = utf8.decode(restoredContent);
          expect(restoredText, testContent);
        } finally {
          await file.delete().catchError((_) {});
        }
      });

      test('should check if file exists', () async {
        const existingFileName = 'integration-test-exists.txt';
        const nonExistingFileName = 'integration-test-does-not-exist.txt';
        final existingFile = bucket.file(existingFileName);
        final nonExistingFile = bucket.file(nonExistingFileName);

        try {
          // Upload a file
          await existingFile.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(existingFile), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

      test('should check if file is public', () async {
        const fileName = 'integration-test-is-public.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

          // Initially file should be private
          final isPublicBefore = await file.isPublic();
          expect(isPublicBefore, isFalse);

          // Make file public
          await file.makePublic();

          // Now file should be public
          final isPublicAfter = await file.isPublic();
          expect(isPublicAfter, isTrue);

          // Make file private again
          await file.makePrivate();

          // File should be private again
          final isPublicAfterPrivate = await file.isPublic();
          expect(isPublicAfterPrivate, isFalse);
        } finally {
          await file.acl.delete(entity: 'allUsers').catchError((_) {});
          await file.delete().catchError((_) {});
        }
      });

      test('should get expiration date when retention policy exists', () async {
        const fileName = 'integration-test-expiration-date.txt';
        final file = bucket.file(fileName);

        try {
          // Upload file first
          await file.save(testContent);

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

          // Try to get expiration date
          // Note: This will only work if the bucket has a retention policy
          // If no retention policy exists, it will throw an exception
          try {
            final expirationDate = await file.getExpirationDate();
            expect(expirationDate, isA<DateTime>());
            expect(expirationDate.isAfter(DateTime.now()), isTrue);
          } on Exception catch (e) {
            // If bucket doesn't have retention policy, expect this error
            expect(
              e.toString(),
              contains('An expiration time is not available'),
            );
            // This is expected behavior - skip test if bucket has no retention policy
            return;
          }
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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

          // Wait for file to be available
          expect(await waitForFileExists(file), isTrue);

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

  group(
    'File.generateSignedPostPolicyV2 integration tests',
    () {
      late Storage storage;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';

      setUp(() {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        runZoned(() {
          storage = Storage(StorageOptions(credential: credentials));
        }, zoneValues: {envSymbol: testEnv});
      });

      tearDown(() async {
        final client = await storage.authClient;
        client.close();
      });

      test('should create V2 signed policy with correct structure', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-policy-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            contentLengthRange: const ContentLengthRange(min: 0, max: 1024),
          ),
        );

        // Verify policy structure
        expect(policy.string, isNotEmpty);
        expect(policy.base64, isNotEmpty);
        expect(policy.signature, isNotEmpty);

        // Verify policy JSON contains expected fields
        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        expect(policyJson['expiration'], isNotEmpty);
        expect(policyJson['conditions'], isA<List>());

        // Verify conditions include key and bucket
        final conditions = policyJson['conditions'] as List;
        expect(
          conditions.any((c) => c is List && c[0] == 'eq' && c[1] == r'$key'),
          isTrue,
        );
        expect(
          conditions.any((c) => c is Map && c['bucket'] == bucketName),
          isTrue,
        );
      });

      test('should include equals conditions in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-equals-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            equals: [
              [r'$Content-Type', 'image/jpeg'],
            ],
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) =>
                c is List &&
                c[0] == 'eq' &&
                c[1] == r'$Content-Type' &&
                c[2] == 'image/jpeg',
          ),
          isTrue,
        );
      });

      test('should include startsWith conditions in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-startswith-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            startsWith: [
              [r'$key', 'uploads/'],
            ],
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) =>
                c is List &&
                c[0] == 'starts-with' &&
                c[1] == r'$key' &&
                c[2] == 'uploads/',
          ),
          isTrue,
        );
      });

      test('should include ACL in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-acl-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            acl: 'public-read',
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any((c) => c is Map && c['acl'] == 'public-read'),
          isTrue,
        );
      });

      test('should include success redirect in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-redirect-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));
        const redirectUrl = 'https://example.com/success';

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            successRedirect: redirectUrl,
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) => c is Map && c['success_action_redirect'] == redirectUrl,
          ),
          isTrue,
        );
      });

      test('should include success status in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-status-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));
        const successStatus = '201';

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            successStatus: successStatus,
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) => c is Map && c['success_action_status'] == successStatus,
          ),
          isTrue,
        );
      });

      test('should include content length range in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-content-length-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(
            expires: expires,
            contentLengthRange: const ContentLengthRange(min: 0, max: 1024),
          ),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) =>
                c is List &&
                c[0] == 'content-length-range' &&
                c[1] == 0 &&
                c[2] == 1024,
          ),
          isTrue,
        );
      });

      test('should add key equality condition with file name', () async {
        final bucket = storage.bucket(bucketName);
        const testFileName = 'v2-key-condition-test.txt';
        final file = bucket.file(testFileName);
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(expires: expires),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        expect(
          conditions.any(
            (c) =>
                c is List &&
                c[0] == 'eq' &&
                c[1] == r'$key' &&
                c[2] == testFileName,
          ),
          isTrue,
        );
      });

      test('should format expiration as ISO string', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v2-expiration-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV2(
          GenerateSignedPostPolicyV2Options(expires: expires),
        );

        final policyJson = jsonDecode(policy.string) as Map<String, dynamic>;
        final expiration = policyJson['expiration'] as String;

        // Should be in ISO format like 2024-01-15T10:30:00Z
        expect(
          expiration,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$')),
        );
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );

  group(
    'File.generateSignedPostPolicyV4 integration tests',
    () {
      late Storage storage;
      const bucketName = 'dart-firebase-admin.firebasestorage.app';

      setUp(() {
        final credentials = Credential.fromServiceAccount(File(credPath!));

        runZoned(() {
          storage = Storage(StorageOptions(credential: credentials));
        }, zoneValues: {envSymbol: testEnv});
      });

      tearDown(() async {
        final client = await storage.authClient;
        client.close();
      });

      test('should create V4 signed policy with correct structure', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-policy-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(expires: expires),
        );

        // Verify policy output structure
        expect(policy.url, isNotEmpty);
        expect(policy.fields, isNotEmpty);

        // Verify URL format
        expect(policy.url, contains('storage.googleapis.com'));
        expect(policy.url, contains(bucketName));

        // Verify required fields
        expect(policy.fields['key'], file.name);
        expect(policy.fields['x-goog-algorithm'], 'GOOG4-RSA-SHA256');
        expect(policy.fields['x-goog-credential'], isNotEmpty);
        expect(policy.fields['x-goog-date'], isNotEmpty);
        expect(policy.fields['policy'], isNotEmpty);
        expect(policy.fields['x-goog-signature'], isNotEmpty);
      });

      test('should include custom fields in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-fields-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            fields: {'x-goog-meta-test': 'value'},
          ),
        );

        expect(policy.fields['x-goog-meta-test'], 'value');
      });

      test('should exclude x-ignore- prefixed fields from signature', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-ignore-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            fields: {
              'x-goog-meta-included': 'yes',
              'x-ignore-not-signed': 'ignored',
            },
          ),
        );

        // Both fields should be in output
        expect(policy.fields['x-goog-meta-included'], 'yes');
        expect(policy.fields['x-ignore-not-signed'], 'ignored');

        // Decode policy to verify x-ignore- is not in conditions
        final policyJson =
            jsonDecode(utf8.decode(base64Decode(policy.fields['policy']!)))
                as Map<String, dynamic>;
        final conditions = policyJson['conditions'] as List;

        // x-goog-meta-included should be in conditions
        expect(
          conditions.any((c) => c is Map && c['x-goog-meta-included'] == 'yes'),
          isTrue,
        );

        // x-ignore-not-signed should NOT be in conditions
        expect(
          conditions.any(
            (c) => c is Map && c.containsKey('x-ignore-not-signed'),
          ),
          isFalse,
        );
      });

      test('should use virtualHostedStyle URL when specified', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-virtual-host-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            virtualHostedStyle: true,
          ),
        );

        expect(policy.url, contains('$bucketName.storage.googleapis.com'));
      });

      test('should use bucketBoundHostname when specified', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-cname-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            bucketBoundHostname: 'https://cdn.example.com',
          ),
        );

        expect(policy.url, startsWith('https://cdn.example.com'));
      });

      test('should encode special characters (unicode) in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-unicode-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            fields: {'x-goog-meta-foo': 'bår'},
          ),
        );

        // Field should be in output as-is
        expect(policy.fields['x-goog-meta-foo'], 'bår');

        // Policy should have unicode escaped
        final decodedPolicy = utf8.decode(
          base64Decode(policy.fields['policy']!),
        );
        expect(decodedPolicy, contains(r'\u00e5'));
      });

      test('should accept additional conditions', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-conditions-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(
            expires: expires,
            conditions: [
              ['starts-with', r'$key', 'uploads/'],
            ],
          ),
        );

        final decodedPolicy =
            jsonDecode(utf8.decode(base64Decode(policy.fields['policy']!)))
                as Map<String, dynamic>;
        final conditions = decodedPolicy['conditions'] as List;

        expect(
          conditions.any(
            (c) =>
                c is List &&
                c[0] == 'starts-with' &&
                c[1] == r'$key' &&
                c[2] == 'uploads/',
          ),
          isTrue,
        );
      });

      test('should include bucket condition in policy', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-bucket-condition-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(expires: expires),
        );

        final decodedPolicy =
            jsonDecode(utf8.decode(base64Decode(policy.fields['policy']!)))
                as Map<String, dynamic>;
        final conditions = decodedPolicy['conditions'] as List;

        expect(
          conditions.any((c) => c is Map && c['bucket'] == bucketName),
          isTrue,
        );
      });

      test('should include x-goog-credential in correct format', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-credential-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(expires: expires),
        );

        final credential = policy.fields['x-goog-credential']!;

        // Should be in format: email/YYYYMMDD/auto/storage/goog4_request
        expect(
          credential,
          matches(RegExp(r'.+/\d{8}/auto/storage/goog4_request$')),
        );
      });

      test('should include x-goog-date in correct format', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-date-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(expires: expires),
        );

        final googDate = policy.fields['x-goog-date']!;

        // Should be in format: YYYYMMDDTHHmmssZ
        expect(googDate, matches(RegExp(r'^\d{8}T\d{6}Z$')));
      });

      test('should have signature in hex format', () async {
        final bucket = storage.bucket(bucketName);
        final file = bucket.file('v4-signature-test.txt');
        final expires = DateTime.now().add(const Duration(hours: 1));

        final policy = await file.generateSignedPostPolicyV4(
          GenerateSignedPostPolicyV4Options(expires: expires),
        );

        final signature = policy.fields['x-goog-signature']!;

        // Should be hex string (only 0-9 and a-f characters)
        expect(signature, matches(RegExp(r'^[0-9a-f]+$')));
      });
    },
    skip: !hasGoogleEnv
        ? 'GOOGLE_APPLICATION_CREDENTIALS environment variable not set'
        : null,
  );
}
