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
  group('Firestore', () {
    late MockFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDoc;

    setUp(() {
      mockFirestore = MockFirestore();
      mockCollection = MockCollectionReference();
      mockDoc = MockDocumentReference();

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDoc);
    });

    test('collection returns the expected collection', () {
      expect(
        mockFirestore.collection('users'),
        isA<CollectionReference<Map<String, dynamic>>>(),
      );
    });

    test('get returns the document data', () async {
      final mockSnap = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc.get).thenAnswer((_) async => mockSnap);
      when(mockSnap.data).thenReturn({'name': 'Alice'});

      final snap = await mockFirestore.collection('users').doc('u1').get();

      expect(snap.data(), {'name': 'Alice'});
    });

    test('set writes the document data', () async {
      when(
        () => mockDoc.set({'name': 'Bob'}),
      ).thenAnswer((_) async => MockWriteResult());

      await mockFirestore.collection('users').doc('u2').set({'name': 'Bob'});

      verify(() => mockDoc.set({'name': 'Bob'})).called(1);
    });
  });

  group('Query', () {
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;

    setUp(() {
      mockQuery = MockQuery();
      mockSnapshot = MockQuerySnapshot();
      when(mockQuery.get).thenAnswer((_) async => mockSnapshot);
    });

    test('get returns the query results', () async {
      expect(await mockQuery.get(), isA<QuerySnapshot<Map<String, dynamic>>>());
    });

    test('snapshot returns the correct size', () async {
      when(() => mockSnapshot.size).thenReturn(3);

      expect((await mockQuery.get()).size, 3);
    });

    test('snapshot returns the correct documents', () async {
      final doc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final doc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(doc1.data).thenReturn({'name': 'Alice'});
      when(doc2.data).thenReturn({'name': 'Bob'});
      when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);

      final docs = (await mockQuery.get()).docs;

      expect(docs.map((d) => d.data()).toList(), [
        {'name': 'Alice'},
        {'name': 'Bob'},
      ]);
    });
  });
}
