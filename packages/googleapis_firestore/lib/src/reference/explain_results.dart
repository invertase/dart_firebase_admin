part of '../firestore.dart';

/// ExplainResults contains information about planning, execution, and results
/// of a query.
class ExplainResults<T> {
  const ExplainResults._({required this.metrics, this.snapshot});

  factory ExplainResults._create({
    required ExplainMetrics metrics,
    T? snapshot,
  }) {
    return ExplainResults._(metrics: metrics, snapshot: snapshot);
  }

  /// Information about planning and execution of the query.
  final ExplainMetrics metrics;

  /// The snapshot that contains the results of executing the query.
  ///
  /// Null if the query was not executed (i.e., [ExplainOptions.analyze] was false).
  final T? snapshot;
}
