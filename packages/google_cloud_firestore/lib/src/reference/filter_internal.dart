part of '../firestore.dart';

@immutable
sealed class _FilterInternal {
  /// Returns a list of all field filters that are contained within this filter
  List<_FieldFilterInternal> get flattenedFilters;

  /// Returns a list of all filters that are contained within this filter
  List<_FilterInternal> get filters;

  /// Returns the field of the first filter that's an inequality, or null if none.
  FieldPath? get firstInequalityField;

  /// Returns the proto representation of this filter
  firestore_v1.Filter toProto();

  @mustBeOverridden
  @override
  bool operator ==(Object other);

  @mustBeOverridden
  @override
  int get hashCode;
}
