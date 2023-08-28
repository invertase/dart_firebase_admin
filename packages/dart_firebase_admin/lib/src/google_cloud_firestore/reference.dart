part of 'firestore.dart';

class CollectionReference<T> extends Query<T> {
  CollectionReference._({
    required super.firestore,
    required _ResourcePath path,
    required FirestoreDataConverter<T> converter,
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
  /// console.log(`Parent name: ${documentRef.path}`);
  /// ```
  DocumentReference<T>? get parent {
    if (!_queryOptions.parentPath.isDocument) return null;

    return DocumentReference<T>._(
      firestore: firestore,
      path: _queryOptions.parentPath,
      converter: _queryOptions.converter,
    );
  }

  /// A string representing the path of the referenced collection (relative
  /// to the root of the database).
  String get path => _resourcePath.relativeName;

  // TODO listDocuments
  // TODO doc
  // TODO add
  // TODO ==

  @override
  CollectionReference<U> withConverter<U>({
    required FromFirestore<U> fromFirestore,
    required ToFirestore<U> toFirestore,
  }) {
    return CollectionReference<U>._(
      firestore: firestore,
      path: _queryOptions.parentPath._append(id),
      converter: FirestoreDataConverter<U>(
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
class DocumentReference<T> implements _Serializable {
  const DocumentReference._({
    required this.firestore,
    required _ResourcePath path,
    required FirestoreDataConverter<T> converter,
  })  : _converter = converter,
        _path = path;

  final _ResourcePath _path;
  final FirestoreDataConverter<T> _converter;
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
      path: _path._parent()!,
      converter: _converter,
    );
  }

  /// The string representation of the DocumentReference's location.
  String get _formattedName {
    return _path
        ._toQualifiedResourcePath(
          firestore.app.projectId,
          firestore._databaseId,
        )
        ._formattedName;
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
      converter: FirestoreDataConverter<R>(
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      ),
    );
  }

  Future<DocumentSnapshot<T>> get() async {
    final result = await firestore.getAll([this], null);
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
  Future<WriteResult> create(DocumentData data) async {
    final writeBatch = WriteBatch._(this.firestore)..create(this, data);

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
      converter: FirestoreDataConverter.jsonConverter,
    );
  }

  // TODO listCollections
  // TODO create
  // TODO delete
  // TODO set
  // TODO update
  // TODO onSnapshot

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

class _QueryCursor {
  _QueryCursor({required this.before, required this.values});

  final bool before;
  final List<firestore1.Value?> values;
}

/*
 * Denotes whether a provided limit is applied to the beginning or the end of
 * the result set.
 */
enum LimitType {
  first,
  last,
}

// TODO
abstract class _FilterInternal {}

enum _Direction {
  ascending('ASCENDING'),
  descending('DESCENDING');

  const _Direction(this.value);

  final String value;
}

/// A Query order-by field.
class _FieldOrder {
  _FieldOrder({required this.fieldPath, required this.direction});

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
}

class _QueryOptions<T> {
  _QueryOptions._({
    required this.parentPath,
    required this.collectionId,
    required this.converter,
    required this.allDescendants,
    required this.filters,
    required this.fieldOrders,
    this.startAt,
    this.endAt,
    this.limit,
    this.projection,
    this.limitType,
    this.offset,
    this.kindless = false,
    this.requireConsistency = true,
  });

  /// Returns query options for a single-collection query.
  factory _QueryOptions.forCollectionQuery(
    _ResourcePath collectionRef,
    FirestoreDataConverter<T> converter,
  ) {
    return _QueryOptions<T>._(
      parentPath: collectionRef._parent()!,
      collectionId: collectionRef.id!,
      converter: converter,
      allDescendants: false,
      filters: [],
      fieldOrders: [],
    );
  }

  // TODO

  final _ResourcePath parentPath;
  final String collectionId;
  final FirestoreDataConverter<T> converter;
  final bool allDescendants;
  final List<_FilterInternal> filters;
  final List<_FieldOrder> fieldOrders;
  final _QueryCursor? startAt;
  final _QueryCursor? endAt;
  final int? limit;
  final LimitType? limitType;
  final int? offset;
  final firestore1.Projection? projection;

  // Whether to select all documents under `parentPath`. By default, only
  // collections that match `collectionId` are selected.
  final bool kindless;
  // Whether to require consistent documents when restarting the query. By
  // default, restarting the query uses the readTime offset of the original
  // query to provide consistent results.
  final bool requireConsistency;

  _QueryOptions<U> withConverter<U>(
    FirestoreDataConverter<U> converter,
  ) {
    return _QueryOptions<U>._(
      converter: converter,
      parentPath: this.parentPath,
      collectionId: this.collectionId,
      allDescendants: this.allDescendants,
      filters: this.filters,
      fieldOrders: this.fieldOrders,
      startAt: this.startAt,
      endAt: this.endAt,
      limit: this.limit,
      limitType: this.limitType,
      offset: this.offset,
      projection: this.projection,
    );
  }

  // TODO ==
}

@immutable
class Query<T> {
  const Query._({
    required this.firestore,
    required _QueryOptions<T> queryOptions,
  }) : _queryOptions = queryOptions;

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
        FirestoreDataConverter(
          fromFirestore: fromFirestore,
          toFirestore: toFirestore,
        ),
      ),
    );
  }

  // TODO where
  // TODO whereFilter
  // TODO select
  // TODO orderBy
  // TODO limit
  // TODO limitToLast
  // TODO offset
  // TODO count
  // TODO ==
  // TODO startAt
  // TODO startAfter
  // TODO endBefore
  // TODO endAt
  // TODO get
  // TODO stream
  // TODO onSnapshot

  @mustBeOverridden
  @override
  bool operator ==(Object other) {
    return other is Query<T> &&
        runtimeType == other.runtimeType &&
        _queryOptions == other._queryOptions;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _queryOptions);
}
