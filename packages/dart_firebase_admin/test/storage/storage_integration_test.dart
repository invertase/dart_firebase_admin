import 'dart:typed_data';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis_storage/googleapis_storage.dart' as gcs;
import 'package:test/test.dart';

import '../helpers.dart';

/// Integration tests for Storage wrapper.
///
/// These tests require the Firebase Storage emulator to be running.
/// Start it with: firebase emulators:start --only storage
///
/// Or run tests with: firebase emulators:exec "dart test test/storage/storage_integration_test.dart"
void main() {
  group(
    'Storage Integration Tests',
    () {
      late FirebaseApp app;
      late FirebaseApp appWithBucket;
      const testBucketName = 'dart-firebase-admin.firebasestorage.app';
      gcs.BucketFile? currentFile;

      setUpAll(() {
        // Create app without default bucket
        app = FirebaseApp.initializeApp(
          name: 'storage-integration-test',
          options: const AppOptions(projectId: projectId),
        );

        // Create app with default bucket configured
        appWithBucket = FirebaseApp.initializeApp(
          name: 'storage-integration-test-with-bucket',
          options: const AppOptions(
            projectId: projectId,
            storageBucket: testBucketName,
          ),
        );
      });

      tearDownAll(() async {
        await app.close();
        await appWithBucket.close();
      });

      tearDown(() async {
        // Clean up any test files created during tests
        if (currentFile != null) {
          try {
            await currentFile!.delete();
          } catch (e) {
            // Ignore errors if file doesn't exist
          }
          currentFile = null;
        }
      });

      group('Storage initialization', () {
        test('should initialize properly in emulator mode', () {
          final storage = app.storage();
          expect(storage, isNotNull);
          expect(storage.app, same(app));
        });

        test('should work with app that has default bucket configured', () {
          final storage = appWithBucket.storage();
          expect(storage, isNotNull);
          expect(storage.app, same(appWithBucket));
        });
      });

      group('bucket()', () {
        test(
          'should return a handle to the default bucket and it works',
          () async {
            final storage = appWithBucket.storage();
            final bucket = storage.bucket(null);

            expect(bucket, isA<gcs.Bucket>());
            expect(bucket.name, testBucketName);

            // Verify bucket works by uploading, downloading, and deleting a file
            await verifyBucket(bucket, 'storage().bucket()');
          },
        );

        test(
          'should return a handle to a specified bucket and it works',
          () async {
            final storage = app.storage();
            final bucket = storage.bucket(testBucketName);

            expect(bucket, isA<gcs.Bucket>());
            expect(bucket.name, testBucketName);

            // Verify bucket works by uploading, downloading, and deleting a file
            await verifyBucket(bucket, 'storage().bucket(string)');
          },
        );

        test('should handle multiple buckets', () async {
          final storage = app.storage();
          final bucket1 = storage.bucket(testBucketName);
          final bucket2 = storage.bucket('$testBucketName-2');

          expect(bucket1.name, testBucketName);
          expect(bucket2.name, '$testBucketName-2');
        });
      });

      group('bucket existence', () {
        test(
          'should return a handle for non-existing bucket which can be queried',
          () async {
            final storage = app.storage();
            final bucket = storage.bucket('non-existing-bucket-test');

            expect(bucket, isA<gcs.Bucket>());
            expect(bucket.name, 'non-existing-bucket-test');

            // Query existence - should return false
            final exists = await bucket.exists();
            expect(exists, isFalse);
          },
        );

        test('should return true for existing bucket', () async {
          final storage = app.storage();
          final bucket = storage.bucket(testBucketName);

          // The test bucket should exist in the emulator
          final exists = await bucket.exists();
          expect(exists, isTrue);
        });
      });

      group('file operations', () {
        test('should upload and download a file successfully', () async {
          final storage = app.storage();
          final bucket = storage.bucket(testBucketName);
          final fileName =
              'test-upload-${DateTime.now().millisecondsSinceEpoch}.txt';
          final file = bucket.file(fileName);
          currentFile = file;

          const testContent = 'Hello from Dart Firebase Admin!';
          final contentBytes = Uint8List.fromList(testContent.codeUnits);

          // Upload file
          await file.save(
            contentBytes,
            const gcs.SaveOptions(contentType: 'text/plain', gzip: false),
          );

          // Verify file exists
          final exists = await file.exists();
          expect(exists, isTrue);

          // Download and verify content
          final downloaded = await file.download();
          final downloadedContent = String.fromCharCodes(downloaded);
          expect(downloadedContent, testContent);
        });

        test('should handle file metadata', () async {
          final storage = app.storage();
          final bucket = storage.bucket(testBucketName);
          final fileName =
              'test-metadata-${DateTime.now().millisecondsSinceEpoch}.txt';
          final file = bucket.file(fileName);
          currentFile = file;

          const testContent = 'Test content for metadata';
          final contentBytes = Uint8List.fromList(testContent.codeUnits);

          // Upload with custom metadata
          final uploadMetadata = gcs.FileMetadata()
            ..contentType = 'text/plain'
            ..metadata = {'customKey': 'customValue'};
          await file.save(
            contentBytes,
            gcs.SaveOptions(metadata: uploadMetadata, gzip: false),
          );

          // Get metadata
          final metadata = await file.getMetadata();
          expect(metadata.contentType, 'text/plain');
          expect(metadata.metadata?['customKey'], 'customValue');
          expect(metadata.name, fileName);
          expect(metadata.bucket, testBucketName);
        });

        test('should delete a file successfully', () async {
          final storage = app.storage();
          final bucket = storage.bucket(testBucketName);
          final fileName =
              'test-delete-${DateTime.now().millisecondsSinceEpoch}.txt';
          final file = bucket.file(fileName);

          const testContent = 'To be deleted';
          final contentBytes = Uint8List.fromList(testContent.codeUnits);

          // Upload file
          await file.save(
            contentBytes,
            const gcs.SaveOptions(contentType: 'text/plain', gzip: false),
          );

          // Verify file exists
          var exists = await file.exists();
          expect(exists, isTrue);

          // Delete file
          await file.delete();

          // Verify file no longer exists
          exists = await file.exists();
          expect(exists, isFalse);
        });
      });

      group('emulator mode verification', () {
        test('should be using emulator host', () {
          expect(Environment.isStorageEmulatorEnabled(), isTrue);
          expect(Environment.getStorageEmulatorHost(), isNotNull);
        });

        test('Storage should work correctly in emulator mode', () async {
          final storage = app.storage();
          final bucket = storage.bucket(testBucketName);

          // Simple round-trip test
          final fileName =
              'emulator-test-${DateTime.now().millisecondsSinceEpoch}.txt';
          final file = bucket.file(fileName);
          currentFile = file;

          const content = 'Emulator test';
          await file.save(
            Uint8List.fromList(content.codeUnits),
            const gcs.SaveOptions(contentType: 'text/plain', gzip: false),
          );

          final downloaded = await file.download();
          expect(String.fromCharCodes(downloaded), content);
        });
      });
    },
    skip: Environment.isStorageEmulatorEnabled()
        ? false
        : 'Skipping Storage integration tests. Set FIREBASE_STORAGE_EMULATOR_HOST'
              ' environment variable to run these tests.',
  );
}

/// Helper function to verify bucket works by performing upload/download/delete operations
Future<void> verifyBucket(gcs.Bucket bucket, String testName) async {
  final expected = 'Hello World: $testName';
  final fileName = 'data_${DateTime.now().millisecondsSinceEpoch}.txt';
  final file = bucket.file(fileName);

  // Upload
  await file.save(
    Uint8List.fromList(expected.codeUnits),
    const gcs.SaveOptions(contentType: 'text/plain', gzip: false),
  );

  // Download and verify
  final downloaded = await file.download();
  final content = String.fromCharCodes(downloaded);
  expect(content, expected, reason: 'Downloaded content should match uploaded');

  // Delete
  await file.delete();

  // Verify deletion
  final exists = await file.exists();
  expect(exists, isFalse, reason: 'File should not exist after deletion');
}
