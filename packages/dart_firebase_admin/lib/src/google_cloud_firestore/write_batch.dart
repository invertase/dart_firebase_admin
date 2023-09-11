part of 'firestore.dart';

/// A WriteResult wraps the write time set by the Firestore servers on sets(),
/// updates(), and creates().
@immutable
class WriteResult {
  const WriteResult._(this.writeTime);

  /// The write time as set by the Firestore servers.
  final Timestamp writeTime;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WriteResult && writeTime == other.writeTime;
  }

  @override
  int get hashCode => writeTime.hashCode;
}

// ignore: avoid_private_typedef_functions
typedef _PendingWriteOp = firestore1.Write Function();

/// A Firestore WriteBatch that can be used to atomically commit multiple write
/// operations at once.
class WriteBatch {
  WriteBatch._(this.firestore);

  final Firestore firestore;
  var _commited = false;
  final _operations = <({String docPath, _PendingWriteOp op})>[];

  /// Create a document with the provided object values. This will fail the batch
  /// if a document exists at its location.
  ///
  /// - [documentRef]: A reference to the document to be created.
  /// - [data] The object to serialize as the document.
  ///
  /// Throws if the provided input is not a valid Firestore document.
  ///
  /// ```dart
  /// final writeBatch = firestore.batch();
  /// final documentRef = firestore.collection('col').doc();
  ///
  /// writeBatch.create(documentRef, {foo: 'bar'});
  ///
  /// writeBatch.commit().then(() {
  ///   print('Successfully executed batch.');
  /// });
  /// ```
  void create<T>(DocumentReference<T> ref, T data) {
    final firestoreData = ref._converter.toFirestore(data);
    _validateDocumentData('data', firestoreData, allowDeletes: false);

    _verifyNotCommited();

    final transform = _DocumentTransform.fromObject(ref, firestoreData);
    transform.validate();

    final precondition = Precondition.exists(false);

    firestore1.Write op() {
      final document = DocumentSnapshot._fromObject(ref, firestoreData);
      final write = document._toWriteProto();
      if (transform.transforms.isNotEmpty) {
        write.updateTransforms = transform.toProto(firestore._serializer);
      }
      write.currentDocument = precondition._toProto();
      return write;
    }

    _operations.add((docPath: ref.path, op: op));
  }

  /// Atomically commits all pending operations to the database and verifies all
  /// preconditions. Fails the entire write if any precondition is not met.
  ///
  /// Returns a future that resolves when this batch completes.
  ///
  /// ```dart
  /// final writeBatch = firestore.batch();
  /// final documentRef = firestore.doc('col/doc');
  ///
  /// writeBatch.set(documentRef, {foo: 'bar'});
  ///
  /// writeBatch.commit().then(() {
  ///   console.log('Successfully executed batch.');
  /// });
  /// ```
  Future<List<WriteResult>> commit() async {
    final response = await _commit(transactionId: null);

    return [
      for (final writeResult
          in response.writeResults ?? <firestore1.WriteResult>[])
        WriteResult._(
          Timestamp._fromString(
            writeResult.updateTime ?? response.commitTime!,
          ),
        ),
    ];
  }

  Future<firestore1.CommitResponse> _commit({
    required String? transactionId,
  }) async {
    _commited = true;

    final request = firestore1.CommitRequest(
      transaction: transactionId,
      writes: _operations.map((op) => op.op()).toList(),
    );

    return firestore._client.v1((client) async {
      return client.projects.databases.documents.commit(
        request,
        firestore._formattedDatabaseName,
      );
    });
  }

  /// Deletes a document from the database.
  ///
  /// - [precondition] can be passed to specify custom requirements for the
  ///   request (e.g. only delete if it was last updated at a given time).
  void delete(
    DocumentReference<Object?> documentRef, {
    Precondition? precondition,
  }) {
    _verifyNotCommited();

    firestore1.Write op() {
      final write = firestore1.Write(
        delete: documentRef._formattedName,
      );
      if (precondition != null && !precondition._isEmpty) {
        write.currentDocument = precondition._toProto();
      }
      return write;
    }

    _operations.add((docPath: documentRef.path, op: op));
  }

