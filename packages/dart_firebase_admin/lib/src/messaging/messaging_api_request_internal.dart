part of '../messaging.dart';

final _legacyFirebaseMessagingHeaders = {
  // TODO send version
  'X-Firebase-Client': 'fire-admin-node/12.0.0',
  'access_token_auth': 'true',
};

@internal
class FirebaseMessagingRequestHandler {
  FirebaseMessagingRequestHandler(this.firebase);

  final FirebaseAdminApp firebase;

  Future<R> _run<R>(
    Future<R> Function(AutoRefreshingAuthClient client) fn,
  ) {
    return _fmcGuard(() => firebase.credential.client.then(fn));
  }

  Future<T> _fmcGuard<T>(
    FutureOr<T> Function() fn,
  ) async {
    try {
      final value = fn();

      if (value is T) return value;

      return value.catchError(_handleException);
    } catch (error, stackTrace) {
      _handleException(error, stackTrace);
    }
  }

  Future<R> v1<R>(
    Future<R> Function(fmc1.FirebaseCloudMessagingApi client) fn,
  ) {
    return _run((client) => fn(fmc1.FirebaseCloudMessagingApi(client)));
  }

  /// Invokes the request handler with the provided request data.
  Future<Object?> invokeRequestHandler({
    required String host,
    required String path,
    Object? requestData,
  }) async {
    try {
      final client = await firebase.credential.client;

      final response = await client.post(
        Uri.https(host, path),
        body: jsonEncode(requestData),
        headers: {
          ..._legacyFirebaseMessagingHeaders,
          'content-type': 'application/json',
          'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        },
      );

      // Send non-JSON responses to the catch() below where they will be treated as errors.
      if (!response.isJson) {
        throw _HttpException(response);
      }

      final json = jsonDecode(response.body);

      // Check for backend errors in the response.
      final errorCode = _getErrorCode(json);
      if (errorCode != null) {
        throw _HttpException(response);
      }

      return json;
    } on _HttpException catch (error, stackTrace) {
      Error.throwWithStackTrace(_createFirebaseError(error), stackTrace);
    }
  }

  String? _getErrorCode(Object? response) {
    if (response is! Map || !response.containsKey('error')) return null;

    final error = response['error'];
    if (error is String) return error;

    error as Map;

    final details = error['details'];
    if (details is List) {
      const fcmErrorType =
          'type.googleapis.com/google.firebase.fcm.v1.FcmError';
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

  /// Creates a new FirebaseMessagingError by extracting the error code, message and other relevant
  /// details from an HTTP error response.
  FirebaseMessagingAdminException _createFirebaseError(_HttpException err) {
    if (err.response.isJson) {
      // For JSON responses, map the server response to a client-side error.
      final json = jsonDecode(err.response.body);
      final errorCode = _getErrorCode(json)!;
      final errorMessage = _getErrorMessage(json);

      return FirebaseMessagingAdminException(
        MessagingClientErrorCode.fromCode(errorCode),
        errorMessage,
      );
    }

    // Non-JSON response
    MessagingClientErrorCode error;
    switch (err.response.statusCode) {
      case 400:
        error = MessagingClientErrorCode.invalidArgument;
      case 401:
      case 403:
        error = MessagingClientErrorCode.authenticationError;
      case 500:
        error = MessagingClientErrorCode.internalError;
      case 503:
        error = MessagingClientErrorCode.serverUnavailable;
      default:
        // Treat non-JSON responses with unexpected status codes as unknown errors.
        error = MessagingClientErrorCode.unknown;
    }

    return FirebaseMessagingAdminException(
      MessagingClientErrorCode.fromCode(error.code),
      '${error.message} Raw server response: "${err.response.body}". Status code: '
      '${err.response.statusCode}.',
    );
  }

  /// Extracts error message from the given response object.
  String? _getErrorMessage(Object? response) {
    switch (response) {
      case <Object?, Object?>{'error': {'message': final String? message}}:
        return message;
    }

    return null;
  }
}

extension on Response {
  bool get isJson =>
      headers['content-type']?.contains('application/json') ?? false;
}

class _HttpException implements Exception {
  _HttpException(this.response);

  final Response response;
}
