part of '../firestore.dart';

/// Marker interface for values that can be selected in a pipeline.
///
/// Used to constrain the types accepted by the select() method.
abstract interface class Selectable {}

/// An expression with an alias.
///
/// Create aliased expressions using the [Expression.as] method:
/// ```dart
/// field('age').as('userAge')
/// constant(42).as('answer')
/// ```
@immutable
final class AliasedExpression implements Selectable {
  const AliasedExpression._(this.expression, this.alias);

  /// The underlying expression.
  final Expression expression;

  /// The alias for this expression.
  final String alias;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliasedExpression &&
          runtimeType == other.runtimeType &&
          expression == other.expression &&
          alias == other.alias;

  @override
  int get hashCode => Object.hash(expression, alias);

  @override
  String toString() => 'AliasedExpression($expression, as: $alias)';

  /// Converts this aliased expression to googleapis proto format.
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      mapValue: firestore_v1.MapValue(
        fields: {
          'expression': expression._toProto(firestore),
          'alias': firestore_v1.Value(stringValue: alias),
        },
      ),
    );
  }
}

/// An aggregate function with an alias.
///
/// Create aliased aggregates using the [AggregateFunction.as] method:
/// ```dart
/// AggregateFunction.count().as('totalCount')
/// AggregateFunction.sum('price').as('totalPrice')
/// ```
@immutable
final class AliasedAggregate {
  const AliasedAggregate._(this.aggregate, this.alias);

  /// The underlying aggregate function.
  final AggregateFunction aggregate;

  /// The alias for this aggregate.
  final String alias;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliasedAggregate &&
          runtimeType == other.runtimeType &&
          aggregate == other.aggregate &&
          alias == other.alias;

  @override
  int get hashCode => Object.hash(aggregate, alias);

  @override
  String toString() => 'AliasedAggregate($aggregate, as: $alias)';

  /// Converts this aliased aggregate to googleapis proto format.
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      mapValue: firestore_v1.MapValue(
        fields: {
          'aggregate': aggregate._toProto(firestore),
          'alias': firestore_v1.Value(stringValue: alias),
        },
      ),
    );
  }
}
