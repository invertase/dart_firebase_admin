// Copyright 2024 Google LLC
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

void main() {
  group('Firestore', () {
    late Firestore firestore;

    setUp(() async => firestore = await createFirestore());

    group('recursiveDelete() integration tests', () {
      late CollectionReference<DocumentData> randomCol;

      // Declare both functions first for mutual recursion
      late final Future<int> Function(DocumentReference<Object?>)
      countDocumentChildren;
      late final Future<int> Function(CollectionReference<Object?>)
      countCollectionChildren;

      // Now define them
      countDocumentChildren = (ref) async {
        var count = 0;
        final collections = await ref.listCollections();
        for (final collection in collections) {
          count += await countCollectionChildren(collection);
        }
        return count;
      };

      countCollectionChildren = (ref) async {
        var count = 0;
        final docs = await ref.listDocuments();
        for (final doc in docs) {
          count += (await countDocumentChildren(doc)) + 1;
        }
        return count;
      };

      setUp(() async {
        randomCol = firestore.collection(
          'recursiveDelete-${DateTime.now().millisecondsSinceEpoch}',
        );

        final batch = firestore.batch();
        batch.set(randomCol.doc('anna'), {'name': 'anna'});
        batch.set(randomCol.doc('bob'), {'name': 'bob'});
        batch.set(randomCol.doc('bob/parentsCol/charlie'), {'name': 'charlie'});
        batch.set(randomCol.doc('bob/parentsCol/daniel'), {'name': 'daniel'});
        batch.set(randomCol.doc('bob/parentsCol/daniel/childCol/ernie'), {
          'name': 'ernie',
        });
        batch.set(randomCol.doc('bob/parentsCol/daniel/childCol/francis'), {
          'name': 'francis',
        });
        await batch.commit();
      });

      test('on top-level collection', () async {
        await firestore.recursiveDelete(randomCol);
        expect(await countCollectionChildren(randomCol), equals(0));
      });

      test('on nested collection', () async {
        final coll = randomCol.doc('bob').collection('parentsCol');
        await firestore.recursiveDelete(coll);

        expect(await countCollectionChildren(coll), equals(0));
        expect(await countCollectionChildren(randomCol), equals(2));
      });

      test('on nested document', () async {
        final doc = randomCol.doc('bob/parentsCol/daniel');
        await firestore.recursiveDelete(doc);

        final docSnap = await doc.get();
        expect(docSnap.exists, isFalse);
        expect(await countDocumentChildren(randomCol.doc('bob')), equals(1));
        expect(await countCollectionChildren(randomCol), equals(3));
      });

      test('on leaf document', () async {
        final doc = randomCol.doc('bob/parentsCol/daniel/childCol/ernie');
        await firestore.recursiveDelete(doc);

        final docSnap = await doc.get();
        expect(docSnap.exists, isFalse);
        expect(await countCollectionChildren(randomCol), equals(5));
      });

      test('does not affect other collections', () async {
        // Add other nested collection that shouldn't be deleted.
        final collB = firestore.collection(
          'doggos-${DateTime.now().millisecondsSinceEpoch}',
        );
        await collB.doc('doggo').set({'name': 'goodboi'});

        await firestore.recursiveDelete(collB);
        expect(await countCollectionChildren(randomCol), equals(6));
        expect(await countCollectionChildren(collB), equals(0));
      });

      test('with custom BulkWriter instance', () async {
        final bulkWriter = firestore.bulkWriter();
        var callbackCount = 0;
        bulkWriter.onWriteResult((ref, result) {
          callbackCount++;
        });
        await firestore.recursiveDelete(randomCol, bulkWriter);
        expect(callbackCount, equals(6));
        await bulkWriter.close();
      });

      test('throws for invalid reference type', () {
        expect(
          () => firestore.recursiveDelete('invalid'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
