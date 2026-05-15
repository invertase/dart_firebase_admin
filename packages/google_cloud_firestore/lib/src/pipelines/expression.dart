part of '../firestore.dart';

/// Abstract base class for all pipeline expressions.
///
/// Expressions represent values in pipeline operations and can be:
/// - Field references (via [Field])
/// - Constant values (via [Constant])
/// - Function calls (via [FunctionExpression])
/// - Boolean expressions (via [BooleanExpression])
///
/// Expressions support method chaining and can be combined using operators.
@immutable
abstract class Expression {
  const Expression._();

  // Factory constructors for creating expressions

  /// Creates a field reference expression.
  ///
  /// Example:
  /// ```dart
  /// Expression.field('name')
  /// Expression.field('address.city')
  /// ```
  factory Expression.field(String fieldPath) => Field._(fieldPath);

  /// Creates a constant value expression.
  ///
  /// Example:
  /// ```dart
  /// Expression.constant(42)
  /// Expression.constant('hello')
  /// Expression.constant(true)
  /// ```
  factory Expression.constant(Object? value) => Constant._(value);

  /// Creates a map expression from field mappings.
  ///
  /// Example:
  /// ```dart
  /// Expression.map({'name': Expression.field('fullName'), 'age': Expression.constant(25)})
  /// ```
  factory Expression.map(Map<String, Expression> fields) =>
      FunctionExpression._('map', [Constant._(fields)]);

  /// Creates an array expression from elements.
  ///
  /// Example:
  /// ```dart
  /// Expression.array([Expression.field('item1'), Expression.field('item2')])
  /// ```
  factory Expression.array(List<Expression> elements) =>
      FunctionExpression._('array', elements);

  // String functions

  /// Concatenates two string expressions.
  factory Expression.stringConcat(Expression first, Expression second) =>
      FunctionExpression._('stringConcat', [first, second]);

  /// Extracts a substring from a string.
  factory Expression.substring(
    Expression str,
    Expression start, [
    Expression? end,
  ]) => end != null
      ? FunctionExpression._('substring', [str, start, end])
      : FunctionExpression._('substring', [str, start]);

  /// Converts a string to uppercase.
  factory Expression.toUpper(Expression str) =>
      FunctionExpression._('toUpper', [str]);

  /// Converts a string to lowercase.
  factory Expression.toLower(Expression str) =>
      FunctionExpression._('toLower', [str]);

  /// Trims whitespace from a string.
  factory Expression.trim(Expression str) =>
      FunctionExpression._('trim', [str]);

  /// Returns the character length of a string.
  factory Expression.charLength(Expression str) =>
      FunctionExpression._('charLength', [str]);

  /// Reverses a string.
  factory Expression.stringReverse(Expression str) =>
      FunctionExpression._('stringReverse', [str]);

  /// Splits a string by a delimiter.
  factory Expression.split(Expression str, Expression delimiter) =>
      FunctionExpression._('split', [str, delimiter]);

  /// Joins array elements into a string.
  factory Expression.join(Expression array, Expression delimiter) =>
      FunctionExpression._('join', [array, delimiter]);

  /// Concatenates multiple expressions.
  factory Expression.concat(
    Expression first,
    Expression second, [
    Expression? third,
    Expression? fourth,
  ]) => third != null && fourth != null
      ? FunctionExpression._('concat', [first, second, third, fourth])
      : third != null
      ? FunctionExpression._('concat', [first, second, third])
      : FunctionExpression._('concat', [first, second]);

  // Array functions

  /// Concatenates two array expressions.
  factory Expression.arrayConcat(Expression first, Expression second) =>
      FunctionExpression._('arrayConcat', [first, second]);

  /// Returns the length of an array.
  factory Expression.arrayLength(Expression array) =>
      FunctionExpression._('arrayLength', [array]);

  /// Gets an element from an array by index.
  factory Expression.arrayGet(Expression array, Expression index) =>
      FunctionExpression._('arrayGet', [array, index]);

  /// Reverses an array.
  factory Expression.arrayReverse(Expression array) =>
      FunctionExpression._('arrayReverse', [array]);

  /// Returns the sum of array elements.
  factory Expression.arraySum(Expression array) =>
      FunctionExpression._('arraySum', [array]);

  // Math functions

  /// Returns the absolute value of an expression.
  factory Expression.abs(Expression value) =>
      FunctionExpression._('abs', [value]);

  /// Returns the ceiling of an expression.
  factory Expression.ceil(Expression value) =>
      FunctionExpression._('ceil', [value]);

  /// Returns the floor of an expression.
  factory Expression.floor(Expression value) =>
      FunctionExpression._('floor', [value]);

  /// Rounds an expression to the nearest integer.
  factory Expression.round(Expression value) =>
      FunctionExpression._('round', [value]);