  /// Write to the document referred to by the provided
  /// [DocumentReference]. If the document does not
  /// exist yet, it will be created.
  void set<T>(DocumentReference<T> documentReference, T data) {
    final firestoreData = documentReference._converter.toFirestore(data);

    _validateDocumentData(
      'data',
      firestoreData,
      allowDeletes: false,
    );

    _verifyNotCommited();

    final transform =
        _DocumentTransform.fromObject(documentReference, firestoreData);
    transform.validate();

    firestore1.Write op() {
      final document =
          DocumentSnapshot._fromObject(documentReference, firestoreData);

      final write = document._toWriteProto();
      if (transform.transforms.isNotEmpty) {
        write.updateTransforms = transform.toProto(firestore._serializer);
      }
      return write;
    }

    _operations.add((docPath: documentReference.path, op: op));
  }

  /// Update fields of the document referred to by the provided
  /// [DocumentReference]. If the document doesn't yet exist,
  /// the update fails and the entire batch will be rejected.
  // TODO support update(ref, List<(FieldPath, value)>)
  void update(
    DocumentReference<Object?> documentRef,
    UpdateMap data, {
    Precondition? precondition,
  }) {
    _update(
      data: data,
      documentRef: documentRef,
      precondition: precondition,
    );
  }

  void _update({
    required UpdateMap data,
    required DocumentReference<Object?> documentRef,
    required Precondition? precondition,
  }) {
    _verifyNotCommited();
    _validateUpdateMap('data', data);

    precondition ??= Precondition.exists(true);

    _validateNoConflictingFields('data', data);

    final transform = _DocumentTransform.fromUpdateMap(documentRef, data);
    transform.validate();

    final documentMask = _DocumentMask.fromUpdateMap(data);

    firestore1.Write op() {
      final document = DocumentSnapshot.fromUpdateMap(documentRef, data);
      final write = document._toWriteProto();
      write.updateMask = documentMask.toProto();
      if (transform.transforms.isNotEmpty) {
        write.updateTransforms = transform.toProto(firestore._serializer);
      }
      write.currentDocument = precondition!._toProto();
      return write;
    }

    _operations.add((docPath: documentRef.path, op: op));
  }

  void _verifyNotCommited() {
    if (_commited) {
      throw StateError('Cannot modify a WriteBatch that has been committed.');
    }
  }
}

/// Validates that the update data does not contain any ambiguous field
/// definitions (such as 'a.b' and 'a').
void _validateNoConflictingFields(String arg, Map<FieldPath, Object?> data) {
  final fields = data.keys.sorted((left, right) => left.compareTo(right));

  for (var i = 1; i < fields.length; i++) {
    if (fields[i - 1]._isPrefixOf(fields[i])) {
      throw ArgumentError.value(
        data,
        arg,
        'Field "${fields[i - 1]._formattedName}" was specified multiple times.',
      );
    }
  }
}

void _validateUpdateMap(String arg, UpdateMap obj) {
  if (obj.isEmpty) {
    throw ArgumentError.value(obj, arg, 'At least one field must be updated.');
  }

  _validateFieldValue(arg, obj);
}

void _validateFieldValue(
  String arg,
  UpdateMap obj, {
  FieldPath? path,
}) {
  _validateUserInput(
    arg,
    obj,
    description: 'Firestore value',
    options: const _ValidateUserInputOptions(
      allowDeletes: _AllowDeletes.root,
      allowTransform: true,
    ),
    path: path,
  );
}

void _validateDocumentData(
  String arg,
  Object? obj, {
  required bool allowDeletes,
}) {
  if (obj is! DocumentData) {
    throw ArgumentError.value(
      obj,
      arg,
      'Value for argument "$arg" is not a valid Firestore document. Input '
      'is not a plain JavaScript object.',
    );
  }

  _validateUserInput(
    arg,
    obj,
    description: 'Firestore document',
    options: _ValidateUserInputOptions(
      allowDeletes: allowDeletes ? _AllowDeletes.all : _AllowDeletes.none,
      allowTransform: true,
    ),
  );
}
