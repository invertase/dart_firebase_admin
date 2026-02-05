part of '../firestore.dart';

/// Abstract base class for pipeline aggregate functions.
///
/// Aggregate functions compute values across groups of documents:
/// - [CountAggregate] - counts documents
/// - [SumAggregate] - sums field values
/// - [AverageAggregate] - averages field values
/// - [MinimumAggregate] - finds minimum value
/// - [MaximumAggregate] - finds maximum value
///
/// Create aggregates using factory constructors or top-level classes.
@immutable
abstract class AggregateFunction {
  const AggregateFunction._();

  /// Creates a count aggregation.
  factory AggregateFunction.count() => const CountAggregate._();

  /// Creates a count all aggregation (counts all documents including nulls).
  factory AggregateFunction.countAll() => const CountAllAggregate._();

  /// Creates a count distinct aggregation.
  factory AggregateFunction.countDistinct(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return CountDistinctAggregate._(field);
  }

  /// Creates a conditional count aggregation.
  factory AggregateFunction.countIf(BooleanExpression condition) =>
      CountIfAggregate._(condition);

  /// Creates a sum aggregation for the specified field.
  factory AggregateFunction.sum(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return SumAggregate._(field);
  }

  /// Creates an average aggregation for the specified field.
  factory AggregateFunction.average(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return AverageAggregate._(field);
  }

  /// Creates a minimum aggregation for the specified field.
  factory AggregateFunction.minimum(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return MinimumAggregate._(field);
  }

  /// Creates a maximum aggregation for the specified field.
  factory AggregateFunction.maximum(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return MaximumAggregate._(field);
  }

  /// Returns an aliased version of this aggregate.
  AliasedAggregate as(String alias) => AliasedAggregate._(this, alias);

  /// Converts this aggregate function to googleapis proto format.
  firestore_v1.Value _toProto(Firestore firestore);

  /// Helper to convert field (String or FieldPath) to proto Value.
  static firestore_v1.Value _fieldOrPathValue(Object field) {
    if (field is String) {
      return firestore_v1.Value(stringValue: field);
    } else if (field is FieldPath) {
      return firestore_v1.Value(stringValue: field._formattedName);
    }
    throw ArgumentError('field must be String or FieldPath');
  }
}

/// Counts the number of documents.
@immutable
final class CountAggregate extends AggregateFunction {
  const CountAggregate._() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountAggregate && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CountAggregate()';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(name: 'count', args: []),
    );
  }
}

/// Counts all documents (including those with null values).
@immutable
final class CountAllAggregate extends AggregateFunction {
  const CountAllAggregate._() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountAllAggregate && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'CountAllAggregate()';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(name: 'count', args: []),
    );
  }
}

/// Counts distinct values of a field.
@immutable
final class CountDistinctAggregate extends AggregateFunction {
  const CountDistinctAggregate._(this.field) : super._();

  /// The field to count distinct values for.
  final Object field; // String or FieldPath

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountDistinctAggregate &&
          runtimeType == other.runtimeType &&
          field == other.field;

  @override
  int get hashCode => Object.hash(runtimeType, field);

  @override
  String toString() => 'CountDistinctAggregate($field)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'count_distinct',
        args: [AggregateFunction._fieldOrPathValue(field)],
      ),
    );
  }
}

/// Counts documents matching a condition.
@immutable
final class CountIfAggregate extends AggregateFunction {
  const CountIfAggregate._(this.condition) : super._();

  /// The condition to evaluate.
  final BooleanExpression condition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountIfAggregate &&
          runtimeType == other.runtimeType &&
          condition == other.condition;

  @override
  int get hashCode => Object.hash(runtimeType, condition);

  @override
  String toString() => 'CountIfAggregate($condition)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'count_if',
        args: [condition._toProto(firestore)],
      ),
    );
  }
}

/// Sums field values across documents.
@immutable
final class SumAggregate extends AggregateFunction {
  const SumAggregate._(this.field) : super._();

  /// The field to sum.
  final Object field; // String or FieldPath

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SumAggregate &&
          runtimeType == other.runtimeType &&
          field == other.field;

  @override
  int get hashCode => Object.hash(runtimeType, field);

  @override
  String toString() => 'SumAggregate($field)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'sum',
        args: [AggregateFunction._fieldOrPathValue(field)],
      ),
    );
  }
}

/// Averages field values across documents.
@immutable
final class AverageAggregate extends AggregateFunction {
  const AverageAggregate._(this.field) : super._();

  /// The field to average.
  final Object field; // String or FieldPath

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AverageAggregate &&
          runtimeType == other.runtimeType &&
          field == other.field;

  @override
  int get hashCode => Object.hash(runtimeType, field);

  @override
  String toString() => 'AverageAggregate($field)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'average',
        args: [AggregateFunction._fieldOrPathValue(field)],
      ),
    );
  }
}

/// Finds the minimum field value across documents.
@immutable
final class MinimumAggregate extends AggregateFunction {
  const MinimumAggregate._(this.field) : super._();

  /// The field to find the minimum for.
  final Object field; // String or FieldPath

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinimumAggregate &&
          runtimeType == other.runtimeType &&
          field == other.field;

  @override
  int get hashCode => Object.hash(runtimeType, field);

  @override
  String toString() => 'MinimumAggregate($field)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'minimum',
        args: [AggregateFunction._fieldOrPathValue(field)],
      ),
    );
  }
}

/// Finds the maximum field value across documents.
@immutable
final class MaximumAggregate extends AggregateFunction {
  const MaximumAggregate._(this.field) : super._();

  /// The field to find the maximum for.
  final Object field; // String or FieldPath

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaximumAggregate &&
          runtimeType == other.runtimeType &&
          field == other.field;

  @override
  int get hashCode => Object.hash(runtimeType, field);

  @override
  String toString() => 'MaximumAggregate($field)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function_(
        name: 'maximum',
        args: [AggregateFunction._fieldOrPathValue(field)],
      ),
    );
  }
}

// Note: We don't create lowercase top-level classes here to avoid
// conflicts with existing aggregate classes in aggregate.dart.
// Use factory constructors or expression functions instead.
