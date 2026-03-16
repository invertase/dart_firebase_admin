// Copyright 2025 Google LLC
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
//
// SPDX-License-Identifier: Apache-2.0

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:test/test.dart' hide throwsArgumentError;

import 'helpers.dart';

void main() {
  group('WriteBatch', () {
    late Firestore firestore;
    late CollectionReference<Map<String, Object?>> testCollection;

    setUp(() async {
      firestore = await createFirestore();
      testCollection = firestore.collection('write-batch-test');
    });

    group('create()', () {
      test('creates a new document', () async {
        final docRef = testCollection.doc();
        final batch = firestore.batch();
        batch.create(docRef, {'foo': 'bar'});
        await batch.commit();

        final snapshot = await docRef.get();
        expect(snapshot.exists, isTrue);
        expect(snapshot.data(), {'foo': 'bar'});
      });

      test('returns WriteResult with valid writeTime', () async {
        final time = DateTime.now().toUtc().millisecondsSinceEpoch - 5000;
        final docRef = testCollection.doc();

        final batch = firestore.batch();
        batch.create(docRef, {'foo': 'bar'});
        final results = await batch.commit();

        expect(results, hasLength(1));
        expect(results[0].writeTime.seconds * 1000, greaterThan(time));
      });

      test('fails if document already exists', () async {
        final docRef = testCollection.doc();
        await docRef.set({'foo': 'bar'});

        final batch = firestore.batch();
        batch.create(docRef, {'foo': 'baz'});

        await expectLater(batch.commit(), throwsA(isA<FirestoreException>()));
      });

      test('supports field transforms', () async {
        final time = DateTime.now().toUtc().millisecondsSinceEpoch - 5000;
        final docRef = testCollection.doc();

        final batch = firestore.batch();
        batch.create(docRef, {'createdAt': FieldValue.serverTimestamp});
        await batch.commit();

        final snapshot = await docRef.get();
        expect(
          (snapshot.data()!['createdAt']! as Timestamp).seconds * 1000,
          greaterThan(time),
        );
      });

      test('multiple creates in one batch', () async {
        final docRef1 = testCollection.doc('multi-create-1');
        final docRef2 = testCollection.doc('multi-create-2');
        final docRef3 = testCollection.doc('multi-create-3');

        final batch = firestore.batch();
        batch.create(docRef1, {'value': 1});
        batch.create(docRef2, {'value': 2});
        batch.create(docRef3, {'value': 3});
        final results = await batch.commit();

        expect(results, hasLength(3));
        expect((await docRef1.get()).data(), {'value': 1});
        expect((await docRef2.get()).data(), {'value': 2});
        expect((await docRef3.get()).data(), {'value': 3});
      });

      test('throws StateError if batch already committed', () async {
        final docRef = testCollection.doc();
        final batch = firestore.batch();
        batch.create(docRef, {'foo': 'bar'});
        await batch.commit();

        expect(
          () => batch.create(testCollection.doc(), {'foo': 'baz'}),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('update()', () {
      test('updates fields of an existing document', () async {
        final docRef = testCollection.doc();
        await docRef.set({'foo': 'bar', 'baz': 'qux'});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'updated',
        });
        await batch.commit();

        final snapshot = await docRef.get();
        expect(snapshot.data(), {'foo': 'updated', 'baz': 'qux'});
      });

      test('returns WriteResult with valid writeTime', () async {
        final time = DateTime.now().toUtc().millisecondsSinceEpoch - 5000;
        final docRef = testCollection.doc();
        await docRef.set({'foo': 'bar'});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'updated',
        });
        final results = await batch.commit();

        expect(results, hasLength(1));
        expect(results[0].writeTime.seconds * 1000, greaterThan(time));
      });

      test('fails if document does not exist', () async {
        final docRef = testCollection.doc();

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'bar',
        });

        await expectLater(batch.commit(), throwsA(isA<FirestoreException>()));
      });

      test('only updates specified fields', () async {
        final docRef = testCollection.doc();
        await docRef.set({'foo': 'original', 'bar': 'untouched'});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'changed',
        });
        await batch.commit();

        final snapshot = await docRef.get();
        expect(snapshot.data()!['foo'], 'changed');
        expect(snapshot.data()!['bar'], 'untouched');
      });

      test('supports nested fields via FieldPath', () async {
        final docRef = testCollection.doc();
        await docRef.set({
          'nested': {'a': 1, 'b': 2},
        });

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['nested', 'a']): 99,
        });
        await batch.commit();

        final snapshot = await docRef.get();
        expect(snapshot.data(), {
          'nested': {'a': 99, 'b': 2},
        });
      });

      test('supports field transforms', () async {
        final time = DateTime.now().toUtc().millisecondsSinceEpoch - 5000;
        final docRef = testCollection.doc();
        await docRef.set({'count': 1});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['count']): const FieldValue.increment(5),
          FieldPath(const ['updatedAt']): FieldValue.serverTimestamp,
        });
        await batch.commit();

        final snapshot = await docRef.get();
        expect(snapshot.data()!['count'], 6);
        expect(
          (snapshot.data()!['updatedAt']! as Timestamp).seconds * 1000,
          greaterThan(time),
        );
      });

      test('with valid Precondition.timestamp', () async {
        final docRef = testCollection.doc();
        final writeResult = await docRef.set({'foo': 'bar'});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'updated',
        }, precondition: Precondition.timestamp(writeResult.writeTime));

        await expectLater(batch.commit(), completes);
      });

      test(
        'with invalid Precondition.timestamp throws FirestoreException',
        () async {
          final docRef = testCollection.doc();
          await docRef.set({'foo': 'bar'});

          final futureTime = Timestamp.fromMillis(
            DateTime.now().toUtc().millisecondsSinceEpoch + 5000,
          );

          final batch = firestore.batch();
          batch.update(docRef, {
            FieldPath(const ['foo']): 'updated',
          }, precondition: Precondition.timestamp(futureTime));

          await expectLater(batch.commit(), throwsA(isA<FirestoreException>()));
        },
      );

      test('multiple updates in one batch', () async {
        final docRef1 = testCollection.doc('multi-update-1');
        final docRef2 = testCollection.doc('multi-update-2');
        await docRef1.set({'value': 1});
        await docRef2.set({'value': 2});

        final batch = firestore.batch();
        batch.update(docRef1, {
          FieldPath(const ['value']): 10,
        });
        batch.update(docRef2, {
          FieldPath(const ['value']): 20,
        });
        final results = await batch.commit();

        expect(results, hasLength(2));
        expect((await docRef1.get()).data()!['value'], 10);
        expect((await docRef2.get()).data()!['value'], 20);
      });

      test('throws ArgumentError for empty update map', () {
        final docRef = testCollection.doc();

        expect(
          () => firestore.batch().update(docRef, {}),
          throwsArgumentError(message: 'At least one field must be updated.'),
        );
      });

      test('throws StateError if batch already committed', () async {
        final docRef = testCollection.doc();
        await docRef.set({'foo': 'bar'});

        final batch = firestore.batch();
        batch.update(docRef, {
          FieldPath(const ['foo']): 'updated',
        });
        await batch.commit();

        expect(
          () => batch.update(docRef, {
            FieldPath(const ['foo']): 'again',
          }),
          throwsA(isA<StateError>()),
        );
      });

      test(
        'throws ArgumentError when a field and its ancestor are both set',
        () {
          // e.g. setting 'a' and 'a.b' at the same time is ambiguous
          final batch = firestore.batch();
          final docRef = testCollection.doc();

          expect(
            () => batch.update(docRef, {
              FieldPath(const ['a']): 1,
              FieldPath(const ['a', 'b']): 2,
            }),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('was specified multiple times'),
              ),
            ),
          );
        },
      );
    });

    group('reset()', () {
      test('allows adding operations after a committed batch', () async {
        final docRef1 = testCollection.doc('reset-doc-1');
        final docRef2 = testCollection.doc('reset-doc-2');

        final batch = firestore.batch();
        batch.create(docRef1, {'value': 1});
        await batch.commit();

        // After reset, the batch should accept new operations
        batch.reset();
        batch.create(docRef2, {'value': 2});
        await batch.commit();

        expect((await docRef2.get()).data(), {'value': 2});
      });

      test('clears pending operations', () async {
        final docRef = testCollection.doc();

        final batch = firestore.batch();
        batch.create(docRef, {'value': 1});

        batch.reset(); // Clears the pending create

        // Committing an empty batch after reset should succeed with no writes
        final results = await batch.commit();
        expect(results, isEmpty);
      });
    });

    group('commit()', () {
      test('committing an empty batch returns empty results', () async {
        final batch = firestore.batch();
        final results = await batch.commit();
        expect(results, isEmpty);
      });
    });
  });
}
