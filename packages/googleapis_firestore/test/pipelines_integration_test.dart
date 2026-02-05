import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Firestore Pipelines Integration Tests',
    () {
      late Firestore firestore;
      const testCollection = 'pipeline-test-books';

      setUp(() async {
        firestore = Firestore(
          settings: const Settings(
            projectId: 'dart-firebase-admin',
            databaseId: 'dart-admin-enterprise',
          ),
        );

        // Create test data
        final batch = firestore.batch();

        // Add books with tags and categories
        final books = [
          {
            'title': "The Hitchhiker's Guide to the Galaxy",
            'author': 'Douglas Adams',
            'rating': 4.8,
            'price': 12.99,
            'category': 'science-fiction',
            'tags': ['comedy', 'space', 'adventure'],
          },
          {
            'title': '1984',
            'author': 'George Orwell',
            'rating': 4.6,
            'price': 10.99,
            'category': 'dystopian',
            'tags': ['political', 'classic'],
          },
          {
            'title': 'Dune',
            'author': 'Frank Herbert',
            'rating': 4.7,
            'price': 15.99,
            'category': 'science-fiction',
            'tags': ['space', 'politics', 'epic'],
          },
          {
            'title': 'The Hobbit',
            'author': 'J.R.R. Tolkien',
            'rating': 4.9,
            'price': 11.99,
            'category': 'fantasy',
            'tags': ['adventure', 'classic', 'dragons'],
          },
          {
            'title': 'Foundation',
            'author': 'Isaac Asimov',
            'rating': 4.5,
            'price': 13.99,
            'category': 'science-fiction',
            'tags': ['space', 'politics'],
          },
        ];

        for (var i = 0; i < books.length; i++) {
          batch.set(
            firestore.collection(testCollection).doc('book$i'),
            books[i],
          );
        }

        await batch.commit();
      });

      tearDown(() async {
        // Clean up test documents
        final docs = await firestore.collection(testCollection).get();
        final batch = firestore.batch();
        for (final doc in docs.docs) {
          batch.delete(doc.ref);
        }
        await batch.commit();
        await firestore.terminate();
      });

      test('basic pipeline with collection and limit', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .limit(3);

        final snapshot = await pipeline.execute();

        expect(snapshot.results.length, equals(3));
        expect(snapshot.executionTime, isNotNull);
      });

      test('pipeline with where clause and select', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .where(
              Expression.field('rating').greaterThan(Expression.constant(4.6)),
            )
            .select(['title', 'rating']);

        final snapshot = await pipeline.execute();

        expect(snapshot.results.length, greaterThanOrEqualTo(3));
        for (final result in snapshot.results) {
          final data = result.data();
          expect(data.containsKey('title'), isTrue);
          expect(data.containsKey('rating'), isTrue);
          expect(data['rating'], greaterThan(4.6));
        }
      });

      test('pipeline with sort and limit', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .sort([Ordering.descending(Expression.field('rating'))])
            .limit(2);

        final snapshot = await pipeline.execute();

        expect(snapshot.results.length, equals(2));

        // First result should have highest rating
        final firstRating = snapshot.results[0].data()['rating']! as double;
        expect(firstRating, equals(4.9)); // The Hobbit
      });

      test('pipeline with aggregate (count by category)', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .aggregate(
              accumulators: [AggregateFunction.count().as('bookCount')],
              groupBy: [Expression.field('category')],
            );

        final snapshot = await pipeline.execute();

        // Should have 3 groups: science-fiction, dystopian, fantasy
        expect(snapshot.results.length, equals(3));

        // Find science-fiction category
        final sciFiResult = snapshot.results.firstWhere(
          (r) => r.data()['category'] == 'science-fiction',
        );
        expect(sciFiResult.data()['bookCount'], equals(3));
      });

      test('pipeline with aggregate (average rating by category)', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .aggregate(
              accumulators: [
                AggregateFunction.average('rating').as('avgRating'),
                AggregateFunction.count().as('count'),
              ],
              groupBy: [Expression.field('category')],
            )
            .sort([Ordering.descending(Expression.field('avgRating'))]);

        final snapshot = await pipeline.execute();

        expect(snapshot.results.length, equals(3));

        // First result should have highest average rating
        final firstResult = snapshot.results[0].data();
        expect(firstResult.containsKey('avgRating'), isTrue);
        expect(firstResult.containsKey('count'), isTrue);
        expect(firstResult.containsKey('category'), isTrue);
      });

      test('pipeline with unnest (tags)', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .where(
              Expression.field('title').equal(
                Expression.constant("The Hitchhiker's Guide to the Galaxy"),
              ),
            )
            .unnest(
              field: Expression.field('tags').as('tag'),
              indexField: 'tagIndex',
            );

        final snapshot = await pipeline.execute();

        // Should have 3 results (one for each tag)
        expect(snapshot.results.length, equals(3));

        // Check that each result has tag and tagIndex
        for (final result in snapshot.results) {
          final data = result.data();
          expect(data.containsKey('tag'), isTrue);
          expect(data.containsKey('tagIndex'), isTrue);
          expect(
            ['comedy', 'space', 'adventure'].contains(data['tag']),
            isTrue,
          );
        }
      });

      test(
        'complex pipeline: unnest then aggregate (tag count by category)',
        () async {
          final pipeline = firestore
              .pipeline()
              .collection(testCollection)
              .unnest(field: Expression.field('tags').as('tagName'))
              .aggregate(
                accumulators: [AggregateFunction.countAll().as('tagCount')],
                groupBy: [Expression.field('category')],
              )
              .sort([Ordering.descending(Expression.field('tagCount'))])
              .limit(10);

          final snapshot = await pipeline.execute();

          // Should have results grouped by category
          expect(snapshot.results.isNotEmpty, isTrue);

          // Each result should have category and tagCount
          for (final result in snapshot.results) {
            final data = result.data();
            expect(data.containsKey('category'), isTrue);
            expect(data.containsKey('tagCount'), isTrue);
            expect(data['tagCount'], isA<int>());
          }

          // science-fiction should have most tags (3 books * avg 2.67 tags)
          final sciFiResult = snapshot.results.firstWhere(
            (r) => r.data()['category'] == 'science-fiction',
          );
          expect(sciFiResult.data()['tagCount'], greaterThan(5));
        },
      );

      test('pipeline with distinct', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .distinct([Expression.field('category')]);

        final snapshot = await pipeline.execute();

        // Should have 3 distinct categories
        expect(snapshot.results.length, equals(3));

        final categories = snapshot.results
            .map((r) => r.data()['category'])
            .toSet();
        expect(
          categories,
          containsAll(['science-fiction', 'dystopian', 'fantasy']),
        );
      });

      test('pipeline result get() method', () async {
        final pipeline = firestore
            .pipeline()
            .collection(testCollection)
            .limit(1);

        final snapshot = await pipeline.execute();
        final result = snapshot.results.first;

        // Test get() with string field path
        final title = result.get('title');
        expect(title, isNotNull);

        // Test get() with FieldPath
        final rating = result.get(FieldPath(const ['rating']));
        expect(rating, isA<double>());

        // Test get() with nested field path (if any)
        final author = result.get('author');
        expect(author, isNotNull);
      });
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
