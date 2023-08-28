part of 'firestore.dart';

/// An internal interface shared by all field transforms.
//
/// A [_FieldTransform] subclass should implement [includeInDocumentMask],
/// [includeInDocumentTransform] and 'toProto' (if [includeInDocumentTransform]
/// is `true`).
abstract class _FieldTransform {
  /// Whether this field transform should be included in the document mask.
  bool get includeInDocumentMask;

  /// Whether this field transform should be included in the document transform.
  bool get includeInDocumentTransform;

  /// The method name used to obtain the field transform.
  String get methodName;

  /// Performs input validation on the values of this field transform.
  ///
  /// - [allowUndefined]: Whether to allow nested properties that are undefined
  void validate({bool allowUndefined});

  /// The proto representation for this field transform.
  firestore1.FieldTransform _toProto(
    Serializer serializer,
    FieldPath fieldPath,
  );
}

/// A transform that deletes a field from a Firestore document.
class _DeleteTransform implements _FieldTransform {
  const _DeleteTransform._();

  /// A sentinel value for a field delete.
  static const deleteSentinel = _DeleteTransform._();

  /// Deletes are included in document masks
  @override
  bool get includeInDocumentMask => true;

  /// Deletes are are omitted from document transforms.
  @override
  bool get includeInDocumentTransform => false;

  @override
  String get methodName => 'FieldValue.delete';

  @override
  void validate({bool? allowUndefined}) {}

  @override
  firestore1.FieldTransform _toProto(
    Serializer serializer,
    FieldPath fieldPath,
  ) {
    throw UnsupportedError(
      'FieldValue.delete() should not be included in a FieldTransform',
    );
  }
}

/// Increments a field value on the backend.
@immutable
class _NumericIncrementTransform implements _FieldTransform {
  const _NumericIncrementTransform(this.value);

  /// The value to increment by.
  final num value;

  @override
  bool get includeInDocumentMask => false;

  @override
  bool get includeInDocumentTransform => true;

  @override
  String get methodName => 'FieldValue.increment';

  @override
  void validate({bool? allowUndefined}) {
    if (value.isNaN) {
      throw ArgumentError.value(
        value,
        'value',
        'Increment transforms require a valid numeric value, but got $value',
      );
    }
  }

  @override
  firestore1.FieldTransform _toProto(
    Serializer serializer,
    FieldPath fieldPath,
  ) {
    return firestore1.FieldTransform(
      fieldPath: fieldPath._formattedName,
      increment: serializer.encodeValue(value),
    );
  }

