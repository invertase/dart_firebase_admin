import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/googleapis_auth.dart' as auth;

/// Base class for Google Cloud credentials.
///
/// This provides a wrapper around googleapis_auth credentials that maintains
/// access to the underlying ServiceAccountCredentials when available.
///
/// Create credentials using one of the factory methods:
/// - [Credential.fromServiceAccount] - For service account JSON files
/// - [Credential.fromServiceAccountParams] - For service account parameters
/// - [Credential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
///
/// This is similar to Node.js google-auth-library's credential management.
sealed class Credential {
  /// Creates a credential using Application Default Credentials (ADC).
  ///
  /// ADC attempts to find credentials in the following order:
  /// 1. GOOGLE_APPLICATION_CREDENTIALS environment variable (path to service account JSON)
  /// 2. Compute Engine default service account (when running on GCE)
  /// 3. Other ADC sources
  ///
  /// [serviceAccountId] can optionally be provided to override the service
  /// account email if needed for specific operations.
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    return ApplicationDefaultCredential(serviceAccountId: serviceAccountId);
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
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccount(
  ///   File('path/to/service-account.json'),
  /// );
  /// ```
  factory Credential.fromServiceAccount(File serviceAccountFile) {
    return ServiceAccountCredential.fromFile(serviceAccountFile);
  }

  /// Creates a credential from individual service account parameters.
  ///
  /// Parameters:
  /// - [privateKey]: The private key in PEM format (required)
  /// - [email]: The service account email address (required)
  /// - [clientId]: The OAuth2 client ID (optional, defaults to email)
  /// - [projectId]: The Google Cloud project ID (optional)
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccountParams(
  ///   privateKey: '-----BEGIN PRIVATE KEY-----\n...',
  ///   email: 'my-sa@my-project.iam.gserviceaccount.com',
  ///   projectId: 'my-project',
  /// );
  /// ```
  factory Credential.fromServiceAccountParams({
    required String privateKey,
    required String email,
    String? clientId,
    String? projectId,
  }) {
    return ServiceAccountCredential.fromParams(
      privateKey: privateKey,
      email: email,
      clientId: clientId,
      projectId: projectId,
    );
  }

  /// Private constructor for sealed class.
  Credential._();

  /// Returns the underlying [auth.ServiceAccountCredentials] if available.
  ///
  /// This is non-null for [ServiceAccountCredential].
  /// For [ApplicationDefaultCredential], this is only non-null if ADC
  /// found service account credentials.
  auth.ServiceAccountCredentials? get serviceAccountCredentials;

  /// Returns the service account ID (email) if available.
  String? get serviceAccountId;

  /// Returns the project ID if available.
  ///
  /// For service account credentials, this is extracted from the JSON file.
  /// For ADC on Compute Engine, this may be null.
  String? get projectId;
}

/// Service account credentials.
///
/// This wraps [auth.ServiceAccountCredentials] from googleapis_auth and optionally
/// includes the project ID from the service account JSON file.
final class ServiceAccountCredential extends Credential {
  /// Creates a [ServiceAccountCredential] from a JSON object.
  factory ServiceAccountCredential.fromJson(Map<String, Object?> json) {
    final projectId = json['project_id'] as String?;

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
      return ServiceAccountCredential._(credentials, projectId);
    } on FormatException catch (e) {
      throw CredentialParseException(
        'Invalid service account format: ${e.message}',
      );
    }
  }

  /// Creates a [ServiceAccountCredential] from a service account JSON file.
  factory ServiceAccountCredential.fromFile(File serviceAccountFile) {
    try {
      final content = serviceAccountFile.readAsStringSync();
      final json = jsonDecode(content);
      if (json is! Map<String, Object?>) {
        throw CredentialParseException(
          'Service account file must be a JSON object',
        );
      }

      return ServiceAccountCredential.fromJson(json);
    } on FileSystemException catch (e) {
      throw CredentialParseException(
        'Failed to read service account file: ${e.message}',
      );
    } on FormatException catch (e) {
      throw CredentialParseException(
        'Invalid JSON in service account file: ${e.message}',
      );
    }
  }

  /// Creates a [ServiceAccountCredential] from individual parameters.
  ///
  /// This is useful when you want to provide credentials programmatically
  /// without creating a JSON file.
  factory ServiceAccountCredential.fromParams({
    required String privateKey,
    required String email,
    String? clientId,
    String? projectId,
  }) {
    final credentials = auth.ServiceAccountCredentials(
      email,
      auth.ClientId(clientId ?? email),
      privateKey,
    );

    return ServiceAccountCredential._(credentials, projectId);
  }

  ServiceAccountCredential._(this._credentials, this._projectId) : super._();

  final auth.ServiceAccountCredentials _credentials;
  final String? _projectId;

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
final class ApplicationDefaultCredential extends Credential {
  ApplicationDefaultCredential({String? serviceAccountId})
    : _serviceAccountId = serviceAccountId,
      super._() {
    // Check for GOOGLE_APPLICATION_CREDENTIALS
    final credPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credPath != null && File(credPath).existsSync()) {
      try {
        final content = File(credPath).readAsStringSync();
        final json = jsonDecode(content);
        if (json is Map<String, Object?>) {
          _serviceAccountCredentials = auth.ServiceAccountCredentials.fromJson(
            json,
          );
          _projectId = json['project_id'] as String?;
        }
      } catch (_) {
        // Ignore parsing errors, will fall back to metadata service
      }
    }
  }

  final String? _serviceAccountId;
  auth.ServiceAccountCredentials? _serviceAccountCredentials;
  String? _projectId;

  @override
  auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId =>
      _serviceAccountId ?? _serviceAccountCredentials?.email;

  @override
  String? get projectId => _projectId;
}

/// Exception thrown when credential parsing fails.
class CredentialParseException implements Exception {
  CredentialParseException(this.message);

  final String message;

  @override
  String toString() => 'CredentialParseException: $message';
}
