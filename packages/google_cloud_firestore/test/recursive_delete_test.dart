// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:google_cloud_firestore/src/firestore_http_client.dart';
import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Mock classes
class MockFirestoreHttpClient extends Mock implements FirestoreHttpClient {}

class MockFirestoreApi extends Mock implements firestore_v1.FirestoreApi {}

class MockProjectsResource extends Mock
    implements firestore_v1.ProjectsResource {}

class MockProjectsDatabasesResource extends Mock
    implements firestore_v1.ProjectsDatabasesResource {}

class MockProjectsDatabasesDocumentsResource extends Mock
    implements firestore_v1.ProjectsDatabasesDocumentsResource {}

// Helper to create a RunQueryResponseElement with a document
firestore_v1.RunQueryResponseElement createDocumentResponse(String docId) {
  return firestore_v1.RunQueryResponseElement(
    document: firestore_v1.Document(
      name:
          'projects/$projectId/databases/(default)/documents/collectionId/$docId',
      fields: {},
      createTime: DateTime.now().toIso8601String(),
      updateTime: DateTime.now().toIso8601String(),
    ),
    readTime: DateTime.now().toIso8601String(),
  );
}

// Helper to create a successful BatchWriteResponse
firestore_v1.BatchWriteResponse createSuccessResponse(int count) {
  return firestore_v1.BatchWriteResponse(
    writeResults: List.generate(
      count,
      (_) => firestore_v1.WriteResult(
        updateTime: DateTime.now().toIso8601String(),
      ),
    ),
    status: List.generate(count, (_) => firestore_v1.Status(code: 0)),
  );
}

