part of '../firestore.dart';

/// Specifies the sort order for a pipeline expression.
///
/// Create ordering using factory constructors:
/// ```dart
/// Ordering.ascending(Expression.field('name'))
/// Ordering.descending(Expression.field('age'))
/// ```
@immutable
final class Ordering {
  /// Creates an ascending sort order.
  factory Ordering.ascending(Expression expression) =>
      Ordering._(expression, 'ASCENDING');

  /// Creates a descending sort order.
  factory Ordering.descending(Expression expression) =>
      Ordering._(expression, 'DESCENDING');
  const Ordering._(this.expression, this.direction);

  /// The expression to sort by.
  final Expression expression;

  /// The sort direction ('ASCENDING' or 'DESCENDING').
  final String direction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ordering &&
          runtimeType == other.runtimeType &&
          expression == other.expression &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(expression, direction);

  @override
  String toString() => 'Ordering($expression, $direction)';

  /// Converts this ordering to googleapis proto format.
  firestore_v1.Value _toProto(Firestore firestore) {
    // Server expects lowercase direction names
    final directionLowercase = direction.toLowerCase();
    return firestore_v1.Value(
      mapValue: firestore_v1.MapValue(
        fields: {
          'expression': expression._toProto(firestore),
          'direction': firestore_v1.Value(stringValue: directionLowercase),
        },
      ),
    );
  }
}
