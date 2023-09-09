part of 'firestore.dart';

typedef UpdateMap = Map<FieldPath, Object?>;

typedef FromFirestore<T> = T Function(
  QueryDocumentSnapshot<DocumentData> value,
);
typedef ToFirestore<T> = DocumentData Function(T value);

DocumentData _jsonFromFirestore(QueryDocumentSnapshot<DocumentData> value) {
  return value.data();
}

DocumentData _jsonToFirestore(DocumentData value) => value;

const _FirestoreDataConverter<DocumentData> _jsonConverter = (
  fromFirestore: _jsonFromFirestore,
  toFirestore: _jsonToFirestore,
);

typedef _FirestoreDataConverter<T> = ({
  FromFirestore<T> fromFirestore,
  ToFirestore<T> toFirestore,
});
