import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Firestore', () {
    late Firestore firestore;

    setUp(() async => firestore = await createFirestore());

    test('listCollections', () async {
      final a = firestore.collection('a');
      final b = firestore.collection('b');

      await a.doc('1').set({'a': 1});
      await b.doc('2').set({'b': 2});

      final collections = await firestore.listCollections();

      expect(collections, containsAll([a, b]));
    });

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

        // ROOT-DB
        // └── randomCol
        //     ├── anna
        //     └── bob
        //         └── parentsCol
        //             ├── charlie
        //             └── daniel
        //                 └── childCol
        //                     ├── ernie
        //                     └── francis
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
