part of '../firestore.dart';

/// Options to use when explaining a query.
class ExplainOptions {
  const ExplainOptions({this.analyze});

  /// Whether to execute the query.
  ///
  /// When false (the default), the query will be planned, returning only
  /// metrics from the planning stages.
  ///
  /// When true, the query will be planned and executed, returning the full
  /// query results along with both planning and execution stage metrics.
  final bool? analyze;

  firestore_v1.ExplainOptions toProto() {
    return firestore_v1.ExplainOptions(analyze: analyze);
  }
}
