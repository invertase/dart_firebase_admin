part of '../firestore.dart';

/// Explain statistics for pipeline execution.
///
/// Provides details about query planning and execution performance.
/// The format depends on the `explainOptions.outputFormat` setting in the request.
@immutable
final class ExplainStats {
  const ExplainStats._(this.data);

  /// Creates ExplainStats from googleapis proto.
  factory ExplainStats._fromProto(firestore_v1.ExplainStats proto) {
    return const ExplainStats._({});
  }

  /// The raw explain stats data from the server.
  ///
  /// The format depends on the `explainOptions.outputFormat` in the request:
  /// - If `outputFormat: 'text'`, the data contains a string representation
  /// - If `outputFormat: 'json'`, the data contains a JSON object
  final Map<String, Object?> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplainStats &&
          runtimeType == other.runtimeType &&
          const MapEquality<String, Object?>().equals(data, other.data);

  @override
  int get hashCode => const MapEquality<String, Object?>().hash(data);

  @override
  String toString() => 'ExplainStats(data: $data)';
}
