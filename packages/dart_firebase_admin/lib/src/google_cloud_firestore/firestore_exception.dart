part of 'firestore.dart';

/// A generic guard wrapper for API calls to handle exceptions.
R _firestoreGuard<R>(R Function() cb) {
  try {
    final value = cb();

    if (value is Future) {
      return value.catchError(_handleException) as R;
    }

    return value;
  } catch (error, stackTrace) {
    _handleException(error, stackTrace);
  }
}

/// Converts a Exception to a FirebaseAdminException.
Never _handleException(Object exception, StackTrace stackTrace) {
  if (exception is firestore1.DetailedApiRequestError) {
    Error.throwWithStackTrace(
      FirebaseFirestoreAdminException.fromServerError(exception),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}

class FirebaseFirestoreAdminException extends FirebaseAdminException {
  FirebaseFirestoreAdminException.fromServerError(
    this.serverError,
  ) : super('firestore', 'unknown', serverError.message);

  /// The error thrown by the http/grpc client.
  ///
  /// This is exposed temporarily as a workaround until proper status codes
  /// are exposed officially.
  // TODO handle firestore error codes.
  @experimental
  final firestore1.DetailedApiRequestError serverError;

  @override
  String toString() =>
      'FirebaseFirestoreAdminException: $code: $message ${serverError.jsonResponse} ';
}

/// Auth client error codes and their default messages.
enum FirestoreErrorCode {
  aborted(
    code: 'aborted',
    message:
        'The operation was aborted, typically due to a concurrency issue like transaction aborts, etc.',
  ),
  alreadyExists(
    code: 'already-exists',
    message: 'Some document that we attempted to create already exists.',
  ),
  cancelled(
    code: 'cancelled',
    message: 'The operation was cancelled (typically by the caller).',
  ),
  dataLoss(
    code: 'data-loss',
    message: 'Unrecoverable data loss or corruption.',
  ),
  deadlineExceeded(
    code: 'deadline_exceeded',
    message: 'Deadline expired before operation could complete.',
  ),
  failedPrecondition(
    code: 'failed_precondition',
    message:
        "Operation was rejected because the system is not in a state required for the operation's execution.",
  ),
  internal(
    code: 'internal',
    message: 'Internal errors.',
  ),
  invalidArgument(
    code: 'invalid_argument',
    message: 'Client specified an invalid argument.',
  ),
  notFound(
    code: 'not_found',
    message: 'Some requested document was not found.',
  ),
  ok(
    code: 'ok',
    message: 'The operation completed successfully.',
  ),
  outOfRange(
    code: 'out_of_range',
    message: 'Operation was attempted past the valid range.',
  ),
  permissionDenied(
    code: 'permission_denied',
    message:
        'The caller does not have permission to execute the specified operation.',
  ),
  resourceExhausted(
    code: 'resource_exhausted',
    message:
        'Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system is out of space.',
  ),
  unauthenticated(
    code: 'unauthenticated',
    message:
        'The request does not have valid authentication credentials for the operation.',
  ),
  unavailable(
    code: 'unavailable',
    message: 'The service is currently unavailable.',
  ),
  unimplemented(
    code: 'unimplemented',
    message: 'Operation is not implemented or not supported/enabled.',
  ),
  unknown(
    code: 'unknown',
    message: 'Unknown error or an error from a different error domain.',
  );

  const FirestoreErrorCode({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}