  /// Returns the square root of an expression.
  factory Expression.sqrt(Expression value) =>
      FunctionExpression._('sqrt', [value]);

  /// Raises the base to the power of the exponent.
  factory Expression.pow(Expression base, Expression exponent) =>
      FunctionExpression._('pow', [base, exponent]);

  /// Returns e raised to the power of the expression.
  factory Expression.exp(Expression value) =>
      FunctionExpression._('exp', [value]);

  /// Returns the natural logarithm of an expression.
  factory Expression.ln(Expression value) =>
      FunctionExpression._('ln', [value]);

  /// Returns the base-10 logarithm of an expression.
  factory Expression.log10(Expression value) =>
      FunctionExpression._('log10', [value]);

  // Vector functions

  /// Calculates cosine distance between two vectors.
  factory Expression.cosineDistance(Expression vector1, Expression vector2) =>
      FunctionExpression._('cosineDistance', [vector1, vector2]);

  /// Calculates dot product of two vectors.
  factory Expression.dotProduct(Expression vector1, Expression vector2) =>
      FunctionExpression._('dotProduct', [vector1, vector2]);

  /// Calculates Euclidean distance between two vectors.
  factory Expression.euclideanDistance(
    Expression vector1,
    Expression vector2,
  ) => FunctionExpression._('euclideanDistance', [vector1, vector2]);

  /// Returns the length (magnitude) of a vector.
  factory Expression.vectorLength(Expression vector) =>
      FunctionExpression._('vectorLength', [vector]);

  // Map functions

  /// Gets a value from a map by key.
  factory Expression.mapGet(Expression map, Expression key) =>
      FunctionExpression._('mapGet', [map, key]);

  /// Merges two maps.
  factory Expression.mapMerge(Expression first, Expression second) =>
      FunctionExpression._('mapMerge', [first, second]);

  /// Removes keys from a map.
  factory Expression.mapRemove(Expression map, Expression keys) =>
      FunctionExpression._('mapRemove', [map, keys]);

  // Conditional functions

  /// Returns one value if condition is true, another if false.
  factory Expression.conditional(
    BooleanExpression condition,
    Expression ifTrue,
    Expression ifFalse,
  ) => FunctionExpression._('conditional', [condition, ifTrue, ifFalse]);

  /// Returns a default value if the expression is absent.
  factory Expression.ifAbsent(Expression expr, Expression defaultValue) =>
      FunctionExpression._('ifAbsent', [expr, defaultValue]);

  /// Returns a default value if the expression results in an error.
  factory Expression.ifError(Expression expr, Expression defaultValue) =>
      FunctionExpression._('ifError', [expr, defaultValue]);

  // Timestamp functions

  /// Returns the current timestamp.
  factory Expression.currentTimestamp() =>
      const FunctionExpression._('currentTimestamp', []);

  /// Adds a duration to a timestamp.
  factory Expression.timestampAdd(
    Expression timestamp,
    Expression duration,
    Expression unit,
  ) => FunctionExpression._('timestampAdd', [timestamp, duration, unit]);

  /// Subtracts a duration from a timestamp.
  factory Expression.timestampSubtract(
    Expression timestamp,
    Expression duration,
    Expression unit,
  ) => FunctionExpression._('timestampSubtract', [timestamp, duration, unit]);

  /// Truncates a timestamp to a unit.
  factory Expression.timestampTruncate(Expression timestamp, Expression unit) =>
      FunctionExpression._('timestampTruncate', [timestamp, unit]);

  /// Converts a timestamp to Unix seconds.
  factory Expression.timestampToUnixSeconds(Expression timestamp) =>
      FunctionExpression._('timestampToUnixSeconds', [timestamp]);

  /// Converts a timestamp to Unix milliseconds.
  factory Expression.timestampToUnixMillis(Expression timestamp) =>
      FunctionExpression._('timestampToUnixMillis', [timestamp]);

  /// Converts a timestamp to Unix microseconds.
  factory Expression.timestampToUnixMicros(Expression timestamp) =>
      FunctionExpression._('timestampToUnixMicros', [timestamp]);

  /// Converts Unix seconds to a timestamp.
  factory Expression.unixSecondsToTimestamp(Expression seconds) =>
      FunctionExpression._('unixSecondsToTimestamp', [seconds]);

  /// Converts Unix milliseconds to a timestamp.
  factory Expression.unixMillisToTimestamp(Expression millis) =>
      FunctionExpression._('unixMillisToTimestamp', [millis]);

  /// Converts Unix microseconds to a timestamp.
  factory Expression.unixMicrosToTimestamp(Expression micros) =>
      FunctionExpression._('unixMicrosToTimestamp', [micros]);

  // Special functions

  /// Returns the document ID.
  factory Expression.documentId() =>
      const FunctionExpression._('documentId', []);

