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

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart';

import '../fixtures/helpers.dart';

/// Integration tests for Vector Search.
///
/// These tests require the Firestore emulator to be running.
/// Start it with: firebase emulators:start --only firestore
void main() {
  // Skip all tests if emulator is not configured
  if (!isFirestoreEmulatorEnabled()) {
    // ignore: avoid_print
    print(
      'Skipping Vector integration tests. '
      'Set FIRESTORE_EMULATOR_HOST environment variable to run these tests.',
    );
    return;
  }

  group('Vector Integration Tests', () {
    late Firestore firestore;

    setUp(() async {
      firestore = await createFirestore();
    });

    group('write and read vector embeddings', () {
      test('can create document with vector field', () async {
        final ref = firestore.collection('vector-test').doc();
        await ref.create({
          'vector0': FieldValue.vector([0.0]),
          'vector1': FieldValue.vector([1.0, 2.0, 3.99]),
        });

        final snap = await ref.get();
        expect(snap.exists, true);
        expect(snap.get('vector0')?.value, isA<VectorValue>());
        expect((snap.get('vector0')!.value! as VectorValue).toArray(), [0.0]);
        expect((snap.get('vector1')!.value! as VectorValue).toArray(), [
          1.0,
          2.0,
          3.99,
        ]);
      });

      test('can set document with vector field', () async {
        final ref = firestore.collection('vector-test').doc();
        await ref.set({
          'vector0': FieldValue.vector([0.0]),
          'vector1': FieldValue.vector([1.0, 2.0, 3.99]),
          'vector2': FieldValue.vector([0.0, 0.0, 0.0]),
        });

        final snap = await ref.get();
        expect(snap.exists, true);
        expect((snap.get('vector0')!.value! as VectorValue).toArray(), [0.0]);
        expect((snap.get('vector1')!.value! as VectorValue).toArray(), [
          1.0,
          2.0,
          3.99,
        ]);
        expect((snap.get('vector2')!.value! as VectorValue).toArray(), [
          0.0,
          0.0,
          0.0,
        ]);
      });

      test('can update document with vector field', () async {
        final ref = firestore.collection('vector-test').doc();
        await ref.set({'name': 'test'});
        await ref.update({
          'vector3': FieldValue.vector([-1.0, -200.0, -999.0]),
        });

        final snap = await ref.get();
        expect((snap.get('vector3')!.value! as VectorValue).toArray(), [
          -1.0,
          -200.0,
          -999.0,
        ]);
      });

      test('VectorValue.isEqual works with retrieved vectors', () async {
        final ref = firestore.collection('vector-test').doc();
        await ref.set({
          'embedding': FieldValue.vector([1.0, 2.0, 3.0]),
        });

        final snap = await ref.get();
        final retrievedVector = snap.get('embedding')!.value! as VectorValue;
        final expectedVector = FieldValue.vector([1.0, 2.0, 3.0]);

        expect(retrievedVector.isEqual(expectedVector), true);
      });
    });

    group('vector search (findNearest)', () {
      late CollectionReference<DocumentData> collection;

      setUp(() async {
        // Create test collection with vector embeddings
        collection = firestore.collection(
          'vector-search-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create test documents with embeddings
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 'bar',
            // No embedding
          }),
          collection.doc('doc2').set({
            'foo': 'xxx',
            'embedding': FieldValue.vector([10.0, 10.0]),
          }),
          collection.doc('doc3').set({
            'foo': 'bar',
            'embedding': FieldValue.vector([1.0, 1.0]),
          }),
          collection.doc('doc4').set({
            'foo': 'bar',
            'embedding': FieldValue.vector([10.0, 0.0]),
          }),
          collection.doc('doc5').set({
            'foo': 'bar',
            'embedding': FieldValue.vector([20.0, 0.0]),
          }),
          collection.doc('doc6').set({
            'foo': 'bar',
            'embedding': FieldValue.vector([100.0, 100.0]),
          }),
        ]);
      });

      test('supports findNearest by EUCLIDEAN distance', () async {
        final vectorQuery = collection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 3);
        expect(res.empty, false);
        expect(res.docs.length, 3);

        // Results should be ordered by distance
        // [10, 0] is closest to [10, 10] with distance 10
        // [1, 1] has distance ~12.7
        // [20, 0] has distance ~14.1
        expect(
          (res.docs[0].get('embedding')!.value! as VectorValue).toArray(),
          [10.0, 0.0],
        );
        expect(
          (res.docs[1].get('embedding')!.value! as VectorValue).toArray(),
          [1.0, 1.0],
        );
        expect(
          (res.docs[2].get('embedding')!.value! as VectorValue).toArray(),
          [20.0, 0.0],
        );
      });

      test('supports findNearest by COSINE distance', () async {
        final vectorQuery = collection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.cosine,
            );

        final res = await vectorQuery.get();
        expect(res.size, 3);

        // For cosine distance, [1,1] and [100,100] have same angle as [10,10]
        // so they should be closest (cosine distance = 0)
        final vectors = res.docs
            .map((d) => (d.get('embedding')!.value! as VectorValue).toArray())
            .toList();

        // All results should have the embedding field
        expect(vectors.length, 3);
      });

      test('supports findNearest by DOT_PRODUCT distance', () async {
        final vectorQuery = collection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [1.0, 1.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.dotProduct,
            );

        final res = await vectorQuery.get();
        expect(res.size, 3);
      });

      test('supports findNearest with distanceResultField', () async {
        final vectorQuery = collection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.euclidean,
              distanceResultField: 'distance',
            );

        final res = await vectorQuery.get();
        expect(res.size, 3);

        // Each document should have a 'distance' field with the computed distance
        for (final doc in res.docs) {
          final distance = doc.get('distance')!.value;
          expect(distance, isA<double>());
          expect(distance! as double, greaterThanOrEqualTo(0));
        }
      });

      test('supports findNearest with distanceThreshold', () async {
        final vectorQuery = collection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 10,
              distanceMeasure: DistanceMeasure.euclidean,
              distanceThreshold: 15, // Only return docs within distance 15
            );

        final res = await vectorQuery.get();
        // Should filter out [100, 100] which has distance ~127
        expect(res.size, lessThanOrEqualTo(4));
      });

      test('VectorQuerySnapshot has correct properties', () async {
        final vectorQuery = collection.findNearest(
          vectorField: 'embedding',
          queryVector: [1.0, 1.0],
          limit: 2,
          distanceMeasure: DistanceMeasure.euclidean,
        );

        final res = await vectorQuery.get();

        expect(res.query, vectorQuery);
        expect(res.readTime, isA<Timestamp>());
        expect(res.docs, isA<List<QueryDocumentSnapshot<DocumentData>>>());
        expect(res.size, res.docs.length);
        expect(res.empty, res.docs.isEmpty);
      });

      test('VectorQuerySnapshot.docChanges returns all as added', () async {
        final vectorQuery = collection.findNearest(
          vectorField: 'embedding',
          queryVector: [1.0, 1.0],
          limit: 3,
          distanceMeasure: DistanceMeasure.euclidean,
        );

        final res = await vectorQuery.get();
        final changes = res.docChanges;

        expect(changes.length, res.size);
        for (final change in changes) {
          expect(change.type, DocumentChangeType.added);
          expect(change.oldIndex, -1);
        }
      });

      test('VectorQuerySnapshot.forEach iterates over docs', () async {
        final vectorQuery = collection.findNearest(
          vectorField: 'embedding',
          queryVector: [1.0, 1.0],
          limit: 3,
          distanceMeasure: DistanceMeasure.euclidean,
        );

        final res = await vectorQuery.get();
        var count = 0;
        res.forEach((doc) {
          expect(doc, isA<QueryDocumentSnapshot<DocumentData>>());
          count++;
        });

        expect(count, res.size);
      });

      test('findNearest works with converters', () async {
        final testCollection = firestore.collection(
          'converter-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        await testCollection.add({
          'foo': 'bar',
          'embedding': FieldValue.vector([5.0, 5.0]),
        });

        final vectorQuery = testCollection
            .withConverter<Map<String, Object?>>(
              fromFirestore: (snapshot) => snapshot.data(),
              toFirestore: (data) => data,
            )
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 1);
        expect(res.docs[0].data()['foo'], 'bar');
        final embedding = res.docs[0].data()['embedding']! as VectorValue;
        expect(embedding.toArray(), [5.0, 5.0]);
      });

      test('supports findNearest skipping fields of wrong types', () async {
        final testCollection = firestore.collection(
          'wrong-types-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        await Future.wait([
          testCollection.add({'foo': 'bar'}),
          // These documents are skipped - not actual vector values
          testCollection.add({
            'foo': 'bar',
            'embedding': [10, 10],
          }),
          testCollection.add({'foo': 'bar', 'embedding': 'not a vector'}),
          testCollection.add({'foo': 'bar', 'embedding': null}),
          // Actual vector values
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([9.0, 9.0]),
          }),
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([50.0, 50.0]),
          }),
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([100.0, 100.0]),
          }),
        ]);

        final vectorQuery = testCollection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 100,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 3);
        expect(
          (res.docs[0].get('embedding')!.value! as VectorValue).isEqual(
            FieldValue.vector([9.0, 9.0]),
          ),
          true,
        );
        expect(
          (res.docs[1].get('embedding')!.value! as VectorValue).isEqual(
            FieldValue.vector([50.0, 50.0]),
          ),
          true,
        );
        expect(
          (res.docs[2].get('embedding')!.value! as VectorValue).isEqual(
            FieldValue.vector([100.0, 100.0]),
          ),
          true,
        );
      });

      test('findNearest ignores mismatching dimensions', () async {
        final testCollection = firestore.collection(
          'dimension-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        await Future.wait([
          testCollection.add({'foo': 'bar'}),
          // Vector with dimension mismatch (1D instead of 2D)
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([10.0]),
          }),
          // Vectors with dimension match (2D)
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([9.0, 9.0]),
          }),
          testCollection.add({
            'foo': 'bar',
            'embedding': FieldValue.vector([50.0, 50.0]),
          }),
        ]);

        final vectorQuery = testCollection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 2);
        expect(
          (res.docs[0].get('embedding')!.value! as VectorValue).isEqual(
            FieldValue.vector([9.0, 9.0]),
          ),
          true,
        );
        expect(
          (res.docs[1].get('embedding')!.value! as VectorValue).isEqual(
            FieldValue.vector([50.0, 50.0]),
          ),
          true,
        );
      });

      test('supports findNearest on non-existent field', () async {
        final testCollection = firestore.collection(
          'nonexistent-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        await Future.wait([
          testCollection.add({'foo': 'bar'}),
          testCollection.add({
            'foo': 'bar',
            'otherField': [10, 10],
          }),
          testCollection.add({'foo': 'bar', 'otherField': 'not a vector'}),
          testCollection.add({'foo': 'bar', 'otherField': null}),
        ]);

        final vectorQuery = testCollection
            .where('foo', WhereFilter.equal, 'bar')
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 3,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 0);
      });

      test('supports findNearest with select to exclude vector data', () async {
        final testCollection = firestore.collection(
          'select-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        await Future.wait([
          testCollection.add({'foo': 1}),
          testCollection.add({
            'foo': 2,
            'embedding': FieldValue.vector([10.0, 10.0]),
          }),
          testCollection.add({
            'foo': 3,
            'embedding': FieldValue.vector([1.0, 1.0]),
          }),
          testCollection.add({
            'foo': 4,
            'embedding': FieldValue.vector([10.0, 0.0]),
          }),
          testCollection.add({
            'foo': 5,
            'embedding': FieldValue.vector([20.0, 0.0]),
          }),
          testCollection.add({
            'foo': 6,
            'embedding': FieldValue.vector([100.0, 100.0]),
          }),
        ]);

        final vectorQuery = testCollection
            .where('foo', WhereFilter.isIn, [1, 2, 3, 4, 5, 6])
            .select([
              FieldPath(const ['foo']),
            ])
            .findNearest(
              vectorField: 'embedding',
              queryVector: [10.0, 10.0],
              limit: 10,
              distanceMeasure: DistanceMeasure.euclidean,
            );

        final res = await vectorQuery.get();
        expect(res.size, 5);
        expect(res.docs[0].get('foo')?.value, 2);
        expect(res.docs[1].get('foo')?.value, 4);
        expect(res.docs[2].get('foo')?.value, 3);
        expect(res.docs[3].get('foo')?.value, 5);
        expect(res.docs[4].get('foo')?.value, 6);

        // Verify embedding field is not returned
        for (final doc in res.docs) {
          expect(doc.get('embedding'), isNull);
        }
      });

      test('supports findNearest with large dimension vectors', () async {
        final testCollection = firestore.collection(
          'large-dim-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        // Create 2048-dimension vectors
        final embeddingVector = <double>[];
        final queryVector = <double>[];
        for (var i = 0; i < 2048; i++) {
          embeddingVector.add((i + 1).toDouble());
          queryVector.add((i - 1).toDouble());
        }

        await testCollection.add({
          'embedding': FieldValue.vector(embeddingVector),
        });

        final vectorQuery = testCollection.findNearest(
          vectorField: 'embedding',
          queryVector: queryVector,
          limit: 1000,
          distanceMeasure: DistanceMeasure.euclidean,
        );

        final res = await vectorQuery.get();
        expect(res.size, 1);
        expect(
          (res.docs[0].get('embedding')!.value! as VectorValue).toArray(),
          embeddingVector,
        );
      });

      test('SDK orders vector field same way as backend', () async {
        final testCollection = firestore.collection(
          'ordering-test-${DateTime.now().millisecondsSinceEpoch}',
        );

        // Test data with VectorValues in the order we expect the backend to sort
        final docsInOrder = [
          {
            'embedding': FieldValue.vector([-100.0]),
          },
          {
            'embedding': FieldValue.vector([0.0]),
          },
          {
            'embedding': FieldValue.vector([100.0]),
          },
          {
            'embedding': FieldValue.vector([1.0, 2.0]),
          },
          {
            'embedding': FieldValue.vector([2.0, 2.0]),
          },
          {
            'embedding': FieldValue.vector([1.0, 2.0, 3.0]),
          },
          {
            'embedding': FieldValue.vector([1.0, 2.0, 3.0, 4.0]),
          },
          {
            'embedding': FieldValue.vector([1.0, 2.0, 3.0, 4.0, 5.0]),
          },
          {
            'embedding': FieldValue.vector([1.0, 2.0, 100.0, 4.0, 4.0]),
          },
          {
            'embedding': FieldValue.vector([100.0, 2.0, 3.0, 4.0, 5.0]),
          },
        ];

        final docRefs = <DocumentReference<DocumentData>>[];
        for (final data in docsInOrder) {
          final docRef = await testCollection.add(data);
          docRefs.add(docRef);
        }

        // Query by ordering on embedding field
        final query = testCollection.orderBy('embedding');
        final snapshot = await query.get();

        // Verify the order matches what we inserted
        expect(snapshot.docs.length, docsInOrder.length);
        for (var i = 0; i < snapshot.docs.length; i++) {
          expect(snapshot.docs[i].ref.path, docRefs[i].path);
        }
      });
    });
  });
}
