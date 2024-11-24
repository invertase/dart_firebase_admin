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

class _TransactionResult<T> {
  _TransactionResult({this.transaction, required this.result});

  final String? transaction;
  final T result;
}

/// A reference to a transaction.
///
/// The Transaction object passed to a transaction's updateFunction provides
/// the methods to read and write data within the transaction context. See
/// [Firestore.runTransaction].
class Transaction {
  Transaction(
    Firestore firestore,
    TransactionOptions? transactionOptions,
  ) {
    _firestore = firestore;

    _maxAttempts = transactionOptions?.maxAttempts ?? defaultMaxTransactionsAttempts;

    switch (transactionOptions) {
      case ReadOnlyTransactionOptions():
        _readOnlyReadTime = transactionOptions.readTime;
        _writeBatch = null;
      default:
        _writeBatch = WriteBatch._(_firestore);
        _backoff = ExponentialBackoff();
    }
  }

  static const int defaultMaxTransactionsAttempts = 5;

  //Error message for transactional reads that were executed after performing writes.
  static const String readAfterWriteErrorMsg = 'Firestore transactions require all reads to be executed before all writes.';

  static const String readOnlyWriteErrorMsg = 'Firestore read-only transactions cannot execute writes.';

  late final Firestore _firestore;

  late final int _maxAttempts;

  /// Optional, could be set only if transaction is read only
  Timestamp? _readOnlyReadTime;

  /// `null` if transaction is read only
  late final WriteBatch? _writeBatch;

  /// `null` if transaction is read only
  late final ExponentialBackoff _backoff;

  /// Future that resolves to the transaction ID of the current attempt.
  /// It is lazily initialised upon the first read. Upon retry, it is reset and
  /// [_prevTransactionId] is set
  Future<String>? _transactionIdPromise;
  String? _prevTransactionId;

  // TODO support Query as parameter for [get]

  /// Retrieve a document from the database by the provided [docRef]. Holds a
  /// pessimistic lock on all returned documents.
  /// If the document does not exist, the operation throws a [FirebaseFirestoreAdminException] with
  /// [FirestoreClientErrorCode.notFound].
  Future<DocumentSnapshot<T>> get<T>(
    DocumentReference<T> docRef,
  ) async {
    if (_writeBatch != null && _writeBatch._operations.isNotEmpty) {
      throw Exception(readAfterWriteErrorMsg);
    }
    return _withLazyStartedTransaction<DocumentReference<T>, DocumentSnapshot<T>>(
      docRef,
      resultFn: _getSingleFn,
    );
  }

  /// Retrieves multiple documents from Firestore provided in [docsdocumentRefsRefs].
  /// Holds a pessimistic lock on all returned documents.
  Future<List<DocumentSnapshot<T>>> getAll<T>(
    List<DocumentReference<T>> docsdocumentRefsRefs, {
    List<FieldMask>? fieldMasks,
  }) async {
    if (_writeBatch != null && _writeBatch._operations.isNotEmpty) {
      throw Exception(readAfterWriteErrorMsg);
    }
    return _withLazyStartedTransaction<List<DocumentReference<T>>, List<DocumentSnapshot<T>>>(
      docsdocumentRefsRefs,
      resultFn: _getBatchFn<T>,
    );
  }

  Future<_TransactionResult<List<DocumentSnapshot<T>>>> _getBatchFn<T>(
    List<DocumentReference<T>> docsdocumentRefs, {
    String? transactionId,
    Timestamp? readTime,
    firestore1.TransactionOptions? transactionOptions,
    List<FieldPath>? fieldMask,
  }) async {
    final reader = _DocumentReader(
      firestore: _firestore,
      documents: docsdocumentRefs,
      fieldMask: fieldMask,
      transactionId: transactionId,
      readTime: readTime,
      transactionOptions: transactionOptions,
    );

    final result = await reader._get();
    return _TransactionResult(transaction: result.transaction, result: result.result);
  }