  /// Returns the collection ID.
  factory Expression.collectionId() =>
      const FunctionExpression._('collectionId', []);

  /// Returns the type of a value.
  factory Expression.type(Expression value) =>
      FunctionExpression._('type', [value]);

  /// Returns the byte length of a value.
  factory Expression.byteLength(Expression value) =>
      FunctionExpression._('byteLength', [value]);

  /// Returns the logical maximum of two values.
  factory Expression.logicalMaximum(Expression first, Expression second) =>
      FunctionExpression._('logicalMaximum', [first, second]);

  /// Returns the logical minimum of two values.
  factory Expression.logicalMinimum(Expression first, Expression second) =>
      FunctionExpression._('logicalMinimum', [first, second]);

  /// Returns the length of a value (alias for arrayLength/charLength).
  factory Expression.length(Expression value) =>
      FunctionExpression._('length', [value]);

  /// Reverses a value (alias for arrayReverse/stringReverse).
  factory Expression.reverse(Expression value) =>
      FunctionExpression._('reverse', [value]);

  // Instance methods

  /// Returns an aliased version of this expression.
  ///
  /// Example:
  /// ```dart
  /// field('age').as('userAge')
  /// ```
  AliasedExpression as(String alias) => AliasedExpression._(this, alias);

  /// Adds two expressions.
  Expression add(Expression other) =>
      FunctionExpression._('add', [this, other]);

  /// Subtracts another expression from this one.
  Expression subtract(Expression other) =>
      FunctionExpression._('subtract', [this, other]);

  /// Multiplies this expression by another.
  Expression multiply(Expression other) =>
      FunctionExpression._('multiply', [this, other]);

  /// Divides this expression by another.
  Expression divide(Expression other) =>
      FunctionExpression._('divide', [this, other]);

  /// Returns the modulo of this expression by another.
  Expression mod(Expression other) =>
      FunctionExpression._('mod', [this, other]);

  /// Returns true if this expression equals another.
  BooleanExpression equal(Expression other) =>
      BooleanExpression._('equal', [this, other]);

  /// Returns true if this expression does not equal another.
  BooleanExpression notEqual(Expression other) =>
      BooleanExpression._('notEqual', [this, other]);

  /// Returns true if this expression is greater than another.
  BooleanExpression greaterThan(Expression other) =>
      BooleanExpression._('greaterThan', [this, other]);

  /// Returns true if this expression is less than another.
  BooleanExpression lessThan(Expression other) =>
      BooleanExpression._('lessThan', [this, other]);

  /// Returns true if this expression is greater than or equal to another.
  BooleanExpression greaterThanOrEqual(Expression other) =>
      BooleanExpression._('greaterThanOrEqual', [this, other]);

  /// Returns true if this expression is less than or equal to another.
  BooleanExpression lessThanOrEqual(Expression other) =>
      BooleanExpression._('lessThanOrEqual', [this, other]);

  /// Converts this expression to googleapis proto format.
  firestore_v1.Value _toProto(Firestore firestore);
}

/// A reference to a document field in a pipeline expression.
///
/// Create field references using [Expression.field]:
/// ```dart
/// Expression.field('name')
/// Expression.field('address.city')
/// ```
@immutable
final class Field extends Expression implements Selectable {
  const Field._(this.fieldPath) : super._();

  /// The field path (e.g., 'name' or 'address.city').
  final String fieldPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Field &&
          runtimeType == other.runtimeType &&
          fieldPath == other.fieldPath;

  @override
  int get hashCode => fieldPath.hashCode;

  @override
  String toString() => 'Field($fieldPath)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(fieldReferenceValue: fieldPath);
  }
}

/// A constant value in a pipeline expression.
///
/// Create constants using [Expression.constant]:
/// ```dart
/// Expression.constant(42)
/// Expression.constant('hello')
/// Expression.constant(true)
/// Expression.constant(null)
/// ```
@immutable
final class Constant extends Expression {
  const Constant._(this.value) : super._();

  /// The constant value.
  final Object? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Constant &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Constant($value)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore._serializer.encodeValue(value)!;
  }
}

/// A function expression that combines other expressions.
///
/// Function expressions are created by expression operators and factory constructors:
/// ```dart
/// Expression.field('price').add(Expression.constant(10))
/// Expression.stringConcat(Expression.field('firstName'), Expression.field('lastName'))
/// ```
@immutable
final class FunctionExpression extends Expression {
  const FunctionExpression._(this.functionName, this.arguments) : super._();

  /// The name of the function.
  final String functionName;

  /// The arguments to the function.
  final List<Expression> arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionExpression &&
          runtimeType == other.runtimeType &&
          functionName == other.functionName &&
          const ListEquality<Expression>().equals(arguments, other.arguments);

  @override
  int get hashCode => Object.hash(
    functionName,
    const ListEquality<Expression>().hash(arguments),
  );

