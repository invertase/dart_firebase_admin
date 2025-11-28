import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// Response from IAM signBlob API.
class SignBlobResponse {
  SignBlobResponse({required this.keyId, required this.signedBlob});

  factory SignBlobResponse.fromJson(Map<String, dynamic> json) {
    return SignBlobResponse(
      keyId: json['keyId'] as String,
      signedBlob: json['signedBlob'] as String,
    );
  }

  final String keyId;
  final String signedBlob;
}

/// Configuration options for impersonated credentials.
class ImpersonatedOptions {
  const ImpersonatedOptions({
    required this.sourceClient,
    required this.targetPrincipal,
    this.targetScopes = const [],
    this.delegates = const [],
    this.lifetime = 3600,
    this.endpoint,
  });

  /// Client used to perform exchange for impersonated client.
  final AuthClient sourceClient;

  /// The service account to impersonate.
  final String targetPrincipal;

  /// Scopes to request during the authorization grant.
  final List<String> targetScopes;

  /// The chained list of delegates required to grant the final access_token.
  final List<String> delegates;

  /// Number of seconds the delegated credential should be valid.
  final int lifetime;

  /// API endpoint to fetch token from.
  final String? endpoint;
}

/// Impersonated service account credentials.
///
/// This class allows credentials issued to a user or service account to
/// impersonate another service account. The source project using impersonated
/// credentials must enable the "IAMCredentials" API. Also, the target service
/// account must grant the originating principal the "Service Account Token
/// Creator" IAM role.
///
/// This is the Dart equivalent of the Node.js Impersonated class.
class ImpersonatedAuthClient implements AuthClient {
  ImpersonatedAuthClient(this.options)
    : _endpoint = options.endpoint ?? 'https://iamcredentials.googleapis.com';

  final ImpersonatedOptions options;
  final String _endpoint;

  /// The source client used to authenticate requests.
  AuthClient get sourceClient => options.sourceClient;

  /// The service account email to be impersonated.
  String get targetPrincipal => options.targetPrincipal;

  @override
  AccessCredentials get credentials => sourceClient.credentials;

  /// Signs some bytes.
  ///
  /// [Reference Documentation](https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/signBlob)
  ///
  /// Returns a [SignBlobResponse] containing the keyID and signedBlob in base64 string.
  Future<SignBlobResponse> sign(String blobToSign) async {
    final name = 'projects/-/serviceAccounts/${options.targetPrincipal}';
    final url = Uri.parse('$_endpoint/v1/$name:signBlob');

    final body = {
      if (options.delegates.isNotEmpty) 'delegates': options.delegates,
      'payload': base64Encode(utf8.encode(blobToSign)),
    };

    final response = await sourceClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to sign blob via impersonation. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return SignBlobResponse.fromJson(responseData);
  }

  /// Generates an access token for the impersonated service account.
  Future<Map<String, dynamic>> generateAccessToken() async {
    final name = 'projects/-/serviceAccounts/${options.targetPrincipal}';
    final url = Uri.parse('$_endpoint/v1/$name:generateAccessToken');

    final body = {
      if (options.delegates.isNotEmpty) 'delegates': options.delegates,
      'scope': options.targetScopes,
      'lifetime': '${options.lifetime}s',
    };

    final response = await sourceClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to generate access token via impersonation. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Delegate all HTTP requests to the source client
    return sourceClient.send(request);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return sourceClient.get(url, headers: headers);
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return sourceClient.post(
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
    return sourceClient.put(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return sourceClient.patch(
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
    return sourceClient.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return sourceClient.head(url, headers: headers);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return sourceClient.read(url, headers: headers);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return sourceClient.readBytes(url, headers: headers);
  }

  @override
  void close() {
    // Don't close the source client - it's managed externally
  }
}

/// Helper to check if an AuthClient is an ImpersonatedAuthClient.
bool isImpersonatedClient(AuthClient client) {
  return client is ImpersonatedAuthClient;
}

/// Helper to cast an AuthClient to ImpersonatedAuthClient if possible.
ImpersonatedAuthClient? asImpersonatedClient(AuthClient client) {
  return client is ImpersonatedAuthClient ? client : null;
}
