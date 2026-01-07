part of '../firestore.dart';

class _QueryCursor {
  const _QueryCursor({required this.before, required this.values});

  final bool before;
  final List<firestore1.Value> values;

  @override
  bool operator ==(Object other) {
    return other is _QueryCursor &&
        runtimeType == other.runtimeType &&
        before == other.before &&
        _valuesEqual(values, other.values);
  }

  @override
  int get hashCode =>
      Object.hash(before, const ListEquality<firestore1.Value>().hash(values));
}

@freezed
class _QueryOptions<T> with _$QueryOptions<T> {
  factory _QueryOptions({
    required _ResourcePath parentPath,
    required String collectionId,
    required _FirestoreDataConverter<T> converter,
    required bool allDescendants,
    required List<_FilterInternal> filters,
    required List<_FieldOrder> fieldOrders,
    _QueryCursor? startAt,
    _QueryCursor? endAt,
    int? limit,
    firestore1.Projection? projection,
    LimitType? limitType,
    int? offset,

    // Whether to select all documents under `parentPath`. By default, only
    // collections that match `collectionId` are selected.
    @Default(false) bool kindless,
    // Whether to require consistent documents when restarting the query. By
    // default, restarting the query uses the readTime offset of the original
    // query to provide consistent results.
    @Default(true) bool requireConsistency,
  }) = __QueryOptions<T>;
  _QueryOptions._();

  /// Returns query options for a single-collection query.
  factory _QueryOptions.forCollectionQuery(
    _ResourcePath collectionRef,
    _FirestoreDataConverter<T> converter,
  ) {
    return _QueryOptions<T>(
      parentPath: collectionRef.parent()!,
      collectionId: collectionRef.id!,
      converter: converter,
      allDescendants: false,
      filters: [],
      fieldOrders: [],
    );
  }

  /// Returns query options for a collection group query.
  factory _QueryOptions.forCollectionGroupQuery(
    String collectionId,
    _FirestoreDataConverter<T> converter,
  ) {
    return _QueryOptions(
      parentPath: _ResourcePath.empty,
      collectionId: collectionId,
      converter: converter,
      allDescendants: true,
      filters: [],
      fieldOrders: [],
    );
  }

  bool get hasFieldOrders => fieldOrders.isNotEmpty;

  _QueryOptions<U> withConverter<U>(_FirestoreDataConverter<U> converter) {
    return _QueryOptions<U>(
      converter: converter,
      parentPath: parentPath,
      collectionId: collectionId,
      allDescendants: allDescendants,
      filters: filters,
      fieldOrders: fieldOrders,
      startAt: startAt,
      endAt: endAt,
      limit: limit,
      limitType: limitType,
      offset: offset,
      projection: projection,
    );
  }
}