  @override
  String toString() => 'FunctionExpression($functionName, $arguments)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function$(
        name: functionName,
        args: arguments.map((arg) => arg._toProto(firestore)).toList(),
      ),
    );
  }
}

/// A boolean expression that evaluates to true or false.
///
/// Boolean expressions are created by comparison operators and factory constructors:
/// ```dart
/// Expression.field('age').greaterThan(Expression.constant(18))
/// BooleanExpression.and(condition1, condition2)
/// BooleanExpression.not(condition)
/// ```
@immutable
final class BooleanExpression extends Expression {
  const BooleanExpression._(this.functionName, this.arguments) : super._();

  // Factory constructors for creating boolean expressions

  /// Returns the logical AND of two boolean expressions.
  factory BooleanExpression.and(
    BooleanExpression first,
    BooleanExpression second,
  ) => BooleanExpression._('and', [first, second]);

  /// Returns the logical OR of two boolean expressions.
  factory BooleanExpression.or(
    BooleanExpression first,
    BooleanExpression second,
  ) => BooleanExpression._('or', [first, second]);

  /// Returns the logical NOT of a boolean expression.
  factory BooleanExpression.not(BooleanExpression expr) =>
      BooleanExpression._('not', [expr]);

  /// Returns the logical XOR of two boolean expressions.
  factory BooleanExpression.xor(
    BooleanExpression first,
    BooleanExpression second,
  ) => BooleanExpression._('xor', [first, second]);

  /// Returns true if the value equals any value in the list.
  factory BooleanExpression.equalAny(Expression value, Expression values) =>
      BooleanExpression._('equalAny', [value, values]);

  /// Returns true if the value does not equal any value in the list.
  factory BooleanExpression.notEqualAny(Expression value, Expression values) =>
      BooleanExpression._('notEqualAny', [value, values]);

  /// Returns true if a string contains a substring.
  factory BooleanExpression.stringContains(
    Expression str,
    Expression substring,
  ) => BooleanExpression._('stringContains', [str, substring]);

  /// Returns true if a string matches a pattern (LIKE operator).
  factory BooleanExpression.like(Expression str, Expression pattern) =>
      BooleanExpression._('like', [str, pattern]);

  /// Returns true if a string contains a regex match.
  factory BooleanExpression.regexContains(Expression str, Expression pattern) =>
      BooleanExpression._('regexContains', [str, pattern]);

  /// Returns true if a string matches a regex.
  factory BooleanExpression.regexMatch(Expression str, Expression pattern) =>
      BooleanExpression._('regexMatch', [str, pattern]);

  /// Returns true if an array contains a value.
  factory BooleanExpression.arrayContains(Expression array, Expression value) =>
      BooleanExpression._('arrayContains', [array, value]);

  /// Returns true if an array contains any of the values.
  factory BooleanExpression.arrayContainsAny(
    Expression array,
    Expression values,
  ) => BooleanExpression._('arrayContainsAny', [array, values]);

  /// Returns true if an array contains all of the values.
  factory BooleanExpression.arrayContainsAll(
    Expression array,
    Expression values,
  ) => BooleanExpression._('arrayContainsAll', [array, values]);

  /// Returns true if the value exists.
  factory BooleanExpression.exists(Expression expr) =>
      BooleanExpression._('exists', [expr]);

  /// Returns true if the value is absent.
  factory BooleanExpression.isAbsent(Expression expr) =>
      BooleanExpression._('isAbsent', [expr]);

  /// Returns true if the expression results in an error.
  factory BooleanExpression.isError(Expression expr) =>
      BooleanExpression._('isError', [expr]);

  /// The name of the boolean function.
  final String functionName;

  /// The arguments to the boolean function.
  final List<Expression> arguments;

  /// Returns the logical AND of this expression with another.
  BooleanExpression and(BooleanExpression other) =>
      BooleanExpression._('and', [this, other]);

  /// Returns the logical OR of this expression with another.
  BooleanExpression or(BooleanExpression other) =>
      BooleanExpression._('or', [this, other]);

  /// Returns the logical NOT of this expression.
  BooleanExpression not() => BooleanExpression._('not', [this]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanExpression &&
          runtimeType == other.runtimeType &&
          functionName == other.functionName &&
          const ListEquality<Expression>().equals(arguments, other.arguments);

  @override
  int get hashCode => Object.hash(
    functionName,
    const ListEquality<Expression>().hash(arguments),
  );

  @override
  String toString() => 'BooleanExpression($functionName, $arguments)';

  @override
  firestore_v1.Value _toProto(Firestore firestore) {
    return firestore_v1.Value(
      functionValue: firestore_v1.Function$(
        name: functionName,
        args: arguments.map((arg) => arg._toProto(firestore)).toList(),
      ),
    );
  }
}
