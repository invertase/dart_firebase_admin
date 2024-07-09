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
      MessagingClientErrorCode.fromCode(error.status, error.message),
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
    final error = MessagingClientErrorCode.fromCode(null, clientCodeKey);
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

///
/// Enum for handling different Firebase Cloud Messaging error cases per
/// https://firebase.google.com/docs/reference/fcm/rest/v1/ErrorCode
///
enum MessagingClientErrorCode {
  ///
  /// The server encountered an error while trying to process the request.
  /// You could retry the same request following the requirements listed in UNAVAILABLE
  /// If the error persists, please contact Firebase support.
  ///
  internal(
    code: 'INTERNAL',
    message: 'Internal server error.',
    httpStatusCode: 500,
  ),

  /// Potential causes include invalid registration, invalid package name,
  /// message too big, invalid data key, invalid TTL, or other invalid parameters.
  ///
  /// Invalid registration: Check the format of the registration token you pass
  /// to the server. Make sure it matches the registration token the client app
  /// receives from registering with Firebase Notifications.
  /// Do not truncate or add additional characters.
  ///
  /// Invalid package name: Make sure the message was addressed to a
  /// registration token whose package name matches the value passed in the request.
  ///
  /// Message too big: Check that the total size of the payload data included
  /// in a message does not exceed FCM limits: 4096 bytes for most messages,
  /// or 2048 bytes in the case of messages to topics.
  /// This includes both the keys and the values.
  ///
  /// Invalid data key: Check that the payload data does not contain a ke
  /// (such as from, or gcm, or any value prefixed by google) that is used internally
  /// by FCM. Note that some words (such as collapse_key) are also used by FCM but are
  /// allowed in the payload, in which case the payload value will be overridden by the FCM value.
  /// Invalid TTL: Check that the value used in ttl is an integer representing a
  /// duration in seconds between 0 and 2,419,200 (4 weeks).
  ///
  /// Invalid parameters: Check that the provided parameters have the right name and type.
  ///
  invalidArgument(
    code: 'INVALID_ARGUMENT',
    message: 'One or more arguments specified in the request were invalid.',
    httpStatusCode: 400,
  ),

  ///
  /// This error can be caused by exceeded message rate quota, exceeded device
  /// message rate quota, or exceeded topic message rate quota.
  ///
  /// Message rate exceeded: The sending rate of messages is too high.
  /// You must reduce the overall rate at which you send messages.
  /// Use exponential backoff with a minimum initial delay of 1 minute to retry rejected messages.
  ///
  /// Device message rate exceeded: The rate of messages to a particular device is too high.
  /// See message rate limit to a single device. Reduce the number of messages
  /// sent to this device and use exponential backoff to retry sending.
  ///
  /// Topic message rate exceeded: The rate of messages to subscribers to a
  /// particular topic is too high.
  /// Reduce the number of messages sent for this topic and use exponential
  /// backoff with a minimum initial delay of 1 minute to retry sending.
  ///
  quotaExceeded(
    code: 'QUOTA_EXCEEDED',
    message: 'Sending limit exceeded for the message target.',
    httpStatusCode: 429,
  ),

  ///
  /// A registration token is tied to a certain group of senders.
  /// When a client app registers for FCM, it must specify which senders are allowed to send messages.
  /// You should use one of those sender IDs when sending messages to the client app.
  /// If you switch to a different sender, the existing registration tokens won't work.
  ///
  senderIdMismatch(
    code: 'SENDER_ID_MISMATCH',
    message:
        'The authenticated sender ID is different from the sender ID for the registration token.',
    httpStatusCode: 403,
  ),

  ///
  /// A message targeted to an iOS device or a web push registration could not be sent.
  /// Check the validity of your development and production credentials.
  ///
  thirdPartyAuthError(
    code: 'THIRD_PARTY_AUTH_ERROR',
    message: 'APNs certificate or web push auth key was invalid or missing.',
    httpStatusCode: 401,
  ),

  ///
  /// The server couldn't process the request in time. Retry the same request, but you must:
  ///
  /// - Honor the Retry-After header if it is included in the response from the FCM Connection Server.
  /// - Implement exponential back-off in your retry mechanism.
  /// (e.g. if you waited one second before the first retry, wait at least two
  /// second before the next one, then 4 seconds and so on). If you're sending
  /// multiple messages, delay each one independently by an additional random
  /// amount to avoid issuing a new request for all messages at the same time.
  /// Senders that cause problems risk being denylisted.
  ///
  unavailable(
    code: 'UNAVAILABLE',
    message: 'Cloud Messaging service is temporarily unavailable.',
    httpStatusCode: 503,
  ),

  ///
  /// This error can be caused by missing registration tokens, or unregistered tokens.
  ///
  /// Missing Registration: If the message's target is a token value, check that
  /// the request contains a registration token.
  ///
  /// Not registered: An existing registration token may cease to be valid in
  /// a number of scenarios, including:
  /// - If the client app unregisters with FCM.
  /// - If the client app is automatically unregistered, which can happen if the
  /// user uninstalls the application. For example, on iOS, if the APNS Feedback Service
  /// reported the APNS token as invalid.
  /// - If the registration token expires (for example, Google might decide to
  /// refresh registration tokens, or the APNS token has expired for iOS devices).
  /// - If the client app is updated but the new version is not configured to
  /// receive messages.
  ///
  /// For all these cases, remove this registration token from the app server and stop using it to send messages.
  unregistered(
    code: 'UNREGISTERED',
    message: 'App instance was unregistered from FCM. '
        'This usually means that the token used is no longer valid and a new one must be used.',
    httpStatusCode: 404,
  ),

  ///
  /// A fallback, catch-all, error.
  ///
  unknown(
    code: 'UNKNOWN_ERROR',
    message: 'Unknown error occurred.',
  );

  const MessagingClientErrorCode({
    required this.message,
    this.code,
    this.httpStatusCode,
  });

  @internal
  factory MessagingClientErrorCode.fromCode(int? httpStatusCode, String? code) {
    final statusCode = httpStatusCode ?? 0;
    final maybeFoundStatusCode = values.firstWhereOrNull((it) => it.httpStatusCode == statusCode);

    if (maybeFoundStatusCode != null) {
      return maybeFoundStatusCode;
    }

    return values.firstWhereOrNull((it) => it.code == code) ?? unknown;
  }

  ///
  /// The HTTP status code returned from FCM
  /// For some non-google services this can be `null`.
  ///
  final int? httpStatusCode;
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
