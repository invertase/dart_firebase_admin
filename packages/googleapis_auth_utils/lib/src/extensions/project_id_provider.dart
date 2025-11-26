part of 'auth_client_extensions.dart';

@internal
class FileSystem {
  const FileSystem();

  bool exists(String path) => File(path).existsSync();

  Future<String> readAsString(String path) => File(path).readAsString();
}

@internal
class ProcessRunner {
  const ProcessRunner();

  Future<ProcessResult> run(String executable, List<String> arguments) {
    return Process.run(executable, arguments, runInShell: true);
  }
}

@internal
class MetadataClient {
  MetadataClient(this._client);

  final AuthClient _client;

  Future<MetadataResponse> getProjectId() async {
    final response = await _client.get(
      Uri.parse(
        'http://metadata.google.internal/computeMetadata/v1/project/project-id',
      ),
      headers: {'Metadata-Flavor': 'Google'},
    );
    return MetadataResponse(response.statusCode, response.body);
  }

  Future<MetadataResponse> getServiceAccountEmail() async {
    final response = await _client.get(
      Uri.parse(
        'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email',
      ),
      headers: {'Metadata-Flavor': 'Google'},
    );
    return MetadataResponse(response.statusCode, response.body);
  }
}

@internal
class MetadataResponse {
  const MetadataResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

/// Provider for discovering Google Cloud project IDs.
///
/// All dependencies are injected, making this fully testable.
@internal
class ProjectIdProvider {
  /// Creates a provider with explicit dependencies. Use this for testing.
  ProjectIdProvider({
    required FileSystem fileSystem,
    required ProcessRunner processRunner,
    required MetadataClient metadataClient,
    required Map<String, String> environment,
  }) : _fileSystem = fileSystem,
       _processRunner = processRunner,
       _metadataClient = metadataClient,
       _environment = environment;

  /// Returns a shared default instance, creating it on first access.
  factory ProjectIdProvider.getDefault(
    AuthClient client, {
    Map<String, String>? environment,
  }) {
    return _instance ??= ProjectIdProvider(
      fileSystem: const FileSystem(),
      processRunner: const ProcessRunner(),
      metadataClient: MetadataClient(client),
      environment: environment ?? Platform.environment,
    );
  }

  static ProjectIdProvider? _instance;

  /// The current instance, if one exists.
  static ProjectIdProvider? get instance => _instance;

  final FileSystem _fileSystem;
  final ProcessRunner _processRunner;
  final MetadataClient _metadataClient;
  final Map<String, String> _environment;

  String? _cachedProjectId;

  String? get cachedProjectId => _cachedProjectId;

  Future<String> getProjectId({String? projectIdOverride}) async {
    if (_cachedProjectId != null) {
      return _cachedProjectId!;
    }

    // 1. Check explicit project ID
    if (projectIdOverride?.isNotEmpty ?? false) {
      return (_cachedProjectId = projectIdOverride)!;
    }

    // 2. Check environment variables
    final envProjectId =
        _environment['GOOGLE_CLOUD_PROJECT'] ?? _environment['GCLOUD_PROJECT'];
    if (envProjectId?.isNotEmpty ?? false) {
      return (_cachedProjectId = envProjectId)!;
    }

    // 3. Try GOOGLE_APPLICATION_CREDENTIALS file
    final credPath = _environment['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credPath?.isNotEmpty ?? false) {
      final projectId = await _getProjectIdFromCredentialsFile(credPath!);
      if (projectId != null) {
        return _cachedProjectId = projectId;
      }
    }

    // 4. Try gcloud config
    final gcloudProjectId = await _getGcloudProjectId();
    if (gcloudProjectId != null) {
      return _cachedProjectId = gcloudProjectId;
    }

    // 5. Try metadata service
    final metadataProjectId = await _getMetadataProjectId();
    if (metadataProjectId != null) {
      return _cachedProjectId = metadataProjectId;
    }

    throw Exception(
      'Failed to determine project ID. Initialize the SDK with service '
      'account credentials or set project ID as an app option. '
      'Alternatively, set the GOOGLE_CLOUD_PROJECT environment variable.',
    );
  }

  Future<String?> _getProjectIdFromCredentialsFile(String path) async {
    try {
      if (!_fileSystem.exists(path)) return null;
      final contents = await _fileSystem.readAsString(path);
      final json = jsonDecode(contents) as Map<String, dynamic>;
      final projectId = json['project_id'] as String?;
      return projectId?.isNotEmpty ?? false ? projectId : null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getGcloudProjectId() async {
    try {
      final result = await _processRunner.run('gcloud', [
        'config',
        'config-helper',
        '--format',
        'json',
      ]);

      if (result.exitCode == 0) {
        final json =
            jsonDecode(result.stdout as String) as Map<String, dynamic>;
        final configuration = json['configuration'] as Map<String, dynamic>?;
        final properties =
            configuration?['properties'] as Map<String, dynamic>?;
        final core = properties?['core'] as Map<String, dynamic>?;
        final project = core?['project'] as String?;
        return project;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _getMetadataProjectId() async {
    try {
      final response = await _metadataClient.getProjectId();
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      }
    } catch (_) {}
    return null;
  }

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
    try {
      final response = await _metadataClient.getServiceAccountEmail();
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      }
    } catch (_) {
      // Not on Compute Engine or metadata service unavailable
    }
    return null;
  }

  @visibleForTesting
  void clearCache() => _cachedProjectId = null;

  /// Replaces the singleton instance. Use for testing.
  @visibleForTesting
  static set instance(ProjectIdProvider? provider) {
    _instance = provider;
  }
}