// Helper to create a failed BatchWriteResponse
firestore_v1.BatchWriteResponse createFailedResponse(int code, String message) {
  return firestore_v1.BatchWriteResponse(
    writeResults: [firestore_v1.WriteResult()],
    status: [firestore_v1.Status(code: code, message: message)],
  );
}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(firestore_v1.RunQueryRequest());
    registerFallbackValue(firestore_v1.BatchWriteRequest());
  });

  group('recursiveDelete() Unit Tests', () {
    late MockFirestoreHttpClient mockClient;
    late MockFirestoreApi mockApi;
    late MockProjectsResource mockProjects;
    late MockProjectsDatabasesResource mockDatabases;
    late MockProjectsDatabasesDocumentsResource mockDocuments;

    setUp(() {
      mockClient = MockFirestoreHttpClient();
      mockApi = MockFirestoreApi();
      mockProjects = MockProjectsResource();
      mockDatabases = MockProjectsDatabasesResource();
      mockDocuments = MockProjectsDatabasesDocumentsResource();

      // Set up the resource hierarchy
      when(() => mockApi.projects).thenReturn(mockProjects);
      when(() => mockProjects.databases).thenReturn(mockDatabases);
      when(() => mockDatabases.documents).thenReturn(mockDocuments);

      // Cache projectId to avoid discovery
      when(() => mockClient.cachedProjectId).thenReturn(projectId);
    });

    group('parameter validation', () {
      test('throws ArgumentError for invalid reference type (string)', () {
        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        expect(
          () => firestore.recursiveDelete('invalid'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be a DocumentReference or CollectionReference'),
            ),
          ),
        );
      });

      test('throws ArgumentError for invalid reference type (number)', () {
        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        expect(
          () => firestore.recursiveDelete(123),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be a DocumentReference or CollectionReference'),
            ),
          ),
        );
      });

      test('throws ArgumentError for invalid reference type (Map)', () {
        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        expect(
          () => firestore.recursiveDelete(<String, dynamic>{}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be a DocumentReference or CollectionReference'),
            ),
          ),
        );
      });
    });

    group('deletion behavior', () {
      test('deletes a collection with documents', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return documents
        when(() => mockDocuments.runQuery(any(), any())).thenAnswer(
          (_) async => [
            createDocumentResponse('doc1'),
            createDocumentResponse('doc2'),
            createDocumentResponse('doc3'),
          ],
        );

        // Mock batchWrite to succeed
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(3));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        await firestore.recursiveDelete(firestore.collection('collectionId'));

        // Verify runQuery was called
        verify(() => mockDocuments.runQuery(any(), any())).called(1);

        // Verify batchWrite was called with deletes
        verify(() => mockDocuments.batchWrite(any(), any())).called(1);
      });

      test('deletes a document reference', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return no subcollection documents
        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => <firestore_v1.RunQueryResponseElement>[]);

        // Mock batchWrite to succeed (for the document itself)
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(1));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        await firestore.recursiveDelete(firestore.doc('collectionId/docId'));

        // Verify runQuery was called to check for subcollections
        verify(() => mockDocuments.runQuery(any(), any())).called(1);

        // Verify batchWrite was called to delete the document
        verify(() => mockDocuments.batchWrite(any(), any())).called(1);
      });

      test('throws error when deletes fail', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return documents
        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => [createDocumentResponse('doc1')]);

        // Mock batchWrite to fail
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createFailedResponse(7, 'PERMISSION_DENIED'));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        await expectLater(
          firestore.recursiveDelete(firestore.collection('collectionId')),
          throwsA(isA<FirestoreException>()),
        );
      });

      test('accepts custom BulkWriter', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return documents
        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => [createDocumentResponse('doc1')]);

        // Mock batchWrite to succeed
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(1));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        final bulkWriter = firestore.bulkWriter();
        var callbackCount = 0;
        bulkWriter.onWriteResult((ref, result) {
          callbackCount++;
        });

        await firestore.recursiveDelete(
          firestore.collection('collectionId'),
          bulkWriter,
        );

        // Verify the callback was called
        expect(callbackCount, 1);
      });

      test('accepts references with converters', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return no documents
        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => <firestore_v1.RunQueryResponseElement>[]);

        // Mock batchWrite to succeed
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(1));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        final docRef = firestore
            .doc('coll/doc')
            .withConverter<DocumentData>(
              fromFirestore: (snapshot) => snapshot.data(),
              toFirestore: (data) => data,
            );

        // Should not throw
        await firestore.recursiveDelete(docRef);

        verify(() => mockDocuments.runQuery(any(), any())).called(1);
      });

      test('deletes document with nested subcollections', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return subcollection documents
        when(() => mockDocuments.runQuery(any(), any())).thenAnswer(
          (_) async => [
            createDocumentResponse('bob/children/charlie'),
            createDocumentResponse('bob/children/daniel'),
          ],
        );

        // Mock batchWrite to succeed (for subcollections + parent doc)
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(3));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        await firestore.recursiveDelete(firestore.doc('collectionId/bob'));

        // Verify runQuery was called to find subcollections
        verify(() => mockDocuments.runQuery(any(), any())).called(1);

        // Verify batchWrite was called
        verify(() => mockDocuments.batchWrite(any(), any())).called(1);
      });

      test('handles multiple concurrent recursiveDelete calls', () async {
        var runQueryCallCount = 0;
        var batchWriteCallCount = 0;

        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return different docs each time
        when(() => mockDocuments.runQuery(any(), any())).thenAnswer((_) async {
          runQueryCallCount++;
          return [createDocumentResponse('doc$runQueryCallCount')];
        });

        // Mock batchWrite to succeed
        when(() => mockDocuments.batchWrite(any(), any())).thenAnswer((
          _,
        ) async {
          batchWriteCallCount++;
          return createSuccessResponse(1);
        });

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        // Make three concurrent calls
        await Future.wait([
          firestore.recursiveDelete(firestore.collection('a')),
          firestore.recursiveDelete(firestore.collection('b')),
          firestore.recursiveDelete(firestore.collection('c')),
        ]);

        // Verify each call made its own runQuery
        expect(runQueryCallCount, 3);
        expect(batchWriteCallCount, 3);
      });
    });

    group('BulkWriter callbacks', () {
      test('success handler receives correct references and results', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return documents
        when(() => mockDocuments.runQuery(any(), any())).thenAnswer(
          (_) async => [
            createDocumentResponse('doc1'),
            createDocumentResponse('doc2'),
          ],
        );

        // Mock batchWrite with specific update times
        when(() => mockDocuments.batchWrite(any(), any())).thenAnswer(
          (_) async => firestore_v1.BatchWriteResponse(
            writeResults: [
              firestore_v1.WriteResult(
                updateTime: DateTime(2024, 1, 1, 12, 0, 1).toIso8601String(),
              ),
              firestore_v1.WriteResult(
                updateTime: DateTime(2024, 1, 1, 12, 0, 2).toIso8601String(),
              ),
            ],
            status: [
              firestore_v1.Status(code: 0),
              firestore_v1.Status(code: 0),
            ],
          ),
        );

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        final refs = <String>[];
        final results = <int>[];
        final bulkWriter = firestore.bulkWriter();
        bulkWriter.onWriteResult((ref, result) {
          refs.add(ref.path);
          results.add(result.writeTime.seconds);
        });

        await firestore.recursiveDelete(
          firestore.collection('collectionId'),
          bulkWriter,
        );

        // Verify callbacks received correct data
        expect(refs.length, 2);
        expect(refs, contains('collectionId/doc1'));
        expect(refs, contains('collectionId/doc2'));
        expect(results.length, 2);
      });

      test(
        'error handler receives correct error codes and references',
        () async {
          // Mock v1 to return the API
          when(
            () => mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(
              any(),
            ),
          ).thenAnswer((invocation) async {
            final fn =
                invocation.positionalArguments[0]
                    as Future<List<firestore_v1.RunQueryResponseElement>>
                    Function(firestore_v1.FirestoreApi, String);
            return fn(mockApi, projectId);
          });

          when(
            () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
          ).thenAnswer((invocation) async {
            final fn =
                invocation.positionalArguments[0]
                    as Future<firestore_v1.BatchWriteResponse> Function(
                      firestore_v1.FirestoreApi,
                      String,
                    );
            return fn(mockApi, projectId);
          });

          // Mock runQuery to return documents
          when(() => mockDocuments.runQuery(any(), any())).thenAnswer(
            (_) async => [
              createDocumentResponse('doc1'),
              createDocumentResponse('doc2'),
            ],
          );

          // Mock batchWrite with failures
          when(() => mockDocuments.batchWrite(any(), any())).thenAnswer(
            (_) async => firestore_v1.BatchWriteResponse(
              writeResults: [
                firestore_v1.WriteResult(),
                firestore_v1.WriteResult(),
              ],
              status: [
                firestore_v1.Status(code: 7, message: 'PERMISSION_DENIED'),
                firestore_v1.Status(code: 14, message: 'UNAVAILABLE'),
              ],
            ),
          );

          final firestore = Firestore.internal(
            settings: const Settings(projectId: projectId),
            client: mockClient,
          );

          final errorCodes = <String>[];
          final errorRefs = <String>[];
          final bulkWriter = firestore.bulkWriter();
          bulkWriter.onWriteError((error) {
            errorCodes.add(error.code.code);
            errorRefs.add(error.documentRef.path);
            return false; // Don't retry
          });

          try {
            await firestore.recursiveDelete(
              firestore.collection('collectionId'),
              bulkWriter,
            );
            fail('Should have thrown');
          } catch (e) {
            // Expected to fail
          }

          // Verify error callbacks received correct data
          expect(errorCodes.length, 2);
          expect(errorRefs, ['collectionId/doc1', 'collectionId/doc2']);
        },
      );

      test('rejects when success handler throws', () async {
        // Mock v1 to return the API
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        // Mock runQuery to return a document
        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => [createDocumentResponse('doc1')]);

        // Mock batchWrite to succeed
        when(
          () => mockDocuments.batchWrite(any(), any()),
        ).thenAnswer((_) async => createSuccessResponse(1));

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        final bulkWriter = firestore.bulkWriter();
        bulkWriter.onWriteResult((ref, result) {
          throw Exception('User callback failed');
        });

        await expectLater(
          firestore.recursiveDelete(
            firestore.collection('collectionId'),
            bulkWriter,
          ),
          throwsA(
            isA<FirestoreException>().having(
              (e) => e.message,
              'message',
              contains('User callback failed'),
            ),
          ),
        );
      });
    });

    group('BulkWriter instance management', () {
      test('throws error if BulkWriter is closed', () async {
        // Mock v1 to return the API (needed even though it will fail early)
        when(
          () =>
              mockClient.v1<List<firestore_v1.RunQueryResponseElement>>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<List<firestore_v1.RunQueryResponseElement>>
                  Function(firestore_v1.FirestoreApi, String);
          return fn(mockApi, projectId);
        });

        when(
          () => mockClient.v1<firestore_v1.BatchWriteResponse>(any()),
        ).thenAnswer((invocation) async {
          final fn =
              invocation.positionalArguments[0]
                  as Future<firestore_v1.BatchWriteResponse> Function(
                    firestore_v1.FirestoreApi,
                    String,
                  );
          return fn(mockApi, projectId);
        });

        when(
          () => mockDocuments.runQuery(any(), any()),
        ).thenAnswer((_) async => <firestore_v1.RunQueryResponseElement>[]);

        final firestore = Firestore.internal(
          settings: const Settings(projectId: projectId),
          client: mockClient,
        );

        final bulkWriter = firestore.bulkWriter();
        await bulkWriter.close();

        await expectLater(
          firestore.recursiveDelete(firestore.collection('test'), bulkWriter),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