  //TODO support SetOptions to include merge parameter
  void set<T>(DocumentReference<T> documentRef, T data) {
    if (_writeBatch == null) {
      throw Exception(readOnlyWriteErrorMsg);
    }
    _writeBatch.set<T>(documentRef, data);
  }

  void delete(DocumentReference<Map<String, dynamic>> documentRef, {Precondition? precondition}) {
    if (_writeBatch == null) {
      throw Exception(readOnlyWriteErrorMsg);
    }
    _writeBatch.delete(documentRef, precondition: precondition);
  }

  void update(DocumentReference<dynamic> documentRef, Map<Object?, Object?> data, {Precondition? precondition}) {
    if (_writeBatch == null) {
      throw Exception(readOnlyWriteErrorMsg);
    }

    _writeBatch.update(
      documentRef,
      {
        for (final entry in data.entries) FieldPath.from(entry.key): entry.value,
      },
      precondition: precondition,
    );
  }

  Future<_TransactionResult<DocumentSnapshot<T>>> _getSingleFn<T>(
    DocumentReference<T> docRef, {
    String? transactionId,
    Timestamp? readTime,
    firestore1.TransactionOptions? transactionOptions,
    List<FieldPath>? fieldMask,
  }) async {
    final reader = _DocumentReader(
      firestore: _firestore,
      documents: [docRef],
      fieldMask: fieldMask,
      transactionId: transactionId,
      readTime: readTime,
      transactionOptions: transactionOptions,
    );
    final result = await reader._get();
    return _TransactionResult(transaction: result.transaction, result: result.result.single);
  }

  /// Given a function that performs a read operation, ensures that the first one
  /// is provided with new transaction options and all subsequent ones are queued
  /// upon the resulting transaction ID.
  Future<TResult> _withLazyStartedTransaction<T, TResult>(
    T docRef, {
    required Future<_TransactionResult<TResult>> Function(
      T docRef, {
      String? transactionId,
      Timestamp? readTime,
      firestore1.TransactionOptions? transactionOptions,
      List<FieldPath>? fieldMask,
    }) resultFn,
  }) {
    if (_transactionIdPromise != null) {
      // Simply queue this subsequent read operation after the first read
      // operation has resolved and we don't expect a transaction ID in the
      // response because we are not starting a new transaction
      return _transactionIdPromise!
          .then(
            (transactionId) => resultFn(docRef, transactionId: transactionId),
          )
          .then((r) => r.result);
    } else {
      if (_readOnlyReadTime != null) {
        // We do not start a transaction for read-only transactions
        // do not set _prevTransactionId
        return resultFn(docRef, readTime: _readOnlyReadTime).then((r) => r.result);
      } else {
        // This is the first read of the transaction so we create the appropriate
        // options for lazily starting the transaction inside this first read op
        final opts = firestore1.TransactionOptions();
        if (_writeBatch != null) {
          opts.readWrite = _prevTransactionId == null ? firestore1.ReadWrite() : firestore1.ReadWrite(retryTransaction: _prevTransactionId);
        } else {
          opts.readOnly = firestore1.ReadOnly();
        }

        final resultPromise = resultFn(docRef, transactionOptions: opts);

        // Ensure the _transactionIdPromise is set synchronously so that
        // subsequent operations will not race to start another transaction
        _transactionIdPromise = resultPromise.then((r) {
          if (r.transaction case final _transaction?) {
            return _transaction;
          } else {
            // Illegal state
            // The read operation was provided with new transaction options but did not return a transaction ID
            // Rejecting here will cause all queued reads to reject
            throw Exception(
              'Transaction ID was missing from server response.',
            );
          }
        });

        return resultPromise.then(
          (r) {
            return r.result;
          },
        );
      }
    }
  }

