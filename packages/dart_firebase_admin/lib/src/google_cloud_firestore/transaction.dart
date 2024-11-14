part of 'firestore.dart';

class ReadOptions {
  ReadOptions({this.fieldMask});

  /// Specifies the set of fields to return and reduces the amount of data
  /// transmitted by the backend.
  ///
  /// Adding a field mask does not filter results. Documents do not need to
  /// contain values for all the fields in the mask to be part of the result
  /// set.
  final List<FieldMask>? fieldMask;
}

List<FieldPath>? _parseFieldMask(ReadOptions? readOptions) {
  return readOptions?.fieldMask?.map(FieldPath.fromArgument).toList();
}

/// The [TransactionHandler] may be executed multiple times; it should be able
/// to handle multiple executions.
typedef TransactionHandler<T> = Future<T> Function(Transaction transaction);

/// Transaction class which is created from a call to [runTransaction()].
class Transaction {
  Transaction(this._firestore, this._transactionId) {
    _transactionWriteBatch = WriteBatch._(_firestore);
  }

  Transaction._(
    this._firestore,
    this._transactionId,
    this._transactionWriteBatch,
  );

  final Firestore _firestore;
  final String _transactionId;

  late final WriteBatch _transactionWriteBatch;

  /// Reads the document referenced by the provided [docRef].
  ///
  /// If the document does not exist, the operation throws a [FirebaseFirestoreAdminException] with
  /// [FirestoreClientErrorCode.notFound].
  Future<DocumentSnapshot<T>> get<T>(
    DocumentReference<T> docRef,
  ) async {
    assert(
      _transactionWriteBatch._operations.isEmpty,
      'Transactions require all reads to be executed before all writes.',
    );
    // return _firestore.doc(documentPath).get();
    final reader = _DocumentReader(
      firestore: _firestore,
      documents: [docRef],
      fieldMask: null,
      transactionId: _transactionId,
    );
    final tag = requestTag();
    final result = (await reader.get(tag)).single;

    if (!result.exists) {
      throw FirebaseFirestoreAdminException(FirestoreClientErrorCode.notFound);
    } else {
      return result;
    }
  }

  /// Deletes the document referred by the provided [docRef].
  ///
  /// If the document does not exist, the operation does nothing and returns
  /// normally.
  Transaction delete(DocumentReference<Map<String, dynamic>> docRef) {
    return Transaction._(
      _firestore,
      _transactionId,
      _transactionWriteBatch..delete(docRef),
    );
  }

  /// Updates fields provided in [data] for the document referred to by [docRef].
  ///
  /// Only the fields specified in [data] will be updated. Fields that
  /// are not specified in [data] will not be changed.
  ///
  /// If the document does not yet exist, it will fail.

  Transaction update(
    DocumentReference<dynamic> docRef,
    Map<Object?, Object?> data, [
    Precondition? precondition,
  ]) {
    _transactionWriteBatch.update(
      docRef,
      {
        for (final entry in data.entries)
          FieldPath.from(entry.key): entry.value,
      },
      precondition: precondition,
    );

    return Transaction._(_firestore, _transactionId, _transactionWriteBatch);
  }

  /// Sets fields provided in [data] for the document referred to by [docRef].
  ///
  /// All fields will be overwritten with the provided [data]. This means
  /// that all fields that are not specified in [data] will be deleted.
  ///
  /// If the document does not yet exist, it will be created.
  Transaction set<T>(
    DocumentReference<T> docRef,
    T data,
  ) {
    _transactionWriteBatch.set(docRef, data);
    return Transaction._(
      _firestore,
      _transactionId,
      _transactionWriteBatch,
    );
  }
}
