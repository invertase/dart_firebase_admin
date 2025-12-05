import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:meta/meta.dart';

import '../../googleapis_auth_utils.dart';
import '../credential.dart';

part 'project_id_provider.dart';

extension AuthClientX on AuthClient {
  /// Gets the [GoogleCredential] associated with this auth client.
  ///
  /// Returns null if this auth client was not created via [createAuthClient].
  ///
  /// Example:
  /// ```dart
  /// final credential = GoogleCredential.fromServiceAccount(file);
  /// final client = await createAuthClient(credential, scopes);
  ///
  /// // Later, access the credential
  /// final associatedCredential = client.credential;
  /// ```
  GoogleCredential? get credential => authClientCredentials[this];

  /// Gets the service account credentials if available.
  ///
  /// This is a convenience getter that returns the service account credentials
  /// from the associated [GoogleCredential], if available.
  ///
  /// Returns null if:
  /// - Auth client was not created via [createAuthClient]
  /// - Associated credential doesn't have service account credentials
  ///
  /// Example:
  /// ```dart
  /// final client = await createAuthClient(credential, scopes);
  ///
  /// if (client.serviceAccountCredentials != null) {
  ///   print('Can use local signing');
  /// }
  /// ```
  ServiceAccountCredentials? get serviceAccountCredentials =>
      authClientCredentials[this]?.serviceAccountCredentials;

  /// Discovers the Google Cloud project ID with support for explicit sources.
  ///
  /// Uses the singleton [ProjectIdProvider] to discover and cache project IDs.
  ///
  /// Checks in the following order:
  /// 1. [projectIdOverride] - if provided
  /// 2. GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT environment variables
  /// 3. GOOGLE_APPLICATION_CREDENTIALS JSON file
  /// 4. Cloud SDK: `gcloud config config-helper --format json`
  /// 5. GCE/Cloud Run metadata service
  Future<String> getProjectId({
    String? projectIdOverride,
    Map<String, String>? environment,
  }) async {
    return ProjectIdProvider.getDefault(
      this,
      environment: environment,
    ).getProjectId(projectIdOverride: projectIdOverride);
  }

  /// Gets the cached project ID from the [ProjectIdProvider].
  ///
  /// Returns null if the project ID has not been discovered yet.
  String? get cachedProjectId =>
      ProjectIdProvider.getDefault(this).cachedProjectId;

  /// Discovers the default service account email.
  ///
  /// This queries the GCE/Cloud Run metadata service to discover the default
  /// service account email when running on Google Cloud infrastructure.
  ///
  /// Returns null if:
  /// - Not running on GCE/Cloud Run
  /// - Metadata service is unavailable
  /// - Network request fails
  Future<String?> getServiceAccountEmail() async {
    return ProjectIdProvider.getDefault(this).getServiceAccountEmail();
  }

  /// Signs some bytes using the credentials from this auth client.
  ///
  /// This is the Dart equivalent of `GoogleAuth.sign()` from the Node.js
  /// google-auth-library.
  ///
  /// The signing behavior depends on the auth client type:
  /// - [ImpersonatedAuthClient]: Uses IAM signBlob API to sign using the
  ///   target principal.
  /// - Auth clients created via [createAuthClient] with service account
  ///   credentials: Signs locally using RSA-SHA256.
  /// - Other auth clients: Uses IAM signBlob API with the default service
  ///   account.
  ///
  /// [data] is the string to be signed.
  /// [endpoint] is an optional custom IAM Credentials API endpoint. This is
  /// useful when working with different universe domains. If not provided,
  /// the endpoint is automatically determined from the credential's universe
  /// domain (e.g., `https://iamcredentials.googleapis.com` for the default
  /// universe, or a custom universe domain from the service account JSON).
  ///
  /// Returns the signature as a base64-encoded string.
  ///
  /// Example:
  /// ```dart
  /// final credential = GoogleCredential.fromServiceAccount(file);
  /// final authClient = await createAuthClient(credential, scopes);
  /// final signature = await authClient.sign('data to sign');
  /// ```
  Future<String> sign(String data, {String? endpoint}) async {
    // Check if this is an impersonated client
    if (this is ImpersonatedAuthClient) {
      final impersonated = this as ImpersonatedAuthClient;
      final response = await impersonated.sign(data);
      return response.signedBlob;
    }

    // Check if we have service account credentials for local signing
    final hasLocalSigningCapability = serviceAccountCredentials != null;

    // Determine the IAM endpoint based on universe domain
    final universeDomain = credential?.universeDomain ?? 'googleapis.com';
    endpoint ??= 'https://iamcredentials.$universeDomain';

    // If we're NOT using local signing, use IAM API signing
    if (!hasLocalSigningCapability) {
      final email = await getServiceAccountEmail();
      if (email == null) {
        throw Exception(
          'Unable to determine service account email for IAM signing. '
          'Ensure you are running on Google Cloud infrastructure or provide '
          'service account credentials.',
        );
      }
      return _signBlobWithEndpoint(data, endpoint, email);
    }

    // Use CryptoSigner for local signing
    // CryptoSigner.fromAuthClient will automatically choose local signing
    // if credentials are available
    final signer = CryptoSigner.fromAuthClient(this);
    final signatureBytes = await signer.sign(utf8.encode(data));
    return base64Encode(signatureBytes);
  }

  /// Signs a blob using the IAM signBlob API with a custom endpoint.
  Future<String> _signBlobWithEndpoint(
    String data,
    String endpoint,
    String email,
  ) async {
    final signer = CryptoSigner.fromAuthClient(
      this,
      serviceAccountEmail: email,
      endpoint: endpoint,
    );
    final signatureBytes = await signer.sign(utf8.encode(data));
    return base64Encode(signatureBytes);
  }
}
