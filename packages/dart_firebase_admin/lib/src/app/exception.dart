part of '../app.dart';

/// Composite type which includes both a `FirebaseError` object and an index
/// which can be used to get the errored item.
class FirebaseArrayIndexError {
  FirebaseArrayIndexError({required this.index, required this.error});

  /// The index of the errored item within the original array passed as part of the
  /// called API method.
  final int index;

  /// The error object.
  final FirebaseAdminException error;
}

/// A set of platform level error codes.
///
/// See https://firebase.google.com/docs/reference/admin/error-handling#platform-error-codes
/// for more information.
String _platformErrorCodeMessage(String code) {
  switch (code) {
    case 'INVALID_ARGUMENT':
      return 'Client specified an invalid argument.';
    case 'FAILED_PRECONDITION':
      return 'Request cannot be executed in the current system state, such as deleting a non-empty directory.';
    case 'OUT_OF_RANGE':
      return 'Client specified an invalid range.';
    case 'UNAUTHENTICATED':
      return 'Request not authenticated due to missing, invalid or expired OAuth token.';
    case 'PERMISSION_DENIED':
      return 'Client does not have sufficient permission. This can happen because the OAuth token does not have the right scopes, the client does not have permission, or the API has not been enabled for the client project.';
    case 'NOT_FOUND':
      return 'Specified resource not found, or the request is rejected due to undisclosed reasons such as whitelisting.';
    case 'CONFLICT':
      return 'Concurrency conflict, such as read-modify-write conflict. Only used by a few legacy services. Most services use ABORTED or ALREADY_EXISTS instead of this. Refer to the service-specific documentation to see which one to handle in your code.';
    case 'ABORTED':
      return 'Concurrency conflict, such as read-modify-write conflict.';
    case 'ALREADY_EXISTS':
      return 'The resource that a client tried to create already exists.';
    case 'RESOURCE_EXHAUSTED':
      return 'Either out of resource quota or reaching rate limiting.';
    case 'CANCELLED':
      return 'Request cancelled by the client.';
    case 'DATA_LOSS':
      return 'Unrecoverable data loss or data corruption. The client should report the error to the user.';
    case 'INTERNAL':
      return 'Internal server error. Typically a server bug.';
    case 'UNAVAILABLE':
      return 'Service unavailable. Typically the server is temporarily down. This error code is also assigned to local network errors (connection refused, no route to host).';
    case 'DEADLINE_EXCEEDED':
      return 'Request deadline exceeded. This will happen only if the caller sets a deadline that is shorter than the target API’s default deadline (i.e. requested deadline is not enough for the server to process the request), and the request did not finish within the deadline.';
    case 'UNKNOWN':
    default:
      return 'Unknown server error. Typically a server bug. This error code is also assigned to local response parsing (unmarshal) errors, and a wide range of other low-level I/O errors that are not easily diagnosable.';
  }
}

/// Base interface for all Firebase Admin related errors.
abstract class FirebaseAdminException {
  FirebaseAdminException(this.service, this._code, [this._message]);

  final String service;
  final String _code;
  final String? _message;

  /// Error codes are strings using the following format: `"service/String-code"`.
  /// Some examples include `"auth/invalid-uid"` and
  /// `"messaging/invalid-recipient"`.
  ///
  /// While the message for a given error can change, the code will remain the same
  /// between backward-compatible versions of the Firebase SDK.
  String get code => '$service/${_code.replaceAll('_', '-').toLowerCase()}';

  /// An explanatory message for the error that just occurred.
  ///
  /// This message is designed to be helpful to you, the developer. Because
  /// it generally does not convey meaningful information to end users,
  /// this message should not be displayed in your application.
  String get message => _message ?? _platformErrorCodeMessage(_code);
}
