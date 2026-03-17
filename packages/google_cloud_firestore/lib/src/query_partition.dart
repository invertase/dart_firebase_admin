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

part of 'firestore.dart';

/// A split point that can be used in a query as a starting and/or end point for
/// the query results.
///
/// The cursors returned by [startAt] and [endBefore] can only be used in a
/// query that matches the constraint of query that produced this partition.
final class QueryPartition<T extends Object?> {
  /// @nodoc
  QueryPartition(
    this._firestore,
    this._collectionId,
    this._converter,
    this._startAt,
    this._endBefore,
  );

  final Firestore _firestore;
  final String _collectionId;
  final _FirestoreDataConverter<T> _converter;
  final List<firestore_v1.Value>? _startAt;
  final List<firestore_v1.Value>? _endBefore;

  List<Object?>? _memoizedStartAt;
  List<Object?>? _memoizedEndBefore;

  /// The cursor that defines the first result for this partition or `null`
  /// if this is the first partition.
  ///
  /// The cursor value must be passed to `startAt()`.
  ///
  /// Example:
  /// ```dart
  /// final query = firestore.collectionGroup('collectionId');
  /// await for (final partition in query.getPartitions(42)) {
  ///   var partitionedQuery = query.orderBy(FieldPath.documentId);
  ///   if (partition.startAt != null) {
  ///     partitionedQuery = partitionedQuery.startAt(values: partition.startAt!);
  ///   }
  ///   if (partition.endBefore != null) {
  ///     partitionedQuery = partitionedQuery.endBefore(values: partition.endBefore!);
  ///   }
  ///   final querySnapshot = await partitionedQuery.get();
  ///   print('Partition contained ${querySnapshot.docs.length} documents');
  /// }
  /// ```
  List<Object?>? get startAt {
    if (_startAt != null && _memoizedStartAt == null) {
      _memoizedStartAt = _startAt
          .map<Object?>(_firestore._serializer.decodeValue)
          .toList();
    }
    return _memoizedStartAt;
  }

  /// The cursor that defines the first result after this partition or `null`
  /// if this is the last partition.
  ///
  /// The cursor value must be passed to `endBefore()`.
  ///
  /// Example:
  /// ```dart
  /// final query = firestore.collectionGroup('collectionId');
  /// await for (final partition in query.getPartitions(42)) {
  ///   var partitionedQuery = query.orderBy(FieldPath.documentId);
  ///   if (partition.startAt != null) {
  ///     partitionedQuery = partitionedQuery.startAt(values: partition.startAt!);
  ///   }
  ///   if (partition.endBefore != null) {
  ///     partitionedQuery = partitionedQuery.endBefore(values: partition.endBefore!);
  ///   }
  ///   final querySnapshot = await partitionedQuery.get();
  ///   print('Partition contained ${querySnapshot.docs.length} documents');
  /// }
  /// ```
  List<Object?>? get endBefore {
    if (_endBefore != null && _memoizedEndBefore == null) {
      _memoizedEndBefore = _endBefore
          .map<Object?>(_firestore._serializer.decodeValue)
          .toList();
    }
    return _memoizedEndBefore;
  }

  /// Returns a query that only encapsulates the documents for this partition.
  ///
  /// Example:
  /// ```dart
  /// final query = firestore.collectionGroup('collectionId');
  /// await for (final partition in query.getPartitions(42)) {
  ///   final partitionedQuery = partition.toQuery();
  ///   final querySnapshot = await partitionedQuery.get();
  ///   print('Partition contained ${querySnapshot.docs.length} documents');
  /// }
  /// ```
  ///
  /// Returns a query partitioned by [startAt] and [endBefore] cursors.
  Query<T> toQuery() {
    // Since the api.Value to Dart type conversion can be lossy,
    // we pass the original protobuf representation to the created query.
    var queryOptions = _QueryOptions.forCollectionGroupQuery(
      _collectionId,
      _converter,
    );

    queryOptions = queryOptions.copyWith(
      fieldOrders: [_FieldOrder(fieldPath: FieldPath.documentId)],
    );

    if (_startAt != null) {
      queryOptions = queryOptions.copyWith(
        startAt: _QueryCursor(before: true, values: _startAt),
      );
    }

    if (_endBefore != null) {
      queryOptions = queryOptions.copyWith(
        endAt: _QueryCursor(before: true, values: _endBefore),
      );
    }

    return Query._(firestore: _firestore, queryOptions: queryOptions);
  }
}
