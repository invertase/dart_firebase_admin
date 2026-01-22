import 'dart:async';

import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_firestore/googleapis_firestore.dart';
import 'package:googleapis_firestore/src/firestore_http_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFirestoreHttpClient extends Mock implements FirestoreHttpClient {}

class MockFirestoreApi extends Mock implements firestore_v1.FirestoreApi {}

class MockProjectsResource extends Mock
    implements firestore_v1.ProjectsResource {}

class MockDatabasesResource extends Mock
    implements firestore_v1.ProjectsDatabasesResource {}

class MockDocumentsResource extends Mock
    implements firestore_v1.ProjectsDatabasesDocumentsResource {}

class FakePartitionQueryRequest extends Fake
    implements firestore_v1.PartitionQueryRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePartitionQueryRequest());
  });

  group('QueryPartition Unit Tests', () {
    late Firestore firestore;

    setUp(() {
      runZoned(
        () {
          firestore = Firestore(
            settings: const Settings(projectId: 'test-project'),
          );
        },
        zoneValues: {
          envSymbol: <String, String>{'GOOGLE_CLOUD_PROJECT': 'test-project'},
        },
      );
    });

    group('getPartitions validation', () {
      test('validates partition count of zero', () async {
        final query = firestore.collectionGroup('collectionId');

        await expectLater(
          () async {
            await for (final _ in query.getPartitions(0)) {
              // Should not reach here
            }
          }(),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              'Value for argument "desiredPartitionCount" must be within [1, Infinity] inclusive, but was: 0',
            ),
          ),
        );
      });

      test('validates negative partition count', () async {
        final query = firestore.collectionGroup('collectionId');

        await expectLater(
          () async {
            await for (final _ in query.getPartitions(-1)) {
              // Should not reach here
            }
          }(),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              'Value for argument "desiredPartitionCount" must be within [1, Infinity] inclusive, but was: -1',
            ),
          ),
        );
      });
    });

    group('getPartitions pagination', () {
      late Firestore mockFirestore;
      late MockFirestoreHttpClient mockHttpClient;
      late MockFirestoreApi mockApi;
      late MockProjectsResource mockProjects;
      late MockDatabasesResource mockDatabases;
      late MockDocumentsResource mockDocuments;

      setUp(() {
        mockHttpClient = MockFirestoreHttpClient();
        mockApi = MockFirestoreApi();
        mockProjects = MockProjectsResource();
        mockDatabases = MockDatabasesResource();
        mockDocuments = MockDocumentsResource();

        // Mock cachedProjectId
        when(() => mockHttpClient.cachedProjectId).thenReturn('test-project');

        // Set up the API resource hierarchy
        when(() => mockApi.projects).thenReturn(mockProjects);
        when(() => mockProjects.databases).thenReturn(mockDatabases);
        when(() => mockDatabases.documents).thenReturn(mockDocuments);

        // Mock v1 to execute the callback with the mock API
        when(
          () => mockHttpClient.v1<firestore_v1.PartitionQueryResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.PartitionQueryResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, 'test-project');
        });

        // Create Firestore instance with mock http client
        mockFirestore = Firestore.internal(
          settings: const Settings(projectId: 'test-project'),
          client: mockHttpClient,
        );
      });

      test('handles single-page response (no pagination)', () async {
        // Mock a single-page response with no nextPageToken
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          _,
        ) async {
          return firestore_v1.PartitionQueryResponse(
            partitions: [
              firestore_v1.Cursor(
                values: [
                  firestore_v1.Value(
                    referenceValue:
                        'projects/test-project/databases/(default)/documents/coll/doc1',
                  ),
                ],
              ),
              firestore_v1.Cursor(
                values: [
                  firestore_v1.Value(
                    referenceValue:
                        'projects/test-project/databases/(default)/documents/coll/doc2',
                  ),
                ],
              ),
            ],
          );
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(3).toList();

        // Verify:
        // - 3 partitions returned (2 cursors + 1 final empty partition)
        // - Only 1 API call made (no pagination)
        expect(partitions, hasLength(3));
        verify(() => mockDocuments.partitionQuery(any(), any())).called(1);
      });

      test('handles multi-page response with nextPageToken', () async {
        var callCount = 0;

        // Mock paginated responses
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          invocation,
        ) async {
          callCount++;

          if (callCount == 1) {
            // First page with nextPageToken
            return firestore_v1.PartitionQueryResponse(
              partitions: [
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc1',
                    ),
                  ],
                ),
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc2',
                    ),
                  ],
                ),
              ],
              nextPageToken: 'page-2-token',
            );
          } else if (callCount == 2) {
            // Second page with nextPageToken
            return firestore_v1.PartitionQueryResponse(
              partitions: [
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc3',
                    ),
                  ],
                ),
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc4',
                    ),
                  ],
                ),
              ],
              nextPageToken: 'page-3-token',
            );
          } else {
            // Final page without nextPageToken
            return firestore_v1.PartitionQueryResponse(
              partitions: [
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc5',
                    ),
                  ],
                ),
              ],
            );
          }
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(10).toList();

        // Verify:
        // - 6 partitions returned (5 cursors from 3 pages + 1 final empty partition)
        // - 3 API calls made (pagination across 3 pages)
        expect(partitions, hasLength(6));
        expect(callCount, equals(3));
        verify(() => mockDocuments.partitionQuery(any(), any())).called(3);
      });

      test('handles empty string nextPageToken correctly', () async {
        // Mock response with empty string nextPageToken (should stop pagination)
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          _,
        ) async {
          return firestore_v1.PartitionQueryResponse(
            partitions: [
              firestore_v1.Cursor(
                values: [
                  firestore_v1.Value(
                    referenceValue:
                        'projects/test-project/databases/(default)/documents/coll/doc1',
                  ),
                ],
              ),
            ],
            nextPageToken: '', // Empty string should stop pagination
          );
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(5).toList();

        // Verify pagination stops with empty token (1 API call only)
        expect(partitions, hasLength(2)); // 1 cursor + 1 final empty partition
        verify(() => mockDocuments.partitionQuery(any(), any())).called(1);
      });

      test('handles null partitions in response', () async {
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          _,
        ) async {
          return firestore_v1.PartitionQueryResponse();
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(3).toList();

        // Should return only the final empty partition
        expect(partitions, hasLength(1));
        expect(partitions[0].startAt, isNull);
        expect(partitions[0].endBefore, isNull);
      });

      test('handles partitions with null values', () async {
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          _,
        ) async {
          return firestore_v1.PartitionQueryResponse(
            partitions: [
              firestore_v1.Cursor(), // Null values
              firestore_v1.Cursor(
                values: [
                  firestore_v1.Value(
                    referenceValue:
                        'projects/test-project/databases/(default)/documents/coll/doc1',
                  ),
                ],
              ),
            ],
          );
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(3).toList();

        // Should skip the cursor with null values and return 2 partitions
        // (1 valid cursor + 1 final empty partition)
        expect(partitions, hasLength(2));
      });

      test('verifies partitions are sorted across multiple pages', () async {
        var callCount = 0;

        // Mock paginated responses with intentionally unsorted cursors
        when(() => mockDocuments.partitionQuery(any(), any())).thenAnswer((
          invocation,
        ) async {
          callCount++;

          if (callCount == 1) {
            // First page - doc3, doc1 (unsorted)
            return firestore_v1.PartitionQueryResponse(
              partitions: [
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc3',
                    ),
                  ],
                ),
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc1',
                    ),
                  ],
                ),
              ],
              nextPageToken: 'page-2-token',
            );
          } else {
            // Second page - doc4, doc2 (unsorted)
            return firestore_v1.PartitionQueryResponse(
              partitions: [
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc4',
                    ),
                  ],
                ),
                firestore_v1.Cursor(
                  values: [
                    firestore_v1.Value(
                      referenceValue:
                          'projects/test-project/databases/(default)/documents/coll/doc2',
                    ),
                  ],
                ),
              ],
            );
          }
        });

        final collectionGroup = mockFirestore.collectionGroup(
          'test-collection',
        );
        final partitions = await collectionGroup.getPartitions(10).toList();

        // Verify partitions are sorted: doc1, doc2, doc3, doc4, empty
        expect(partitions, hasLength(5));

        // Extract document names from reference values
        final docNames = partitions.where((p) => p.startAt != null).map((p) {
          final docRef = p.startAt!.first! as DocumentReference;
          return docRef.path.split('/').last;
        }).toList();

        expect(docNames, equals(['doc1', 'doc2', 'doc3', 'doc4']));
      });
    });
  });
}
