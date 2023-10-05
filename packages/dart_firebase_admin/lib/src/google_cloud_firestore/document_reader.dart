part of 'firestore.dart';

class _DocumentReader<T> {
  _DocumentReader({
    required this.firestore,
    required this.documents,
    required this.fieldMask,
    required this.transactionId,
  }) : _outstandingDocuments = documents.map((e) => e._formattedName).toSet();

  final Firestore firestore;
  final List<DocumentReference<T>> documents;
  final List<FieldPath>? fieldMask;
  final String? transactionId;
  final Set<String> _outstandingDocuments;
  final _retreivedDocuments = <String, DocumentSnapshot<DocumentData>>{};

  /// Invokes the BatchGetDocuments RPC and returns the results.
  Future<List<DocumentSnapshot<T>>> get(String requestTag) async {
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

    return orderedDocuments;
  }

  Future<void> _fetchDocuments(String requestTag) async {
    if (_outstandingDocuments.isEmpty) return;

    final documents = await firestore._client.v1((client) async {
      return client.projects.databases.documents.batchGet(
        firestore1.BatchGetDocumentsRequest(
          documents: _outstandingDocuments.toList(),
          mask: fieldMask.let((fieldMask) {
            return firestore1.DocumentMask(
              fieldPaths: fieldMask.map((e) => e._formattedName).toList(),
            );
          }),
          transaction: transactionId,
        ),
        firestore._formattedDatabaseName,
      );
    });

    for (final response in documents) {
      DocumentSnapshot<DocumentData> documentSnapshot;

      final found = response.found;
      if (found != null) {
        documentSnapshot = DocumentSnapshot._fromDocument(
          found,
          response.readTime,
          firestore,
        );
      } else {
        final missing = response.missing!;
        documentSnapshot = DocumentSnapshot._missing(
          missing,
          response.readTime,
          firestore,
        );
      }

      final path = documentSnapshot.ref._formattedName;
      _outstandingDocuments.remove(path);
      _retreivedDocuments[path] = documentSnapshot;
    }
    // TODO handle retry
  }
}
