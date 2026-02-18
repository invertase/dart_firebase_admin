import 'dart:async';

import 'package:google_cloud/constants.dart' as google_cloud;
import 'package:google_cloud/google_cloud.dart' as google_cloud;
import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../googleapis_firestore.dart';
import 'environment.dart';
import 'firestore_exception.dart';

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
class EmulatorClient extends BaseClient implements googleapis_auth.AuthClient {
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
  void close() => client.close();
}

/// HTTP client wrapper for Firestore API operations.
///
/// Provides authenticated API access with automatic project ID discovery.
class FirestoreHttpClient {
  FirestoreHttpClient({required this.credential, required Settings settings})
    : _settings = settings;

  final Credential credential;
  final Settings _settings;

  String? _cachedProjectId;

  String? get cachedProjectId => _cachedProjectId;

  /// Gets the Firestore API host URL based on emulator configuration.
  Uri get _firestoreApiHost {
    final emulatorHost = Environment.getFirestoreEmulatorHost(
      _settings.environmentOverride,
    );

    if (emulatorHost != null) {
      return Uri.http(emulatorHost, '/');
    }

    return Uri.https(_settings.host ?? 'firestore.googleapis.com', '/');
  }

  /// Checks if the Firestore emulator is enabled via environment variable.
  bool get _isUsingEmulator =>
      Environment.isFirestoreEmulatorEnabled(_settings.environmentOverride);

  /// Lazy-initialized HTTP client that's cached for reuse.
  late final Future<googleapis_auth.AuthClient> _client = _createClient();

  /// Creates the appropriate HTTP client based on emulator configuration.
  Future<googleapis_auth.AuthClient> _createClient() async {
    if (_isUsingEmulator) {
      // Emulator: Create unauthenticated client
      return EmulatorClient(Client());
    }

    // Production: Create authenticated client
    final serviceAccountCreds = credential.serviceAccountCredentials;
    if (serviceAccountCreds != null) {
      return googleapis_auth.clientViaServiceAccount(serviceAccountCreds, [
        firestore_v1.FirestoreApi.cloudPlatformScope,
      ]);
    }

    // Fall back to Application Default Credentials
    return googleapis_auth.clientViaApplicationDefaultCredentials(
      scopes: [firestore_v1.FirestoreApi.cloudPlatformScope],
    );
  }

  Future<R> _run<R>(
    Future<R> Function(googleapis_auth.AuthClient client, String projectId) fn,
  ) async {
    final client = await _client;

    String? projectId;

    final env = _settings.environmentOverride;
    if (env != null) {
      for (final envKey in google_cloud.projectIdEnvironmentVariableOptions) {
        final value = env[envKey];
        if (value != null) {
          projectId = value;
          break;
        }
      }
    }

    projectId ??= _settings.projectId;
    projectId ??= await google_cloud.computeProjectId();

    _cachedProjectId = projectId;

    return firestoreGuard(() => fn(client, projectId!));
  }

  /// Executes a Firestore v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(firestore_v1.FirestoreApi api, String projectId) fn,
  ) => _run(
    (client, projectId) => fn(
      firestore_v1.FirestoreApi(client, rootUrl: _firestoreApiHost.toString()),
      projectId,
    ),
  );

  /// Closes the HTTP client and releases resources.
  Future<void> close() async {
    final client = await _client;
    client.close();
  }
}
