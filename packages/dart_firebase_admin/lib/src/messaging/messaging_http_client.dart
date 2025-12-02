part of 'messaging.dart';

final _legacyFirebaseMessagingHeaders = {
  // TODO send version
  'X-Firebase-Client': 'fire-admin-node/12.0.0',
  'access_token_auth': 'true',
};

/// HTTP client for Firebase Cloud Messaging API operations.
///
/// Handles HTTP client management, googleapis API client creation,
/// path builders, and simple API operations.
/// Does not handle emulator routing as FCM has no emulator support.
class FirebaseMessagingHttpClient {
  FirebaseMessagingHttpClient(this.app);

  final FirebaseApp app;

  /// Builds the parent resource path for FCM operations.
  String buildParent(String projectId) {
    return 'projects/$projectId';
  }

  Future<R> _run<R>(Future<R> Function(Client client) fn) {
    return _fmcGuard(() => app.client.then(fn));
  }

  /// Executes a Messaging v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(fmc1.FirebaseCloudMessagingApi client, String projectId)
    fn,
  ) async {
    final client = await app.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return _run(
      (client) => fn(fmc1.FirebaseCloudMessagingApi(client), projectId),
    );
  }

  /// Invokes the legacy FCM API with the provided request data.
  ///
  /// This is used for legacy FCM API operations that don't use googleapis.
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

extension on Response {
  bool get isJson =>
      headers['content-type']?.contains('application/json') ?? false;
}

class _HttpException implements Exception {
  _HttpException(this.response);

  final Response response;
}
