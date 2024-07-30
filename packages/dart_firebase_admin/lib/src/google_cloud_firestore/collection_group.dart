part of 'firestore.dart';

final class CollectionGroup<T> extends Query<T> {
  CollectionGroup._(
    String collectionId, {
    required super.firestore,
    required _FirestoreDataConverter<T> converter,
  }) : super._(
          queryOptions:
              _QueryOptions.forCollectionGroupQuery(collectionId, converter),
        );

  @override
  CollectionGroup<U> withConverter<U>({
    required FromFirestore<U> fromFirestore,
    required ToFirestore<U> toFirestore,
  }) {
    return CollectionGroup._(
      _queryOptions.collectionId,
      firestore: firestore,
      converter: (
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      ),
    );
  }

  @override
  // ignore: hash_and_equals, already implemented by Query
  bool operator ==(Object other) {
    return super == other && other is CollectionGroup<T>;
  }
}
