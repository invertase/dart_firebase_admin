part of '../firestore.dart';

@immutable
class AggregateQuery {
  const AggregateQuery._({required this.query, required this.aggregations});

  /// The query whose aggregations will be calculated by this object.
  final Query<Object?> query;

  @internal
  final List<AggregateFieldInternal> aggregations;

  /// Executes the aggregate query and returns the results as an
  /// [AggregateQuerySnapshot].
  ///
  /// ```dart
  /// firestore.collection('cities').count().get().then(
  ///   (res) => print(res.count),
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  Future<AggregateQuerySnapshot> get() async {
    final firestore = query.firestore;

    final aggregationQuery = firestore_v1.RunAggregationQueryRequest(
      structuredAggregationQuery: firestore_v1.StructuredAggregationQuery(
        structuredQuery: query._toStructuredQuery(),
        aggregations: [
          for (final field in aggregations)
            firestore_v1.Aggregation(
              alias: field.alias,
              count: field.aggregation.count,
              sum: field.aggregation.sum,
              avg: field.aggregation.avg,
            ),
        ],
      ),
    );

    final response = await firestore._firestoreClient.v1((
      api,
      projectId,
    ) async {
      return api.projects.databases.documents.runAggregationQuery(
        aggregationQuery,
        query._buildProtoParentPath(),
      );
    });

    final results = <String, Object?>{};
    Timestamp? readTime;

    for (final result in response) {
      if (result.result != null && result.result!.aggregateFields != null) {
        for (final entry in result.result!.aggregateFields!.entries) {
          final value = entry.value;
          if (value.integerValue != null) {
            results[entry.key] = int.parse(value.integerValue!);
          } else if (value.doubleValue != null) {
            results[entry.key] = value.doubleValue;
          } else if (value.nullValue != null) {
            results[entry.key] = null;
          }
        }
      }

      if (result.readTime != null) {
        readTime = Timestamp._fromString(result.readTime!);
      }
    }

    return AggregateQuerySnapshot._(
      query: this,
      readTime: readTime,
      data: results,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AggregateQuery &&
        query == other.query &&
        const ListEquality<AggregateFieldInternal>().equals(
          aggregations,
          other.aggregations,
        );
  }

  @override
  int get hashCode => Object.hash(
    query,
    const ListEquality<AggregateFieldInternal>().hash(aggregations),
  );
}
