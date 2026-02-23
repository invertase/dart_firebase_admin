import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

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

      // Regression test for https://github.com/invertase/dart_firebase_admin/issues/83
      //
      // Firestore allows '/' characters inside map *keys* (e.g. document
      // reference paths stored as map keys). The SDK was incorrectly routing
      // map keys through field-path validation, which rejects '/', causing an
      // ArgumentError before any network call was made.
      group('map keys with "/" characters (issue #83)', () {
        late Firestore firestore;

        setUp(() {
          firestore = Firestore(settings: const Settings(projectId: 'test'));
        });

        test('set() should not throw for a map key containing "/"', () {
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

        test('set() should not throw for nested maps with "/" in keys', () {
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
  });
}
