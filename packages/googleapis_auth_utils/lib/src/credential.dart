import 'dart:convert';
import 'dart:io';

import 'package:googleapis/identitytoolkit/v3.dart' as auth3;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:meta/meta.dart';

import 'extensions/auth_client_extensions.dart';

/// Base class for Google Cloud credentials.
///
/// This provides a wrapper around googleapis_auth credentials that maintains
/// access to the underlying ServiceAccountCredentials when available.
///
/// Create credentials using one of the factory methods:
/// - [GoogleCredential.fromServiceAccount] - For service account JSON files
/// - [GoogleCredential.fromServiceAccountParams] - For service account parameters
/// - [GoogleCredential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
///
/// This is similar to Node.js google-auth-library's credential management.
sealed class GoogleCredential {
  /// Creates a credential using Application Default Credentials (ADC).
  ///
  /// ADC attempts to find credentials in the following order:
  /// 1. GOOGLE_APPLICATION_CREDENTIALS environment variable (path to service account JSON)
  /// 2. Compute Engine default service account (when running on GCE)
  /// 3. Other ADC sources
  ///
  /// [serviceAccountId] can optionally be provided to override the service
  /// account email if needed for specific operations.
  /// [environment] can optionally be provided to override Platform.environment
  /// (useful for testing with runZoned).
  /// [authClient] can optionally be provided to use an existing authenticated
  /// client instead of creating a new one.
  factory GoogleCredential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
    Map<String, String>? environment,
    auth_io.AuthClient? authClient,
  }) {
    return GoogleApplicationDefaultCredential(
      serviceAccountId: serviceAccountId,
      environment: environment,
      authClient: authClient,
    );
  }

  /// Creates a credential from a service account JSON file.
  ///
  /// The service account file must contain:
  /// - `private_key`: The service account private key
  /// - `client_email`: The service account email
  ///
  /// Optionally may contain:
  /// - `project_id`: The Google Cloud project ID
  /// - `client_id`: The OAuth2 client ID
  ///
  /// You can download service account JSON files from the Google Cloud Console
  /// under IAM & Admin > Service Accounts.
  ///
  /// [authClient] can optionally be provided to use an existing authenticated
  /// client instead of creating a new one.
  ///
  /// Example:
  /// ```dart
  /// final credential = GoogleCredential.fromServiceAccount(
  ///   File('path/to/service-account.json'),
  /// );
  /// ```
  factory GoogleCredential.fromServiceAccount(
    File serviceAccountFile, {
    auth_io.AuthClient? authClient,
  }) {
    return GoogleServiceAccountCredential.fromFile(
      serviceAccountFile,
      authClient: authClient,
    );
  }

  /// Creates a credential from individual service account parameters.
  ///
  /// Parameters:
  /// - [privateKey]: The private key in PEM format (required)
  /// - [email]: The service account email address (required)
  /// - [clientId]: The OAuth2 client ID (optional, defaults to email)
  /// - [projectId]: The Google Cloud project ID (optional)
  /// - [universeDomain]: The universe domain (optional, defaults to 'googleapis.com')
  /// - [authClient]: Optional authenticated client to use instead of creating a new one
  ///
  /// Example:
  /// ```dart
  /// final credential = GoogleCredential.fromServiceAccountParams(
  ///   privateKey: '-----BEGIN PRIVATE KEY-----\n...',
  ///   email: 'my-sa@my-project.iam.gserviceaccount.com',
  ///   projectId: 'my-project',
  /// );
  /// ```
  factory GoogleCredential.fromServiceAccountParams({
    required String privateKey,
    required String email,
    String? clientId,
    String? projectId,
    String? universeDomain,
    auth_io.AuthClient? authClient,
  }) {
    return GoogleServiceAccountCredential.fromParams(
      privateKey: privateKey,
      email: email,
      clientId: clientId,
      projectId: projectId,
      universeDomain: universeDomain,
      authClient: authClient,
    );
  }

  /// Private constructor for sealed class.
  GoogleCredential._();

  /// Returns the underlying [auth.ServiceAccountCredentials] if available.
  ///
  /// This is non-null for [GoogleServiceAccountCredential].
  /// For [GoogleApplicationDefaultCredential], this is only non-null if ADC
  /// found service account credentials.
  auth.ServiceAccountCredentials? get serviceAccountCredentials;

  /// Returns the service account ID (email) if available.
  String? get serviceAccountId;

  /// Returns the project ID if available.
  ///
  /// For service account credentials, this is extracted from the JSON file.
  /// For ADC on Compute Engine, this may be null.
  String? get projectId;

  /// Returns the universe domain for this credential.
  ///
  /// The universe domain identifies which Google Cloud universe to use.
  /// Defaults to 'googleapis.com' for the default public cloud.
  ///
  /// For service account credentials, this is extracted from the JSON file's
  /// 'universe_domain' field. For ADC, this is extracted from the credentials
  /// or defaults to 'googleapis.com'.
  ///
  /// Example values:
  /// - 'googleapis.com' (default public cloud)
  /// - Custom universe domains for government or sovereign clouds
  String get universeDomain;

  /// Returns a Google OAuth2 access token.
  ///
  /// This method obtains a valid access token that can be used to authenticate
  /// API requests to Google Cloud services. The token is automatically refreshed
  /// if expired.
  ///
  /// The returned [auth.AccessToken] contains:
  /// - [auth.AccessToken.data]: The token string to use in Authorization headers
  /// - [auth.AccessToken.expiry]: The DateTime when the token expires
  ///
  /// Example:
  /// ```dart
  /// final credential = GoogleCredential.fromServiceAccount(file);
  /// final token = await credential.getAccessToken();
  /// print('Token: ${token.data}');
  /// print('Expires at: ${token.expiry}');
  /// ```
  Future<auth.AccessToken> getAccessToken();
}

