part of 'firestore.dart';

typedef UpdateMap = Map<FieldPath, Object?>;

enum _FirestoreUnaryMethod {
  listDocuments,
  listCollectionIds,
  roolback,
  beginTransaction,
  comit,
  batchWrite;
}

enum _FirestoreStreamingMethod {
  listen,
  partitionQueryStream,
  runQuery,
  runAggregationQuery,
  batchGetDocuments;
}

abstract class FirestoreDataConverter<T> {
  factory FirestoreDataConverter({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) = _DelegateDataConverter<T>;

  static const FirestoreDataConverter<DocumentData> jsonConverter =
      _DocumentDataConverter();

  DocumentData toFirestore(T value);

  T fromFirestore(QueryDocumentSnapshot<DocumentData> value);
}

class _DocumentDataConverter implements FirestoreDataConverter<DocumentData> {
  const _DocumentDataConverter();
  @override
  DocumentData fromFirestore(QueryDocumentSnapshot<DocumentData> value) {
    return value.data();
  }

  @override
  DocumentData toFirestore(DocumentData value) => value;
}

typedef FromFirestore<T> = T Function(
  QueryDocumentSnapshot<DocumentData> value,
);
typedef ToFirestore<T> = DocumentData Function(T value);

class _DelegateDataConverter<T> implements FirestoreDataConverter<T> {
  _DelegateDataConverter({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  })  : _fromFirestore = fromFirestore,
        _toFirestore = toFirestore;

  final FromFirestore<T> _fromFirestore;
  final DocumentData Function(T value) _toFirestore;

  @override
  T fromFirestore(QueryDocumentSnapshot<DocumentData> value) =>
      _fromFirestore(value);

  @override
  DocumentData toFirestore(T value) => _toFirestore(value);
}
