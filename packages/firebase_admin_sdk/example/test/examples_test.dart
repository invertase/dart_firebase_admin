// Copyright 2026 Google LLC
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

import 'package:google_cloud_firestore/google_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract interface class UserRepository {
  Future<Map<String, dynamic>?> findById(String id);

  Future<void> save(String id, Map<String, dynamic> data);

  Future<List<Map<String, dynamic>>> findAll();
}

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._firestore);

  final Firestore _firestore;

  @override
  Future<Map<String, dynamic>?> findById(String id) async {
    final snap = await _firestore.collection('users').doc(id).get();
    return snap.data();
  }

  @override
  Future<void> save(String id, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(id).set(data);
  }

  @override
  Future<List<Map<String, dynamic>>> findAll() async {
    final snap = await _firestore.collection('users').get();
    return [for (final doc in snap.docs) doc.data()];
  }
}

class UserService {
  UserService(this._repo);

  final UserRepository _repo;

  Future<String?> getDisplayName(String id) async {
    final data = await _repo.findById(id);
    return data?['displayName'] as String?;
  }

  Future<void> createUser(String id, String displayName) {
    return _repo.save(id, {'displayName': displayName});
  }

  Future<int> countUsers() async {
    final users = await _repo.findAll();
    return users.length;
  }
}

class ReportService {
  Future<int> countMatchingDocuments(Query<Map<String, dynamic>> query) async {
    final snap = await query.get();
    return snap.size;
  }

  Future<List<Map<String, dynamic>>> fetchMatchingDocuments(
    Query<Map<String, dynamic>> query,
  ) async {
    final snap = await query.get();
    return [for (final doc in snap.docs) doc.data()];
  }
}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirestore extends Mock implements Firestore {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {
  @override
  CollectionReference<U> withConverter<U>({
    Object? fromFirestore,
    Object? toFirestore,
  }) => throw UnimplementedError();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {
  @override
  Query<U> withConverter<U>({Object? fromFirestore, Object? toFirestore}) =>
      throw UnimplementedError();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockWriteResult extends Mock implements WriteResult {}

void main() {
  group('UserService', () {
    late MockUserRepository mockRepo;
    late UserService service;

    setUp(() {
      mockRepo = MockUserRepository();
      service = UserService(mockRepo);
    });

    test(
      'getDisplayName returns the display name from the repository',
      () async {
        when(
          () => mockRepo.findById('user-1'),
        ).thenAnswer((_) async => {'displayName': 'Alice'});

        expect(await service.getDisplayName('user-1'), 'Alice');
        verify(() => mockRepo.findById('user-1')).called(1);
      },
    );

    test('getDisplayName returns null when the user does not exist', () async {
      when(() => mockRepo.findById('missing')).thenAnswer((_) async => null);

      expect(await service.getDisplayName('missing'), isNull);
    });

    test(
      'createUser delegates to the repository with the correct data',
      () async {
        when(
          () => mockRepo.save('user-2', {'displayName': 'Bob'}),
        ).thenAnswer((_) async {});

        await service.createUser('user-2', 'Bob');

        verify(() => mockRepo.save('user-2', {'displayName': 'Bob'})).called(1);
      },
    );

    test(
      'countUsers returns the number of users from the repository',
      () async {
        when(mockRepo.findAll).thenAnswer(
          (_) async => [
            {'displayName': 'Alice'},
            {'displayName': 'Bob'},
          ],
        );

        expect(await service.countUsers(), 2);
      },
    );
  });

  group('FirestoreUserRepository', () {
    late MockFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDoc;
    late FirestoreUserRepository repo;

    setUp(() {
      mockFirestore = MockFirestore();
      mockCollection = MockCollectionReference();
      mockDoc = MockDocumentReference();
      repo = FirestoreUserRepository(mockFirestore);

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDoc);
    });

    test('findById returns data when document exists', () async {
      final mockSnap = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.get).thenAnswer((_) async => mockSnap);
      when(mockSnap.data).thenReturn({'displayName': 'Alice'});

      expect(await repo.findById('user-1'), {'displayName': 'Alice'});
      verify(() => mockFirestore.collection('users')).called(1);
      verify(() => mockCollection.doc('user-1')).called(1);
    });

    test('save calls set on the document reference', () async {
      when(
        () => mockDoc.set({'displayName': 'Bob'}),
      ).thenAnswer((_) async => MockWriteResult());

      await repo.save('user-2', {'displayName': 'Bob'});

      verify(() => mockDoc.set({'displayName': 'Bob'})).called(1);
    });
  });

  group('ReportService', () {
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;
    late ReportService service;

    setUp(() {
      mockQuery = MockQuery();
      mockSnapshot = MockQuerySnapshot();
      service = ReportService();

      when(mockQuery.get).thenAnswer((_) async => mockSnapshot);
    });

    test('countMatchingDocuments returns the snapshot size', () async {
      when(() => mockSnapshot.size).thenReturn(5);

      expect(await service.countMatchingDocuments(mockQuery), 5);
      verify(mockQuery.get).called(1);
    });

    test('fetchMatchingDocuments returns mapped document data', () async {
      final doc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final doc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(doc1.data).thenReturn({'name': 'Alice'});
      when(doc2.data).thenReturn({'name': 'Bob'});
      when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);

      final result = await service.fetchMatchingDocuments(mockQuery);

      expect(result, [
        {'name': 'Alice'},
        {'name': 'Bob'},
      ]);
    });
  });
}
