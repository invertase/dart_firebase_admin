part of 'firestore.dart';

enum DocumentChangeType {
  added,
  removed,
  modified,
}

/// A DocumentChange represents a change to the documents matching a query.
/// It contains the document affected and the type of change that occurred.
@immutable
class DocumentChange<T> {
  const DocumentChange._({
    required this.oldIndex,
    required this.newIndex,
    required this.doc,
    required this.type,
  });

  /// The index of the changed document in the result set immediately prior to
  /// this DocumentChange (i.e. supposing that all prior DocumentChange objects
  /// have been applied). Is -1 for 'added' events.
  final int oldIndex;

  /// The index of the changed document in the result set immediately after
  /// this DocumentChange (i.e. supposing that all prior DocumentChange
  /// objects and the current DocumentChange object have been applied).
  /// Is -1 for 'removed' events.
  final int newIndex;

  /// The document affected by this change.
  final QueryDocumentSnapshot<T> doc;

  /// The type of change ('added', 'modified', or 'removed').
  final DocumentChangeType type;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DocumentChange<T> &&
            runtimeType == other.runtimeType &&
            oldIndex == other.oldIndex &&
            newIndex == other.newIndex &&
            doc == other.doc &&
            type == other.type;
  }

  @override
  int get hashCode => Object.hash(runtimeType, oldIndex, newIndex, doc, type);
}
