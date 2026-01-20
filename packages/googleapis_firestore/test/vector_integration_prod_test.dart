import 'dart:io';

import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:googleapis_firestore/src/environment.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Integration tests for Vector Search that require production Firestore.
///
/// These tests run against production because certain features (like nested
/// field vector search) are not supported by the Firestore emulator.
///
/// To run these tests:
/// export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
/// dart test test/vector_integration_prod_test.dart
void main() {
  group(
    'Vector Production Tests',
    () {
      late Firestore firestore;

      setUp(() async {
        // Remove emulator env var to ensure we connect to production
        // This allows prod tests to run even inside firebase emulators:exec
        final prodEnv = Map<String, String>.from(Platform.environment);
        prodEnv.remove(Environment.firestoreEmulatorHost);

        // Create Firestore instance for production tests
        firestore = Firestore(
          settings: Settings(
            projectId: 'dart-firebase-admin',
            environmentOverride: prodEnv,
          ),
        );
      });

      group('vector search with nested fields', () {
        test('supports findNearest on vector nested in a map', () async {
          // Use fixed collection name for production (requires pre-configured index)
          final collection = firestore.collection('nested-vector-test-prod');
          final testId = 'test-${DateTime.now().millisecondsSinceEpoch}';

          try {
            await Future.wait([
              collection.add({
                'testId': testId,
                'nested': {
                  'embedding': FieldValue.vector([1.0, 1.0]),
                },
              }),
              collection.add({
                'testId': testId,
                'nested': {
                  'embedding': FieldValue.vector([10.0, 10.0]),
                },
              }),
            ]);

            // Query with testId filter for test isolation
            final vectorQuery = collection
                .where('testId', WhereFilter.equal, testId)
                .findNearest(
                  vectorField: 'nested.embedding',
                  queryVector: [1.0, 1.0],
                  limit: 2,
                  distanceMeasure: DistanceMeasure.euclidean,
                );

            final res = await vectorQuery.get();
            expect(res.size, 2);
          } finally {
            // Clean up: delete test documents
            final docs = await collection
                .where('testId', WhereFilter.equal, testId)
                .get();
            for (final doc in docs.docs) {
              await doc.ref.delete();
            }
          }
        });
      });
    },
    skip: hasGoogleEnv
        ? false
        : 'Vector search and embedding require production Firestore '
              '(not supported in emulator',
  );
}
