part of 'functions.dart';

/// Functions server to client enum error codes.
@internal
const functionsServerToClientCode = {
  // Cloud Tasks error codes
  'ABORTED': FunctionsClientErrorCode.aborted,
  'INVALID_ARGUMENT': FunctionsClientErrorCode.invalidArgument,
  'INVALID_CREDENTIAL': FunctionsClientErrorCode.invalidCredential,
  'INTERNAL': FunctionsClientErrorCode.internalError,
  'FAILED_PRECONDITION': FunctionsClientErrorCode.failedPrecondition,
  'PERMISSION_DENIED': FunctionsClientErrorCode.permissionDenied,
  'UNAUTHENTICATED': FunctionsClientErrorCode.unauthenticated,
  'NOT_FOUND': FunctionsClientErrorCode.notFound,
  'UNKNOWN': FunctionsClientErrorCode.unknownError,
  'ALREADY_EXISTS': FunctionsClientErrorCode.taskAlreadyExists,
};

/// Exception thrown by Firebase Functions operations.
class FirebaseFunctionsAdminException extends FirebaseAdminException
    implements Exception {
  /// Creates a Functions exception with the given error code and message.
  FirebaseFunctionsAdminException(this.errorCode, [String? message])
    : super(
        FirebaseServiceType.functions.name,
        errorCode.code,
        message ?? errorCode.message,
      );

  /// Creates a Functions exception from a server error response.
  @internal
  factory FirebaseFunctionsAdminException.fromServerError({
    required String serverErrorCode,
    String? message,
    Object? rawServerResponse,
  }) {
    // If not found, default to unknown error.
    final error =
        functionsServerToClientCode[serverErrorCode] ??
        FunctionsClientErrorCode.unknownError;
    var effectiveMessage = message ?? error.message;

    if (error == FunctionsClientErrorCode.unknownError &&
        rawServerResponse != null) {
      try {
        effectiveMessage +=
            ' Raw server response: "${jsonEncode(rawServerResponse)}"';
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseFunctionsAdminException(error, effectiveMessage);
  }

  /// The error code for this exception.
  final FunctionsClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseFunctionsAdminException: $code: $message';
}

/// Functions client error codes and their default messages.
enum FunctionsClientErrorCode {
  /// Invalid argument provided.
  invalidArgument(
    code: 'invalid-argument',
    message: 'Invalid argument provided.',
  ),

  /// Invalid credential.
  invalidCredential(code: 'invalid-credential', message: 'Invalid credential.'),

  /// Internal server error.
  internalError(code: 'internal-error', message: 'Internal server error.'),

  /// Failed precondition.
  failedPrecondition(
    code: 'failed-precondition',
    message: 'Failed precondition.',
  ),

  /// Permission denied.
  permissionDenied(code: 'permission-denied', message: 'Permission denied.'),

  /// Unauthenticated.
  unauthenticated(code: 'unauthenticated', message: 'Unauthenticated.'),

  /// Resource not found.
  notFound(code: 'not-found', message: 'Resource not found.'),

  /// Unknown error.
  unknownError(code: 'unknown-error', message: 'Unknown error.'),

  /// Task with the given ID already exists.
  taskAlreadyExists(
    code: 'task-already-exists',
    message: 'Task already exists.',
  ),

  /// Request aborted.
  aborted(code: 'aborted', message: 'Request aborted.');

  const FunctionsClientErrorCode({required this.code, required this.message});

  /// The error code string.
  final String code;

  /// The default error message.
  final String message;
}

/// Helper function to create a Firebase error from an HTTP response.
FirebaseFunctionsAdminException _createFirebaseError({
  required int statusCode,
  required String body,
  required bool isJson,
}) {
  if (!isJson) {
    return FirebaseFunctionsAdminException(
      FunctionsClientErrorCode.unknownError,
      'Unexpected response with status: $statusCode and body: $body',
    );
  }

  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final error = json['error'] as Map<String, dynamic>?;

    if (error != null) {
      final status = error['status'] as String?;
      final message = error['message'] as String?;

      if (status != null) {
        return FirebaseFunctionsAdminException.fromServerError(
          serverErrorCode: status,
          message: message,
          rawServerResponse: json,
        );
      }
    }
  } catch (e) {
    // Fall through to default error
  }

  return FirebaseFunctionsAdminException(
    FunctionsClientErrorCode.unknownError,
    'Unknown server error: $body',
  );
}
