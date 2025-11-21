part of 'messaging.dart';

final _legacyFirebaseMessagingHeaders = {
  // TODO send version
  'X-Firebase-Client': 'fire-admin-node/12.0.0',
  'access_token_auth': 'true',
};

@internal
class FirebaseMessagingRequestHandler {
  FirebaseMessagingRequestHandler(
    this.app, [
    ProjectIdProvider? projectIdProvider,
  ]) : _projectIdProvider = projectIdProvider ?? ProjectIdProvider(app);

  final FirebaseApp app;
  final ProjectIdProvider _projectIdProvider;

  Future<R> _run<R>(
    Future<R> Function(Client client) fn,
  ) {
    return _fmcGuard(() => app.client.then(fn));
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

  /// Executes a Messaging v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(fmc1.FirebaseCloudMessagingApi client, String projectId)
        fn,
  ) async {
    final projectId = await _projectIdProvider.discoverProjectId();
    return _run(
      (client) => fn(fmc1.FirebaseCloudMessagingApi(client), projectId),
    );
  }

  /// Builds the parent resource path for FCM operations.
  String buildParent(String projectId) {
    return 'projects/$projectId';
  }

  /// Invokes the request handler with the provided request data.
  Future<Object?> invokeRequestHandler({
    required String host,
    required String path,
    Object? requestData,
  }) async {
    try {
      final client = await app.client;
      final response = await client.post(
        Uri.https(host, path),
        body: jsonEncode(requestData),
        headers: {
          ..._legacyFirebaseMessagingHeaders,
          'content-type': 'application/json',
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
      Error.throwWithStackTrace(
        _createFirebaseError(
          body: error.response.body,
          statusCode: error.response.statusCode,
          isJson: error.response.isJson,
        ),
        stackTrace,
      );
    }
  }
}

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

/// Creates a new FirebaseMessagingError by extracting the error code, message and other relevant
/// details from an HTTP error response.
FirebaseMessagingAdminException _createFirebaseError({
  required String body,
  required int? statusCode,
  required bool isJson,
}) {
  if (isJson) {
    // For JSON responses, map the server response to a client-side error.

    final json = jsonDecode(body);
    final errorCode = _getErrorCode(json)!;
    final errorMessage = _getErrorMessage(json);

    return FirebaseMessagingAdminException.fromServerError(
      serverErrorCode: errorCode,
      message: errorMessage,
      rawServerResponse: json,
    );
  }

  // Non-JSON response
  MessagingClientErrorCode error;
  switch (statusCode) {
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
      error = MessagingClientErrorCode.unknownError;
  }

  return FirebaseMessagingAdminException(
    error,
    '${error.message} Raw server response: "$body". Status code: '
    '$statusCode.',
  );
}

extension on Response {
  bool get isJson =>
      headers['content-type']?.contains('application/json') ?? false;
}

class _HttpException implements Exception {
  _HttpException(this.response);

  final Response response;
}
