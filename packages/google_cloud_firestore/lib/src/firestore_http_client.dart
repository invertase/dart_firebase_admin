// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';

import 'package:google_cloud/constants.dart' as google_cloud;
import 'package:google_cloud/google_cloud.dart' as google_cloud;
import 'package:googleapis/firestore/v1.dart' as firestore_v1;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../google_cloud_firestore.dart';
import 'environment.dart';
import 'firestore.dart'
    show Serializer, kInfinitySentinel, kNaNSentinel, kNegInfinitySentinel;
import 'firestore_exception.dart';

// Matches a complete Firestore Value JSON object whose doubleValue is one of
// the three special IEEE 754 strings the REST API emits. Anchoring on the
// surrounding braces prevents false-positive matches inside user string fields
// that happen to contain the text `"doubleValue":"Infinity"`.
final _specialDoublePattern = RegExp(
  r'\{\s*"doubleValue"\s*:\s*"(Infinity|-Infinity|NaN)"\s*\}',
);

/// HTTP client wrapper that rewrites special IEEE 754 double values in
/// Firestore REST API responses before the googleapis library parses them.
///
/// The Firestore REST API encodes [double.infinity], [double.negativeInfinity],
/// and [double.nan] as the JSON strings `"Infinity"`, `"-Infinity"`, and
/// `"NaN"` respectively (since those values are not representable in standard
/// JSON). The googleapis-generated [firestore_v1.Value.fromJson] does a hard `as num` cast
/// on the `doubleValue` field and therefore throws when it encounters a string.
///
/// This client intercepts every response body and replaces those patterns with
/// a `stringValue` sentinel that [Serializer.decodeValue] understands.
/// The sentinel strings are defined alongside [Serializer.decodeValue] in
/// `serializer.dart`.
class _SpecialDoubleClient extends BaseClient {
  _SpecialDoubleClient(this._inner);

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _inner.send(request);

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) return response;

    final body = await response.stream.bytesToString();
    if (!body.contains('"doubleValue"')) return _rebuild(response, body);

    final patched = body.replaceAllMapped(_specialDoublePattern, (m) {
      final sentinel = switch (m.group(1)) {
        'Infinity' => kInfinitySentinel,
        '-Infinity' => kNegInfinitySentinel,
        _ => kNaNSentinel, // 'NaN'
      };
      return '{"stringValue":"$sentinel"}';
    });

    return _rebuild(response, patched);
  }

  StreamedResponse _rebuild(StreamedResponse original, String body) {
    final bytes = utf8.encode(body);
    final headers = Map<String, String>.from(original.headers)
      ..['content-length'] = bytes.length.toString();
    return StreamedResponse(
      Stream.value(bytes),
      original.statusCode,
      contentLength: bytes.length,
      headers: headers,
      request: original.request,
      reasonPhrase: original.reasonPhrase,
    );
  }
}

/// An [googleapis_auth.AuthClient] wrapper that applies [_SpecialDoubleClient]
/// response rewriting while preserving the [credentials] required by the
/// googleapis request pipeline.
class _SpecialDoubleAuthClient extends _SpecialDoubleClient
    implements googleapis_auth.AuthClient {
  _SpecialDoubleAuthClient(this._authInner) : super(_authInner);

  final googleapis_auth.AuthClient _authInner;

  @override
  googleapis_auth.AccessCredentials get credentials => _authInner.credentials;

  @override
  void close() => _authInner.close();
}

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

  /// Synchronously resolves the project ID from environment variables or the
  /// credentials file, without any network I/O.
  ///
  /// Returns `null` when only async strategies (gcloud CLI, metadata server)
  /// could succeed; those are handled by [_run] and cached in [cachedProjectId].
  String? getProjectId() {
    final zoneEnv = Zone.current[envSymbol] as Map<String, String>?;
    if (zoneEnv != null) {
      for (final envKey in google_cloud.projectIdEnvironmentVariableOptions) {
        final value = zoneEnv[envKey];
        if (value != null) return value;
      }
      return null;
    }

    final explicitProjectId = _settings.projectId;
    if (explicitProjectId != null) return explicitProjectId;

    return google_cloud.projectIdFromEnvironmentVariables() ??
        google_cloud.projectIdFromCredentialsFile();
  }

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
      // Emulator: Create unauthenticated client, wrapped to rewrite special
      // doubles before EmulatorClient adds auth headers.
      return EmulatorClient(_SpecialDoubleClient(Client()));
    }

    // Production: Create authenticated client, then wrap to rewrite special
    // doubles in responses before googleapis parses them.
    final serviceAccountCreds = credential.serviceAccountCredentials;
    if (serviceAccountCreds != null) {
      final authClient = await googleapis_auth.clientViaServiceAccount(
        serviceAccountCreds,
        [firestore_v1.FirestoreApi.cloudPlatformScope],
      );
      return _SpecialDoubleAuthClient(authClient);
    }

    // Fall back to Application Default Credentials
    final authClient = await googleapis_auth
        .clientViaApplicationDefaultCredentials(
          scopes: [firestore_v1.FirestoreApi.cloudPlatformScope],
        );
    return _SpecialDoubleAuthClient(authClient);
  }

  Future<R> _run<R>(
    Future<R> Function(googleapis_auth.AuthClient client, String projectId) fn,
  ) async {
    final client = await _client;

    String? projectId;

    final zoneEnv = Zone.current[envSymbol] as Map<String, String>?;
    if (zoneEnv != null) {
      for (final envKey in google_cloud.projectIdEnvironmentVariableOptions) {
        final value = zoneEnv[envKey];
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
