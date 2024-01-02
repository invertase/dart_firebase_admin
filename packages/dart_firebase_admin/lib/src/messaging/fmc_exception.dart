part of '../messaging.dart';

class FirebaseMessagingAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseMessagingAdminException(
    this.errorCode, [
    String? message,
  ]) : super('messaging', errorCode.name, message ?? errorCode.message);

  @internal
  factory FirebaseMessagingAdminException.fromServerError(
    fmc1.DetailedApiRequestError error,
  ) {
    return FirebaseMessagingAdminException(
      MessagingClientErrorCode.fromCode(error.message),
    );
  }

  @internal
  factory FirebaseMessagingAdminException.fromTopicManagementServerError({
    required String serverErrorCode,
    String? message,
    Object? rawServerResponse,
  }) {
    // If not found, default to unknown error.
    final clientCodeKey =
        _topicMgtServerToClientCode[serverErrorCode] ?? 'UNKNOWN_ERROR';
    final error = MessagingClientErrorCode.fromCode(clientCodeKey);
    message ??= error.message;

    if (error == MessagingClientErrorCode.unknown &&
        rawServerResponse != null) {
      try {
        message += ' Raw server response: "${jsonEncode(rawServerResponse)}"';
      } catch (e) {
        // Ignore JSON parsing error.
      }
    }

    return FirebaseMessagingAdminException(error, message);
  }

  final MessagingClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseMessagingAdminException: $code: $message';
}

/// Topic management (IID) server to client enum error codes.
const _topicMgtServerToClientCode = {
  /* TOPIC SUBSCRIPTION MANAGEMENT ERRORS */
  'NOT_FOUND': 'REGISTRATION_TOKEN_NOT_REGISTERED',
  'INVALID_ARGUMENT': 'INVALID_REGISTRATION_TOKEN',
  'TOO_MANY_TOPICS': 'TOO_MANY_TOPICS',
  'RESOURCE_EXHAUSTED': 'TOO_MANY_TOPICS',
  'PERMISSION_DENIED': 'AUTHENTICATION_ERROR',
  'DEADLINE_EXCEEDED': 'SERVER_UNAVAILABLE',
  'INTERNAL': 'INTERNAL_ERROR',
  'UNKNOWN': 'UNKNOWN_ERROR',
};

enum MessagingClientErrorCode {
  internal(
    code: 'INTERNAL',
    'Internal server error.',
  ),

  invalidArgument(
    code: 'INVALID_ARGUMENT',
    'One or more arguments specified in the request were invalid.',
  ),

  quotaExceeded(
    code: 'QUOTA_EXCEEDED',
    'Sending limit exceeded for the message target.',
  ),

  senderIdMismatch(
    code: 'SENDER_ID_MISMATCH',
    'The authenticated sender ID is different from the sender ID for the registration token.',
  ),

  thirdPartyAuthError(
    code: 'THIRD_PARTY_AUTH_ERROR',
    'APNs certificate or web push auth key was invalid or missing.',
  ),

  unavailable(
    code: 'UNAVAILABLE',
    'Cloud Messaging service is temporarily unavailable.',
  ),

  unregistered(
    code: 'UNREGISTERED',
    'App instance was unregistered from FCM. '
    'This usually means that the token used is no longer valid and a new one must be used.',
  ),

  authenticationError(
    code: null,
    'An error occurred when trying to authenticate to the FCM servers. '
    'Make sure the credential used to authenticate this SDK has the proper permissions.',
  ),
  internalError(
    code: null,
    'An internal error occurred when trying to send the message to the FCM servers. '
    'Please try again later.',
  ),
  invalidOptions(
    code: null,
    'Invalid message options were provided.',
  ),
  invalidPayload(
    code: null,
    'Invalid message payload provided.',
  ),
  serverUnavailable(
    code: null,
    'The FCM servers are temporarily unavailable. '
    'Please try again later.',
  ),

  unknown(
    code: 'UNKNOWN_ERROR',
    'Unknown error occurred.',
  );

  const MessagingClientErrorCode(
    this.message, {
    required this.code,
  });

  @internal
  factory MessagingClientErrorCode.fromCode(String? code) {
    if (code == null) return unknown;
    return values.firstWhereOrNull((it) => it.code == code) ?? unknown;
  }

  final String? code;
  final String message;
}

/// Converts a Exception to a FirebaseAdminException.
Never _handleException(Object exception, StackTrace stackTrace) {
  if (exception is fmc1.DetailedApiRequestError) {
    Error.throwWithStackTrace(
      FirebaseMessagingAdminException.fromServerError(exception),
      stackTrace,
    );
  }

  Error.throwWithStackTrace(exception, stackTrace);
}
