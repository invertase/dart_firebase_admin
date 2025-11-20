part of '../app.dart';

/// Internal HTTP request implementation that wraps a stream.
///
/// This is used by [_EmulatorClient] to create modified requests with
/// updated headers while preserving the request body stream.
class _RequestImpl extends BaseRequest {
  _RequestImpl(super.method, super.url, [Stream<List<int>>? stream])
      : _stream = stream ?? const Stream.empty();

  final Stream<List<int>> _stream;

  @override
  ByteStream finalize() {
    super.finalize();
    return ByteStream(_stream);
  }
}

/// HTTP client wrapper that adds Firebase emulator authentication.
///
/// This client wraps another HTTP client and automatically adds the
/// `Authorization: Bearer owner` header to all requests, which is required
/// when connecting to Firebase emulators.
///
/// The emulator expects this specific bearer token to grant full admin
/// privileges for local development and testing.
class _EmulatorClient extends BaseClient {
  _EmulatorClient(this.client);

  final Client client;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    // Make new request object and perform the authenticated request.
    final modifiedRequest = _RequestImpl(
      request.method,
      request.url,
      request.finalize(),
    );
    modifiedRequest.headers.addAll(request.headers);
    modifiedRequest.headers['Authorization'] = 'Bearer owner';

    return client.send(modifiedRequest);
  }

  @override
  void close() {
    client.close();
    super.close();
  }
}
