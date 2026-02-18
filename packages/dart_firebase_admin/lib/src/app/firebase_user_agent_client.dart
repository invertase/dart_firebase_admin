part of '../app.dart';

/// HTTP client wrapper that adds the `X-Firebase-Client` header for usage tracking.
///
/// Wraps another HTTP client and injects `X-Firebase-Client: fire-admin-dart/{version}`
/// into every outgoing request so Firebase backend services can identify the SDK.
@internal
class FirebaseUserAgentClient extends BaseClient
    implements googleapis_auth.AuthClient {
  FirebaseUserAgentClient(this._client);

  final googleapis_auth.AuthClient _client;

  @override
  googleapis_auth.AccessCredentials get credentials => _client.credentials;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['X-Firebase-Client'] = 'fire-admin-dart/$packageVersion';
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
