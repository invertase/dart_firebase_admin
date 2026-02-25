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

    group('map keys with "/" characters', () {
      test('set() round-trips a map with "/" in key', () async {
        final docRef = firestore.doc('activities/new-activity');

        await docRef.set({
          'activityType': 'activityA',
          'agents': {'products/product-a': 5.0},
        });

        final data = (await docRef.get()).data()!;
        expect(data['activityType'], 'activityA');
        expect(
          (data['agents']! as Map<String, Object?>)['products/product-a'],
          5.0,
        );
      });

      test('update() round-trips a map value with "/" in key', () async {
        final docRef = firestore.doc('activities/update-activity');
        await docRef.set({'activityType': 'activityA'});

        await docRef.update({'agents': {'products/product-b': 10.0}});

        final data = (await docRef.get()).data()!;
        expect(
          (data['agents']! as Map<String, Object?>)['products/product-b'],
          10.0,
        );
      });
    });
  });
}
