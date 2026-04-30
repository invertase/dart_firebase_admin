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
import 'package:google_cloud_firestore/src/firestore_http_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFirestoreHttpClient extends Mock implements FirestoreHttpClient {}

void main() {
  group('Firestore', () {
    test('toJSON() returns projectId from settings', () {
      final firestore = Firestore(
        settings: const Settings(projectId: 'my-project-id'),
      );

      final json = firestore.toJSON();

      expect(json, {'projectId': 'my-project-id'});
    });

    test('toJSON() returns null projectId when not set', () {
      final firestore = Firestore(settings: const Settings());

      final json = firestore.toJSON();

      // Project ID should be null if not explicitly set and not yet discovered
      expect(json, {'projectId': null});
    });

    test('projectId getter returns value from settings', () {
      final firestore = Firestore(
        settings: const Settings(projectId: 'explicit-project'),
      );

      expect(firestore.projectId, 'explicit-project');
    });

    test(
      'projectId getter returns value from GOOGLE_CLOUD_PROJECT env var',
      () {
        runZoned(
          () {
            final firestore = Firestore(settings: const Settings());
            expect(firestore.projectId, 'env-project');
          },
          zoneValues: {
            envSymbol: <String, String>{'GOOGLE_CLOUD_PROJECT': 'env-project'},
          },
        );
      },
    );

    test('projectId getter returns value from GCLOUD_PROJECT env var', () {
      runZoned(
        () {
          final firestore = Firestore(settings: const Settings());
          expect(firestore.projectId, 'env-project');
        },
        zoneValues: {
          envSymbol: <String, String>{'GCLOUD_PROJECT': 'env-project'},
        },
      );
    });

    test('projectId getter throws when no project ID is discoverable', () {
      runZoned(() {
        final firestore = Firestore(settings: const Settings());
        expect(() => firestore.projectId, throwsStateError);
      }, zoneValues: {envSymbol: <String, String>{}});
    });

    test('databaseId getter returns default when not set', () {
      final firestore = Firestore(settings: const Settings());

      expect(firestore.databaseId, '(default)');
    });

    test('databaseId getter returns custom value when set', () {
      final firestore = Firestore(
        settings: const Settings(databaseId: 'custom-db'),
      );

      expect(firestore.databaseId, 'custom-db');
    });

    group('doc()', () {
      late Firestore firestore;

      setUp(() {
        firestore = Firestore(settings: const Settings(projectId: 'test'));
      });

      test('returns DocumentReference', () {
        final docRef = firestore.doc('collectionId/documentId');
        expect(docRef, isA<DocumentReference<DocumentData>>());
      });

      test('rejects empty path', () {
        expect(() => firestore.doc(''), throwsArgumentError);
      });

      test('rejects path with empty components', () {
        expect(() => firestore.doc('coll//doc'), throwsArgumentError);
      });

      test('must point to document (even number of components)', () {
        expect(
          () => firestore.doc('collectionId'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must point to a document'),
            ),
          ),
        );
      });

      test('exposes properties correctly', () {
        final docRef = firestore.doc('collectionId/documentId');
        expect(docRef.id, 'documentId');
        expect(docRef.path, 'collectionId/documentId');
        expect(docRef.firestore, firestore);
      });

      test('handles nested paths', () {
        final docRef = firestore.doc('col1/doc1/col2/doc2');
        expect(docRef.id, 'doc2');
        expect(docRef.path, 'col1/doc1/col2/doc2');
      });
    });

    group('collection()', () {
      late Firestore firestore;

      setUp(() {
        firestore = Firestore(settings: const Settings(projectId: 'test'));
      });

      test('returns CollectionReference', () {
        final colRef = firestore.collection('collectionId');
        expect(colRef, isA<CollectionReference<DocumentData>>());
      });

      test('rejects empty path', () {
        expect(() => firestore.collection(''), throwsArgumentError);
      });

      test('must point to collection (odd number of components)', () {
        expect(
          () => firestore.collection('collectionId/documentId'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must point to a collection'),
            ),
          ),
        );
      });

      test('exposes properties correctly', () {
        final colRef = firestore.collection('collectionId');
        expect(colRef.id, 'collectionId');
        expect(colRef.path, 'collectionId');
      });

      test('handles nested collection paths', () {
        final colRef = firestore.collection('col1/doc1/col2');
        expect(colRef.id, 'col2');
        expect(colRef.path, 'col1/doc1/col2');
      });
    });

    group('collectionGroup()', () {
      late Firestore firestore;

      setUp(() {
        firestore = Firestore(settings: const Settings(projectId: 'test'));
      });

      test('returns CollectionGroup', () {
        final group = firestore.collectionGroup('collectionId');
        expect(group, isA<CollectionGroup<DocumentData>>());
      });

      test('rejects collection ID with slash', () {
        expect(
          () => firestore.collectionGroup('col/doc'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must not contain "/"'),
            ),
          ),
        );
      });
    });

    group('batch()', () {
      test('returns WriteBatch', () {
        final firestore = Firestore(
          settings: const Settings(projectId: 'test'),
        );
        final batch = firestore.batch();
        expect(batch, isA<WriteBatch>());
      });

      group('set() with map keys containing "/"', () {
        test('accepts a top-level map value with "/" in key', () {
          final firestore = Firestore(
            settings: const Settings(projectId: 'test'),
          );
          final batch = firestore.batch();
          final docRef = firestore.doc('activities/new-activity');

          expect(
            () => batch.set(docRef, {
              'activityType': 'activityA',
              'agents': {'products/product-a': 5.0},
            }),
            returnsNormally,
          );
        });

        test('accepts nested maps with "/" in keys', () {
          final firestore = Firestore(
            settings: const Settings(projectId: 'test'),
          );
          final batch = firestore.batch();
          final docRef = firestore.doc('col/doc');

          expect(
            () => batch.set(docRef, {
              'refs': {'users/alice': true, 'users/bob': false},
            }),
            returnsNormally,
          );
        });
      });
    });

    group('bulkWriter()', () {
      test('returns BulkWriter', () {
        final firestore = Firestore(
          settings: const Settings(projectId: 'test'),
        );
        final writer = firestore.bulkWriter();
        expect(writer, isA<BulkWriter>());
      });

      test('accepts options', () {
        final firestore = Firestore(
          settings: const Settings(projectId: 'test'),
        );
        final writer = firestore.bulkWriter(
          const BulkWriterOptions(
            throttling: EnabledThrottling(
              initialOpsPerSecond: 100,
              maxOpsPerSecond: 1000,
            ),
          ),
        );
        expect(writer, isA<BulkWriter>());
      });
    });

    group('bundle()', () {
      test('returns BundleBuilder', () {
        final firestore = Firestore(
          settings: const Settings(projectId: 'test'),
        );
        final bundle = firestore.bundle('my-bundle');
        expect(bundle, isA<BundleBuilder>());
        expect(bundle.bundleId, 'my-bundle');
      });
    });

    group('terminate()', () {
      test('calls close() on the HTTP client', () async {
        final mockClient = MockFirestoreHttpClient();
        when(mockClient.close).thenAnswer((_) async {});
        when(() => mockClient.cachedProjectId).thenReturn('test');

        final firestore = Firestore.internal(
          settings: const Settings(projectId: 'test'),
          client: mockClient,
        );

        await firestore.terminate();

        verify(mockClient.close).called(1);
      });
    });
  });
}
