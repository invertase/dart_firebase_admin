import 'dart:io';

import 'package:test/test.dart';
import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_storage/googleapis_storage.dart';
import 'main.dart';

void storageTests() {
  group('Bucket Operations', () {
    var createdBuckets = <Bucket>[];

    tearDownAll(() async {
      await Future.wait(
        createdBuckets.map(
          (bucket) =>
              bucket.delete(options: DeleteOptions(ignoreNotFound: true)),
        ),
      );
    });

    test('should create a bucket', () async {
      // Ensure setup completed successfully
      if (storage == null || projectId == null) {
        fail(
          'Test setup failed. Check that PROJECT_ID is set and authentication is configured.',
        );
      }

      final bucketName = generateBucketName();

      // Create bucket
      final bucketMetadata = storage_v1.Bucket()..name = bucketName;
      final createdBucket = await storage!.createBucket(bucketMetadata);

      createdBuckets.add(createdBucket);

      // Verify bucket was created
      expect(createdBucket.id, equals(bucketName));
      final metadata = createdBucket.metadata;
      expect(metadata, isNotNull);
      expect(metadata.name, equals(bucketName));

      // Verify we can get the bucket
      final retrievedBucket = await storage!.bucket(bucketName).getMetadata();
      expect(retrievedBucket.name, equals(bucketName));
    });

    test('should get buckets with default options', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      final (buckets, nextQuery) = await storage!.getBuckets();
      expect(buckets, isA<List<Bucket>>());
      expect(nextQuery, isNull); // Auto-pagination returns null for nextQuery
      // Verify all items are Bucket instances
      for (final bucket in buckets) {
        expect(bucket, isA<Bucket>());
        expect(bucket.id, isNotNull);
      }
    });

    test('should get buckets with prefix filter', () async {
      if (storage == null || projectId == null || testPrefix == null) {
        fail('Test setup failed.');
      }

      // Create test buckets
      final bucketNames = [generateBucketName(), generateBucketName()];

      for (final bucketName in bucketNames) {
        final bucketMetadata = storage_v1.Bucket()..name = bucketName;
        final bucket = await storage!.createBucket(bucketMetadata);
        createdBuckets.add(bucket);
      }

      // Get buckets with prefix filter
      final (buckets, _) = await storage!.getBuckets(
        GetBucketsOptions(prefix: testPrefix),
      );

      // Verify our test buckets are in the results
      final foundBuckets = buckets
          .where((b) => bucketNames.contains(b.id))
          .toList();
      expect(foundBuckets.length, equals(bucketNames.length));
    });

    test('should get buckets with maxResults limit', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      final (buckets, nextQuery) = await storage!.getBuckets(
        GetBucketsOptions(maxResults: 5, autoPaginate: false),
      );

      expect(buckets.length, lessThanOrEqualTo(5));
      // nextQuery may or may not be null depending on whether there are more results
      if (nextQuery != null) {
        expect(nextQuery.pageToken, isNotNull);
      }
    });

    test('should get buckets with pagination', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      // Get first page
      final (firstPage, nextQuery) = await storage!.getBuckets(
        GetBucketsOptions(maxResults: 2, autoPaginate: false),
      );

      expect(firstPage.length, lessThanOrEqualTo(2));

      // If there's a next page, fetch it
      if (nextQuery != null) {
        final (secondPage, _) = await storage!.getBuckets(nextQuery);
        expect(secondPage, isA<List<Bucket>>());
        // Verify no overlap (assuming bucket names are unique)
        final firstPageIds = firstPage.map((b) => b.id).toSet();
        final secondPageIds = secondPage.map((b) => b.id).toSet();
        expect(
          firstPageIds.intersection(secondPageIds).isEmpty,
          isTrue,
          reason: 'Pages should not have overlapping buckets',
        );
      }
    });

    test('should get buckets with softDeleted filter', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      // This test verifies the API accepts the softDeleted parameter
      // We may not have soft-deleted buckets, so we just verify it doesn't error
      final (buckets, _) = await storage!.getBuckets(
        GetBucketsOptions(softDeleted: false),
      );

      expect(buckets, isA<List<Bucket>>());
    });

    test('should get buckets as a stream', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      final buckets = <Bucket>[];
      var bucketEmitted = false;

      await for (final bucket in storage!.getBucketsStream()) {
        expect(bucket, isA<Bucket>());
        expect(bucket.id, isNotNull);
        buckets.add(bucket);
        bucketEmitted = true;
        // Limit to first 10 to avoid long test runs
        if (buckets.length >= 10) break;
      }

      // Verify at least one bucket was emitted (there should be at least the test buckets)
      expect(
        bucketEmitted,
        isTrue,
        reason: 'At least one bucket should be emitted from stream',
      );
    });
  });

  group('HMAC Key Operations', () {
    String? serviceAccountEmail;

    setUpAll(() async {
      if (storage == null || projectId == null) {
        return;
      }

      // HMAC keys require a service account email
      // Try environment variable first, then fall back to App Engine default service account
      final envServiceAccount =
          Platform.environment['HMAC_KEY_TEST_SERVICE_ACCOUNT'];
      if (envServiceAccount != null && envServiceAccount.isNotEmpty) {
        serviceAccountEmail = envServiceAccount;
        return;
      }

      // Fall back to App Engine default service account format
      // This is the format: PROJECT_ID@appspot.gserviceaccount.com
      serviceAccountEmail = '$projectId@appspot.gserviceaccount.com';

      // Verify the service account exists by trying to get HMAC keys
      // If it fails, we'll skip the tests
      try {
        await storage!.getHmacKeys(
          GetHmacKeysOptions(
            serviceAccountEmail: serviceAccountEmail,
            maxResults: 1,
            autoPaginate: false,
          ),
        );
      } catch (e) {
        // Service account might not exist or not have permissions
        print(
          'Warning: Could not access HMAC keys for service account $serviceAccountEmail: $e',
        );
        serviceAccountEmail = null;
      }
    });

    test('should create an HMAC key for a service account', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        final hmacKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );

        expect(hmacKey, isA<HmacKey>());
        expect(hmacKey.id, isNotNull);
        expect(hmacKey.id, isNotEmpty);

        final metadata = hmacKey.metadata;
        expect(metadata, isNotNull);
        expect(metadata.id, equals(hmacKey.id));
        expect(metadata.state, equals('ACTIVE'));
        expect(metadata.projectId, equals(projectId));
        expect(metadata.serviceAccountEmail, equals(serviceAccountEmail));
        expect(metadata.etag, isNotNull);
        expect(metadata.timeCreated, isNotNull);
        expect(metadata.updated, isNotNull);

        createdKey = hmacKey;
      } catch (e) {
        // Provide better error message for HMAC key creation failures
        if (e is ApiError) {
          fail(
            'Failed to create HMAC key: ${e.message}. Details: ${e.details}. '
            'Make sure the service account $serviceAccountEmail exists and has proper permissions.',
          );
        }
        rethrow;
      } finally {
        // Clean up: deactivate and delete
        if (createdKey != null) {
          try {
            await createdKey.setMetadata(
              SetHmacKeyMetadata(state: HmacKeyState.inactive),
            );
            await createdKey.delete();
          } catch (e) {
            // Ignore cleanup errors
            print('Warning: Failed to clean up HMAC key: $e');
          }
        }
      }
    });

    test('should get HMAC keys without filter', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        // Create a test key
        createdKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );

        // Get all HMAC keys
        final (keys, _) = await storage!.getHmacKeys(
          GetHmacKeysOptions(projectId: projectId),
        );

        expect(keys, isA<List<HmacKey>>());
        expect(keys.length, greaterThan(0));

        // Verify our created key is in the list
        final foundKey = keys.firstWhere(
          (k) => k.id == createdKey!.id,
          orElse: () => throw Exception('Created key not found'),
        );
        expect(foundKey.id, equals(createdKey.id));
      } finally {
        if (createdKey != null) {
          try {
            await createdKey.setMetadata(
              SetHmacKeyMetadata(state: HmacKeyState.inactive),
            );
            await createdKey.delete();
          } catch (e) {
            print('Warning: Failed to clean up HMAC key: $e');
          }
        }
      }
    });

    test('should get HMAC keys with serviceAccountEmail filter', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        // Create a test key
        createdKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );

        // Get HMAC keys filtered by service account
        final (keys, _) = await storage!.getHmacKeys(
          GetHmacKeysOptions(
            serviceAccountEmail: serviceAccountEmail,
            projectId: projectId,
          ),
        );

        expect(keys, isA<List<HmacKey>>());

        // All keys should belong to the specified service account
        for (final key in keys) {
          final metadata = key.metadata;
          expect(metadata.serviceAccountEmail, equals(serviceAccountEmail));
        }

        // Our created key should be in the list
        final foundKey = keys.firstWhere(
          (k) => k.id == createdKey!.id,
          orElse: () => throw Exception('Created key not found'),
        );
        expect(foundKey.id, equals(createdKey.id));
      } finally {
        if (createdKey != null) {
          try {
            await createdKey.setMetadata(
              SetHmacKeyMetadata(state: HmacKeyState.inactive),
            );
            await createdKey.delete();
          } catch (e) {
            print('Warning: Failed to clean up HMAC key: $e');
          }
        }
      }
    });

    test('should get HMAC keys with showDeletedKeys option', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        // Create and delete a key
        createdKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );
        final id = createdKey.id;

        // Deactivate and delete
        await createdKey.setMetadata(
          SetHmacKeyMetadata(state: HmacKeyState.inactive),
        );
        await createdKey.delete();

        // Get keys without showDeletedKeys (should not include deleted)
        final (activeKeys, _) = await storage!.getHmacKeys(
          GetHmacKeysOptions(
            serviceAccountEmail: serviceAccountEmail,
            projectId: projectId,
          ),
        );

        final foundDeleted = activeKeys.any((k) => k.id == id);
        expect(foundDeleted, isFalse, reason: 'Deleted key should not appear');

        // Get keys with showDeletedKeys (should include deleted)
        final (allKeys, _) = await storage!.getHmacKeys(
          GetHmacKeysOptions(
            serviceAccountEmail: serviceAccountEmail,
            showDeletedKeys: true,
            projectId: projectId,
          ),
        );

        // Note: Deleted keys may or may not appear immediately
        // This test verifies the API accepts the parameter
        expect(allKeys, isA<List<HmacKey>>());
      } catch (e) {
        // Clean up if deletion failed
        if (createdKey != null) {
          try {
            final metadata = await createdKey.getMetadata();
            if (metadata.state != 'DELETED') {
              await createdKey.setMetadata(
                SetHmacKeyMetadata(state: HmacKeyState.inactive),
              );
              await createdKey.delete();
            }
          } catch (_) {
            // Ignore cleanup errors
          }
        }
        rethrow;
      }
    });

    test('should get HMAC keys with pagination', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      // Get first page
      final (firstPage, nextQuery) = await storage!.getHmacKeys(
        GetHmacKeysOptions(
          maxResults: 2,
          autoPaginate: false,
          serviceAccountEmail: serviceAccountEmail,
          projectId: projectId,
        ),
      );

      expect(firstPage.length, lessThanOrEqualTo(2));

      // If there's a next page, fetch it
      if (nextQuery != null) {
        final (secondPage, _) = await storage!.getHmacKeys(nextQuery);
        expect(secondPage, isA<List<HmacKey>>());
      }
    });

    test('should get HMAC keys as a stream', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      final keys = <HmacKey>[];
      await for (final key in storage!.getHmacKeysStream(
        GetHmacKeysOptions(
          serviceAccountEmail: serviceAccountEmail,
          projectId: projectId,
        ),
      )) {
        expect(key, isA<HmacKey>());
        expect(key.id, isNotNull);
        keys.add(key);
        // Limit to first 10 to avoid long test runs
        if (keys.length >= 10) break;
      }

      expect(keys, isA<List<HmacKey>>());
    });

    test('should get HMAC key metadata', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        createdKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );

        // Get metadata using getMetadata
        final metadata = await createdKey.getMetadata();
        expect(metadata.id, equals(createdKey.id));
        expect(metadata.state, equals('ACTIVE'));
        expect(metadata.serviceAccountEmail, equals(serviceAccountEmail));
      } finally {
        if (createdKey != null) {
          try {
            await createdKey.setMetadata(
              SetHmacKeyMetadata(state: HmacKeyState.inactive),
            );
            await createdKey.delete();
          } catch (e) {
            print('Warning: Failed to clean up HMAC key: $e');
          }
        }
      }
    });

    test('should set HMAC key metadata to INACTIVE', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      HmacKey? createdKey;

      try {
        createdKey = await storage!.createHmacKey(
          serviceAccountEmail!,
          CreateHmacKeyOptions(projectId: projectId),
        );

        // Get current metadata to get etag
        final currentMetadata = await createdKey.getMetadata();

        // Set to INACTIVE
        final updatedMetadata = await createdKey.setMetadata(
          SetHmacKeyMetadata(
            state: HmacKeyState.inactive,
            etag: currentMetadata.etag,
          ),
        );

        expect(updatedMetadata.state, equals('INACTIVE'));

        // Verify by getting metadata again
        final verifiedMetadata = await createdKey.getMetadata();
        expect(verifiedMetadata.state, equals('INACTIVE'));
      } finally {
        if (createdKey != null) {
          try {
            // Ensure it's inactive before deleting
            final metadata = await createdKey.getMetadata();
            if (metadata.state != 'INACTIVE') {
              await createdKey.setMetadata(
                SetHmacKeyMetadata(
                  state: HmacKeyState.inactive,
                  etag: metadata.etag,
                ),
              );
            }
            await createdKey.delete();
          } catch (e) {
            print('Warning: Failed to clean up HMAC key: $e');
          }
        }
      }
    });

    test('should delete HMAC key', () async {
      if (storage == null || projectId == null || serviceAccountEmail == null) {
        markTestSkipped('Service account email not available');
        return;
      }

      final createdKey = await storage!.createHmacKey(
        serviceAccountEmail!,
        CreateHmacKeyOptions(projectId: projectId),
      );

      try {
        // Deactivate first (required before deletion)
        final metadata = await createdKey.getMetadata();
        await createdKey.setMetadata(
          SetHmacKeyMetadata(state: HmacKeyState.inactive, etag: metadata.etag),
        );

        // Delete the key
        await createdKey.delete();

        // Verify it's deleted by getting metadata
        final deletedMetadata = await createdKey.getMetadata();
        expect(deletedMetadata.state, equals('DELETED'));
        expect(createdKey.metadata.state, equals('DELETED'));
      } catch (e) {
        // If deletion failed, try to clean up
        try {
          final metadata = await createdKey.getMetadata();
          if (metadata.state != 'DELETED') {
            if (metadata.state != 'INACTIVE') {
              await createdKey.setMetadata(
                SetHmacKeyMetadata(
                  state: HmacKeyState.inactive,
                  etag: metadata.etag,
                ),
              );
            }
            await createdKey.delete();
          }
        } catch (_) {
          // Ignore cleanup errors
        }
        rethrow;
      }
    });
  });

  group('Service Account Operations', () {
    test('should get service account', () async {
      if (storage == null || projectId == null) {
        fail('Test setup failed.');
      }

      final serviceAccount = await storage!.getServiceAccount();

      expect(serviceAccount, isNotNull);
      expect(serviceAccount.emailAddress, isNotNull);
      expect(serviceAccount.emailAddress, isNotEmpty);
      expect(serviceAccount.emailAddress, contains('@'));
    });
  });
}
