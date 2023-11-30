part of '../messaging.dart';

class FirebaseMessagingAdminException extends FirebaseAdminException
    implements Exception {
  FirebaseMessagingAdminException(
    this.errorCode, [
    String? message,
  ]) : super('messaging', errorCode.name, message ?? errorCode.message);

  factory FirebaseMessagingAdminException.fromServerError(
    fmc1.DetailedApiRequestError error,
  ) {
    return FirebaseMessagingAdminException(
      MessagingClientErrorCode._fromCode(error.message),
    );
  }

  final MessagingClientErrorCode errorCode;

  @override
  String toString() => 'FirebaseMessagingAdminException: $code: $message';
}

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

  unknown(
    code: 'UNKNOWN',
    'Unknown error occurred.',
  );

  const MessagingClientErrorCode(
    this.message, {
    required this.code,
  });

  factory MessagingClientErrorCode._fromCode(String? code) {
    return values.firstWhereOrNull((it) => it.code == code) ?? unknown;
  }

  final String code;
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
