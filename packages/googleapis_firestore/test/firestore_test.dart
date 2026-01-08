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
  });
}
