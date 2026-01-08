part of '../firestore.dart';

@immutable
class QuerySnapshot<T> {
  QuerySnapshot._({
    required this.docs,
    required this.query,
    required this.readTime,
  });

  /// The query used in order to get this [QuerySnapshot].
  final Query<T> query;

  /// The time this query snapshot was obtained.
  final Timestamp? readTime;

  /// A list of all the documents in this QuerySnapshot.
  final List<QueryDocumentSnapshot<T>> docs;

  /// Returns a list of the documents changes since the last snapshot.
  ///
  /// If this is the first snapshot, all documents will be in the list as added
  /// changes.
  late final List<DocumentChange<T>> docChanges = [
    for (final (index, doc) in docs.indexed)
      DocumentChange<T>._(
        type: DocumentChangeType.added,
        oldIndex: -1,
        newIndex: index,
        doc: doc,
      ),
  ];

  @override
  bool operator ==(Object other) {
    return other is QuerySnapshot<T> &&
        runtimeType == other.runtimeType &&
        query == other.query &&
        const ListEquality<QueryDocumentSnapshot<Object?>>().equals(
          docs,
          other.docs,
        ) &&
        const ListEquality<DocumentChange<Object?>>().equals(
          docChanges,
          other.docChanges,
        );
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    const ListEquality<QueryDocumentSnapshot<Object?>>().hash(docs),
    const ListEquality<DocumentChange<Object?>>().hash(docChanges),
  );
}
