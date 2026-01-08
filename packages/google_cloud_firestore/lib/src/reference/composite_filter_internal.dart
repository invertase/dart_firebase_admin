part of '../firestore.dart';

class _CompositeFilterInternal extends _FilterInternal {
  _CompositeFilterInternal({required this.op, required this.filters});

  final _CompositeOperator op;
  @override
  final List<_FilterInternal> filters;

  bool get isConjunction => op == _CompositeOperator.and;

  @override
  late final flattenedFilters = filters.fold<List<_FieldFilterInternal>>([], (
    allFilters,
    subFilter,
  ) {
    return allFilters..addAll(subFilter.flattenedFilters);
  });

  @override
  FieldPath? get firstInequalityField {
    return flattenedFilters
        .firstWhereOrNull((filter) => filter.isInequalityFilter)
        ?.field;
  }

  @override
  firestore_v1.Filter toProto() {
    if (filters.length == 1) return filters.single.toProto();

    return firestore_v1.Filter(
      compositeFilter: firestore_v1.CompositeFilter(
        op: op.proto,
        filters: filters.map((e) => e.toProto()).toList(),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _CompositeFilterInternal &&
        runtimeType == other.runtimeType &&
        op == other.op &&
        const ListEquality<_FilterInternal>().equals(filters, other.filters);
  }

  @override
  int get hashCode => Object.hash(runtimeType, op, filters);
}
