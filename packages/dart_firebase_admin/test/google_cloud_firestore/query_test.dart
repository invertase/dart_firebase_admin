import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

void main() {
  group('query interface', () {
    late Firestore firestore;

    setUp(() => firestore = createInstance());

    test('overrides ==', () {
      final queryA = firestore.collection('col1');
      final queryB = firestore.collection('col1');

      void queryEquals(
        List<Query<Object?>> equals, [
        List<Query<Object?>> notEquals = const [],
      ]) {
        for (var i = 0; i < equals.length; ++i) {
          for (final equal in equals) {
            expect(equals[i], equal);
            expect(equal, equals[i]);
          }

          for (final notEqual in notEquals) {
            expect(equals[i], isNot(notEqual));
            expect(notEqual, isNot(equals[i]));
          }
        }
      }

      queryEquals(
        [
          queryA.where('a', WhereFilter.equal, '1'),
          queryB.where('a', WhereFilter.equal, '1'),
        ],
      );

      queryEquals(
        [
          queryA
              .where('a', WhereFilter.equal, '1')
              .where('b', WhereFilter.equal, 2),
          queryB
              .where('a', WhereFilter.equal, '1')
              .where('b', WhereFilter.equal, 2),
        ],
      );

      queryEquals([
        queryA.orderBy('__name__'),
        queryA.orderBy('__name__', descending: false),
        queryB.orderBy(FieldPath.documentId),
      ], [
        queryA.orderBy('foo'),
        queryB.orderBy(FieldPath.documentId, descending: true),
      ]);

      queryEquals(
        [queryA.limit(0), queryB.limit(0).limit(0)],
        [queryA, queryB.limit(10)],
      );

      queryEquals(
        [queryA.offset(0), queryB.offset(0).offset(0)],
        [queryA, queryB.offset(10)],
      );

      queryEquals([
        queryA.orderBy('foo').startAt(['a']),
        queryB.orderBy('foo').startAt(['a']),
      ], [
        queryA.orderBy('foo').startAfter(['a']),
        queryB.orderBy('foo').endAt(['a']),
        queryA.orderBy('foo').endBefore(['a']),
        queryB.orderBy('foo').startAt(['b']),
        queryA.orderBy('bar').startAt(['a']),
      ]);

      queryEquals([
        queryA.orderBy('foo').startAfter(['a']),
        queryB.orderBy('foo').startAfter(['a']),
      ], [
        queryA.orderBy('foo').startAfter(['b']),
        queryB.orderBy('bar').startAfter(['a']),
      ]);

      queryEquals([
        queryA.orderBy('foo').endBefore(['a']),
        queryB.orderBy('foo').endBefore(['a']),
      ], [
        queryA.orderBy('foo').endBefore(['b']),
        queryB.orderBy('bar').endBefore(['a']),
      ]);

      queryEquals(
        [
          queryA.orderBy('foo').endAt(['a']),
          queryB.orderBy('foo').endAt(['a']),
        ],
        [
          queryA.orderBy('foo').endAt(['b']),
          queryB.orderBy('bar').endAt(['a']),
        ],
      );

      queryEquals(
        [
          queryA
              .orderBy('foo')
              .orderBy('__name__')
              .startAt(['b', queryA.doc('c')]),
          queryB
              .orderBy('foo')
              .orderBy('__name__')
              .startAt(['b', queryA.doc('c')]),
        ],
      );
    });
  });
}
