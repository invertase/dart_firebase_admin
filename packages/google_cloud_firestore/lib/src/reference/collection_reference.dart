part of '../firestore.dart';

@immutable
final class CollectionReference<T> extends Query<T> {
  CollectionReference._({
    required super.firestore,
    required _ResourcePath path,
    required _FirestoreDataConverter<T> converter,
  }) : super._(queryOptions: _QueryOptions.forCollectionQuery(path, converter));

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
    final effectivePath = documentPath ?? autoId();

    if (documentPath != null) {
      _validateResourcePath('documentPath', documentPath);
    }

    final path = _resourcePath._append(effectivePath);
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
    final response = await firestore._firestoreClient.v1((api, projectId) {
      final parentPath = _queryOptions.parentPath._toQualifiedResourcePath(
        projectId,
        firestore.databaseId,
      );

      return api.projects.databases.documents.list(
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
          in response.documents ?? const <firestore_v1.Document>[])
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
    _validateDocumentData('data', firestoreData, allowDeletes: false);

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
      path: _queryOptions.parentPath._append(id),
      converter: (fromFirestore: fromFirestore, toFirestore: toFirestore),
    );
  }

  @override
  // ignore: hash_and_equals, already implemented in Query
  bool operator ==(Object other) {
    return other is CollectionReference<T> && super == other;
  }
}
