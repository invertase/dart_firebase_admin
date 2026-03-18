part of 'firestore.dart';

/// Options to configure [WriteBatch.set], [Transaction.set], and [BulkWriter.set] behavior.
///
/// Provides control over whether the set operation should merge data into an
/// existing document instead of replacing it entirely.
@immutable
sealed class SetOptions {
  const SetOptions._();

  /// Merge all provided fields.
  ///
  /// If a field is present in the data but not in the document, it will be added.
  /// If a field is present in both, the document's field will be updated.
  /// Fields in the document that are not in the data will remain untouched.
  const factory SetOptions.merge() = _MergeAllSetOptions;

  /// Merge only the specified fields.
  ///
  /// Only the field paths listed in [mergeFields] will be updated or created.
  /// All other fields will remain untouched.
  ///
  /// Example:
  /// ```dart
  /// // Only update the 'name' field, leave other fields unchanged
  /// ref.set(
  ///   {'name': 'John', 'age': 30},
  ///   SetOptions.mergeFields([FieldPath(['name'])]),
  /// );
  /// ```
  const factory SetOptions.mergeFields(List<FieldPath> fields) =
      _MergeFieldsSetOptions;

  /// Whether this represents a merge operation (either merge all or specific fields).
  bool get isMerge;

  /// The list of field paths to merge. Null if merging all fields or not merging.
  List<FieldPath>? get mergeFields;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

/// Merge all fields from the provided data.
@immutable
class _MergeAllSetOptions extends SetOptions {
  const _MergeAllSetOptions() : super._();

  @override
  bool get isMerge => true;

  @override
  List<FieldPath>? get mergeFields => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _MergeAllSetOptions;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'SetOptions.merge()';
}

/// Merge only the specified field paths.
@immutable
class _MergeFieldsSetOptions extends SetOptions {
  const _MergeFieldsSetOptions(this.fields) : super._();

  final List<FieldPath> fields;

  @override
  bool get isMerge => true;

  @override
  List<FieldPath>? get mergeFields => fields;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _MergeFieldsSetOptions &&
          const ListEquality<FieldPath>().equals(fields, other.fields));

  @override
  int get hashCode =>
      Object.hash(runtimeType, const ListEquality<FieldPath>().hash(fields));

  @override
  String toString() => 'SetOptions.mergeFields($fields)';
}
