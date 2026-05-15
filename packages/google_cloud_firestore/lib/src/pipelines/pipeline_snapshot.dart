part of '../firestore.dart';

/// The results of executing a pipeline.
///
/// Contains the pipeline that was executed, the results, and execution metadata.
@immutable
final class PipelineSnapshot {
  const PipelineSnapshot._({
    required this.pipeline,
    required this.results,
    required this.executionTime,
    this.explainStats,
  });

  /// The pipeline that was executed.
  final Pipeline pipeline;

  /// The results of the pipeline execution.
  final List<PipelineResult> results;

  /// The time this snapshot was obtained.
  final Timestamp executionTime;

  /// Optional execution statistics (if explain was enabled).
  final ExplainStats? explainStats;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineSnapshot &&
          runtimeType == other.runtimeType &&
          pipeline == other.pipeline &&
          const ListEquality<PipelineResult>().equals(results, other.results) &&
          executionTime == other.executionTime &&
          explainStats == other.explainStats;

  @override
  int get hashCode => Object.hash(
    pipeline,
    const ListEquality<PipelineResult>().hash(results),
    executionTime,
    explainStats,
  );

  @override
  String toString() =>
      'PipelineSnapshot(pipeline: $pipeline, results: ${results.length} documents)';
}

/// A single result from a pipeline execution.
///
/// Contains document data and metadata.
@immutable
final class PipelineResult {
  const PipelineResult._({
    required this.ref,
    required this.id,
    required this.createTime,
    required this.updateTime,
    required Map<String, Object?> data,
  }) : _data = data;

  /// Reference to the document (may be null for aggregated results).
  final DocumentReference<Object?>? ref;

  /// Document ID (may be null for aggregated results).
  final String? id;

  /// Document creation time (may be null for aggregated results).
  final Timestamp? createTime;

  /// Document update time (may be null for aggregated results).
  final Timestamp? updateTime;

  final Map<String, Object?> _data;

  /// Returns the data contained in this result.
  Map<String, Object?> data() => Map.unmodifiable(_data);

  /// Gets a specific field from the result.
  ///
  /// Accepts either a String field path or a [FieldPath] object.
  Object? get(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );

    if (field is String) {
      // Simple field access
      if (!field.contains('.')) {
        return _data[field];
      }
      // Nested field access
      final parts = field.split('.');
      dynamic current = _data;
      for (final part in parts) {
        if (current is! Map) return null;
        current = current[part];
        if (current == null) return null;
      }
      return current;
    } else {
      // FieldPath access
      final fieldPath = field as FieldPath;
      dynamic current = _data;
      for (final segment in fieldPath.segments) {
        if (current is! Map) return null;
        current = current[segment];
        if (current == null) return null;
      }
      return current;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelineResult &&
          runtimeType == other.runtimeType &&
          ref == other.ref &&
          id == other.id &&
          createTime == other.createTime &&
          updateTime == other.updateTime &&
          const MapEquality<String, Object?>().equals(_data, other._data);

  @override
  int get hashCode => Object.hash(
    ref,
    id,
    createTime,
    updateTime,
    const MapEquality<String, Object?>().hash(_data),
  );

  @override
  String toString() => 'PipelineResult(id: $id, data: $_data)';
}

// Note: ExecutionStats is already defined in query_profile.dart
// We'll reuse that class instead of creating a duplicate
