part of '../firestore.dart';

/// The results of executing an aggregation query.
@immutable
class AggregateQuerySnapshot {
  const AggregateQuerySnapshot._({
    required this.query,
    required this.readTime,
    required this.data,
  });

  /// The query that was executed to produce this result.
  final AggregateQuery query;

  /// The time this snapshot was obtained.
  final Timestamp? readTime;

  /// The raw aggregation data, keyed by alias.
  final Map<String, Object?> data;

  /// The count of documents that match the query. Returns `null` if the
  /// count aggregation was not performed.
  int? get count => data['count'] as int?;

  /// Gets the sum for the specified field. Returns `null` if the
  /// sum aggregation was not performed.
  ///
  /// - [field]: The field that was summed.
  num? getSum(String field) {
    final alias = 'sum_$field';
    final value = data[alias];
    if (value == null) return null;
    if (value is int || value is double) return value as num;
    // Handle case where sum might be returned as a string
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Gets the average for the specified field. Returns `null` if the
  /// average aggregation was not performed.
  ///
  /// - [field]: The field that was averaged.
  double? getAverage(String field) {
    final alias = 'avg_$field';
    final value = data[alias];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    // Handle case where average might be returned as a string
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Gets an aggregate field by alias.
  ///
  /// - [alias]: The alias of the aggregate field to retrieve.
  Object? getField(String alias) => data[alias];

  @override
  bool operator ==(Object other) {
    return other is AggregateQuerySnapshot &&
        query == other.query &&
        readTime == other.readTime &&
        const MapEquality<String, Object?>().equals(data, other.data);
  }

  @override
  int get hashCode => Object.hash(query, readTime, data);
}
