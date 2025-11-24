part of 'auth_client_extensions.dart';

/// Provider for discovering and caching Google Cloud project IDs.
///
/// This class encapsulates the pattern of discovering and caching project IDs
/// from various sources including explicit configuration, environment variables,
/// credential files, gcloud config, and metadata service.
final class _ProjectIdProvider {
  _ProjectIdProvider._();

  static final _ProjectIdProvider _instance = _ProjectIdProvider._();

  /// Gets the singleton instance of [_ProjectIdProvider].
  static _ProjectIdProvider get instance => _instance;

  /// Cached project ID after first discovery.
  String? _cachedProjectId;

  /// Gets the cached project ID if it has been discovered.
  /// Returns null if projectId has not been discovered yet.
  String? get cachedProjectId => _cachedProjectId;

  /// Discovers and caches the Google Cloud project ID using the provided [client].
  ///
  /// Checks in the following order:
  /// 1. [projectIdOverride]
  /// 2. GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT environment variables
  /// 3. GOOGLE_APPLICATION_CREDENTIALS JSON file
  /// 4. Cloud SDK: `gcloud config config-helper --format json`
  /// 5. GCE/Cloud Run metadata service
  ///
  /// The discovered project ID is cached for subsequent calls.
  Future<String> getProjectId(
    AuthClient client, {
    String? projectIdOverride,
    Map<String, String>? environment,
  }) async {
    if (_cachedProjectId != null) {
      return _cachedProjectId!;
    }

    // 1. Check explicit project ID
    if (projectIdOverride != null && projectIdOverride.isNotEmpty) {
      return _cachedProjectId = projectIdOverride;
    }

    // 2. Check environment variables
    final env = environment ?? Platform.environment;
    final envProjectId = env['GOOGLE_CLOUD_PROJECT'] ?? env['GCLOUD_PROJECT'];
    if (envProjectId != null && envProjectId.isNotEmpty) {
      return _cachedProjectId = envProjectId;
    }

    // 3. Try to get from GOOGLE_APPLICATION_CREDENTIALS file
    final credPath = env['GOOGLE_APPLICATION_CREDENTIALS'];
    if (credPath != null && credPath.isNotEmpty) {
      try {
        final file = File(credPath);
        if (file.existsSync()) {
          final contents = await file.readAsString();
          final json = jsonDecode(contents) as Map<String, dynamic>;
          final projectId = json['project_id'] as String?;
          if (projectId != null && projectId.isNotEmpty) {
            return _cachedProjectId = projectId;
          }
        }
      } catch (_) {
        // Ignore errors and continue to next source
      }
    }

    // 4. Try gcloud config
    final gcloudProjectId = await _getGcloudProjectId();
    if (gcloudProjectId != null && gcloudProjectId.isNotEmpty) {
      return _cachedProjectId = gcloudProjectId;
    }

    // 5. Try metadata service (GCE/Cloud Run)
    final metadataProjectId = await _getMetadataProjectId(client);
    if (metadataProjectId != null && metadataProjectId.isNotEmpty) {
      return _cachedProjectId = metadataProjectId;
    }

    if (_cachedProjectId == null || _cachedProjectId!.isEmpty) {
      throw Exception(
        'Failed to determine project ID. Initialize the SDK with service '
        'account credentials or set project ID as an app option. '
        'Alternatively, set the GOOGLE_CLOUD_PROJECT environment variable.',
      );
    }

    return _cachedProjectId!;
  }

  /// Attempts to get project ID from gcloud config.
  Future<String?> _getGcloudProjectId() async {
    try {
      final result = await Process.run(
        'gcloud',
        ['config', 'config-helper', '--format', 'json'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final json =
            jsonDecode(result.stdout as String) as Map<String, dynamic>;
        final config = json['configuration'] as Map<String, dynamic>?;
        final properties = config?['properties'] as Map<String, dynamic>?;
        final core = properties?['core'] as Map<String, dynamic>?;
        return core?['project'] as String?;
      }
    } catch (_) {
      // gcloud might not be installed or configured
    }
    return null;
  }

  /// Attempts to get project ID from GCE/Cloud Run metadata service.
  Future<String?> _getMetadataProjectId(AuthClient client) async {
    try {
      final response = await client.get(
        Uri.parse(
          'http://metadata.google.internal/computeMetadata/v1/project/project-id',
        ),
        headers: {'Metadata-Flavor': 'Google'},
      );

      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (_) {
      // Not running on GCE/Cloud Run or metadata service unavailable
    }
    return null;
  }
}
