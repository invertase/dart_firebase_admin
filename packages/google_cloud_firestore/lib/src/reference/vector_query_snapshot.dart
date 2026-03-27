// Copyright 2026 Firebase
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

part of '../firestore.dart';

/// A `VectorQuerySnapshot` contains zero or more [QueryDocumentSnapshot] objects
/// representing the results of a vector query. The documents can be accessed as a
/// list via the [docs] property. The number of documents can be determined via
/// the [empty] and [size] properties.
@immutable
class VectorQuerySnapshot<T> {
  VectorQuerySnapshot._({
    required this.query,
    required this.readTime,
    required this.docs,
  });

  /// The [VectorQuery] on which you called [VectorQuery.get] to get this [VectorQuerySnapshot].
  final VectorQuery<T> query;

  /// The time this query snapshot was obtained.
  final Timestamp readTime;

  /// A list of all the documents in this [VectorQuerySnapshot].
  final List<QueryDocumentSnapshot<T>> docs;

  /// `true` if there are no documents in the [VectorQuerySnapshot].
  bool get empty => docs.isEmpty;

  /// The number of documents in the [VectorQuerySnapshot].
  int get size => docs.length;

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

  /// Enumerates all of the documents in the [VectorQuerySnapshot].
  ///
  /// This is a convenience method for running the same callback on each
  /// [QueryDocumentSnapshot] that is returned.
  void forEach(void Function(QueryDocumentSnapshot<T> doc) callback) {
    docs.forEach(callback);
  }

  /// Returns true if the document data in this [VectorQuerySnapshot] is equal
  /// to the provided value.
  bool isEqual(VectorQuerySnapshot<T> other) {
    // Since the read time is different on every query read, we explicitly
    // ignore all metadata in this comparison.

    if (identical(this, other)) {
      return true;
    }

    if (size != other.size) {
      return false;
    }

    if (!query.isEqual(other.query)) {
      return false;
    }

    // Compare documents
    return const ListEquality<QueryDocumentSnapshot<Object?>>().equals(
          docs,
          other.docs,
        ) &&
        const ListEquality<DocumentChange<Object?>>().equals(
          docChanges,
          other.docChanges,
        );
  }

  @override
  bool operator ==(Object other) {
    return other is VectorQuerySnapshot<T> && isEqual(other);
  }

  @override
  int get hashCode => Object.hash(
    query,
    const ListEquality<QueryDocumentSnapshot<Object?>>().hash(docs),
    const ListEquality<DocumentChange<Object?>>().hash(docChanges),
  );
}