  @override
  bool operator ==(Object? other) {
    return other is _NumericIncrementTransform && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Transforms an array value via a union operation.
@immutable
class _ArrayUnionTransform implements _FieldTransform {
  const _ArrayUnionTransform(this.elements);

  final List<Object?> elements;

  @override
  bool get includeInDocumentMask => false;

  @override
  bool get includeInDocumentTransform => true;

  @override
  String get methodName => 'FieldValue.arrayUnion';

  @override
  void validate({bool? allowUndefined}) {
    elements.forEachIndexed(_validateArrayElement);
  }

  @override
  firestore1.FieldTransform _toProto(
    Serializer serializer,
    FieldPath fieldPath,
  ) {
    return firestore1.FieldTransform(
      fieldPath: fieldPath._formattedName,
      appendMissingElements: serializer.encodeValue(elements)!.arrayValue,
    );
  }

  @override
  bool operator ==(Object? other) {
    return other is _ArrayUnionTransform &&
        const DeepCollectionEquality().equals(elements, other.elements);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(elements);
}

/// Transforms an array value via a remove operation.
@immutable
class _ArrayRemoveTransform implements _FieldTransform {
  const _ArrayRemoveTransform(this.elements);

  final List<Object?> elements;

  @override
  bool get includeInDocumentMask => false;

  @override
  bool get includeInDocumentTransform => true;

  @override
  String get methodName => 'FieldValue.arrayRemove';

  @override
  void validate({bool? allowUndefined}) {
    elements.forEachIndexed(_validateArrayElement);
  }

  @override
  firestore1.FieldTransform _toProto(
    Serializer serializer,
    FieldPath fieldPath,
  ) {
    return firestore1.FieldTransform(
      fieldPath: fieldPath._formattedName,
      removeAllFromArray: serializer.encodeValue(elements)!.arrayValue,
    );
  }

  @override
  bool operator ==(Object? other) {
    return other is _ArrayRemoveTransform &&
        const DeepCollectionEquality().equals(elements, other.elements);
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(elements);
}

enum _AllowDeletes {
  none,
  root,
  all;
}

/// The maximum depth of a Firestore object.
const _maxDepth = 20;

class _ValidateUserInputOptions {
  const _ValidateUserInputOptions({
    required this.allowDeletes,
    required this.allowTransform,
  });

  /// At what level field deletes are supported.
  final _AllowDeletes allowDeletes;

  /// Whether server transforms are supported.
  final bool allowTransform;
}

/// Validates a Dart value for usage as a Firestore value.
void _validateUserInput(
  Object arg,
  Object? value, {
  required String description,
  required _ValidateUserInputOptions options,
  int level = 0,
  bool inArray = false,
  FieldPath? path,
}) {
  if (path != null && path._length > _maxDepth) {
    throw ArgumentError.value(
      value,
      description,
      'Firestore objects may not contain more than $_maxDepth levels of nesting or contain a cycle',
    );
  }

  final fieldPathMessage =
      path == null ? '' : ' (found in field ${path._formattedName})';

  switch (value) {
    case List<Object?>():
      value.forEachIndexed((index, element) {
        _validateUserInput(
          arg,
          element,
          description: description,
          options: options,
          path: path == null
              ? FieldPath([arg.toString()])
              : path._append(arg.toString()),
          level: level + 1,
          inArray: true,
        );
      });

    case Map<Object?, Object?>():
      for (final entry in value.entries) {
        _validateUserInput(
          arg,
          entry.value,
          description: description,
          options: options,
          path: path == null
              ? FieldPath.from(entry.key)
              : path._appendPath(FieldPath.from(entry.key)),
          level: level + 1,
          inArray: inArray,
        );
      }

    case _DeleteTransform():
      if (inArray) {
        throw ArgumentError.value(
          value,
          value.methodName,
          'cannot be used inside an array$fieldPathMessage',
        );
      } else if (options.allowDeletes == _AllowDeletes.none) {
        throw ArgumentError.value(
          value,
          value.methodName,
          'must appear at the top-level and can only be used in update() '
          'or set() with {merge:true}$fieldPathMessage.',
        );
      } else if (options.allowDeletes == _AllowDeletes.root) {
        switch (level) {
          case 0:
          // Ok (update() with UpdateData).
          case 1 when path?._length == 1:
            // Ok (update with varargs).
            break;
          default:
            throw ArgumentError.value(
              value,
              value.methodName,
              'must appear at the top-level and can only be used in update() '
              'or set() with {merge:true}$fieldPathMessage.',
            );
        }
      }

    case _FieldTransform():
      if (inArray) {
        throw ArgumentError.value(
          value,
          value.methodName,
          'cannot be used inside an array$fieldPathMessage',
        );
      } else if (!options.allowTransform) {
        throw ArgumentError.value(
          value,
          value.methodName,
          'can only be used with set(), create() or update()$fieldPathMessage.',
        );
      }

    case FieldPath():
      throw ArgumentError.value(
        value,
        description,
        'Cannot use object of type "FieldPath" as a Firestore value$fieldPathMessage',
      );

    case DocumentReference():
    case GeoPoint():
    case Timestamp() || DateTime():
    // TODO case Buffer || Uint8Array:
    case null:
    // Ok.

    default:
      throw ArgumentError.value(
        value,
        description,
        'Unsupported value type: ${value.runtimeType}$fieldPathMessage',
      );
  }
}

// Validates that `value` can be used as an element inside of an array. Certain
// field values (such as ServerTimestamps) are rejected. Nested arrays are also
// rejected.
void _validateArrayElement(int index, Object? item) {
  if (item is List) {
    throw ArgumentError.value(
      item,
      'elements[$index]',
      'Nested arrays are not supported',
    );
  }

  _validateUserInput(
    index,
    item,
    description: 'array element',
    options: const _ValidateUserInputOptions(
      allowDeletes: _AllowDeletes.none,
      allowTransform: false,
    ),
    inArray: true,
  );
}