/// Service account credentials.
///
/// This wraps [auth.ServiceAccountCredentials] from googleapis_auth and optionally
/// includes the project ID from the service account JSON file.
final class GoogleServiceAccountCredential extends GoogleCredential {
  /// Creates a [GoogleServiceAccountCredential] from a JSON object.
  factory GoogleServiceAccountCredential.fromJson(
    Map<String, Object?> json, {
    auth_io.AuthClient? authClient,
  }) {
    final projectId = json['project_id'] as String?;
    final universeDomain =
        json['universe_domain'] as String? ?? 'googleapis.com';

    // Validate required fields before calling googleapis_auth
    if (json['type'] != 'service_account') {
      throw CredentialParseException(
        'Invalid service account credentials: type must be "service_account" (was: ${json['type']})',
      );
    }
    if (json['client_email'] == null) {
      throw CredentialParseException(
        'Invalid service account credentials: missing client_email',
      );
    }
    if (json['private_key'] == null) {
      throw CredentialParseException(
        'Invalid service account credentials: missing private_key',
      );
    }

    try {
      // Use googleapis_auth to parse the credentials
      final credentials = auth.ServiceAccountCredentials.fromJson(json);
      return GoogleServiceAccountCredential._(
        credentials,
        projectId,
        universeDomain,
        authClient,
      );
    } on FormatException catch (e) {
      throw CredentialParseException(
        'Invalid service account format: ${e.message}',
      );
    }
  }

  /// Creates a [GoogleServiceAccountCredential] from a service account JSON file.
  factory GoogleServiceAccountCredential.fromFile(
    File serviceAccountFile, {
    @internal FileSystem? fileSystem,
    auth_io.AuthClient? authClient,
  }) {
    final content = fileSystem != null
        ? fileSystem.readAsString(serviceAccountFile.path)
        : serviceAccountFile.readAsStringSync();

    final json = jsonDecode(content);
    if (json is! Map<String, Object?>) {
      throw CredentialParseException(
        'Service account file must be a JSON object',
      );
    }

    return GoogleServiceAccountCredential.fromJson(
      json,
      authClient: authClient,
    );
  }

  /// Creates a [GoogleServiceAccountCredential] from individual parameters.
  ///
  /// This is useful when you want to provide credentials programmatically
  /// without creating a JSON file.
  factory GoogleServiceAccountCredential.fromParams({
    required String privateKey,
    required String email,
    String? clientId,
    String? projectId,
    String? universeDomain,
    auth_io.AuthClient? authClient,
  }) {
    final credentials = auth.ServiceAccountCredentials(
      email,
      auth.ClientId(clientId ?? email),
      privateKey,
    );

    return GoogleServiceAccountCredential._(
      credentials,
      projectId,
      universeDomain ?? 'googleapis.com',
      authClient,
    );
  }

