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
    return ApplicationDefaultCredential.fromEnvironment(
      serviceAccountId: serviceAccountId,
    );
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
    return ServiceAccountCredential.fromFile(serviceAccountFile);
  }

  /// Creates a credential from individual service account parameters.
  ///
  /// This is primarily useful for testing when you want to provide mock
  /// credentials without creating a JSON file.
  ///
  /// Parameters:
  /// - [clientId]: The OAuth2 client ID (optional)
  /// - [privateKey]: The private key in PEM format
  /// - [email]: The service account email address
  /// - [projectId]: The Google Cloud project ID (optional, defaults to 'test-project')
  ///
  /// Example:
  /// ```dart
  /// final credential = Credential.fromServiceAccountParams(
  ///   clientId: 'test-client-id',
  ///   privateKey: '-----BEGIN RSA PRIVATE KEY-----\n...',
  ///   email: 'test@example.iam.gserviceaccount.com',
  ///   projectId: 'my-project',
  /// );
  /// ```
  factory Credential.fromServiceAccountParams({
    String? clientId,
    required String privateKey,
    required String email,
    String projectId = 'test-project',
  }) {
    return ServiceAccountCredential.fromParams(
      clientId: clientId,
      privateKey: privateKey,
      email: email,
      projectId: projectId,
    );
  }

  /// Private constructor for sealed class.
  Credential._();

  /// Returns the underlying [auth.ServiceAccountCredentials] if this is a
  /// [ServiceAccountCredential], null otherwise.
  @internal
  auth.ServiceAccountCredentials? get serviceAccountCredentials;

  /// Returns the service account ID (email) if available.
  @internal
  String? get serviceAccountId;
}

/// Extended service account credentials that includes projectId.
///
/// This wraps [auth.ServiceAccountCredentials] and adds the [projectId] field
/// which is required for Firebase Admin SDK operations.
@internal
final class ServiceAccountCredential extends Credential {
  /// Creates a [ServiceAccountCredential] from a JSON object.
  factory ServiceAccountCredential.fromJson(Map<String, Object?> json) {
    // Extract and validate projectId - required for service accounts
    final projectId = json['project_id'] as String?;
    if (projectId == null || projectId.isEmpty) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Service account JSON must contain a "project_id" property',
      );
    }

    // Use parent's fromJson to create the base credentials
    final credentials = auth.ServiceAccountCredentials.fromJson(json);

    return ServiceAccountCredential._(credentials, projectId);
  }

  /// Creates a [ServiceAccountCredential] from a service account JSON file.
  factory ServiceAccountCredential.fromFile(File serviceAccountFile) {
    final content = serviceAccountFile.readAsStringSync();
    final json = jsonDecode(content);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid service account file');
    }

    return ServiceAccountCredential.fromJson(json);
  }

  /// Creates a [ServiceAccountCredential] from individual parameters.
  ///
  /// This is useful for testing when you want to provide mock credentials
  /// without creating a JSON file.
  factory ServiceAccountCredential.fromParams({
    String? clientId,
    required String privateKey,
    required String email,
    required String projectId,
  }) {
    final credentials = auth.ServiceAccountCredentials(
      email,
      auth.ClientId(clientId ?? email),
      privateKey,
    );

    return ServiceAccountCredential._(credentials, projectId);
  }

  ServiceAccountCredential._(
    this._credentials,
    this.projectId,
  ) : super._();

  final auth.ServiceAccountCredentials _credentials;

  /// The Google Cloud project ID associated with this service account.
  ///
  /// This is extracted from the `project_id` field in the service account JSON.
  final String projectId;

  /// The service account email address.
  ///
  /// This is the `client_email` field from the service account JSON.
  /// Format: `firebase-adminsdk-xxxxx@project-id.iam.gserviceaccount.com`
  String get clientEmail => _credentials.email;

  /// The service account private key in PEM format.
  ///
  /// This is used to sign authentication tokens for API calls.
  String get privateKey => _credentials.privateKey;

  @override
  auth.ServiceAccountCredentials get serviceAccountCredentials => _credentials;

  @override
  String? get serviceAccountId => _credentials.email;
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
  ApplicationDefaultCredential({
    String? serviceAccountId,
    auth.ServiceAccountCredentials? serviceAccountCredentials,
    String? projectId,
  })  : _serviceAccountId = serviceAccountId,
        _serviceAccountCredentials = serviceAccountCredentials,
        _projectId = projectId,
        super._();

  /// Factory to create from environment.
  ///
  /// Checks [Environment.googleApplicationCredentials] for a service account file path.
  factory ApplicationDefaultCredential.fromEnvironment({
    String? serviceAccountId,
  }) {
    auth.ServiceAccountCredentials? creds;
    String? projectId;

    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final maybeConfig = env[Environment.googleApplicationCredentials];
    if (maybeConfig != null && File(maybeConfig).existsSync()) {
      try {
        final text = File(maybeConfig).readAsStringSync();
        final decodedValue = jsonDecode(text);
        if (decodedValue is Map) {
          creds = auth.ServiceAccountCredentials.fromJson(decodedValue);
          projectId = decodedValue['project_id'] as String?;
        }
      } on FormatException catch (_) {
        // Ignore parsing errors, will fall back to metadata service
      }
    }

    return ApplicationDefaultCredential(
      serviceAccountId: serviceAccountId,
      serviceAccountCredentials: creds,
      projectId: projectId,
    );
  }

  final String? _serviceAccountId;
  final auth.ServiceAccountCredentials? _serviceAccountCredentials;
  final String? _projectId;

  @override
  auth.ServiceAccountCredentials? get serviceAccountCredentials =>
      _serviceAccountCredentials;

  @override
  String? get serviceAccountId =>
      _serviceAccountId ?? _serviceAccountCredentials?.email;

  /// The project ID if available from the service account file.
  ///
  /// For Compute Engine deployments, this will be null and needs to be
  /// fetched asynchronously via [getProjectId].
  String? get projectId => _projectId;

  /// Fetches the project ID from the GCE metadata service.
  ///
  /// This is used when running on Google Compute Engine, Cloud Run, or other
  /// GCP environments where the project ID can be queried from the metadata
  /// service.
  ///
  /// Returns null if:
  /// - Not running on GCE/Cloud Run
  /// - Metadata service is unavailable
  /// - Network request fails
  Future<String?> getProjectId() async {
    if (_projectId != null) {
      return _projectId;
    }

    // Try to get from metadata service
    try {
      final response = await get(
        Uri.parse(
          'http://metadata.google.internal/computeMetadata/v1/project/project-id',
        ),
        headers: {
          'Metadata-Flavor': 'Google',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {
      // Not on Compute Engine or metadata service unavailable
    }

    return null;
  }

  /// Fetches the service account email from the GCE metadata service.
  ///
  /// This is used when running on Google Compute Engine to discover the default
  /// service account email associated with the compute instance.
  ///
  /// Returns null if:
  /// - Not running on GCE/Cloud Run
  /// - Metadata service is unavailable
  /// - Network request fails
  Future<String?> getServiceAccountEmail() async {
    if (_serviceAccountId != null) {
      return _serviceAccountId;
    }

    if (_serviceAccountCredentials != null) {
      return _serviceAccountCredentials.email;
    }

    // Try to get from metadata service
    try {
      final response = await get(
        Uri.parse(
          'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
        ),
        headers: {
          'Metadata-Flavor': 'Google',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {
      // Not on Compute Engine or metadata service unavailable
    }

    return null;
  }
}