  Future<T> _runTransaction<T>(
    TransactionHandler<T> updateFunction,
  ) async {
    // No backoff is set for readonly transactions (i.e. attempts == 1)
    if (_writeBatch == null) {
      return _runTransactionOnce(updateFunction);
    }
    FirebaseFirestoreAdminException? lastError;

    for (var attempts = 0; attempts < _maxAttempts; attempts++) {
      try {
        _writeBatch.reset();
        await maybeBackoff(_backoff, lastError);

        return await _runTransactionOnce(updateFunction);
      } on FirebaseFirestoreAdminException catch (e) {
        lastError = e;

        if (!_isRetryableTransactionError(e)) {
          return Future.error(e);
        }
      } catch (e) {
        return Future.error(e);
      }
    }

    throw Exception('Transaction max attempts exceeded');
  }

  Future<T> _runTransactionOnce<T>(
    TransactionHandler<T> updateFunction,
  ) async {
    try {
      final result = await updateFunction(this);
      //If we are on a readWrite transaction, commit
      if (_writeBatch != null) {
        await commit();
      }
      return result;
    } catch (e) {
      await rollback();
      return Future.error(e);
    }
  }

  Future<void> commit() async {
    if (_writeBatch == null) {
      throw Exception(readOnlyWriteErrorMsg);
    }

    String? transactionId;
    // If we have not performed any reads in this particular attempt
    // then the writes will be atomically committed without a transaction ID
    if (_transactionIdPromise != null) {
      transactionId = await _transactionIdPromise;
    } else if (_writeBatch._operations.isEmpty) {
      // If we have not started a transaction (no reads) and we have no writes
      // then the commit is a no-op (success)
      return;
    }
    //TODO support requestTag parameter on commit.
    await _writeBatch._commit(transactionId: transactionId);

    _transactionIdPromise = null;
    _prevTransactionId = transactionId;
  }

  Future<void> rollback() async {
    // No need to roll back if we have not lazily started the transaction
    // or if we are read only
    if (_transactionIdPromise == null || _writeBatch == null) {
      return;
    }

    String? transactionId;

    try {
      transactionId = await _transactionIdPromise;
    } catch (e) {
      // This means the initial read operation rejected
      // and we do not have a transaction ID to roll back
      _transactionIdPromise = null;
      return;
    }

    _transactionIdPromise = null;
    _prevTransactionId = transactionId;

    // We don't need to wait for rollback to completed before continuing.
    // If there are any locks held, then rollback will eventually release them.
    // Rollback can be done concurrently thereby reducing latency caused by
    // otherwise blocking.
    final rollBackRequest = firestore1.RollbackRequest(transaction: transactionId);
    return _firestore._client.v1((client) {
      return client.projects.databases.documents
          .rollback(
            rollBackRequest,
            _firestore._formattedDatabaseName,
          )
          .catchError(_handleException);
    });
  }
}

/// The [TransactionHandler] may be executed multiple times; it should be able
/// to handle multiple executions.
typedef TransactionHandler<T> = Future<T> Function(Transaction transaction);

/// Delays further operations based on the provided error.
Future<void> maybeBackoff(
  ExponentialBackoff backoff, [
  FirebaseFirestoreAdminException? error,
]) async {
  if (error?.errorCode.statusCode == StatusCode.resourceExhausted) {
    backoff.resetToMax();
  }
  await backoff.backoffAndWait();
}

bool _isRetryableTransactionError(FirebaseFirestoreAdminException error) {
  switch (error.errorCode.statusCode) {
    case StatusCode.aborted:
    case StatusCode.cancelled:
    case StatusCode.unknown:
    case StatusCode.deadlineExceeded:
    case StatusCode.internal:
    case StatusCode.unavailable:
    case StatusCode.unauthenticated:
    case StatusCode.resourceExhausted:
      return true;
    case StatusCode.invalidArgument:
      // The Firestore backend uses "INVALID_ARGUMENT" for transactions
      // IDs that have expired. While INVALID_ARGUMENT is generally not
      // retryable, we retry this specific case.
      return error.message.toLowerCase().contains('transaction has expired');
    default:
      return false;
  }
}
