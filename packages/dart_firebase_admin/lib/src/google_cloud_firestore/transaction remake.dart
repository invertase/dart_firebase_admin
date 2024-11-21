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

/// A reference to a transaction.
///
/// The Transaction object passed to a transaction's updateFunction provides
/// the methods to read and write data within the transaction context. See
/// [Firestore.runTransaction].
/// [_firestore] The Firestore Database client.
/// [_requestTag] A unique client-assigned identifier for the scope of
/// this transaction.
///
class NewTransaction {
  NewTransaction(
    Firestore firestore,
    String requestTag,
    firestore1.TransactionOptions transactionOptions,
  ) {
    _firestore = firestore;
    _requestTag = requestTag;

    if (transactionOptions.readOnly != null) {
      _maxAttempts = transactionOptions.readWrite.maxAttempts;
      _backoff = ExponentialBackoff();
    }

    switch (transactionOptions.readOnly) {
      case true:
        _maxAttempts = transactionOptions.maxAttempts;
        _backoff = ExponentialBackoff();
      case ReadOnlyTransactionOptions():
        _maxAttempts = 1;
        _readOnlyReadTime = transactionOptions.readTime;
        _writeBatch = WriteBatch._(_firestore);
    }
  }

/*!
 * Error message for transactional reads that were executed after performing
 * writes.
 */
  static const String readAfterWriteErrorMsg =
      'Firestore transactions require all reads to be executed before all writes.';

  static const String readOnlyWriteErrorMsg =
      'Firestore read-only transactions cannot execute writes.';

  late final Firestore _firestore;
  late final int _maxAttempts;
  late final String _requestTag;

  /// Optional, could be set only if transaction is read only
  late final Timestamp? _readOnlyReadTime;

  /// `null` if transaction is read only
  late final WriteBatch? _writeBatch;

  /// `null` if transaction is read only
  late final ExponentialBackoff _backoff;

  /// Future that resolves to the transaction ID of the current attempt.
  /// It is lazily initialised upon the first read. Upon retry, it is reset and
  /// [_prevTransactionId] is set
  late final Future<String>? _transactionIdPromise;
  final String? _prevTransactionId;

  //TODO accept a QuerySnapshot as parameter for [get]
  /// Reads the document referenced by the provided [docRef].
  ///
  /// If the document does not exist, the operation throws a [FirebaseFirestoreAdminException] with
  /// [FirestoreClientErrorCode.notFound].
  Future<DocumentSnapshot<T>> get<T>(
    DocumentReference<T> docRef,
  ) async {
    if (_writeBatch != null && _writeBatch._operations.isNotEmpty) {
      throw Exception(readAfterWriteErrorMsg);
    }

    return withLazyStartedTransaction<T>(
      docRef,
      null,
      null,
      null,
      _getSingleFn,
    );
  }

  Future<Map<String, dynamic>> _getSingleFn<T>(
    DocumentReference<T> docRef, {
    Timestamp? readTime,
    String? transactionId,
    firestore1.TransactionOptions? transactionOptions,
  }) async {
    // return _firestore.doc(documentPath).get();
    final reader = _DocumentReader(
      firestore: _firestore,
      documents: [docRef],
      fieldMask: null,
      transactionId: transactionId,
      readTime: readTime,
      transactionOptions: transactionOptions,
    );

    final result = (await reader.get(_requestTag)).single;
    return {
      'transaction': this,
      'result': result,
    };
  }

  /// Given a function that performs a read operation, ensures that the first one
  /// is provided with new transaction options and all subsequent ones are queued
  /// upon the resulting transaction ID.
  Future<DocumentSnapshot<T>> withLazyStartedTransaction<T>(
    DocumentReference<T> docRef,
    String? transactionId,
    Timestamp? readTime,
    firestore1.TransactionOptions? transactionOptions,
    Future<Map<String, dynamic>> Function(
      DocumentReference<T> docRef, {
      String? transactionId,
      Timestamp? readTime,
      firestore1.TransactionOptions? transactionOptions,
    }) resultFn,
  ) {
    if (_transactionIdPromise != null) {
      // Simply queue this subsequent read operation after the first read
      // operation has resolved and we don't expect a transaction ID in the
      // response because we are not starting a new transaction
      return _transactionIdPromise
          .then(
              (transactionId) => resultFn(docRef, transactionId: transactionId))
          .then((r) => r['result'] as DocumentSnapshot<T>);
    } else {
      if (_readOnlyReadTime != null) {
        // We do not start a transaction for read-only transactions
        // do not set _prevTransactionId
        return resultFn(docRef, readTime: _readOnlyReadTime)
            .then((r) => r['result'] as DocumentSnapshot<T>);
      } else {
        // This is the first read of the transaction so we create the appropriate
        // options for lazily starting the transaction inside this first read op
        final newTransactionOptions = firestore1.TransactionOptions(
          readWrite: firestore1.ReadWrite(retryTransaction: _prevTransactionId),
        );

        final resultPromise =
            resultFn(docRef, transactionOptions: newTransactionOptions);

        // Ensure the _transactionIdPromise is set synchronously so that
        // subsequent operations will not race to start another transaction
        _transactionIdPromise = resultPromise.then((r) {
          if (r['transaction'] == null) {
            // Illegal state
            // The read operation was provided with new transaction options but did not return a transaction ID
            // Rejecting here will cause all queued reads to reject
            throw Exception(
              'Transaction ID was missing from server response',
            );
          }
          return r['transaction'] as String;
        });

        return resultPromise.then((r) => r['result'] as DocumentSnapshot<T>);
      }
    }
  }
}
