part of 'firestore.dart';

final class CollectionReference<T> extends Query<T> {
  CollectionReference._({
    required super.firestore,
    required _ResourcePath path,
    required _FirestoreDataConverter<T> converter,
  }) : super._(
          queryOptions: _QueryOptions.forCollectionQuery(path, converter),
        );

  _ResourcePath get _resourcePath => _queryOptions.parentPath._append(id);

  /// The last path element of the referenced collection.
  String get id => _queryOptions.collectionId;

  /// A reference to the containing Document if this is a subcollection, else
  /// null.
  ///
  /// ```dart
  /// final collectionRef = firestore.collection('col/doc/subcollection');
  /// final documentRef = collectionRef.parent;
  /// print('Parent name: ${documentRef.path}');
  /// ```
  DocumentReference<DocumentData>? get parent {
    if (!_queryOptions.parentPath.isDocument) return null;

    return DocumentReference<DocumentData>._(
      firestore: firestore,
      path: _queryOptions.parentPath,
      converter: _jsonConverter,
    );
  }

  /// A string representing the path of the referenced collection (relative
  /// to the root of the database).
  String get path => _resourcePath.relativeName;

  /// Gets a [DocumentReference] instance that refers to the document at
  /// the specified path.
  ///
  /// If no path is specified, an automatically-generated unique ID will be
  /// used for the returned [DocumentReference].
  ///
  /// If using [withConverter], the [path] must not contain any slash.
  DocumentReference<T> doc([String? documentPath]) {
    if (documentPath != null) {
      _validateResourcePath('documentPath', documentPath);
    } else {
      documentPath = autoId();
    }

    final path = _resourcePath._append(documentPath);
    if (!path.isDocument) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'Value for argument "documentPath" must point to a document, but was '
            '"$documentPath". Your path does not contain an even number of components.',
      );
    }

    if (!identical(_queryOptions.converter, _jsonConverter) &&
        path.parent() != _resourcePath) {
      throw ArgumentError.value(
        documentPath,
        'documentPath',
        'Value for argument "documentPath" must not contain a slash (/) if '
            'the parent collection has a custom converter.',
      );
    }

    return DocumentReference<T>._(
      firestore: firestore,
      path: path,
      converter: _queryOptions.converter,
    );
  }

  /// Retrieves the list of documents in this collection.
  ///
  /// The document references returned may include references to "missing
  /// documents", i.e. document locations that have no document present but
  /// which contain subcollections with documents. Attempting to read such a
  /// document reference (e.g. via [DocumentReference.get]) will return a
  /// [DocumentSnapshot] whose [DocumentSnapshot.exists] property is `false`.
  Future<List<DocumentReference<T>>> listDocuments() async {
    final response = await firestore._client.v1((client, projectId) {
      final parentPath = _queryOptions.parentPath._toQualifiedResourcePath(
        projectId,
        firestore._databaseId,
      );

      return client.projects.databases.documents.list(
        parentPath._formattedName,
        id,
        showMissing: true,
        // Setting `pageSize` to an arbitrarily large value lets the backend cap
        // the page size (currently to 300). Note that the backend rejects
        // MAX_INT32 (b/146883794).
        pageSize: math.pow(2, 16 - 1).toInt(),
        mask_fieldPaths: [],
      );
    });

    return [
      for (final document
          in response.documents ?? const <firestore1.Document>[])
        doc(
          // ignore: unnecessary_null_checks, we don't want to inadvertently obtain a new document
          _QualifiedResourcePath.fromSlashSeparatedString(document.name!).id!,
        ),
    ];
  }

  /// Add a new document to this collection with the specified data, assigning
  /// it a document ID automatically.
  Future<DocumentReference<T>> add(T data) async {
    final firestoreData = _queryOptions.converter.toFirestore(data);
    _validateDocumentData(
      'data',
      firestoreData,
      allowDeletes: false,
    );

    final documentRef = doc();
    final jsonDocumentRef = documentRef.withConverter<DocumentData>(
      fromFirestore: _jsonConverter.fromFirestore,
      toFirestore: _jsonConverter.toFirestore,
    );

    return jsonDocumentRef.create(firestoreData).then((_) => documentRef);
  }

  @override
  CollectionReference<U> withConverter<U>({
    required FromFirestore<U> fromFirestore,
    required ToFirestore<U> toFirestore,
  }) {
    return CollectionReference<U>._(
      firestore: firestore,
      path: _queryOptions.parentPath._append(id) as _QualifiedResourcePath,
      converter: (
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      ),
    );
  }

  @override
  // ignore: hash_and_equals, already implemented in Query
  bool operator ==(Object other) {
    return other is CollectionReference<T> && super == other;
  }
}

@immutable
final class DocumentReference<T> implements _Serializable {
  const DocumentReference._({
    required this.firestore,
    required _ResourcePath path,
    required _FirestoreDataConverter<T> converter,
  })  : _converter = converter,
        _path = path;

  final _ResourcePath _path;
  final _FirestoreDataConverter<T> _converter;
  final Firestore firestore;

  /// A string representing the path of the referenced document (relative
  /// to the root of the database).
  ///
  /// ```dart
  /// final collectionRef = firestore.collection('col');
  ///
  /// collectionRef.add({'foo': 'bar'}).then((documentReference) {
  ///   print('Added document at "${documentReference.path}"');
  /// });
  /// ```
  String get path => _path.relativeName;

  /// The last path element of the referenced document.
  String get id => _path.id!;

  /// A reference to the collection to which this DocumentReference belongs.
  CollectionReference<T> get parent {
    return CollectionReference<T>._(
      firestore: firestore,
      path: _path.parent()!,
      converter: _converter,
    );
  }

  /// The string representation of the DocumentReference's location.
  /// This can only be called after projectId has been discovered.
  String get _formattedName {
    return _path
        ._toQualifiedResourcePath(
          firestore._projectId,
          firestore._databaseId,
        )
        ._formattedName;
  }

  /// Fetches the subcollections that are direct children of this document.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// documentRef.listCollections().then((collections) {
  ///   for (final collection in collections) {
  ///     print('Found subcollection with id: ${collection.id}');
  ///   }
  /// });
  /// ```
  Future<List<CollectionReference<DocumentData>>> listCollections() {
    return firestore._client.v1((a, projectId) async {
      final request = firestore1.ListCollectionIdsRequest(
        // Setting `pageSize` to an arbitrarily large value lets the backend cap
        // the page size (currently to 300). Note that the backend rejects
        // MAX_INT32 (b/146883794).
        pageSize: (math.pow(2, 16) - 1).toInt(),
      );

      final result = await a.projects.databases.documents.listCollectionIds(
        request,
        _formattedName,
      );

      final ids = result.collectionIds ?? [];
      ids.sort((a, b) => a.compareTo(b));

      return [
        for (final id in ids) collection(id),
      ];
    });
  }