  GoogleServiceAccountCredential._(
    this._credentials,
    this._projectId,
    this._universeDomain,
    this._authClient,
  ) : super._();

  final auth.ServiceAccountCredentials _credentials;
  final String? _projectId;
  final String _universeDomain;
  auth_io.AuthClient? _authClient;

  /// The service account email address.
  ///
  /// Format: `my-service-account@project-id.iam.gserviceaccount.com`
  String get email => _credentials.email;

  /// The service account private key in PEM format.
  ///
  /// This is used to sign authentication tokens for API calls.
  String get privateKey => _credentials.privateKey;

  @override
  auth.ServiceAccountCredentials get serviceAccountCredentials => _credentials;

  @override
  String get serviceAccountId => _credentials.email;

  @override
  String? get projectId => _projectId;

  @override
  String get universeDomain => _universeDomain;

  @override
  Future<auth.AccessToken> getAccessToken() async {
    // Lazy-load and cache the auth client (matches Node.js pattern)
    if (_authClient == null) {
      // Use the same scopes as Firebase Admin SDK
      const scopes = [
        auth3.IdentityToolkitApi.cloudPlatformScope,
        auth3.IdentityToolkitApi.firebaseScope,
      ];
      _authClient = await auth_io.clientViaServiceAccount(_credentials, scopes);
    }

    // Return the current access token from credentials
    // The AuthClient automatically refreshes the token when needed
    return _authClient!.credentials.accessToken;
  }
}

/// Application Default Credentials (ADC).
///
/// Uses Google Application Default Credentials to automatically discover
/// credentials from the environment. ADC checks the following sources in order:
///
/// 1. GOOGLE_APPLICATION_CREDENTIALS environment variable pointing to a
///    service account JSON file
/// 2. Compute Engine default service account (when running on GCE, Cloud Run, etc.)
/// 3. Other ADC sources (gcloud CLI credentials, etc.)
///
/// This credential type is recommended for production environments as it allows
/// the same code to work across different deployment environments without
/// hardcoding credential paths.
final class GoogleApplicationDefaultCredential extends GoogleCredential {
  GoogleApplicationDefaultCredential({
    String? serviceAccountId,
    Map<String, String>? environment,
    auth_io.AuthClient? authClient,
  }) : _serviceAccountId = serviceAccountId,
       _authClient = authClient,
       super._() {
    // Check for GOOGLE_APPLICATION_CREDENTIALS
    final env = environment ?? Platform.environment;
    final credPath = env['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credPath != null && File(credPath).existsSync()) {
      try {
        final content = File(credPath).readAsStringSync();
        final json = jsonDecode(content);
        if (json is Map<String, Object?>) {
          _serviceAccountCredentials = auth.ServiceAccountCredentials.fromJson(
            json,
          );
          _projectId = json['project_id'] as String?;
          _universeDomain =
              json['universe_domain'] as String? ?? 'googleapis.com';
        }
      } catch (_) {
        // Ignore parsing errors, will fall back to metadata service
      }
    }
  }

  final String? _serviceAccountId;
  auth.ServiceAccountCredentials? _serviceAccountCredentials;
  String? _projectId;
  String _universeDomain = 'googleapis.com';
  auth_io.AuthClient? _authClient;

  @override
  auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId =>
      _serviceAccountId ?? _serviceAccountCredentials?.email;

  @override
  String? get projectId => _projectId;

  @override
  String get universeDomain => _universeDomain;

  @override
  Future<auth.AccessToken> getAccessToken() async {
    // Lazy-load and cache the auth client
    if (_authClient == null) {
      const scopes = [
        auth3.IdentityToolkitApi.cloudPlatformScope,
        auth3.IdentityToolkitApi.firebaseScope,
      ];

      // Use service account credentials if available, otherwise use ADC
      if (_serviceAccountCredentials != null) {
        _authClient = await auth_io.clientViaServiceAccount(
          _serviceAccountCredentials!,
          scopes,
        );
      } else {
        _authClient = await auth_io.clientViaApplicationDefaultCredentials(
          scopes: scopes,
        );
      }
    }

    // Return the current access token from credentials
    // The AuthClient automatically refreshes the token when needed
    return _authClient!.credentials.accessToken;
  }
}

/// Exception thrown when credential parsing fails.
class CredentialParseException implements Exception {
  CredentialParseException(this.message);

  final String message;

  @override
  String toString() => 'CredentialParseException: $message';
}
