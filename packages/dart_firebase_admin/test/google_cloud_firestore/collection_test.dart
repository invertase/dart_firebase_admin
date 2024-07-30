import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart' hide throwsArgumentError;

import 'util/helpers.dart';

void main() {
  group('Collection interface', () {
    late Firestore firestore;

    setUp(() => firestore = createFirestore());

    test('has doc() method', () {
      final collection = firestore.collection('colId');

      expect(collection.id, 'colId');
      expect(collection.path, 'colId');

      final documentRef = collection.doc('docId');

      expect(documentRef, isA<DocumentReference<DocumentData>>());
      expect(documentRef.id, 'docId');
      expect(documentRef.path, 'colId/docId');

      expect(
        () => collection.doc(''),
        throwsArgumentError(message: 'Must be a non-empty string'),
      );
      expect(
        () => collection.doc('doc/coll'),
        throwsArgumentError(
          message:
              'Value for argument "documentPath" must point to a document, '
              'but was "doc/coll". '
              'Your path does not contain an even number of components.',
        ),
      );

      expect(
        collection.doc('docId/colId/docId'),
        isA<DocumentReference<DocumentData>>(),
      );
    });

    test('has parent getter', () {
      final collection = firestore.collection('col1/doc/col2');
      expect(collection.path, 'col1/doc/col2');

      final document = collection.parent;
      expect(document!.path, 'col1/doc');
    });

    test('parent returns null for root', () {
      final collection = firestore.collection('col1');

      expect(collection.parent, isNull);
    });

    test('supports auto-generated ids', () {
      final collection = firestore.collection('col1');

      final document = collection.doc();
      expect(document.id, hasLength(20));
    });

    test('has add() method', () async {
      final collection = firestore.collection('addCollection');

      final documentRef = await collection.add({'foo': 'bar'});

      expect(documentRef, isA<DocumentReference<DocumentData>>());
      expect(documentRef.id, hasLength(20));
      expect(documentRef.path, 'addCollection/${documentRef.id}');

      final documentSnapshot = await documentRef.get();

      expect(documentSnapshot.data(), {'foo': 'bar'});
    });

    test('has list() method', () async {
      final collection = firestore.collection('listCollection');

      final a = collection.doc('a');
      await a.set({'foo': 'bar'});

      final b = collection.doc('b');
      await b.set({'baz': 'quaz'});

      final documents = await collection.listDocuments();

      expect(documents, unorderedEquals([a, b]));
    });

    test('override equal', () async {
      final coll1 = firestore.collection('coll1');
      final coll1Equals = firestore.collection('coll1');
      final coll2 = firestore.collection('coll2');

      expect(coll1, coll1Equals);
      expect(coll1, isNot(coll2));
    });

    test('override hashCode', () async {
      final coll1 = firestore.collection('coll1');
      final coll1Equals = firestore.collection('coll1');
      final coll2 = firestore.collection('coll2');

      expect(coll1.hashCode, coll1Equals.hashCode);
      expect(coll1.hashCode, isNot(coll2.hashCode));
    });

    test('for CollectionReference.withConverter().doc()', () async {
      final collection = firestore.collection('withConverterColDoc');

      final rawDoc = collection.doc('doc');

      final docRef = collection
          .withConverter<int>(
            fromFirestore: (snapshot) => snapshot.data()['value']! as int,
            toFirestore: (value) => {'value': value},
          )
          .doc('doc');

      expect(docRef, isA<DocumentReference<int>>());
      expect(docRef.id, 'doc');
      expect(docRef.path, 'withConverterColDoc/doc');

      await docRef.set(42);

      final rawDocSnapshot = await rawDoc.get();
      expect(rawDocSnapshot.data(), {'value': 42});

      final docSnapshot = await docRef.get();
      expect(docSnapshot.data(), 42);
    });

    test('for CollectionReference.withConverter().add()', () async {
      final collection =
          firestore.collection('withConverterColAdd').withConverter<int>(
                fromFirestore: (snapshot) => snapshot.data()['value']! as int,
                toFirestore: (value) => {'value': value},
              );

      expect(collection, isA<CollectionReference<int>>());

      final docRef = await collection.add(42);

      expect(docRef, isA<DocumentReference<int>>());
      expect(docRef.id, hasLength(20));
      expect(docRef.path, 'withConverterColAdd/${docRef.id}');

      final docSnapshot = await docRef.get();
      expect(docSnapshot.data(), 42);
    });

    test('drops the converter when calling CollectionReference<T>.parent()',
        () {
      final collection = firestore
          .collection('withConverterColParent/doc/child')
          .withConverter(
            fromFirestore: (snapshot) => snapshot.data()['value']! as int,
            toFirestore: (value) => {'value': value},
          );

      expect(collection, isA<CollectionReference<int>>());

      final DocumentReference<DocumentData>? parent = collection.parent;

      expect(parent!.path, 'withConverterColParent/doc');
    });
  });
}
