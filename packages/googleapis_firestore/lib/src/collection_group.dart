part of 'firestore.dart';

@immutable
final class CollectionGroup<T> extends Query<T> {
  CollectionGroup._(
    String collectionId, {
    required super.firestore,
    required _FirestoreDataConverter<T> converter,
  }) : super._(
         queryOptions: _QueryOptions.forCollectionGroupQuery(
           collectionId,
           converter,
         ),
       );

  /// Partitions a query by returning partition cursors that can be used to run
  /// the query in parallel.
  ///
  /// The returned partition cursors are split points that can be used as
  /// starting and end points for individual query invocations.
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
  /// [desiredPartitionCount] The desired maximum number of partition points.
  /// The number must be strictly positive. The actual number of partitions
  /// returned may be fewer.
  ///
  /// Returns a stream of [QueryPartition]s.
  Stream<QueryPartition<T>> getPartitions(int desiredPartitionCount) async* {
    final partitions = <List<firestore_v1.Value>>[];

    // Validate the partition count
    if (desiredPartitionCount < 1) {
      throw FirestoreException(
        FirestoreClientErrorCode.invalidArgument,
        'Value for argument "desiredPartitionCount" must be within [1, Infinity] inclusive, but was: $desiredPartitionCount',
      );
    }

    if (desiredPartitionCount > 1) {
      // Partition queries require explicit ordering by __name__.
      final queryWithDefaultOrder = orderBy(FieldPath.documentId);
      final structuredQuery = queryWithDefaultOrder._toStructuredQuery();

      // Since we are always returning an extra partition (with an empty endBefore
      // cursor), we reduce the desired partition count by one.
      final partitionRequest = firestore_v1.PartitionQueryRequest(
        structuredQuery: structuredQuery,
        partitionCount: '${desiredPartitionCount - 1}',
      );

      final response = await firestore._firestoreClient.v1((api, projectId) {
        return api.projects.databases.documents.partitionQuery(
          partitionRequest,
          '${firestore._formattedDatabaseName}/documents',
        );
      });

      if (response.partitions != null) {
        for (final cursor in response.partitions!) {
          if (cursor.values != null) {
            partitions.add(cursor.values!);
          }
        }
      }

      // Sort partitions as they may not be ordered if responses are paged
      mergeSort(partitions, compare: _compareValueLists);
    }

    // Yield partitions
    for (var i = 0; i < partitions.length; i++) {
      yield QueryPartition<T>(
        firestore,
        _queryOptions.collectionId,
        _queryOptions.converter,
        i > 0 ? partitions[i - 1] : null,
        partitions[i],
      );
    }

    // Return the extra partition with the empty cursor.
    yield QueryPartition<T>(
      firestore,
      _queryOptions.collectionId,
      _queryOptions.converter,
      partitions.isNotEmpty ? partitions.last : null,
      null,
    );
  }

  @override
  CollectionGroup<U> withConverter<U>({
    required FromFirestore<U> fromFirestore,
    required ToFirestore<U> toFirestore,
  }) {
    return CollectionGroup._(
      _queryOptions.collectionId,
      firestore: firestore,
      converter: (fromFirestore: fromFirestore, toFirestore: toFirestore),
    );
  }

  @override
  // ignore: hash_and_equals, already implemented by Query
  bool operator ==(Object other) {
    return super == other && other is CollectionGroup<T>;
  }
}

/// Compares two lists of Firestore Values for sorting partition cursors.
///
/// This is used to sort partition query results as they may not be ordered
/// if responses are paged.
///
/// The comparison follows Firestore's ordering semantics:
/// - Compares element-by-element until a difference is found
/// - If all elements are equal, compares list lengths
///
/// Note: Currently handles common partition cursor cases (document references).
int _compareValueLists(
  List<firestore_v1.Value> left,
  List<firestore_v1.Value> right,
) {
  // Compare element by element
  for (var i = 0; i < left.length && i < right.length; i++) {
    final comparison = _compareValues(left[i], right[i]);
    if (comparison != 0) {
      return comparison;
    }
  }

  // If all values matched, compare lengths
  return left.length.compareTo(right.length);
}

/// Compares two Firestore Values.
///
/// Implements basic comparison for common partition cursor types.
/// Partition cursors are typically document references ordered by __name__.
int _compareValues(firestore_v1.Value left, firestore_v1.Value right) {
  // Document references (most common case for partition cursors)
  if (left.referenceValue != null && right.referenceValue != null) {
    return left.referenceValue!.compareTo(right.referenceValue!);
  }

  // String values
  if (left.stringValue != null && right.stringValue != null) {
    return left.stringValue!.compareTo(right.stringValue!);
  }

  // Integer values
  if (left.integerValue != null && right.integerValue != null) {
    final leftInt = int.parse(left.integerValue!);
    final rightInt = int.parse(right.integerValue!);
    return leftInt.compareTo(rightInt);
  }

  // Double values
  if (left.doubleValue != null && right.doubleValue != null) {
    return left.doubleValue!.compareTo(right.doubleValue!);
  }

  // Timestamp values (RFC 3339 strings are lexicographically sortable)
  if (left.timestampValue != null && right.timestampValue != null) {
    return left.timestampValue!.compareTo(right.timestampValue!);
  }

  // Boolean values
  if (left.booleanValue != null && right.booleanValue != null) {
    return left.booleanValue! == right.booleanValue!
        ? 0
        : (left.booleanValue! ? 1 : -1);
  }

  // Null values (always equal)
  if (left.nullValue != null && right.nullValue != null) {
    return 0;
  }

  // TODO: Implement full Firestore type ordering (blob, geopoint, array, map, vector)
  // For now, fall back to comparing hash codes (unstable but at least consistent)
  return left.hashCode.compareTo(right.hashCode);
}
