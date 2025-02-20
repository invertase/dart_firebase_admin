import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

void main() {
  group('collectionGroup', () {
    late Firestore firestore;

    setUp(() => firestore = createFirestore());

    test('throws if collectionId contains "/"', () {
      expect(
        () => firestore.collectionGroup('my-group/docA'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Invalid collectionId "my-group/docA". '
                'Collection IDs must not contain "/".',
          ),
        ),
      );
    });

    test('supports withConverter', () async {
      await Future.wait([
        firestore.doc('with-converter-group/docA').set({'value': 42}),
        firestore.doc('abc/def/with-converter-group/docB').set({'value': 13}),
        firestore.doc('abc/def/with-converter-group/docC').set({'value': 10}),
      ]);

      final group =
          firestore.collectionGroup('with-converter-group').withConverter(
                fromFirestore: (firestore) => firestore.data()['value']! as num,
                toFirestore: (value) => {'value': value},
              );

      final query = group.where('value', WhereFilter.greaterThan, 12);
      final snapshot = await query.get();

      expect(snapshot.docs, hasLength(2));
      expect(snapshot.docs[0].data(), 13);
      expect(snapshot.docs[1].data(), 42);
    });

    test('defaults to JSON decoding', () async {
      await Future.wait([
        firestore.doc('group/docA').set({'value': 42}),
        firestore.doc('abc/def/group/docB').set({'value': 13}),
        firestore.doc('abc/def/group/docC').set({'value': 10}),
      ]);

      final group = firestore.collectionGroup('group');

      final query = group.where('value', WhereFilter.greaterThan, 12);
      final snapshot = await query.get();

      expect(snapshot.docs, hasLength(2));
      expect(snapshot.docs[0].data(), {'value': 13});
      expect(snapshot.docs[1].data(), {'value': 42});
    });
  });
}
