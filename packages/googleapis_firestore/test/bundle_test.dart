import 'dart:convert';
import 'dart:typed_data';
import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:test/test.dart';

const testBundleId = 'test-bundle';
const testBundleVersion = 1;
const databaseRoot = 'projects/test-project/databases/(default)';

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

/// Verifies bundle metadata matches expected values.
void verifyMetadata(
  Map<String, dynamic> meta,
  Timestamp createTime,
  int totalDocuments, {
  bool expectEmptyContent = false,
}) {
  if (!expectEmptyContent) {
    expect(int.parse(meta['totalBytes'] as String), greaterThan(0));
  } else {
    expect(int.parse(meta['totalBytes'] as String), equals(0));
  }
  expect(meta['id'], equals(testBundleId));
  expect(meta['version'], equals(testBundleVersion));
  expect(meta['totalDocuments'], equals(totalDocuments));
  expect(
    meta['createTime'],
    equals({
      'seconds': createTime.seconds.toString(),
      'nanos': createTime.nanoseconds,
    }),
  );
}

void main() {
  group('Bundle Builder', () {
    late Firestore firestore;

    setUp(() {
      firestore = Firestore(
        settings: const Settings(projectId: 'test-project'),
      );
    });

    tearDown(() async {
      await firestore.terminate();
    });

    test('succeeds to read length prefixed json with testing function', () {
      const bundleString =
          '20{"a":"string value"}9{"b":123}26{"c":{"d":"nested value"}}';
      final elements = bundleToElementArray(
        Uint8List.fromList(bundleString.codeUnits),
      );
      expect(
        elements,
        equals([
          {'a': 'string value'},
          {'b': 123},
          {
            'c': {'d': 'nested value'},
          },
        ]),
      );
    });

    test('throws when bundleId is empty', () {
      expect(() => BundleBuilder(''), throwsA(isA<ArgumentError>()));
    });

    test('succeeds with document snapshots', () {
      final bundle = firestore.bundle(testBundleId);

      final snap1 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId/doc1',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        // This should be the bundle read time.
        Timestamp(seconds: 1577840405, nanoseconds: 6),
      );

      // Same document but older read time.
      final snap2 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId/doc1',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '-42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        Timestamp(seconds: 5, nanoseconds: 6),
      );

      bundle.addDocument(snap1);
      bundle.addDocument(snap2);

      // Bundle is expected to be [bundleMeta, snap1Meta, snap1] because snap1 is newer.
      final elements = bundleToElementArray(bundle.build());
      expect(elements.length, equals(3));

      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(
        meta,
        // snap1.readTime is the bundle createTime, because it is larger than snap2.readTime.
        snap1.readTime!,
        1,
      );

      // Verify doc1Meta and doc1Snap
      final docMeta = elements[1]['documentMetadata'] as Map<String, dynamic>;
      final docSnap = elements[2]['document'] as Map<String, dynamic>;
      expect(
        docMeta,
        equals({
          'name': '$databaseRoot/documents/collectionId/doc1',
          'readTime': {
            'seconds': snap1.readTime!.seconds.toString(),
            'nanos': snap1.readTime!.nanoseconds,
          },
          'exists': true,
        }),
      );
      expect(
        docSnap['name'],
        equals('$databaseRoot/documents/collectionId/doc1'),
      );
      expect(docSnap['fields'], isNotNull);
    });

    test('succeeds with query snapshots', () {
      final bundle = firestore.bundle(testBundleId);

      final snap =
          firestore.snapshot_(
                firestore_v1.Document(
                  name: '$databaseRoot/documents/collectionId/doc1',
                  fields: {'foo': firestore_v1.Value(stringValue: 'value')},
                  createTime: '1970-01-01T00:00:01.002Z',
                  updateTime: '1970-01-01T00:00:03.000004Z',
                ),
                Timestamp(seconds: 1577840405, nanoseconds: 6),
              )
              as QueryDocumentSnapshot<Object?>;

      final query = firestore
          .collection('collectionId')
          .where('value', WhereFilter.equal, 'string');
      final querySnapshot = firestore.createQuerySnapshot(
        query: query,
        readTime: snap.readTime!,
        docs: [snap],
      );

      final newQuery = firestore.collection('collectionId');
      final newQuerySnapshot = firestore.createQuerySnapshot(
        query: newQuery,
        readTime: snap.readTime!,
        docs: [snap],
      );

      bundle.addQuery('test-query', querySnapshot);
      bundle.addQuery('test-query-new', newQuerySnapshot);

      // Bundle is expected to be [bundleMeta, namedQuery, newNamedQuery, snapMeta, snap]
      final elements = bundleToElementArray(bundle.build());
      expect(elements.length, equals(5));

      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(meta, snap.readTime!, 1);

      // Verify named query
      final namedQuery =
          elements.firstWhere(
                (e) =>
                    e.containsKey('namedQuery') &&
                    (e['namedQuery'] as Map<String, dynamic>)['name'] ==
                        'test-query',
              )['namedQuery']
              as Map<String, dynamic>;

      final newNamedQuery =
          elements.firstWhere(
                (e) =>
                    e.containsKey('namedQuery') &&
                    (e['namedQuery'] as Map<String, dynamic>)['name'] ==
                        'test-query-new',
              )['namedQuery']
              as Map<String, dynamic>;

      expect(namedQuery['name'], equals('test-query'));
      expect(
        namedQuery['readTime'],
        equals({
          'seconds': snap.readTime!.seconds.toString(),
          'nanos': snap.readTime!.nanoseconds,
        }),
      );

      expect(newNamedQuery['name'], equals('test-query-new'));
      expect(
        newNamedQuery['readTime'],
        equals({
          'seconds': snap.readTime!.seconds.toString(),
          'nanos': snap.readTime!.nanoseconds,
        }),
      );

      // Verify docMeta and docSnap
      final docMeta = elements[3]['documentMetadata'] as Map<String, dynamic>;
      final docSnap = elements[4]['document'] as Map<String, dynamic>;

      final queries = List<String>.from(docMeta['queries'] as List)..sort();
      expect(
        docMeta['name'],
        equals('$databaseRoot/documents/collectionId/doc1'),
      );
      expect(
        docMeta['readTime'],
        equals({
          'seconds': snap.readTime!.seconds.toString(),
          'nanos': snap.readTime!.nanoseconds,
        }),
      );
      expect(docMeta['exists'], equals(true));
      expect(queries, equals(['test-query', 'test-query-new']));
      expect(
        docSnap['name'],
        equals('$databaseRoot/documents/collectionId/doc1'),
      );
    });

    test('succeeds with multiple calls to build()', () {
      final bundle = firestore.bundle(testBundleId);

      final snap1 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId/doc1',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        Timestamp(seconds: 1577840405, nanoseconds: 6),
      );

      bundle.addDocument(snap1);

      // Bundle is expected to be [bundleMeta, doc1Meta, doc1Snap].
      final elements = bundleToElementArray(bundle.build());
      expect(elements.length, equals(3));

      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(meta, snap1.readTime!, 1);

      // Verify doc1Meta and doc1Snap
      final doc1Meta = elements[1]['documentMetadata'] as Map<String, dynamic>;
      final doc1Snap = elements[2]['document'] as Map<String, dynamic>;
      expect(
        doc1Meta,
        equals({
          'name': '$databaseRoot/documents/collectionId/doc1',
          'readTime': {
            'seconds': snap1.readTime!.seconds.toString(),
            'nanos': snap1.readTime!.nanoseconds,
          },
          'exists': true,
        }),
      );
      expect(
        doc1Snap['name'],
        equals('$databaseRoot/documents/collectionId/doc1'),
      );

      // Add another document
      final snap2 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId/doc2',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '-42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        Timestamp(seconds: 5, nanoseconds: 6),
      );

      bundle.addDocument(snap2);

      // Bundle is expected to be [bundleMeta, doc1Meta, doc1Snap, doc2Meta, doc2Snap].
      final newElements = bundleToElementArray(bundle.build());
      expect(newElements.length, equals(5));

      final newMeta = newElements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(newMeta, snap1.readTime!, 2);

      expect(newElements.sublist(1, 3), equals(elements.sublist(1)));

      // Verify doc2Meta and doc2Snap
      final doc2Meta =
          newElements[3]['documentMetadata'] as Map<String, dynamic>;
      final doc2Snap = newElements[4]['document'] as Map<String, dynamic>;
      expect(
        doc2Meta,
        equals({
          'name': '$databaseRoot/documents/collectionId/doc2',
          'readTime': {
            'seconds': snap2.readTime!.seconds.toString(),
            'nanos': snap2.readTime!.nanoseconds,
          },
          'exists': true,
        }),
      );
      expect(
        doc2Snap['name'],
        equals('$databaseRoot/documents/collectionId/doc2'),
      );
    });

    test('succeeds when nothing is added', () {
      final bundle = firestore.bundle(testBundleId);

      final elements = bundleToElementArray(bundle.build());
      expect(elements.length, equals(1));

      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(
        meta,
        Timestamp(seconds: 0, nanoseconds: 0),
        0,
        expectEmptyContent: true,
      );
    });

    test('handles identical document id from different collections', () {
      final bundle = firestore.bundle(testBundleId);

      final snap1 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId_A/doc1',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        Timestamp(seconds: 1577840405, nanoseconds: 6),
      );

      // Same document id but different collection
      final snap2 = firestore.snapshot_(
        firestore_v1.Document(
          name: '$databaseRoot/documents/collectionId_B/doc1',
          fields: {
            'foo': firestore_v1.Value(stringValue: 'value'),
            'bar': firestore_v1.Value(integerValue: '-42'),
          },
          createTime: '1970-01-01T00:00:01.002Z',
          updateTime: '1970-01-01T00:00:03.000004Z',
        ),
        Timestamp(seconds: 5, nanoseconds: 6),
      );

      bundle.addDocument(snap1);
      bundle.addDocument(snap2);

      // Bundle is expected to be [bundleMeta, snap1Meta, snap1, snap2Meta, snap2] because snap1 is newer.
      final elements = bundleToElementArray(bundle.build());
      expect(elements.length, equals(5));

      final meta = elements[0]['metadata'] as Map<String, dynamic>;
      verifyMetadata(meta, snap1.readTime!, 2);

      // Verify doc1Meta and doc1Snap
      var docMeta = elements[1]['documentMetadata'] as Map<String, dynamic>;
      var docSnap = elements[2]['document'] as Map<String, dynamic>;
      expect(
        docMeta,
        equals({
          'name': '$databaseRoot/documents/collectionId_A/doc1',
          'readTime': {
            'seconds': snap1.readTime!.seconds.toString(),
            'nanos': snap1.readTime!.nanoseconds,
          },
          'exists': true,
        }),
      );
      expect(
        docSnap['name'],
        equals('$databaseRoot/documents/collectionId_A/doc1'),
      );

      // Verify doc2Meta and doc2Snap
      docMeta = elements[3]['documentMetadata'] as Map<String, dynamic>;
      docSnap = elements[4]['document'] as Map<String, dynamic>;
      expect(
        docMeta,
        equals({
          'name': '$databaseRoot/documents/collectionId_B/doc1',
          'readTime': {
            'seconds': snap2.readTime!.seconds.toString(),
            'nanos': snap2.readTime!.nanoseconds,
          },
          'exists': true,
        }),
      );
      expect(
        docSnap['name'],
        equals('$databaseRoot/documents/collectionId_B/doc1'),
      );
    });
  });
}
