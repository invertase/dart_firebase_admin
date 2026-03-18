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

  firestore_v1.Order _toProto() {
    return firestore_v1.Order(
      field: firestore_v1.FieldReference(fieldPath: fieldPath._formattedName),
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
