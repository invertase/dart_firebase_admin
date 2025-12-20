part of '../app.dart';

/// Internal HTTP request implementation that wraps a stream.
///
/// This is used by [EmulatorClient] to create modified requests with
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
/// when communicating with Firebase emulators (Auth, Firestore, etc.).
///
/// Firebase emulators expect this specific bearer token to grant full
/// admin privileges for local development and testing.
@internal
class EmulatorClient implements googleapis_auth.AuthClient {
  EmulatorClient(this.client);

  final Client client;

  @override
  googleapis_auth.AccessCredentials get credentials =>
      throw UnimplementedError();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
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
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      client.head(url, headers: headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      client.get(url, headers: headers);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => client.post(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => client.put(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => client.patch(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => client.delete(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      client.read(url, headers: headers);

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      client.readBytes(url, headers: headers);
}

/// HTTP client for Cloud Tasks emulator that rewrites URLs.
///
/// The googleapis CloudTasksApi uses `/v2/` prefix in its API paths, but the
/// Firebase Cloud Tasks emulator expects paths without this prefix:
/// - googleapis sends: `http://host:port/v2/projects/{projectId}/...`
/// - emulator expects: `http://host:port/projects/{projectId}/...`
///
/// This client intercepts requests and removes the `/v2/` prefix from the path.
@internal
class CloudTasksEmulatorClient implements googleapis_auth.AuthClient {
  CloudTasksEmulatorClient(this._emulatorHost)
    : _innerClient = EmulatorClient(Client());

  final String _emulatorHost;
  final EmulatorClient _innerClient;

  @override
  googleapis_auth.AccessCredentials get credentials =>
      throw UnimplementedError();

  /// Rewrites the URL to remove `/v2/` prefix and route to emulator host.
  Uri _rewriteUrl(Uri url) {
    // Replace the path: remove /v2/ prefix if present
    var path = url.path;
    if (path.startsWith('/v2/')) {
      path = path.substring(3); // Remove '/v2' (keep the trailing /)
    }

    // Route to emulator host
    return Uri.parse(
      'http://$_emulatorHost$path${url.hasQuery ? '?${url.query}' : ''}',
    );
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final rewrittenUrl = _rewriteUrl(request.url);

    final modifiedRequest = _RequestImpl(
      request.method,
      rewrittenUrl,
      request.finalize(),
    );
    modifiedRequest.headers.addAll(request.headers);
    modifiedRequest.headers['Authorization'] = 'Bearer owner';

    return _innerClient.client.send(modifiedRequest);
  }

  @override
  void close() {
    _innerClient.close();
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _innerClient.head(_rewriteUrl(url), headers: headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      _innerClient.get(_rewriteUrl(url), headers: headers);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _innerClient.post(
    _rewriteUrl(url),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _innerClient.put(
    _rewriteUrl(url),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _innerClient.patch(
    _rewriteUrl(url),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _innerClient.delete(
    _rewriteUrl(url),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      _innerClient.read(_rewriteUrl(url), headers: headers);

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      _innerClient.readBytes(_rewriteUrl(url), headers: headers);
}
