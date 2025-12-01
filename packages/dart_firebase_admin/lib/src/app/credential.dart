part of '../app.dart';

@internal
const envSymbol = #_envSymbol;

/// Base class for Firebase Admin SDK credentials.
///
/// Create credentials using one of the factory methods:
/// - [Credential.fromServiceAccount] - For service account JSON files
/// - [Credential.fromApplicationDefaultCredentials] - For Application Default Credentials (ADC)
///
/// The credential is used to authenticate all API calls made by the Admin SDK.
sealed class Credential {
  /// Creates a credential using Application Default Credentials (ADC).
  ///
  /// ADC attempts to find credentials in the following order:
  /// 1. [Environment.googleApplicationCredentials] environment variable (path to service account JSON)
  /// 2. Compute Engine default service account (when running on GCE)
  /// 3. Other ADC sources
  ///
  /// [serviceAccountId] can optionally be provided to override the service
  /// account email if needed for specific operations.
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    // Get environment from zone
    final env = Zone.current[envSymbol] as Map<String, String>?;

    final googleCredential =
        googleapis_auth_utils
            .GoogleCredential.fromApplicationDefaultCredentials(
          serviceAccountId: serviceAccountId,
          environment: env,
        );
    return ApplicationDefaultCredential._(googleCredential);
  }

  /// Creates a credential from a service account JSON file.
  ///
  /// The service account file must contain:
  /// - `project_id`: The Google Cloud project ID
  /// - `private_key`: The service account private key
  /// - `client_email`: The service account email
  ///
  /// You can download service account JSON files from the Firebase Console
  /// under Project Settings > Service Accounts.
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccount(
  ///   File('path/to/service-account.json'),
  /// );
  /// ```
  factory Credential.fromServiceAccount(File serviceAccountFile) {
    try {
      final googleCredential = googleapis_auth_utils
          .GoogleCredential.fromServiceAccount(serviceAccountFile);
      return ServiceAccountCredential._(googleCredential);
    } on googleapis_auth_utils.CredentialParseException catch (e) {
      throw FirebaseAppException(AppErrorCode.invalidCredential, e.message);
    }
  }

  /// Creates a credential from individual service account parameters.
  ///
  /// Parameters:
  /// - [clientId]: The OAuth2 client ID (optional)
  /// - [privateKey]: The private key in PEM format
  /// - [email]: The service account email address
  /// - [projectId]: The Google Cloud project ID
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccountParams(
  ///   clientId: 'client-id',
  ///   privateKey: '-----BEGIN PRIVATE KEY-----\n...',
  ///   email: 'client@example.iam.gserviceaccount.com',
  ///   projectId: 'my-project',
  /// );
  /// ```
  factory Credential.fromServiceAccountParams({
    String? clientId,
    required String privateKey,
    required String email,
    required String projectId,
  }) {
    try {
      final googleCredential =
          googleapis_auth_utils.GoogleCredential.fromServiceAccountParams(
            privateKey: privateKey,
            email: email,
            clientId: clientId,
            projectId: projectId,
          );
      return ServiceAccountCredential._(googleCredential);
    } on googleapis_auth_utils.CredentialParseException catch (e) {
      throw FirebaseAppException(AppErrorCode.invalidCredential, e.message);
    }
  }

  /// Private constructor for sealed class.
  Credential._();

  /// Returns a Google OAuth2 access token.
  ///
  /// This method obtains a valid access token that can be used to authenticate
  /// API requests to Google Cloud services. The token is automatically refreshed
  /// if expired.
  ///
  /// The returned [googleapis_auth.AccessToken] contains:
  /// - [googleapis_auth.AccessToken.data]: The token string to use in Authorization headers
  /// - [googleapis_auth.AccessToken.expiry]: The DateTime when the token expires
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccount(file);
  /// final token = await credential.getAccessToken();
  /// print('Token: ${token.data}');
  /// print('Expires at: ${token.expiry}');
  /// ```
  Future<googleapis_auth.AccessToken> getAccessToken() {
    return googleCredential.getAccessToken();
  }

  /// Returns the underlying [googleapis_auth.ServiceAccountCredentials] if this is a
  /// [ServiceAccountCredential], null otherwise.
  @internal
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials;

  /// Returns the service account ID (email) if available.
  @internal
  String? get serviceAccountId;

  /// Returns the underlying [googleapis_auth_utils.GoogleCredential].
  @internal
  googleapis_auth_utils.GoogleCredential get googleCredential;
}

/// Extended service account credentials that includes projectId.
///
/// This wraps [googleapis_auth_utils.GoogleCredential] and ensures
/// the [projectId] field is present, which is required for Firebase Admin SDK operations.
@internal
final class ServiceAccountCredential extends Credential {
  ServiceAccountCredential._(this._googleCredential) : super._() {
    // Firebase requires projectId
    if (_googleCredential.projectId == null) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Service account JSON must contain a "project_id" property',
      );
    }
  }

  final googleapis_auth_utils.GoogleCredential _googleCredential;

  /// The Google Cloud project ID associated with this service account.
  ///
  /// This is extracted from the `project_id` field in the service account JSON.
  String get projectId => _googleCredential.projectId!;

  /// The service account email address.
  ///
  /// This is the `client_email` field from the service account JSON.
  /// Format: `firebase-adminsdk-xxxxx@project-id.iam.gserviceaccount.com`
  String get clientEmail => _googleCredential.serviceAccountCredentials!.email;

  /// The service account private key in PEM format.
  ///
  /// This is used to sign authentication tokens for API calls.
  String get privateKey =>
      _googleCredential.serviceAccountCredentials!.privateKey;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _googleCredential.serviceAccountCredentials;

  @override
  String? get serviceAccountId => _googleCredential.serviceAccountId;

  @override
  googleapis_auth_utils.GoogleCredential get googleCredential =>
      _googleCredential;
}

/// Application Default Credentials for Firebase Admin SDK.
///
/// Uses Google Application Default Credentials (ADC) to automatically discover
/// credentials from the environment. ADC checks the following sources in order:
///
/// 1. [Environment.googleApplicationCredentials] environment variable pointing to a
///    service account JSON file
/// 2. **Compute Engine** default service account (when running on GCE, Cloud Run, etc.)
/// 3. Other ADC sources (gcloud CLI credentials, etc.)
///
/// This credential type is recommended for production environments as it allows
/// the same code to work across different deployment environments without
/// hardcoding credential paths.
///
/// The project ID is discovered lazily from:
/// - The service account JSON file (if using [Environment.googleApplicationCredentials])
/// - The GCE metadata service (if running on Compute Engine)
/// - Environment variables ([Environment.googleCloudProject], [Environment.gcloudProject])
@internal
final class ApplicationDefaultCredential extends Credential {
  ApplicationDefaultCredential._(this._googleCredential) : super._();

  final googleapis_auth_utils.GoogleCredential _googleCredential;

  @override
  googleapis_auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _googleCredential.serviceAccountCredentials;

  @override
  String? get serviceAccountId => _googleCredential.serviceAccountId;

  @override
  googleapis_auth_utils.GoogleCredential get googleCredential =>
      _googleCredential;

  /// The project ID if available from the service account file.
  ///
  /// For Compute Engine deployments, this will be null.
  String? get projectId => _googleCredential.projectId;
}
