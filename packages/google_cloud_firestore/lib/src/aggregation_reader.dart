part of 'firestore.dart';

/// Response wrapper containing both aggregation results and transaction ID.
class _AggregationReaderResponse {
  _AggregationReaderResponse(this.result, this.transaction);

  final AggregateQuerySnapshot result;
  final String? transaction;
}

/// Reader class for executing aggregation queries within transactions.
///
/// Follows the same pattern as [_QueryReader] to handle:
/// - Lazy transaction initialization via `transactionOptions`
/// - Reusing existing transactions via `transactionId`
/// - Read-only snapshots via `readTime`
/// - Capturing and returning transaction IDs from responses
class _AggregationReader {
  _AggregationReader({
    required this.aggregateQuery,
    this.transactionId,
    this.readTime,
    this.transactionOptions,
  }) : assert(
         [transactionId, readTime, transactionOptions].nonNulls.length <= 1,
         'Only transactionId or readTime or transactionOptions must be provided. '
         'transactionId = $transactionId, readTime = $readTime, transactionOptions = $transactionOptions',
       );

  final AggregateQuery aggregateQuery;
  final String? transactionId;
  final Timestamp? readTime;
  final firestore_v1.TransactionOptions? transactionOptions;

  String? _retrievedTransactionId;

  /// Executes the aggregation query and captures the transaction ID from the response.
  ///
  /// Returns a [_AggregationReaderResponse] containing both the aggregation results
  /// and the transaction ID (if one was started or provided).
  Future<_AggregationReaderResponse> _get() async {
    final request = aggregateQuery._toProto(
      transactionId: transactionId,
      readTime: readTime,
      transactionOptions: transactionOptions,
    );

    final response = await aggregateQuery.query.firestore._firestoreClient.v1((
      api,
      projectId,
    ) async {
      return api.projects.databases.documents.runAggregationQuery(
        request,
        aggregateQuery.query._buildProtoParentPath(),
      );
    });

    final results = <String, Object?>{};
    Timestamp? aggregationReadTime;

    // Process streaming response
    for (final result in response) {
      // Capture transaction ID from response (if present)
      if (result.transaction?.isNotEmpty ?? false) {
        _retrievedTransactionId = result.transaction;
      }

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
        aggregationReadTime = Timestamp._fromString(result.readTime!);
      }
    }

    // Return both aggregation results and transaction ID
    return _AggregationReaderResponse(
      AggregateQuerySnapshot._(
        query: aggregateQuery,
        readTime: aggregationReadTime,
        data: results,
      ),
      _retrievedTransactionId,
    );
  }
}
