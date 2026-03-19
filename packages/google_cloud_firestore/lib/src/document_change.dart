// Copyright 2024 Google LLC
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

part of 'firestore.dart';

enum DocumentChangeType { added, removed, modified }

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
