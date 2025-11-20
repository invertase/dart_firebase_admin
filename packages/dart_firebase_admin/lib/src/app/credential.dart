part of '../app.dart';

@internal
const envSymbol = #_envSymbol;

/// Base class for Firebase Admin SDK credentials.
///
/// Use [ServiceAccountCredential] for service account credentials,
/// or [ApplicationDefaultCredential] for Application Default Credentials.
sealed class Credential {
  /// Factory to create a credential using Application Default Credentials.
  factory Credential.fromApplicationDefaultCredentials({
    String? serviceAccountId,
  }) {
    return ApplicationDefaultCredential.fromEnvironment(
      serviceAccountId: serviceAccountId,
    );
  }

  /// Factory to create a credential from a service account file.
  factory Credential.fromServiceAccount(File serviceAccountFile) {
    return ServiceAccountCredential.fromFile(serviceAccountFile);
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
      throw const FormatException(
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

  ServiceAccountCredential._(
    this._credentials,
    this.projectId,
  ) : super._();

  final auth.ServiceAccountCredentials _credentials;

  /// The Google Cloud project ID associated with this service account.
  final String projectId;

  /// The service account email (client_email).
  String get clientEmail => _credentials.email;

  /// The private key.
  String get privateKey => _credentials.privateKey;

  @override
  auth.ServiceAccountCredentials get serviceAccountCredentials => _credentials;

  @override
  String? get serviceAccountId => _credentials.email;
}

/// Application Default Credentials for Firebase Admin SDK.
///
/// Uses Google Application Default Credentials (ADC) which can be:
/// - A service account file specified via GOOGLE_APPLICATION_CREDENTIALS
/// - Compute Engine default service account
/// - Other ADC sources
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

  /// Factory to create from environment (GOOGLE_APPLICATION_CREDENTIALS).
  factory ApplicationDefaultCredential.fromEnvironment({
    String? serviceAccountId,
  }) {
    auth.ServiceAccountCredentials? creds;
    String? projectId;

    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final maybeConfig = env['GOOGLE_APPLICATION_CREDENTIALS'];
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
  /// For Compute Engine, this needs to be fetched asynchronously via metadata service.
  String? get projectId => _projectId;

  /// Fetches the project ID from the metadata service (for Compute Engine).
  /// Returns null if not available.
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

  /// Fetches the service account email from the metadata service (for Compute Engine).
  /// Returns null if not available.
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
