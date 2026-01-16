import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

import 'helpers.dart';

const testBundleId = 'test-bundle';
const testBundleVersion = 1;

/// Helper function to parse a length-prefixed bundle buffer into elements.
List<Map<String, dynamic>> bundleToElementArray(Uint8List buffer) {
  final elements = <Map<String, dynamic>>[];
  var offset = 0;
  final str = utf8.decode(buffer);

  while (offset < str.length) {
    // Read the length prefix
    final lengthBuffer = StringBuffer();
    while (offset < str.length &&
        str.codeUnitAt(offset) >= '0'.codeUnitAt(0) &&
        str.codeUnitAt(offset) <= '9'.codeUnitAt(0)) {
      lengthBuffer.write(str[offset]);
      offset++;
    }

    final lengthStr = lengthBuffer.toString();
    if (lengthStr.isEmpty) break;

    final length = int.parse(lengthStr);
    if (offset + length > str.length) break;

    // Read the JSON content
    final jsonStr = str.substring(offset, offset + length);
    offset += length;

    elements.add(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  return elements;
}

/// Integration tests for BundleBuilder.
///
/// These tests require the Firestore emulator to be running.
/// Start it with: firebase emulators:start --only firestore
void main() {
  // Skip all tests if emulator is not configured
  if (!isFirestoreEmulatorEnabled()) {
    // ignore: avoid_print
    print(
      'Skipping Bundle integration tests. '
      'Set FIRESTORE_EMULATOR_HOST environment variable to run these tests.',
    );
    return;
  }

  group('BundleBuilder Integration Tests', () {
    late Firestore firestore;

    setUp(() async {
      firestore = await createFirestore();
    });

    test('succeeds with document snapshots', () async {
      final bundle = BundleBuilder(testBundleId);

      // Create test documents
      final doc1Ref = firestore.collection('test-bundle').doc('doc1');
      await doc1Ref.set({'foo': 'value', 'bar': 42});

      final doc2Ref = firestore.collection('test-bundle').doc('doc2');
      await doc2Ref.set({'baz': 'other-value', 'qux': -42});

      // Get snapshots
      final snap1 = await doc1Ref.get();
      final snap2 = await doc2Ref.get();

      // Add to bundle
      bundle.addDocument(snap1);
      bundle.addDocument(snap2);

      // Build and verify
      final elements = bundleToElementArray(bundle.build());

      // Should have: metadata + (doc1Meta + doc1) + (doc2Meta + doc2) = 5 elements
      expect(elements.length, equals(5));

      // Verify metadata
      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      expect(meta['id'], equals(testBundleId));
      expect(meta['version'], equals(testBundleVersion));
      expect(meta['totalDocuments'], equals(2));
      expect(int.parse(meta['totalBytes'] as String), greaterThan(0));

      // Verify documents are present
      final docNames = elements
          .where((e) => e.containsKey('document'))
          .map((e) => (e['document'] as Map<String, dynamic>)['name'])
          .toList();

      expect(docNames.length, equals(2));

      // Clean up
      await doc1Ref.delete();
      await doc2Ref.delete();
    });

    test('succeeds with query snapshots', () async {
      final bundle = BundleBuilder(testBundleId);

      // Create test documents
      final collection = firestore.collection('test-bundle-query');
      await collection.doc('doc1').set({'value': 'test', 'count': 1});
      await collection.doc('doc2').set({'value': 'test', 'count': 2});
      await collection.doc('doc3').set({'value': 'other', 'count': 3});

      // Create query
      final query = collection.where('value', WhereFilter.equal, 'test');
      final querySnapshot = await query.get();

      // Add query to bundle
      bundle.addQuery('test-query', querySnapshot);

      // Build and verify
      final elements = bundleToElementArray(bundle.build());

      // Should have: metadata + namedQuery + (doc1Meta + doc1) + (doc2Meta + doc2) = 6 elements
      expect(elements.length, equals(6));

      // Verify named query exists
      final namedQuery =
          elements.firstWhere((e) => e.containsKey('namedQuery'))['namedQuery']
              as Map<String, dynamic>;

      expect(namedQuery['name'], equals('test-query'));

      // Verify documents have queries array
      final docsWithQueries = elements
          .where(
            (e) =>
                e.containsKey('documentMetadata') &&
                (e['documentMetadata'] as Map<String, dynamic>).containsKey(
                  'queries',
                ),
          )
          .toList();

      expect(docsWithQueries.length, equals(2));

      for (final doc in docsWithQueries) {
        final queries =
            (doc['documentMetadata'] as Map<String, dynamic>)['queries']
                as List;
        expect(queries, contains('test-query'));
      }

      // Clean up
      await collection.doc('doc1').delete();
      await collection.doc('doc2').delete();
      await collection.doc('doc3').delete();
    });

    test('handles same document from multiple queries', () async {
      final bundle = BundleBuilder(testBundleId);

      // Create test document
      final collection = firestore.collection('test-bundle-multi-query');
      await collection.doc('doc1').set({'value': 'test', 'count': 10});

      // Create two queries that both include the same document
      final query1 = collection.where('value', WhereFilter.equal, 'test');
      final query2 = collection.where(
        'count',
        WhereFilter.greaterThanOrEqual,
        5,
      );

      final querySnapshot1 = await query1.get();
      final querySnapshot2 = await query2.get();

      // Add both queries
      bundle.addQuery('query1', querySnapshot1);
      bundle.addQuery('query2', querySnapshot2);

      // Build and verify
      final elements = bundleToElementArray(bundle.build());

      // Verify the document metadata has both queries
      final docMeta =
          elements.firstWhere(
                (e) => e.containsKey('documentMetadata'),
              )['documentMetadata']
              as Map<String, dynamic>;

      final queries = List<String>.from(docMeta['queries'] as List);
      queries.sort();
      expect(queries, equals(['query1', 'query2']));

      // Should only have one document element (not duplicated)
      final docCount = elements.where((e) => e.containsKey('document')).length;
      expect(docCount, equals(1));

      // Clean up
      await collection.doc('doc1').delete();
    });

    test('throws when query name already exists', () async {
      final bundle = BundleBuilder(testBundleId);

      final collection = firestore.collection('test-bundle-duplicate');
      await collection.doc('doc1').set({'value': 'test'});

      final query = collection.where('value', WhereFilter.equal, 'test');
      final querySnapshot = await query.get();

      bundle.addQuery('duplicate-name', querySnapshot);

      expect(
        () => bundle.addQuery('duplicate-name', querySnapshot),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Query name conflict'),
          ),
        ),
      );

      // Clean up
      await collection.doc('doc1').delete();
    });

    test('handles non-existent documents', () async {
      final bundle = BundleBuilder(testBundleId);

      // Get a non-existent document
      final docRef = firestore.collection('test-bundle').doc('non-existent');
      final snap = await docRef.get();

      expect(snap.exists, isFalse);

      // Add to bundle
      bundle.addDocument(snap);

      // Build and verify
      final elements = bundleToElementArray(bundle.build());

      // Should have: metadata + docMeta (no document since it doesn't exist)
      expect(elements.length, equals(2));

      final docMeta = elements[1]['documentMetadata'] as Map<String, dynamic>;
      expect(docMeta['exists'], equals(false));

      // Should not have a document element
      final hasDocument = elements.any((e) => e.containsKey('document'));
      expect(hasDocument, isFalse);
    });

    test('handles documents from different collections with same ID', () async {
      final bundle = BundleBuilder(testBundleId);

      // Create documents with same ID in different collections
      final doc1Ref = firestore.collection('collectionA').doc('same-id');
      await doc1Ref.set({'source': 'A'});

      final doc2Ref = firestore.collection('collectionB').doc('same-id');
      await doc2Ref.set({'source': 'B'});

      // Get snapshots
      final snap1 = await doc1Ref.get();
      final snap2 = await doc2Ref.get();

      // Add to bundle
      bundle.addDocument(snap1);
      bundle.addDocument(snap2);

      // Build and verify
      final elements = bundleToElementArray(bundle.build());

      // Should have both documents
      final docs = elements
          .where((e) => e.containsKey('document'))
          .map((e) => e['document'] as Map<String, dynamic>)
          .toList();

      expect(docs.length, equals(2));

      // Verify they have different paths
      final paths = docs.map((d) => d['name']).toSet();
      expect(paths.length, equals(2));

      // Clean up
      await doc1Ref.delete();
      await doc2Ref.delete();
    });
  });
}
