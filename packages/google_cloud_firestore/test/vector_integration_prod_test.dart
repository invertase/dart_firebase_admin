// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'package:google_cloud_firestore/google_cloud_firestore.dart';
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
        firestore = Firestore(
          settings: const Settings(projectId: 'dart-firebase-admin'),
        );
      });

      group('vector search with nested fields', () {
        test('supports findNearest on vector nested in a map', () async {
          await runZoned(() async {
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
          }, zoneValues: {envSymbol: <String, String>{}});
        });
      });
    },
    skip: hasProdEnv
        ? false
        : 'Vector search and embedding require production Firestore '
              '(not supported in emulator',
  );
}
