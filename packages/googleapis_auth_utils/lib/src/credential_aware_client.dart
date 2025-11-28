import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'credential.dart';

/// An [AuthClient] that maintains a reference to its [GoogleCredential].
///
/// This allows determining whether the client has access to service account
/// credentials for local signing operations, similar to how Node.js's
/// google-auth-library JWT client exposes the private key.
///
/// Example:
/// ```dart
/// final credential = Credential.fromServiceAccount(
///   File('service-account.json'),
/// );
/// final authClient = await createAuthClient(credential, scopes);
///
/// // Later, can check if it has service account credentials
/// if (authClient is CredentialAwareAuthClient &&
///     authClient.credential.serviceAccountCredentials != null) {
///   // Can use local signing
/// }
/// ```
class CredentialAwareAuthClient implements AuthClient {
  /// Creates a credential-aware auth client.
  ///
  /// The [delegate] is the actual AuthClient that handles HTTP requests.
  /// The [credential] is maintained for access to underlying credentials.
  CredentialAwareAuthClient({
    required AuthClient delegate,
    required this.credential,
  }) : _delegate = delegate;

  final AuthClient _delegate;

  /// The credential used to create this auth client.
  ///
  /// Access [GoogleCredential.serviceAccountCredentials] to get the underlying
  /// service account credentials for local signing operations.
  final GoogleCredential credential;

  @override
  AccessCredentials get credentials => _delegate.credentials;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _delegate.send(request);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _delegate.get(url, headers: headers);
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _delegate.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _delegate.put(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _delegate.patch(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _delegate.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return _delegate.head(url, headers: headers);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return _delegate.read(url, headers: headers);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return _delegate.readBytes(url, headers: headers);
  }

  @override
  void close() {
    _delegate.close();
  }
}

/// Creates an authenticated HTTP client from a [GoogleCredential].
///
/// This is a convenience function that:
/// 1. Creates an AuthClient using googleapis_auth
/// 2. Wraps it in a [CredentialAwareAuthClient] to maintain credential access
///
/// The returned client will automatically refresh access tokens as needed.
///
/// Example:
/// ```dart
/// final credential = Credential.fromServiceAccount(
///   File('service-account.json'),
/// );
/// final client = await createAuthClient(credential, [
///   'https://www.googleapis.com/auth/cloud-platform',
/// ]);
///
/// // Use client for API calls
/// final response = await client.get(Uri.parse('https://...'));
///
/// // Don't forget to close when done
/// client.close();
/// ```
Future<CredentialAwareAuthClient> createAuthClient(
  GoogleCredential credential,
  List<String> scopes, {
  http.Client? baseClient,
}) async {
  AuthClient delegate;

  if (credential is GoogleServiceAccountCredential) {
    // Use service account credentials
    delegate = await clientViaServiceAccount(
      credential.serviceAccountCredentials,
      scopes,
      baseClient: baseClient,
    );
  } else if (credential is GoogleApplicationDefaultCredential) {
    // For ADC, check if we have service account credentials
    final serviceAccountCreds = credential.serviceAccountCredentials;
    if (serviceAccountCreds != null) {
      delegate = await clientViaServiceAccount(
        serviceAccountCreds,
        scopes,
        baseClient: baseClient,
      );
    } else {
      // Fall back to regular ADC (will use metadata service on GCE/Cloud Run)
      delegate = await clientViaApplicationDefaultCredentials(
        scopes: scopes,
        baseClient: baseClient,
      );
    }
  } else {
    throw UnsupportedError(
      'Unknown credential type: ${credential.runtimeType}',
    );
  }

  return CredentialAwareAuthClient(delegate: delegate, credential: credential);
}