  /// Changes the de/serializing mechanism for this [DocumentReference].
  ///
  /// This changes the return value of [DocumentSnapshot.data].
  DocumentReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    return DocumentReference<R>._(
      firestore: firestore,
      path: _path,
      converter: (
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      ),
    );
  }

  Future<DocumentSnapshot<T>> get() async {
    final result = await firestore.getAll([this]);
    return result.single;
  }

  /// Create a document with the provided object values. This will fail the write
  /// if a document exists at its location.
  ///
  /// - [data]: An object that contains the fields and data to
  ///   serialize as the document.
  ///
  /// Throws if the provided input is not a valid Firestore document.
  ///
  /// Returns a Future that resolves with the write time of this create.
  ///
  /// ```dart
  /// final documentRef = firestore.collection('col').doc();
  ///
  /// documentRef.create({foo: 'bar'}).then((res) {
  ///   print('Document created at ${res.updateTime}');
  /// }).catch((err) => {
  ///   print('Failed to create document: ${err}');
  /// });
  /// ```
  Future<WriteResult> create(T data) async {
    final writeBatch = WriteBatch._(firestore)..create<T>(this, data);

    final results = await writeBatch.commit();
    return results.single;
  }

  /// Deletes the document referred to by this [DocumentReference].
  ///
  /// A delete for a non-existing document is treated as a success (unless
  /// [precondition] is specified).
  Future<WriteResult> delete([Precondition? precondition]) async {
    final writeBatch = WriteBatch._(firestore)
      ..delete(this, precondition: precondition);

    final results = await writeBatch.commit();
    return results.single;
  }

  /// Writes to the document referred to by this DocumentReference. If the
  /// document does not yet exist, it will be created.
  Future<WriteResult> set(T data) async {
    final writeBatch = WriteBatch._(firestore)..set(this, data);

    final results = await writeBatch.commit();
    return results.single;
  }

  /// Updates fields in the document referred to by this DocumentReference.
  /// If the document doesn't yet exist, the update fails and the returned
  /// Promise will be rejected.
  ///
  /// The update() method accepts either an object with field paths encoded as
  /// keys and field values encoded as values, or a variable number of arguments
  /// that alternate between field paths and field values.
  ///
  /// A [Precondition] restricting this update can be specified as the last
  /// argument.
  Future<WriteResult> update(
    Map<Object?, Object?> data, [
    Precondition? precondition,
  ]) async {
    final writeBatch = WriteBatch._(firestore)
      ..update(
        this,
        {
          for (final entry in data.entries)
            FieldPath.from(entry.key): entry.value,
        },
        precondition: precondition,
      );

    final results = await writeBatch.commit();
    return results.single;
  }

  /// Gets a [CollectionReference] instance
  /// that refers to the collection at the specified path.
  ///
  /// - [collectionPath]: A slash-separated path to a collection.
  ///
  /// Returns A reference to the new subcollection.
  ///
  /// ```dart
  /// final documentRef = firestore.doc('col/doc');
  /// final subcollection = documentRef.collection('subcollection');
  /// print('Path to subcollection: ${subcollection.path}');
  /// ```
  CollectionReference<DocumentData> collection(String collectionPath) {
    _validateResourcePath('collectionPath', collectionPath);

    final path = _path._append(collectionPath);
    if (!path.isCollection) {
      throw ArgumentError.value(
        collectionPath,
        'collectionPath',
        'Value for argument "collectionPath" must point to a collection, but was '
            '"$collectionPath". Your path does not contain an odd number of components.',
      );
    }

    return CollectionReference<DocumentData>._(
      firestore: firestore,
      path: path,
      converter: _jsonConverter,
    );
  }

  // TODO listCollections
  // TODO snapshots

  @override
  firestore1.Value _toProto() {
    return firestore1.Value(referenceValue: _formattedName);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentReference<T> &&
        runtimeType == other.runtimeType &&
        firestore == other.firestore &&
        _path == other._path &&
        _converter == other._converter;
  }

  @override
  int get hashCode => Object.hash(runtimeType, firestore, _path, _converter);
}

bool _valuesEqual(
  List<firestore1.Value>? a,
  List<firestore1.Value>? b,
) {
  if (a == null) return b == null;
  if (b == null) return false;

  if (a.length != b.length) return false;

  for (final (index, value) in a.indexed) {
    if (!_valueEqual(value, b[index])) return false;
  }

  return true;
}

bool _valueEqual(firestore1.Value a, firestore1.Value b) {
  switch (a) {
    case firestore1.Value(:final arrayValue?):
      return _valuesEqual(arrayValue.values, b.arrayValue?.values);
    case firestore1.Value(:final booleanValue?):
      return booleanValue == b.booleanValue;
    case firestore1.Value(:final bytesValue?):
      return bytesValue == b.bytesValue;
    case firestore1.Value(:final doubleValue?):
      return doubleValue == b.doubleValue;
    case firestore1.Value(:final geoPointValue?):
      return geoPointValue.latitude == b.geoPointValue?.latitude &&
          geoPointValue.longitude == b.geoPointValue?.longitude;
    case firestore1.Value(:final integerValue?):
      return integerValue == b.integerValue;
    case firestore1.Value(:final mapValue?):
      final bMap = b.mapValue;
      if (bMap == null || bMap.fields?.length != mapValue.fields?.length) {
        return false;
      }

      for (final MapEntry(:key, :value) in mapValue.fields?.entries ??
          const <MapEntry<String, firestore1.Value>>[]) {
        final bValue = bMap.fields?[key];
        if (bValue == null) return false;
        if (!_valueEqual(value, bValue)) return false;
      }
    case firestore1.Value(:final nullValue?):
      return nullValue == b.nullValue;
    case firestore1.Value(:final referenceValue?):
      return referenceValue == b.referenceValue;
    case firestore1.Value(:final stringValue?):
      return stringValue == b.stringValue;
    case firestore1.Value(:final timestampValue?):
      return timestampValue == b.timestampValue;
  }
  return false;
}

@immutable
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
  int get hashCode => Object.hash(
        before,
        const ListEquality<firestore1.Value>().hash(values),
      );
}

/*
 * Denotes whether a provided limit is applied to the beginning or the end of
 * the result set.
 */
enum LimitType {
  first,
  last,
}

enum _Direction {
  ascending('ASCENDING'),
  descending('DESCENDING');

  const _Direction(this.value);

