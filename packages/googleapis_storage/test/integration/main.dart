import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:googleapis/storage/v1.dart' as storage_v1;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis_storage/googleapis_storage.dart';
import 'package:test/test.dart';

import 'storage.dart';

// Global test state
Storage? storage;
String? projectId;
String? testPrefix;
auth.AuthClient? authClient;

/// Generate a short UUID for bucket names (similar to Node.js implementation)
/// Uses timestamp + random component to ensure uniqueness
String shortUUID() {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  // Add a random component to avoid collisions if called in same millisecond
  final random = (timestamp.hashCode ^ DateTime.now().microsecondsSinceEpoch)
      .toString();
  final bytes = utf8.encode('$timestamp-$random');
  final hash = sha256.convert(bytes);
  return hash.toString().substring(0, 8);
}

/// Generate a unique bucket name with test prefix
String generateBucketName() {
  return '$testPrefix${shortUUID()}';
}

void main() {
  setUpAll(() async {
    // Read PROJECT_ID from environment variable
    projectId =
        Platform.environment['PROJECT_ID'] ??
        (throw Exception(
          'PROJECT_ID environment variable is required for integration tests',
        ));

    // Set up authentication using Application Default Credentials
    authClient = await auth.clientViaApplicationDefaultCredentials(
      scopes: [storage_v1.StorageApi.devstorageFullControlScope],
    );

    // Initialize Storage instance with authenticated client
    // Note: projectId is passed to individual operations, not StorageOptions
    storage = Storage(
      StorageOptions(projectId: projectId!, authClient: authClient),
    );

    // Generate test prefix for unique bucket names
    testPrefix = 'storage-tests-${shortUUID()}-';
  });

  // tearDownAll(() async {
  //   // Only clean up if setup was successful
  //   if (storage == null || testPrefix == null || projectId == null) {
  //     return;
  //   }

  //   // Clean up created buckets
  //   try {
  //     // Get all buckets with test prefix
  //     final (buckets, _) = await storage!.getBuckets(
  //       GetBucketsOptions(
  //         prefix: testPrefix!,
  //         autoPaginate: true,
  //         projectId: projectId!,
  //       ),
  //     );

  //     // Delete all buckets with test prefix
  //     for (final bucket in buckets) {
  //       try {
  //         await bucket.delete();
  //       } catch (e) {
  //         // Ignore errors during cleanup
  //         print('Warning: Failed to delete bucket ${bucket.id}: $e');
  //       }
  //     }
  //   } catch (e) {
  //     print('Warning: Failed to clean up buckets: $e');
  //   }

  //   // Close HTTP client if it was initialized
  //   authClient?.close();
  // });

  storageTests();
}
