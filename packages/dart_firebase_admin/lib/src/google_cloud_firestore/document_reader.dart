part of 'firestore.dart';

class _BatchGetResponse<T> {
  _BatchGetResponse(this.result, this.transaction);

  List<DocumentSnapshot<T>> result;
  String? transaction;
}

class _DocumentReader<T> {
  _DocumentReader({
    required this.firestore,
    required this.documents,
    required this.fieldMask,
    this.transactionId,
    this.readTime,
    this.transactionOptions,
  })  : _outstandingDocuments = documents.map((e) => e._formattedName).toSet(),
        assert(
          [transactionId, readTime, transactionOptions].nonNulls.length <= 1,
          'Only transactionId or readTime or transactionOptions must be provided. transactionId = $transactionId, readTime = $readTime, transactionOptions = $transactionOptions',
        );

  String? _retrievedTransactionId;
  final Firestore firestore;
  final List<DocumentReference<T>> documents;
  final List<FieldPath>? fieldMask;
  final String? transactionId;
  final Timestamp? readTime;
  final firestore1.TransactionOptions? transactionOptions;
  final Set<String> _outstandingDocuments;
  final _retreivedDocuments = <String, DocumentSnapshot<DocumentData>>{};

  /// Invokes the BatchGetDocuments RPC and returns the results.
  Future<List<DocumentSnapshot<T>>> get(String requestTag) async {
    return _get(requestTag).then((value) => value.result);
  }

  Future<_BatchGetResponse<T>> _get(String requestTag) async {
    await _fetchDocuments(requestTag);

    // BatchGetDocuments doesn't preserve document order. We use the request
    // order to sort the resulting documents.
    final orderedDocuments = <DocumentSnapshot<T>>[];

    for (final docRef in documents) {
      final document = _retreivedDocuments[docRef._formattedName];
      if (document != null) {
        // Recreate the DocumentSnapshot with the DocumentReference
        // containing the original converter.
        final finalDoc = _DocumentSnapshotBuilder(docRef)
          ..fieldsProto = document._fieldsProto
          ..createTime = document.createTime
          ..readTime = document.readTime
          ..updateTime = document.updateTime;

        orderedDocuments.add(finalDoc.build());
      } else {
        throw StateError('Did not receive document for "${docRef.path}".');
      }
    }
    return _BatchGetResponse<T>(orderedDocuments, _retrievedTransactionId);
  }

  Future<void> _fetchDocuments(String requestTag) async {
    if (_outstandingDocuments.isEmpty) return;

    final request = firestore1.BatchGetDocumentsRequest(
      documents: _outstandingDocuments.toList(),
      mask: fieldMask.let((fieldMask) {
        return firestore1.DocumentMask(
          fieldPaths: fieldMask.map((e) => e._formattedName).toList(),
        );
      }),
      transaction: transactionId,
      newTransaction: transactionOptions,
      readTime: readTime?._toProto().timestampValue,
    );

    var resultCount = 0;
    try {
      final documents = await firestore._client.v1((client) async {
        return client.projects.databases.documents.batchGet(
          request,
          firestore._formattedDatabaseName,
        );
      }).catchError(_handleException);

      for (final response in documents) {
        DocumentSnapshot<DocumentData>? documentSnapshot;

        if (response.transaction?.isNotEmpty ?? false) {
          this._retrievedTransactionId = response.transaction;
        }

        final found = response.found;
        if (found != null) {
          documentSnapshot = DocumentSnapshot._fromDocument(
            found,
            response.readTime,
            firestore,
          );
        } else if (response.missing != null) {
          final missing = response.missing!;
          documentSnapshot = DocumentSnapshot._missing(
            missing,
            response.readTime,
            firestore,
          );
        }

        if (documentSnapshot != null) {
          final path = documentSnapshot.ref._formattedName;
          _outstandingDocuments.remove(path);
          _retreivedDocuments[path] = documentSnapshot;
          resultCount++;
        }
      }
    } on FirebaseFirestoreAdminException catch (firestoreError) {
      final shoulRetry = request.transaction != null &&
          request.newTransaction != null &&
          // Only retry if we made progress.
          resultCount > 0 &&
          // Don't retry permanent errors.
          StatusCode.batchGetRetryCodes
              .contains(firestoreError.errorCode.statusCode);
      if (shoulRetry) {
        return _fetchDocuments(requestTag);
      } else {
        rethrow;
      }
    }
  }
}
