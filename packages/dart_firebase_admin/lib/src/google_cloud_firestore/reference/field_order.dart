part of '../firestore.dart';

/// A Query order-by field.
@immutable
class _FieldOrder {
  const _FieldOrder({
    required this.fieldPath,
    this.direction = _Direction.ascending,
  });

  final FieldPath fieldPath;
  final _Direction direction;

  firestore1.Order _toProto() {
    return firestore1.Order(
      field: firestore1.FieldReference(fieldPath: fieldPath._formattedName),
      direction: direction.value,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _FieldOrder &&
        fieldPath == other.fieldPath &&
        direction == other.direction;
  }

  @override
  int get hashCode => Object.hash(fieldPath, direction);
}
