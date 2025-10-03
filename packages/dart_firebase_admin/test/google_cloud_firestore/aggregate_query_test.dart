import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

import 'util/helpers.dart';

void main() {
  group('AggregateQuery', () {
    late Firestore firestore;
    late CollectionReference<DocumentData> collection;

    setUp(() async {
      firestore = await createFirestore();
      collection = firestore.collection(
          'aggregate-test-${DateTime.now().millisecondsSinceEpoch}');
    });

    test('count() on empty collection returns 0', () async {
      final query = collection.where('foo', WhereFilter.equal, 'bar');
      final aggregateQuery = query.count();
      final snapshot = await aggregateQuery.get();

      expect(snapshot.count, 0);
    });

    test('count() returns correct count for matching documents', () async {
      // Add some test documents
      await collection.add({'name': 'Alice', 'age': 30});
      await collection.add({'name': 'Bob', 'age': 25});
      await collection.add({'name': 'Charlie', 'age': 30});
      await collection.add({'name': 'David', 'age': 35});

      // Test count without filter
      final allCount = await collection.count().get();
      expect(allCount.count, 4);

      // Test count with filter
      final filtered =
          await collection.where('age', WhereFilter.equal, 30).count().get();
      expect(filtered.count, 2);
    });

    test('count() works with complex queries', () async {
      // Add test documents
      await collection
          .add({'category': 'books', 'price': 15.99, 'inStock': true});
      await collection
          .add({'category': 'books', 'price': 25.99, 'inStock': false});
      await collection
          .add({'category': 'books', 'price': 9.99, 'inStock': true});
      await collection
          .add({'category': 'electronics', 'price': 199.99, 'inStock': true});
      await collection
          .add({'category': 'electronics', 'price': 299.99, 'inStock': false});

      // Test with multiple where conditions
      final query = collection
          .where('category', WhereFilter.equal, 'books')
          .where('inStock', WhereFilter.equal, true);
      final count = await query.count().get();
      expect(count.count, 2);

      // Test with range query
      final rangeQuery = collection
          .where('price', WhereFilter.greaterThanOrEqual, 20)
          .where('price', WhereFilter.lessThan, 200);
      final rangeCount = await rangeQuery.count().get();
      expect(rangeCount.count, 2);
    });

    test('count() works with orderBy and limit', () async {
      // Add test documents
      for (var i = 1; i <= 10; i++) {
        await collection.add({'value': i});
      }

      // Test with limit
      final limitQuery = collection.orderBy('value').limit(5);
      final limitCount = await limitQuery.count().get();
      expect(limitCount.count, 5);

      // Test with limitToLast
      final limitToLastQuery = collection.orderBy('value').limitToLast(3);
      final limitToLastCount = await limitToLastQuery.count().get();
      expect(limitToLastCount.count, 3);
    });

    test('count() works with startAt and endAt', () async {
      // Add test documents
      for (var i = 1; i <= 10; i++) {
        await collection.add({'value': i});
      }

      // Test with startAt
      final startAtQuery = collection.orderBy('value').startAt([5]);
      final startAtCount = await startAtQuery.count().get();
      expect(startAtCount.count, 6); // values 5-10

      // Test with endBefore
      final endBeforeQuery = collection.orderBy('value').endBefore([7]);
      final endBeforeCount = await endBeforeQuery.count().get();
      expect(endBeforeCount.count, 6); // values 1-6

      // Test with both startAfter and endAt
      final rangeQuery = collection.orderBy('value').startAfter([3]).endAt([8]);
      final rangeCount = await rangeQuery.count().get();
      expect(rangeCount.count, 5); // values 4-8
    });

    test('count() works with collection groups', () async {
      // Create documents with subcollections
      final doc1 = collection.doc('doc1');
      final doc2 = collection.doc('doc2');

      await doc1.set({'type': 'parent'});
      await doc2.set({'type': 'parent'});

      await doc1.collection('items').add({'name': 'item1'});
      await doc1.collection('items').add({'name': 'item2'});
      await doc2.collection('items').add({'name': 'item3'});

      // Count collection group
      final collectionGroup = firestore.collectionGroup('items');
      final groupCount = await collectionGroup.count().get();
      expect(groupCount.count, 3);
    });

    test('AggregateQuerySnapshot provides readTime', () async {
      await collection.add({'test': true});

      final snapshot = await collection.count().get();
      expect(snapshot.count, 1);
      expect(snapshot.readTime, isNotNull);
    });

    test('AggregateQuery equality', () {
      final query1 = collection.where('foo', WhereFilter.equal, 'bar');
      final query2 = collection.where('foo', WhereFilter.equal, 'bar');
      final query3 = collection.where('foo', WhereFilter.equal, 'baz');

      final aggregate1 = query1.count();
      final aggregate2 = query2.count();
      final aggregate3 = query3.count();

      expect(aggregate1, equals(aggregate2));
      expect(aggregate1, isNot(equals(aggregate3)));
      expect(aggregate1.hashCode, equals(aggregate2.hashCode));
    });

    test('AggregateQuerySnapshot equality', () async {
      await collection.add({'test': true});

      final aggregate = collection.count();
      final snapshot1 = await aggregate.get();
      final snapshot2 = await aggregate.get();

      // Note: These won't be equal because readTime will be different
      // But we can test the structure
      expect(snapshot1.query, equals(snapshot2.query));
      expect(snapshot1.count, equals(snapshot2.count));
    });

    test('count() with composite filters', () async {
      await collection.add({'a': 1, 'b': 'x'});
      await collection.add({'a': 2, 'b': 'y'});
      await collection.add({'a': 3, 'b': 'x'});
      await collection.add({'a': 1, 'b': 'y'});

      // Test AND filter
      final andFilter = Filter.and([
        Filter.where('a', WhereFilter.greaterThan, 1),
        Filter.where('b', WhereFilter.equal, 'x'),
      ]);
      final andCount = await collection.whereFilter(andFilter).count().get();
      expect(andCount.count, 1); // Only {a: 3, b: 'x'} matches

      // Test OR filter
      final orFilter = Filter.or([
        Filter.where('a', WhereFilter.equal, 1),
        Filter.where('b', WhereFilter.equal, 'y'),
      ]);
      final orCount = await collection.whereFilter(orFilter).count().get();
      expect(
          orCount.count, 3); // {a: 1, b: 'x'}, {a: 2, b: 'y'}, {a: 1, b: 'y'}
    });

    test('getField() returns correct values', () async {
      await collection.add({'test': true});

      final snapshot = await collection.count().get();
      expect(snapshot.getField('count'), equals(snapshot.count));
      expect(snapshot.getField('nonexistent'), isNull);
    });
  });
}