  final String value;
}

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
      field: firestore1.FieldReference(
        fieldPath: fieldPath._formattedName,
      ),
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

  _QueryOptions<U> withConverter<U>(
    _FirestoreDataConverter<U> converter,
  ) {
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

@immutable
sealed class _FilterInternal {
  /// Returns a list of all field filters that are contained within this filter
  List<_FieldFilterInternal> get flattenedFilters;

  /// Returns a list of all filters that are contained within this filter
  List<_FilterInternal> get filters;

  /// Returns the field of the first filter that's an inequality, or null if none.
  FieldPath? get firstInequalityField;

  /// Returns the proto representation of this filter
  firestore1.Filter toProto();

  @mustBeOverridden
  @override
  bool operator ==(Object other);

  @mustBeOverridden
  @override
  int get hashCode;
}

class _CompositeFilterInternal implements _FilterInternal {
  _CompositeFilterInternal({required this.op, required this.filters});

  final _CompositeOperator op;
  @override
  final List<_FilterInternal> filters;

  bool get isConjunction => op == _CompositeOperator.and;

  @override
  late final flattenedFilters = filters.fold<List<_FieldFilterInternal>>(
    [],
    (allFilters, subFilter) {
      return allFilters..addAll(subFilter.flattenedFilters);
    },
  );

  @override
  FieldPath? get firstInequalityField {
    return flattenedFilters
        .firstWhereOrNull((filter) => filter.isInequalityFilter)
        ?.field;
  }

  @override
  firestore1.Filter toProto() {
    if (filters.length == 1) return filters.single.toProto();

    return firestore1.Filter(
      compositeFilter: firestore1.CompositeFilter(
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

class _FieldFilterInternal implements _FilterInternal {
  _FieldFilterInternal({
    required this.field,
    required this.op,
    required this.value,
    required this.serializer,
  });

  final FieldPath field;
  final WhereFilter op;
  final Object? value;
  final _Serializer serializer;

  @override
  List<_FieldFilterInternal> get flattenedFilters => [this];

  @override
  List<_FieldFilterInternal> get filters => [this];

  @override
  FieldPath? get firstInequalityField => isInequalityFilter ? field : null;

  bool get isInequalityFilter {
    return op == WhereFilter.lessThan ||
        op == WhereFilter.lessThanOrEqual ||
        op == WhereFilter.greaterThan ||
        op == WhereFilter.greaterThanOrEqual;
  }

  @override
  firestore1.Filter toProto() {
    final value = this.value;
    if (value is num && value.isNaN) {
      return firestore1.Filter(
        unaryFilter: firestore1.UnaryFilter(
          field: firestore1.FieldReference(
            fieldPath: field._formattedName,
          ),
          op: op == WhereFilter.equal ? 'IS_NAN' : 'IS_NOT_NAN',
        ),
      );
    }

    if (value == null) {
      return firestore1.Filter(
        unaryFilter: firestore1.UnaryFilter(
          field: firestore1.FieldReference(
            fieldPath: field._formattedName,
          ),
          op: op == WhereFilter.equal ? 'IS_NULL' : 'IS_NOT_NULL',
        ),
      );
    }

    return firestore1.Filter(
      fieldFilter: firestore1.FieldFilter(
        field: firestore1.FieldReference(
          fieldPath: field._formattedName,
        ),
        op: op.proto,
        value: serializer.encodeValue(value),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _FieldFilterInternal &&
        field == other.field &&
        op == other.op &&
        value == other.value;
  }

  @override
  int get hashCode => Object.hash(field, op, value);
}

@immutable
base class Query<T> {
  const Query._({
    required this.firestore,
    required _QueryOptions<T> queryOptions,
  }) : _queryOptions = queryOptions;

  static List<Object?> _extractFieldValues(
    DocumentSnapshot<Object?> documentSnapshot,
    List<_FieldOrder> fieldOrders,
  ) {
    return fieldOrders.map((fieldOrder) {
      if (fieldOrder.fieldPath == FieldPath.documentId) {
        return documentSnapshot.ref;
      }

      final fieldValue = documentSnapshot.get(fieldOrder.fieldPath);
      if (fieldValue == null) {
        throw StateError(
          'Field "${fieldOrder.fieldPath}" is missing in the provided DocumentSnapshot. '
          'Please provide a document that contains values for all specified orderBy() '
          'and where() constraints.',
        );
      }
      return fieldValue.value;
    }).toList();
  }

  final Firestore firestore;
  final _QueryOptions<T> _queryOptions;

  /// Applies a custom data converter to this Query, allowing you to use your
  /// own custom model objects with Firestore. When you call [get] on the
  /// returned [Query], the provided converter will convert between Firestore
  /// data and your custom type U.
  ///
  /// Using the converter allows you to specify generic type arguments when
  /// storing and retrieving objects from Firestore.
  @mustBeOverridden
  Query<U> withConverter<U>({
    required FromFirestore<U> fromFirestore,
    required ToFirestore<U> toFirestore,
  }) {
    return Query<U>._(
      firestore: firestore,
      queryOptions: _queryOptions.withConverter(
        (
          fromFirestore: fromFirestore,
          toFirestore: toFirestore,
        ),
      ),
    );
  }

  _QueryCursor _createCursor(
    List<_FieldOrder> fieldOrders, {
    List<Object?>? fieldValues,
    DocumentSnapshot<Object?>? snapshot,
    required bool before,
  }) {
    if (fieldValues != null && snapshot != null) {
      throw ArgumentError(
        'You cannot specify both "fieldValues" and "snapshot".',
      );
    }

    if (snapshot != null) {
      fieldValues = Query._extractFieldValues(snapshot, fieldOrders);
    }

    if (fieldValues == null) {
      throw ArgumentError(
        'You must specify "fieldValues" or "snapshot".',
      );
    }

    if (fieldValues.length > fieldOrders.length) {
      throw ArgumentError(
        'Too many cursor values specified. The specified '
        'values must match the orderBy() constraints of the query.',
      );
    }

    final cursorValues = <firestore1.Value>[];
    final cursor = _QueryCursor(before: before, values: cursorValues);

    for (var i = 0; i < fieldValues.length; ++i) {
      final fieldValue = fieldValues[i];

      if (fieldOrders[i].fieldPath == FieldPath.documentId &&
          fieldValue is! DocumentReference) {
        throw ArgumentError(
          'When ordering with FieldPath.documentId(), '
          'the cursor must be a DocumentReference.',
        );
      }

      _validateQueryValue('$i', fieldValue);
      cursor.values.add(firestore._serializer.encodeValue(fieldValue)!);
    }

    return cursor;
  }

  (_QueryCursor, List<_FieldOrder>) _cursorFromValues({
    List<Object?>? fieldValues,
    DocumentSnapshot<Object?>? snapshot,
    required bool before,
  }) {
    if (fieldValues != null && fieldValues.isEmpty) {
      throw ArgumentError.value(
        fieldValues,
        'fieldValues',
        'Value must not be an empty List.',
      );
    }

    final fieldOrders = _createImplicitOrderBy(snapshot);
    final cursor = _createCursor(
      fieldOrders,
      fieldValues: fieldValues,
      snapshot: snapshot,
      before: before,
    );
    return (cursor, fieldOrders);
  }

  /// Computes the backend ordering semantics for DocumentSnapshot cursors.
  List<_FieldOrder> _createImplicitOrderBy(
    DocumentSnapshot<Object?>? snapshot,
  ) {
    // Add an implicit orderBy if the only cursor value is a DocumentSnapshot
    // or a DocumentReference.
    if (snapshot == null) return _queryOptions.fieldOrders;

    final fieldOrders = _queryOptions.fieldOrders.toList();

    // If no explicit ordering is specified, use the first inequality to
    // define an implicit order.
    if (fieldOrders.isEmpty) {
      for (final filter in _queryOptions.filters) {
        final fieldReference = filter.firstInequalityField;
        if (fieldReference != null) {
          fieldOrders.add(_FieldOrder(fieldPath: fieldReference));
          break;
        }
      }
    }

    final hasDocumentId = fieldOrders.any(
      (fieldOrder) => fieldOrder.fieldPath == FieldPath.documentId,
    );
    if (!hasDocumentId) {
      // Add implicit sorting by name, using the last specified direction.
      final lastDirection = fieldOrders.isEmpty
          ? _Direction.ascending
          : fieldOrders.last.direction;

      fieldOrders.add(
        _FieldOrder(fieldPath: FieldPath.documentId, direction: lastDirection),
      );
    }

    return fieldOrders;
  }

  /// Creates and returns a new [Query] that starts at the provided
  /// set of field values relative to the order of the query. The order of the
  /// provided values must match the order of the order by clauses of the query.
  ///
  /// - [fieldValues] The field values to start this query at,
  ///   in order of the query's order by.
  ///
  /// ```dart
  /// final query = firestore.collection('col');
  ///
  /// query.orderBy('foo').startAt(42).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> startAt(List<Object?> fieldValues) {
    final (startAt, fieldOrders) = _cursorFromValues(
      fieldValues: fieldValues,
      before: true,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      startAt: startAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that starts at the provided
  /// set of field values relative to the order of the query. The order of the
  /// provided values must match the order of the order by clauses of the query.
  ///
  /// - [documentSnapshot] The snapshot of the document the query results
  ///   should start at, in order of the query's order by.
  Query<T> startAtDocument(DocumentSnapshot<Object?> documentSnapshot) {
    final (startAt, fieldOrders) = _cursorFromValues(
      snapshot: documentSnapshot,
      before: true,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      startAt: startAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that starts after the
  /// provided set of field values relative to the order of the query. The order
  /// of the provided values must match the order of the order by clauses of the
  /// query.
  ///
  /// - [fieldValues]: The field values to
  ///   start this query after, in order of the query's order by.
  ///
  /// ```dart
  /// final query = firestore.collection('col');
  ///
  /// query.orderBy('foo').startAfter(42).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> startAfter(List<Object?> fieldValues) {
    final (startAt, fieldOrders) = _cursorFromValues(
      fieldValues: fieldValues,
      before: false,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      startAt: startAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that starts after the
  /// provided set of field values relative to the order of the query. The order
  /// of the provided values must match the order of the order by clauses of the
  /// query.
  ///
  /// - [snapshot]: The snapshot of the document the query results
  ///   should start at, in order of the query's order by.
  Query<T> startAfterDocument(DocumentSnapshot<Object?> snapshot) {
    final (startAt, fieldOrders) = _cursorFromValues(
      snapshot: snapshot,
      before: false,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      startAt: startAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that ends before the set of
  /// field values relative to the order of the query. The order of the provided
  /// values must match the order of the order by clauses of the query.
  ///
  /// - [fieldValues]: The field values to
  ///   end this query before, in order of the query's order by.
  ///
  /// ```dart
  /// final query = firestore.collection('col');
  ///
  /// query.orderBy('foo').endBefore(42).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> endBefore(List<Object?> fieldValues) {
    final (endAt, fieldOrders) = _cursorFromValues(
      fieldValues: fieldValues,
      before: true,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      endAt: endAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that ends before the set of
  /// field values relative to the order of the query. The order of the provided
  /// values must match the order of the order by clauses of the query.
  ///
  /// - [snapshot]: The snapshot
  ///   of the document the query results should end before.
  Query<T> endBeforeDocument(DocumentSnapshot<Object?> snapshot) {
    final (endAt, fieldOrders) = _cursorFromValues(
      snapshot: snapshot,
      before: true,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      endAt: endAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that ends at the provided
  /// set of field values relative to the order of the query. The order of the
  /// provided values must match the order of the order by clauses of the query.
  ///
  /// - [fieldValues]: The field values to end
  ///   this query at, in order of the query's order by.
  ///
  /// ```dart
  /// final query = firestore.collection('col');
  ///
  /// query.orderBy('foo').endAt(42).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> endAt(List<Object?> fieldValues) {
    final (endAt, fieldOrders) = _cursorFromValues(
      fieldValues: fieldValues,
      before: false,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      endAt: endAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that ends at the provided
  /// set of field values relative to the order of the query. The order of the
  /// provided values must match the order of the order by clauses of the query.
  ///
  /// - [snapshot]: The snapshot
  ///   of the document the query results should end at, in order of the query's order by.
  /// ```
  Query<T> endAtDocument(DocumentSnapshot<Object?> snapshot) {
    final (endAt, fieldOrders) = _cursorFromValues(
      snapshot: snapshot,
      before: false,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: fieldOrders,
      endAt: endAt,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Executes the query and returns the results as a [QuerySnapshot].
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', WhereFilter.equal, 'bar');
  ///
  /// query.get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Future<QuerySnapshot<T>> get() => _get(transactionId: null);

  Future<QuerySnapshot<T>> _get({required String? transactionId}) async {
    final response = await firestore._client.v1((client, projectId) async {
      return client.projects.databases.documents.runQuery(
        _toProto(
          transactionId: transactionId,
          readTime: null,
        ),
        _buildProtoParentPath(),
      );
    });

    Timestamp? readTime;
    final snapshots = response
        .map((e) {
          final document = e.document;
          if (document == null) {
            readTime = e.readTime.let(Timestamp._fromString);
            return null;
          }

          final snapshot = DocumentSnapshot._fromDocument(
            document,
            e.readTime,
            firestore,
          );
          final finalDoc = _DocumentSnapshotBuilder(
            snapshot.ref.withConverter<T>(
              fromFirestore: _queryOptions.converter.fromFirestore,
              toFirestore: _queryOptions.converter.toFirestore,
            ),
          )
            // Recreate the QueryDocumentSnapshot with the DocumentReference
            // containing the original converter.
            ..fieldsProto = firestore1.MapValue(fields: document.fields)
            ..readTime = snapshot.readTime
            ..createTime = snapshot.createTime
            ..updateTime = snapshot.updateTime;

          return finalDoc.build();
        })
        .nonNulls
        // Specifying fieldsProto should cause the builder to create a query snapshot.
        .cast<QueryDocumentSnapshot<T>>()
        .toList();

    return QuerySnapshot<T>._(
      query: this,
      readTime: readTime,
      docs: snapshots,
    );
  }

  String _buildProtoParentPath() {
    return _queryOptions.parentPath
        ._toQualifiedResourcePath(
          firestore._projectId,
          firestore._databaseId,
        )
        ._formattedName;
  }

  firestore1.RunQueryRequest _toProto({
    required String? transactionId,
    required Timestamp? readTime,
  }) {
    if (readTime != null && transactionId != null) {
      throw ArgumentError(
        'readTime and transactionId cannot both be set.',
      );
    }

    final structuredQuery = _toStructuredQuery();

    // For limitToLast queries, the structured query has to be translated to a version with
    // reversed ordered, and flipped startAt/endAt to work properly.
    if (_queryOptions.limitType == LimitType.last) {
      if (!_queryOptions.hasFieldOrders) {
        throw ArgumentError(
          'limitToLast() queries require specifying at least one orderBy() clause.',
        );
      }

      structuredQuery.orderBy = _queryOptions.fieldOrders.map((order) {
        // Flip the orderBy directions since we want the last results
        final dir = order.direction == _Direction.descending
            ? _Direction.ascending
            : _Direction.descending;
        return _FieldOrder(fieldPath: order.fieldPath, direction: dir)
            ._toProto();
      }).toList();

      // Swap the cursors to match the now-flipped query ordering.
      structuredQuery.startAt = _queryOptions.endAt != null
          ? _toCursor(
              _QueryCursor(
                values: _queryOptions.endAt!.values,
                before: !_queryOptions.endAt!.before,
              ),
            )
          : null;
      structuredQuery.endAt = _queryOptions.startAt != null
          ? _toCursor(
              _QueryCursor(
                values: _queryOptions.startAt!.values,
                before: !_queryOptions.startAt!.before,
              ),
            )
          : null;
    }

    final runQueryRequest = firestore1.RunQueryRequest(
      structuredQuery: structuredQuery,
    );

    if (transactionId != null) {
      runQueryRequest.transaction = transactionId;
    } else if (readTime != null) {
      runQueryRequest.readTime = readTime._toProto().timestampValue;
    }

    return runQueryRequest;
  }

  firestore1.StructuredQuery _toStructuredQuery() {
    final structuredQuery = firestore1.StructuredQuery(
      from: [firestore1.CollectionSelector()],
    );

    if (_queryOptions.allDescendants) {
      structuredQuery.from![0].allDescendants = true;
    }

    // Kindless queries select all descendant documents, so we remove the
    // collectionId field.
    if (!_queryOptions.kindless) {
      structuredQuery.from![0].collectionId = _queryOptions.collectionId;
    }

    if (_queryOptions.filters.isNotEmpty) {
      structuredQuery.where = _CompositeFilterInternal(
        filters: _queryOptions.filters,
        op: _CompositeOperator.and,
      ).toProto();
    }

    if (_queryOptions.hasFieldOrders) {
      structuredQuery.orderBy =
          _queryOptions.fieldOrders.map((o) => o._toProto()).toList();
    }

    structuredQuery.startAt = _toCursor(_queryOptions.startAt);
    structuredQuery.endAt = _toCursor(_queryOptions.endAt);

    final limit = _queryOptions.limit;
    if (limit != null) structuredQuery.limit = limit;

    structuredQuery.offset = _queryOptions.offset;
    structuredQuery.select = _queryOptions.projection;

    return structuredQuery;
  }

  /// Converts a QueryCursor to its proto representation.
  firestore1.Cursor? _toCursor(_QueryCursor? cursor) {
    if (cursor == null) return null;

    return cursor.before
        ? firestore1.Cursor(before: true, values: cursor.values)
        : firestore1.Cursor(values: cursor.values);
  }

  // TODO onSnapshot
  // TODO stream

  /// {@macro collection_reference.where}
  Query<T> where(Object path, WhereFilter op, Object? value) {
    final fieldPath = FieldPath.from(path);
    return whereFieldPath(fieldPath, op, value);
  }

  /// {@template collection_reference.where}
  /// Creates and returns a new [Query] with the additional filter
  /// that documents must contain the specified field and that its value should
  /// satisfy the relation constraint provided.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the filter.
  ///
  /// - [fieldPath]: The name of a property value to compare.
  /// - [op]: A comparison operation in the form of a string.
  ///   Acceptable operator strings are "<", "<=", "==", "!=", ">=", ">", "array-contains",
  ///   "in", "not-in", and "array-contains-any".
  /// - [value]: The value to which to compare the field for inclusion in
  ///   a query.
  ///
  /// ```dart
  /// final collectionRef = firestore.collection('col');
  ///
  /// collectionRef.where('foo', WhereFilter.equal, 'bar').get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  /// {@endtemplate}
  Query<T> whereFieldPath(
    FieldPath fieldPath,
    WhereFilter op,
    Object? value,
  ) {
    return whereFilter(Filter.where(fieldPath, op, value));
  }

  /// Creates and returns a new [Query] with the additional filter
  /// that documents should satisfy the relation constraint(s) provided.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the filter.
  ///
  /// - [filter] A unary or composite filter to apply to the Query.
  ///
  /// ```dart
  /// final collectionRef = firestore.collection('col');
  ///
  /// collectionRef.where(Filter.and(Filter.where('foo', WhereFilter.equal, 'bar'), Filter.where('foo', WhereFilter.notEqual, 'baz'))).get()
  ///   .then((querySnapshot) {
  ///     querySnapshot.forEach((documentSnapshot) {
  ///       print('Found document at ${documentSnapshot.ref.path}');
  ///     });
  /// });
  /// ```
  Query<T> whereFilter(Filter filter) {
    if (_queryOptions.startAt != null || _queryOptions.endAt != null) {
      throw ArgumentError(
        'Cannot specify a where() filter after calling '
        'startAt(), startAfter(), endBefore() or endAt().',
      );
    }

    final parsedFilter = _parseFilter(filter);
    if (parsedFilter.filters.isEmpty) {
      // Return the existing query if not adding any more filters (e.g. an empty composite filter).
      return this;
    }

    final options = _queryOptions.copyWith(
      filters: [..._queryOptions.filters, parsedFilter],
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  _FilterInternal _parseFilter(Filter filter) {
    switch (filter) {
      case _UnaryFilter():
        return _parseFieldFilter(filter);
      case _CompositeFilter():
        return _parseCompositeFilter(filter);
    }
  }

  _FieldFilterInternal _parseFieldFilter(_UnaryFilter fieldFilterData) {
    final value = fieldFilterData.value;
    final operator = fieldFilterData.op;
    final fieldPath = fieldFilterData.fieldPath;

    _validateQueryValue('value', value);

    if (fieldPath == FieldPath.documentId) {
      switch (operator) {
        case WhereFilter.arrayContains:
        case WhereFilter.arrayContainsAny:
          throw ArgumentError.value(
            operator,
            'op',
            "Invalid query. You can't perform '$operator' queries on FieldPath.documentId().",
          );
        case WhereFilter.isIn:
        case WhereFilter.notIn:
          if (value is! List || value.isEmpty) {
            throw ArgumentError.value(
              value,
              'value',
              "Invalid query. A non-empty array is required for '$operator' filters.",
            );
          }
          for (final item in value) {
            if (item is! DocumentReference) {
              throw ArgumentError.value(
                value,
                'value',
                "Invalid query. When querying with '$operator', "
                    'you must provide a List of non-empty DocumentReference instances as the argument.',
              );
            }
          }
        default:
          if (value is! DocumentReference) {
            throw ArgumentError.value(
              value,
              'value',
              'Invalid query. When querying by document ID you must provide a '
                  'DocumentReference instance.',
            );
          }
      }
    }

    return _FieldFilterInternal(
      serializer: firestore._serializer,
      field: fieldPath,
      op: operator,
      value: value,
    );
  }

  _FilterInternal _parseCompositeFilter(_CompositeFilter compositeFilterData) {
    final parsedFilters = compositeFilterData.filters
        .map(_parseFilter)
        .where((filter) => filter.filters.isNotEmpty)
        .toList();

    // For composite filters containing 1 filter, return the only filter.
    // For example: AND(FieldFilter1) == FieldFilter1
    if (parsedFilters.length == 1) {
      return parsedFilters.single;
    }
    return _CompositeFilterInternal(
      filters: parsedFilters,
      op: compositeFilterData.operator == _CompositeOperator.and
          ? _CompositeOperator.and
          : _CompositeOperator.or,
    );
  }

  /// Creates and returns a new [Query] instance that applies a
  /// field mask to the result and returns only the specified subset of fields.
  /// You can specify a list of field paths to return, or use an empty list to
  /// only return the references of matching documents.
  ///
  /// Queries that contain field masks cannot be listened to via `onSnapshot()`
  /// listeners.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the field mask.
  ///
  /// - [fieldPaths] The field paths to return.
  ///
  /// ```dart
  /// final collectionRef = firestore.collection('col');
  /// final documentRef = collectionRef.doc('doc');
  ///
  /// return documentRef.set({x:10, y:5}).then(() {
  ///   return collectionRef.where('x', '>', 5).select('y').get();
  /// }).then((res) {
  ///   print('y is ${res.docs[0].get('y')}.');
  /// });
  /// ```
  Query<DocumentData> select([List<FieldPath> fieldPaths = const []]) {
    final fields = <firestore1.FieldReference>[
      if (fieldPaths.isEmpty)
        firestore1.FieldReference(
          fieldPath: FieldPath.documentId._formattedName,
        )
      else
        for (final fieldPath in fieldPaths)
          firestore1.FieldReference(fieldPath: fieldPath._formattedName),
    ];

    return Query<DocumentData>._(
      firestore: firestore,
      queryOptions: _queryOptions
          .copyWith(projection: firestore1.Projection(fields: fields))
          .withConverter(
            // By specifying a field mask, the query result no longer conforms to type
            // `T`. We there return `Query<DocumentData>`.
            _jsonConverter,
          ),
    );
  }

  /// Creates and returns a new [Query] that's additionally sorted
  /// by the specified field, optionally in descending order instead of
  /// ascending.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the field mask.
  ///
  /// - [fieldPath]: The field to sort by.
  /// - [descending] (false by default) Whether to obtain documents in descending order.
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', WhereFilter.equal, 42);
  ///
  /// query.orderBy('foo', descending: true).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
  }) {
    if (_queryOptions.startAt != null || _queryOptions.endAt != null) {
      throw ArgumentError(
        'Cannot specify an orderBy() constraint after calling '
        'startAt(), startAfter(), endBefore() or endAt().',
      );
    }

    final newOrder = _FieldOrder(
      fieldPath: fieldPath,
      direction: descending ? _Direction.descending : _Direction.ascending,
    );

    final options = _queryOptions.copyWith(
      fieldOrders: [..._queryOptions.fieldOrders, newOrder],
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that's additionally sorted
  /// by the specified field, optionally in descending order instead of
  /// ascending.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the field mask.
  ///
  /// - [path]: The field to sort by.
  /// - [descending] (false by default) Whether to obtain documents in descending order.
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', WhereFilter.equal, 42);
  ///
  /// query.orderBy('foo', descending: true).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> orderBy(
    Object path, {
    bool descending = false,
  }) {
    return orderByFieldPath(
      FieldPath.from(path),
      descending: descending,
    );
  }

  /// Creates and returns a new [Query] that only returns the first matching documents.
  ///
  /// This function returns a new (immutable) instance of the Query (rather than
  /// modify the existing instance) to impose the limit.
  ///
  /// - [limit] The maximum number of items to return.
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', WhereFilter.equal, 42);
  ///
  /// query.limit(1).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> limit(int limit) {
    final options = _queryOptions.copyWith(
      limit: limit,
      limitType: LimitType.first,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Creates and returns a new [Query] that only returns the last matching
  /// documents.
  ///
  /// You must specify at least one [orderBy] clause for limitToLast queries,
  /// otherwise an exception will be thrown during execution.
  ///
  /// Results for limitToLast queries cannot be streamed.
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', '>', 42);
  ///
  /// query.limitToLast(1).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Last matching document is ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> limitToLast(int limit) {
    final options = _queryOptions.copyWith(
      limit: limit,
      limitType: LimitType.last,
    );
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  /// Specifies the offset of the returned results.
  ///
  /// This function returns a new (immutable) instance of the [Query]
  /// (rather than modify the existing instance) to impose the offset.
  ///
  /// - [offset] The offset to apply to the Query results
  ///
  /// ```dart
  /// final query = firestore.collection('col').where('foo', WhereFilter.equal, 42);
  ///
  /// query.limit(10).offset(20).get().then((querySnapshot) {
  ///   querySnapshot.forEach((documentSnapshot) {
  ///     print('Found document at ${documentSnapshot.ref.path}');
  ///   });
  /// });
  /// ```
  Query<T> offset(int offset) {
    final options = _queryOptions.copyWith(offset: offset);
    return Query<T>._(
      firestore: firestore,
      queryOptions: options,
    );
  }

  @mustBeOverridden
  @override
  bool operator ==(Object other) {
    return other is Query<T> &&
        runtimeType == other.runtimeType &&
        _queryOptions == other._queryOptions;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _queryOptions);

  /// Returns an [AggregateQuery] that can be used to execute one or more
  /// aggregation queries over the result set of this query.
  ///
  /// ## Limitations
  /// - Aggregation queries are only supported through direct server response
  /// - Cannot be used with real-time listeners or offline queries
  /// - Must complete within 60 seconds or returns DEADLINE_EXCEEDED error
  /// - For sum() and average(), non-numeric values are ignored
  /// - When combining aggregations on different fields, only documents
  ///   containing all those fields are included
  ///
  /// ```dart
  /// firestore.collection('cities').aggregate(
  ///   count(),
  ///   sum('population'),
  ///   average('population'),
  /// ).get().then(
  ///   (res) {
  ///     print(res.count);
  ///     print(res.getSum('population'));
  ///     print(res.getAverage('population'));
  ///   },
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  AggregateQuery aggregate(
    AggregateField aggregateField1, [
    AggregateField? aggregateField2,
    AggregateField? aggregateField3,
  ]) {
    final fields = [
      aggregateField1,
      if (aggregateField2 != null) aggregateField2,
      if (aggregateField3 != null) aggregateField3,
    ];

    return AggregateQuery._(
      query: this,
      aggregations: fields.map((field) => field._toInternal()).toList(),
    );
  }

  /// Returns an [AggregateQuery] that can be used to execute a count
  /// aggregation.
  ///
  /// The returned query, when executed, counts the documents in the result
  /// set of this query without actually downloading the documents.
  ///
  /// ```dart
  /// firestore.collection('cities').count().get().then(
  ///   (res) => print(res.count),
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  AggregateQuery count() {
    return aggregate(AggregateField.count());
  }

  /// Returns an [AggregateQuery] that can be used to execute a sum
  /// aggregation on the specified field.
  ///
  /// The returned query, when executed, calculates the sum of all values
  /// for the specified field across all documents in the result set.
  ///
  /// - [field]: The field to sum across all matching documents. Can be a
  ///   String or a [FieldPath] for nested fields.
  ///
  /// ```dart
  /// firestore.collection('products').sum('price').get().then(
  ///   (res) => print(res.getSum('price')),
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  AggregateQuery sum(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return aggregate(AggregateField.sum(field));
  }

  /// Returns an [AggregateQuery] that can be used to execute an average
  /// aggregation on the specified field.
  ///
  /// The returned query, when executed, calculates the average of all values
  /// for the specified field across all documents in the result set.
  ///
  /// - [field]: The field to average across all matching documents. Can be a
  ///   String or a [FieldPath] for nested fields.
  ///
  /// ```dart
  /// firestore.collection('products').average('price').get().then(
  ///   (res) => print(res.getAverage('price')),
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  AggregateQuery average(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    return aggregate(AggregateField.average(field));
  }
}

/// Defines an aggregation that can be performed by Firestore.
@immutable
class AggregateField {
  const AggregateField._({
    required this.fieldPath,
    required this.alias,
    required this.type,
  });

  /// Creates a count aggregation.
  ///
  /// Count aggregations provide the number of documents that match the query.
  /// The result can be accessed using [AggregateQuerySnapshot.count].
  factory AggregateField.count() {
    return const AggregateField._(
      fieldPath: null,
      alias: 'count',
      type: _AggregateType.count,
    );
  }

  /// Creates a sum aggregation for the specified field.
  ///
  /// - [field]: The field to sum across all matching documents. Can be a
  ///   String or a [FieldPath] for nested fields.
  ///
  /// The result can be accessed using [AggregateQuerySnapshot.getSum].
  factory AggregateField.sum(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    final fieldPath = FieldPath.from(field);
    final fieldName = fieldPath._formattedName;
    return AggregateField._(
      fieldPath: fieldName,
      alias: 'sum_$fieldName',
      type: _AggregateType.sum,
    );
  }

  /// Creates an average aggregation for the specified field.
  ///
  /// - [field]: The field to average across all matching documents. Can be a
  ///   String or a [FieldPath] for nested fields.
  ///
  /// The result can be accessed using [AggregateQuerySnapshot.getAverage].
  factory AggregateField.average(Object field) {
    assert(
      field is String || field is FieldPath,
      'field must be a String or FieldPath, got ${field.runtimeType}',
    );
    final fieldPath = FieldPath.from(field);
    final fieldName = fieldPath._formattedName;
    return AggregateField._(
      fieldPath: fieldName,
      alias: 'avg_$fieldName',
      type: _AggregateType.average,
    );
  }

  /// The field to aggregate on, or null for count aggregations.
  final String? fieldPath;

  /// The alias to use for this aggregation result.
  final String alias;

  /// The type of aggregation.
  final _AggregateType type;

  /// Converts this public field to the internal representation.
  _AggregateFieldInternal _toInternal() {
    firestore1.Aggregation aggregation;
    switch (type) {
      case _AggregateType.count:
        aggregation = firestore1.Aggregation(
          count: firestore1.Count(),
        );
      case _AggregateType.sum:
        aggregation = firestore1.Aggregation(
          sum: firestore1.Sum(
            field: firestore1.FieldReference(fieldPath: fieldPath),
          ),
        );
      case _AggregateType.average:
        aggregation = firestore1.Aggregation(
          avg: firestore1.Avg(
            field: firestore1.FieldReference(fieldPath: fieldPath),
          ),
        );
    }

    return _AggregateFieldInternal(
      alias: alias,
      aggregation: aggregation,
    );
  }
}

/// The type of aggregation to perform.
enum _AggregateType {
  count,
  sum,
  average,
}

/// Create a CountAggregateField object that can be used to compute
/// the count of documents in the result set of a query.
// ignore: camel_case_types
class count extends AggregateField {
  /// Creates a count aggregation.
  const count()
      : super._(
          fieldPath: null,
          alias: 'count',
          type: _AggregateType.count,
        );
}

/// Create an object that can be used to compute the sum of a specified field
/// over a range of documents in the result set of a query.
// ignore: camel_case_types
class sum extends AggregateField {
  /// Creates a sum aggregation for the specified field.
  const sum(this.field)
      : super._(
          fieldPath: field,
          alias: 'sum_$field',
          type: _AggregateType.sum,
        );

  /// The field to sum.
  final String field;
}

/// Create an object that can be used to compute the average of a specified field
/// over a range of documents in the result set of a query.
// ignore: camel_case_types
class average extends AggregateField {
  /// Creates an average aggregation for the specified field.
  const average(this.field)
      : super._(
          fieldPath: field,
          alias: 'avg_$field',
          type: _AggregateType.average,
        );

  /// The field to average.
  final String field;
}

/// Internal representation of an aggregation field.
@immutable
class _AggregateFieldInternal {
  const _AggregateFieldInternal({
    required this.alias,
    required this.aggregation,
  });

  final String alias;
  final firestore1.Aggregation aggregation;

  @override
  bool operator ==(Object other) {
    return other is _AggregateFieldInternal &&
        alias == other.alias &&
        // For count aggregations, we just check that both have count set
        ((aggregation.count != null && other.aggregation.count != null) ||
            (aggregation.sum != null && other.aggregation.sum != null) ||
            (aggregation.avg != null && other.aggregation.avg != null));
  }

  @override
  int get hashCode => Object.hash(
        alias,
        aggregation.count != null ||
            aggregation.sum != null ||
            aggregation.avg != null,
      );
}

/// Calculates aggregations over an underlying query.
@immutable
class AggregateQuery {
  const AggregateQuery._({
    required this.query,
    required this.aggregations,
  });

  /// The query whose aggregations will be calculated by this object.
  final Query<Object?> query;

  @internal
  final List<_AggregateFieldInternal> aggregations;

  /// Executes the aggregate query and returns the results as an
  /// [AggregateQuerySnapshot].
  ///
  /// ```dart
  /// firestore.collection('cities').count().get().then(
  ///   (res) => print(res.count),
  ///   onError: (e) => print('Error completing: $e'),
  /// );
  /// ```
  Future<AggregateQuerySnapshot> get() async {
    final firestore = query.firestore;

    final aggregationQuery = firestore1.RunAggregationQueryRequest(
      structuredAggregationQuery: firestore1.StructuredAggregationQuery(
        structuredQuery: query._toStructuredQuery(),
        aggregations: [
          for (final field in aggregations)
            firestore1.Aggregation(
              alias: field.alias,
              count: field.aggregation.count,
              sum: field.aggregation.sum,
              avg: field.aggregation.avg,
            ),
        ],
      ),
    );

    final response = await firestore._client.v1((client, projectId) async {
      return client.projects.databases.documents.runAggregationQuery(
        aggregationQuery,
        query._buildProtoParentPath(),
      );
    });

    final results = <String, Object?>{};
    Timestamp? readTime;

    for (final result in response) {
      if (result.result != null && result.result!.aggregateFields != null) {
        for (final entry in result.result!.aggregateFields!.entries) {
          final value = entry.value;
          if (value.integerValue != null) {
            results[entry.key] = int.parse(value.integerValue!);
          } else if (value.doubleValue != null) {
            results[entry.key] = value.doubleValue;
          } else if (value.nullValue != null) {
            results[entry.key] = null;
          }
        }
      }

      if (result.readTime != null) {
        readTime = Timestamp._fromString(result.readTime!);
      }
    }

    return AggregateQuerySnapshot._(
      query: this,
      readTime: readTime,
      data: results,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AggregateQuery &&
        query == other.query &&
        const ListEquality<_AggregateFieldInternal>()
            .equals(aggregations, other.aggregations);
  }

  @override
  int get hashCode => Object.hash(
        query,
        const ListEquality<_AggregateFieldInternal>().hash(aggregations),
      );
}

/// The results of executing an aggregation query.
@immutable
class AggregateQuerySnapshot {
  const AggregateQuerySnapshot._({
    required this.query,
    required this.readTime,
    required this.data,
  });

  /// The query that was executed to produce this result.
  final AggregateQuery query;

  /// The time this snapshot was obtained.
  final Timestamp? readTime;

  /// The raw aggregation data, keyed by alias.
  final Map<String, Object?> data;

  /// The count of documents that match the query. Returns `null` if the
  /// count aggregation was not performed.
  int? get count => data['count'] as int?;

  /// Gets the sum for the specified field. Returns `null` if the
  /// sum aggregation was not performed.
  ///
  /// - [field]: The field that was summed.
  num? getSum(String field) {
    final alias = 'sum_$field';
    final value = data[alias];
    if (value == null) return null;
    if (value is int || value is double) return value as num;
    // Handle case where sum might be returned as a string
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Gets the average for the specified field. Returns `null` if the
  /// average aggregation was not performed.
  ///
  /// - [field]: The field that was averaged.
  double? getAverage(String field) {
    final alias = 'avg_$field';
    final value = data[alias];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    // Handle case where average might be returned as a string
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Gets an aggregate field by alias.
  ///
  /// - [alias]: The alias of the aggregate field to retrieve.
  Object? getField(String alias) => data[alias];

  @override
  bool operator ==(Object other) {
    return other is AggregateQuerySnapshot &&
        query == other.query &&
        readTime == other.readTime &&
        const MapEquality<String, Object?>().equals(data, other.data);
  }

  @override
  int get hashCode => Object.hash(query, readTime, data);
}

/// A QuerySnapshot contains zero or more [QueryDocumentSnapshot] objects
/// representing the results of a query.
///
/// The documents can be accessed as an array via the [docs] property.
@immutable
class QuerySnapshot<T> {
  QuerySnapshot._({
    required this.docs,
    required this.query,
    required this.readTime,
  });

  /// The query used in order to get this [QuerySnapshot].
  final Query<T> query;

  /// The time this query snapshot was obtained.
  final Timestamp? readTime;

  /// A list of all the documents in this QuerySnapshot.
  final List<QueryDocumentSnapshot<T>> docs;

  /// Returns a list of the documents changes since the last snapshot.
  ///
  /// If this is the first snapshot, all documents will be in the list as added
  /// changes.
  late final List<DocumentChange<T>> docChanges = [
    for (final (index, doc) in docs.indexed)
      DocumentChange<T>._(
        type: DocumentChangeType.added,
        oldIndex: -1,
        newIndex: index,
        doc: doc,
      ),
  ];

  @override
  bool operator ==(Object other) {
    return other is QuerySnapshot<T> &&
        runtimeType == other.runtimeType &&
        query == other.query &&
        const ListEquality<QueryDocumentSnapshot<Object?>>()
            .equals(docs, other.docs) &&
        const ListEquality<DocumentChange<Object?>>()
            .equals(docChanges, other.docChanges);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        query,
        const ListEquality<QueryDocumentSnapshot<Object?>>().hash(docs),
        const ListEquality<DocumentChange<Object?>>().hash(docChanges),
      );
}

/// Validates that 'value' can be used as a query value.
void _validateQueryValue(
  String arg,
  Object? value,
) {
  _validateUserInput(
    arg,
    value,
    description: 'query constraint',
    options: const _ValidateUserInputOptions(
      allowDeletes: _AllowDeletes.none,
      allowTransform: false,
    ),
  );
}
