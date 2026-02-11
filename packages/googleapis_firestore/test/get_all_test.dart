import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:googleapis_firestore/src/firestore_http_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

const projectId = 'test-project';

class MockFirestoreHttpClient extends Mock implements FirestoreHttpClient {}

firestore_v1.BatchGetDocumentsResponseElement createFoundResponse({
  required String documentPath,
  required Map<String, Object?> fields,
  required Firestore firestore,
}) {
  return firestore_v1.BatchGetDocumentsResponseElement()
    ..found = (firestore_v1.Document()
      ..name = 'projects/$projectId/databases/(default)/documents/$documentPath'
      ..fields = fields.map((key, value) {
        // Use SDK's serializer to properly encode values
        final encoded = firestore.serializer.encodeValue(value);
        return MapEntry(key, encoded!);
      })
      ..createTime = DateTime.now().toUtc().toIso8601String()
      ..updateTime = DateTime.now().toUtc().toIso8601String())
    ..readTime = DateTime.now().toUtc().toIso8601String();
}

firestore_v1.BatchGetDocumentsResponseElement createMissingResponse(
  String documentPath,
) {
  return firestore_v1.BatchGetDocumentsResponseElement()
    ..missing =
        'projects/$projectId/databases/(default)/documents/$documentPath'
    ..readTime = DateTime.now().toUtc().toIso8601String();
}

void main() {
  group('Firestore.getAll()', () {
    late MockFirestoreHttpClient mockClient;
    late Firestore firestore;

    setUp(() {
      mockClient = MockFirestoreHttpClient();
      firestore = Firestore.internal(
        settings: const Settings(projectId: projectId),
        client: mockClient,
      );

      when(() => mockClient.cachedProjectId).thenReturn(projectId);
    });

    test('accepts single document', () async {
      when(
        () => mockClient
            .v1<List<firestore_v1.BatchGetDocumentsResponseElement>>(any()),
      ).thenAnswer((_) async {
        return [
          createFoundResponse(
            documentPath: 'collectionId/documentId',
            fields: {'foo': 'bar'},
            firestore: firestore,
          ),
        ];
      });

      final doc = firestore.doc('collectionId/documentId');
      final results = await firestore.getAll([doc]);

      expect(results, hasLength(1));
      expect(results[0].exists, isTrue);
      expect(results[0].id, 'documentId');
      expect(results[0].get('foo')?.value, 'bar');
    });

    test('accepts multiple documents', () async {
      when(
        () => mockClient
            .v1<List<firestore_v1.BatchGetDocumentsResponseElement>>(any()),
      ).thenAnswer((_) async {
        return [
          createFoundResponse(
            documentPath: 'col/doc1',
            fields: {'a': 1},
            firestore: firestore,
          ),
          createFoundResponse(
            documentPath: 'col/doc2',
            fields: {'b': 2},
            firestore: firestore,
          ),
        ];
      });

      final doc1 = firestore.doc('col/doc1');
      final doc2 = firestore.doc('col/doc2');
      final results = await firestore.getAll([doc1, doc2]);

      expect(results, hasLength(2));
      expect(results[0].exists, isTrue);
      expect(results[0].id, 'doc1');
      expect(results[0].get('a')?.value, 1);
      expect(results[1].exists, isTrue);
      expect(results[1].id, 'doc2');
      expect(results[1].get('b')?.value, 2);
    });

    test('returns missing documents', () async {
      when(
        () => mockClient
            .v1<List<firestore_v1.BatchGetDocumentsResponseElement>>(any()),
      ).thenAnswer((_) async {
        return [createMissingResponse('col/missing')];
      });

      final doc = firestore.doc('col/missing');
      final results = await firestore.getAll([doc]);

      expect(results, hasLength(1));
      expect(results[0].exists, isFalse);
      expect(results[0].id, 'missing');
    });

    test('handles mix of found and missing documents', () async {
      when(
        () => mockClient
            .v1<List<firestore_v1.BatchGetDocumentsResponseElement>>(any()),
      ).thenAnswer((_) async {
        return [
          createFoundResponse(
            documentPath: 'col/found',
            fields: {'exists': true},
            firestore: firestore,
          ),
          createMissingResponse('col/missing'),
        ];
      });

      final doc1 = firestore.doc('col/found');
      final doc2 = firestore.doc('col/missing');
      final results = await firestore.getAll([doc1, doc2]);

      expect(results, hasLength(2));
      expect(results[0].exists, isTrue);
      expect(results[0].get('exists')?.value, true);
      expect(results[1].exists, isFalse);
    });

    test('rejects empty array', () async {
      expect(
        () => firestore.getAll([]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must not be an empty array'),
          ),
        ),
      );
    });

    test('verifies document order is preserved', () async {
      when(
        () => mockClient
            .v1<List<firestore_v1.BatchGetDocumentsResponseElement>>(any()),
      ).thenAnswer((_) async {
        // Return in different order than requested
        return [
          createFoundResponse(
            documentPath: 'col/doc3',
            fields: {'n': 3},
            firestore: firestore,
          ),
          createFoundResponse(
            documentPath: 'col/doc1',
            fields: {'n': 1},
            firestore: firestore,
          ),
          createFoundResponse(
            documentPath: 'col/doc2',
            fields: {'n': 2},
            firestore: firestore,
          ),
        ];
      });

      final doc1 = firestore.doc('col/doc1');
      final doc2 = firestore.doc('col/doc2');
      final doc3 = firestore.doc('col/doc3');
      final results = await firestore.getAll([doc1, doc2, doc3]);

      // Results should be in request order, not response order
      expect(results, hasLength(3));
      expect(results[0].id, 'doc1');
      expect(results[1].id, 'doc2');
      expect(results[2].id, 'doc3');
    });
  });
}
