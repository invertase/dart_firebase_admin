part of '../app.dart';

/// Exception thrown for Firebase app initialization and lifecycle errors.
class FirebaseAppException implements Exception {
  FirebaseAppException(
    this.errorCode, [
    String? message,
  ])  : code = errorCode.code,
        _message = message;

  /// The error code object containing code and default message.
  final AppErrorCode errorCode;

  /// The error code string.
  final String code;

  /// Custom error message, if provided.
  final String? _message;

  /// The error message. Returns custom message if provided, otherwise default.
  String get message => _message ?? errorCode.message;

  @override
  String toString() => 'FirebaseAppException($code): $message';
}

/// Firebase App error codes with their default messages.
///
/// These error codes match the Node.js SDK's AppErrorCodes for consistency.
enum AppErrorCode {
  /// Firebase app with the given name has already been deleted.
  appDeleted(
    code: 'app-deleted',
    message: 'The specified Firebase app has already been deleted.',
  ),

  /// Firebase app with the same name already exists.
  duplicateApp(
    code: 'duplicate-app',
    message: 'A Firebase app with the given name already exists.',
  ),

  /// Invalid argument provided to a Firebase App method.
  invalidArgument(
    code: 'invalid-argument',
    message: 'Invalid argument provided.',
  ),

  /// An internal error occurred within the Firebase SDK.
  internalError(
    code: 'internal-error',
    message: 'An internal error has occurred.',
  ),

  /// Invalid Firebase app name provided.
  invalidAppName(
    code: 'invalid-app-name',
    message: 'Invalid Firebase app name provided.',
  ),

  /// Invalid app options provided to initializeApp().
  invalidAppOptions(
    code: 'invalid-app-options',
    message: 'Invalid app options provided to initializeApp().',
  ),

  /// Invalid credential configuration.
  invalidCredential(
    code: 'invalid-credential',
    message: 'The credential configuration is invalid.',
  ),

  /// Network error occurred during the operation.
  networkError(
    code: 'network-error',
    message: 'A network error has occurred.',
  ),

  /// Network timeout occurred during the operation.
  networkTimeout(
    code: 'network-timeout',
    message: 'The network request timed out.',
  ),

  /// No Firebase app exists with the given name.
  noApp(
    code: 'no-app',
    message: 'No Firebase app exists with the given name.',
  ),

  /// Unable to parse the server response.
  unableToParseResponse(
    code: 'unable-to-parse-response',
    message: 'Unable to parse the response from the server.',
  );

  const AppErrorCode({
    required this.code,
    required this.message,
  });

  /// The error code string identifier.
  final String code;

  /// The default error message for this error code.
  final String message;
}
