import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

void main() {
  group('Firestore', () {
    late Firestore firestore;

    setUp(() => firestore = createFirestore());

    test('listCollections', () async {
      final a = firestore.collection('a');
      final b = firestore.collection('b');

      await a.doc('1').set({'a': 1});
      await b.doc('2').set({'b': 2});

      final collections = await firestore.listCollections();

      expect(collections, unorderedEquals([a, b]));
    });
  });
}
