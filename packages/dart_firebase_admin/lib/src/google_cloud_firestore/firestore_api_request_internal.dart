part of 'firestore.dart';

String? _getErrorCode(Object? response) {
  if (response is! Map || !response.containsKey('error')) return null;

  final error = response['error'];
  if (error is String) return error;

  error as Map;

  final details = error['details'];
  if (details is List) {
    const fcmErrorType = 'type.googleapis.com/google.firebase.fcm.v1.FcmError';
    for (final element in details) {
      if (element is Map && element['@type'] == fcmErrorType) {
        return element['errorCode'] as String?;
      }
    }
  }

  if (error.containsKey('status')) {
    return error['status'] as String?;
  }

  return error['message'] as String?;
}

/// Extracts error message from the given response object.
String? _getErrorMessage(Object? response) {
  switch (response) {
    case <Object?, Object?>{'error': {'message': final String? message}}:
      return message;
  }

  return null;
}

/// Creates a new FirebaseFirestoreAdminException by extracting the error code, message and other relevant
/// details from an HTTP error response.
FirebaseFirestoreAdminException _createFirebaseError({
  required String body,
  required int? statusCode,
  required bool isJson,
}) {
  if (isJson) {
    // For JSON responses, map the server response to a client-side error.

    final json = jsonDecode(body);
    final errorCode = _getErrorCode(json)!;
    final errorMessage = _getErrorMessage(json);

    return FirebaseFirestoreAdminException.fromServerError(
      serverErrorCode: errorCode,
      message: errorMessage,
      rawServerResponse: json,
    );
  }

  // Non-JSON response
  FirestoreClientErrorCode error;
  switch (statusCode) {
    case 400:
      error = FirestoreClientErrorCode.invalidArgument;
    case 401:
    case 403:
      error = FirestoreClientErrorCode.unauthenticated;
    case 500:
      error = FirestoreClientErrorCode.internal;
    case 503:
      error = FirestoreClientErrorCode.unavailable;
    case 409: // HTTP Mapping: 409 Conflict
      error = FirestoreClientErrorCode.aborted;
    default:
      // Treat non-JSON responses with unexpected status codes as unknown errors.
      error = FirestoreClientErrorCode.unknown;
  }

  return FirebaseFirestoreAdminException(
    error,
    '${error.message} Raw server response: "$body". Status code: '
    '$statusCode.',
  );
}
