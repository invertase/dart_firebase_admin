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
      _createFirebaseError(
        statusCode: exception.status,
        body: switch (exception.jsonResponse) {
          null => '',
          final json => jsonEncode(json),
        },
        isJson: exception.jsonResponse != null,
      ),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}

class FirebaseFirestoreAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseFirestoreAdminException(
    this.errorCode, [
    String? message,
  ]) : super('firestore', errorCode.code, message ?? errorCode.message);

  @internal
  factory FirebaseFirestoreAdminException.fromServerError({
    required String serverErrorCode,
    String? message,
    Object? rawServerResponse,
  }) {
    // If not found, default to unknown error.
    final error = firestoreServerToClientCode[serverErrorCode] ??
        FirestoreClientErrorCode.unknown;
    message ??= error.message;

    if (error == FirestoreClientErrorCode.unknown &&
        rawServerResponse != null) {
      try {
        message += ' Raw server response: "${jsonEncode(rawServerResponse)}"';
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseFirestoreAdminException(error, message);
  }

  final FirestoreClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseFirestoreAdminException: $code: $message';
}

/// Firestore server to client enum error codes.
/// https://cloud.google.com/firestore/docs/use-rest-api#error_codes
@internal
const firestoreServerToClientCode = {
  // The operation was aborted, typically due to a concurrency issue like transaction aborts, etc.
  'ABORTED': FirestoreClientErrorCode.aborted,
  // Some document that we attempted to create already exists.
  'ALREADY_EXISTS': FirestoreClientErrorCode.alreadyExists,
  // The operation was cancelled (typically by the caller).
  'CANCELLED': FirestoreClientErrorCode.cancelled,
  // Unrecoverable data loss or corruption.
  'DATA_LOSS': FirestoreClientErrorCode.dataLoss,
  // Deadline expired before operation could complete.
  'DEADLINE_EXCEEDED': FirestoreClientErrorCode.deadlineExceeded,
  // Operation was rejected because the system is not in a state required for the operation's execution.
  'FAILED_PRECONDITION': FirestoreClientErrorCode.failedPrecondition,
  // Internal errors.
  'INTERNAL': FirestoreClientErrorCode.internal,
  // Client specified an invalid argument.
  'INVALID_ARGUMENT': FirestoreClientErrorCode.invalidArgument,
  // Some requested document was not found.
  'NOT_FOUND': FirestoreClientErrorCode.notFound,
  // The operation completed successfully.
  'OK': FirestoreClientErrorCode.ok,
  // Operation was attempted past the valid range.
  'OUT_OF_RANGE': FirestoreClientErrorCode.outOfRange,
  // The caller does not have permission to execute the specified operation.
  'PERMISSION_DENIED': FirestoreClientErrorCode.permissionDenied,
  // Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system is out of space.
  'RESOURCE_EXHAUSTED': FirestoreClientErrorCode.resourceExhausted,
  // The request does not have valid authentication credentials for the operation.
  'UNAUTHENTICATED': FirestoreClientErrorCode.unauthenticated,
  // The service is currently unavailable.
  'UNAVAILABLE': FirestoreClientErrorCode.unavailable,
  // Operation is not implemented or not supported/enabled.
  'UNIMPLEMENTED': FirestoreClientErrorCode.unimplemented,
  // Unknown error or an error from a different error domain.
  'UNKNOWN': FirestoreClientErrorCode.unknown,
};

/// Firestore client error codes and their default messages.
enum FirestoreClientErrorCode {
  aborted(
    statusCode: StatusCode.aborted,
    code: 'aborted',
    message:
        'The operation was aborted, typically due to a concurrency issue like transaction aborts, etc.',
  ),
  alreadyExists(
    statusCode: StatusCode.alreadyExists,
    code: 'already-exists',
    message: 'Some document that we attempted to create already exists.',
  ),
  cancelled(
    statusCode: StatusCode.cancelled,
    code: 'cancelled',
    message: 'The operation was cancelled (typically by the caller).',
  ),
  dataLoss(
    statusCode: StatusCode.dataLoss,
    code: 'data-loss',
    message: 'Unrecoverable data loss or corruption.',
  ),
  deadlineExceeded(
    statusCode: StatusCode.deadlineExceeded,
    code: 'deadline_exceeded',
    message: 'Deadline expired before operation could complete.',
  ),
  failedPrecondition(
    statusCode: StatusCode.failedPrecondition,
    code: 'failed_precondition',
    message:
        "Operation was rejected because the system is not in a state required for the operation's execution.",
  ),
  internal(
    statusCode: StatusCode.internal,
    code: 'internal',
    message: 'Internal errors.',
  ),
  invalidArgument(
    statusCode: StatusCode.invalidArgument,
    code: 'invalid_argument',
    message: 'Client specified an invalid argument.',
  ),
  notFound(
    statusCode: StatusCode.notFound,
    code: 'not_found',
    message: 'Some requested document was not found.',
  ),
  ok(
    statusCode: StatusCode.ok,
    code: 'ok',
    message: 'The operation completed successfully.',
  ),
  outOfRange(
    statusCode: StatusCode.outOfRange,
    code: 'out_of_range',
    message: 'Operation was attempted past the valid range.',
  ),
  permissionDenied(
    statusCode: StatusCode.permissionDenied,
    code: 'permission_denied',
    message:
        'The caller does not have permission to execute the specified operation.',
  ),
  resourceExhausted(
    statusCode: StatusCode.resourceExhausted,
    code: 'resource_exhausted',
    message:
        'Some resource has been exhausted, perhaps a per-user quota, or perhaps the entire file system is out of space.',
  ),
  unauthenticated(
    statusCode: StatusCode.unauthenticated,
    code: 'unauthenticated',
    message:
        'The request does not have valid authentication credentials for the operation.',
  ),
  unavailable(
    statusCode: StatusCode.unavailable,
    code: 'unavailable',
    message: 'The service is currently unavailable.',
  ),
  unimplemented(
    statusCode: StatusCode.unimplemented,
    code: 'unimplemented',
    message: 'Operation is not implemented or not supported/enabled.',
  ),
  unknown(
    statusCode: StatusCode.unknown,
    code: 'unknown',
    message: 'Unknown error or an error from a different error domain.',
  );

  const FirestoreClientErrorCode({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final StatusCode statusCode;
  final String code;
  final String message;
}
