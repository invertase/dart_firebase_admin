import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import '../app.dart';

/// Provider for Firebase services that need project ID discovery.
///
/// This class encapsulates the pattern of discovering and caching project IDs
/// for Firebase services. Services can inject this class to gain access
/// to project ID resolution capabilities.
@internal
final class ProjectIdProvider {
  ProjectIdProvider(this.app);

  final FirebaseApp app;

  /// Cached project ID after first discovery
  String? _cachedProjectId;

  /// Gets the cached project ID if it has been discovered.
  /// Returns null if projectId has not been discovered yet.
  @internal
  String? get cachedProjectId => _cachedProjectId;

  /// Gets the explicitly specified project ID from synchronous sources.
  /// This is exposed for internal use by services that need synchronous
  /// access to project ID (e.g., Firestore serialization).
  @internal
  String? get explicitProjectId => _getExplicitProjectId();

  /// Returns the Google Cloud project ID associated with the Firebase app.
  ///
  /// This method first checks if a project ID is explicitly specified in either
  /// the Firebase app options, credentials or the local environment. If no
  /// explicit project ID is configured, but the SDK has been initialized with
  /// ApplicationDefaultCredential, this method attempts to discover the project
  /// ID from the local metadata service.
  ///
  /// The discovered project ID is cached for subsequent calls.
  ///
  /// Throws [FirebaseAppException] if project ID cannot be determined.
  Future<String> discoverProjectId() async {
    if (_cachedProjectId != null) {
      return _cachedProjectId!;
    }

    final projectId = await _findProjectId();
    if (projectId == null || projectId.isEmpty) {
      throw FirebaseAppException(
        AppErrorCode.invalidCredential,
        'Failed to determine project ID. Initialize the SDK with service '
        'account credentials or set project ID as an app option. '
        'Alternatively, set the GOOGLE_CLOUD_PROJECT environment variable.',
      );
    }

    _cachedProjectId = projectId;
    return _cachedProjectId!;
  }

  /// Gets the explicitly specified project ID from synchronous sources.
  ///
  /// Checks in priority order:
  /// 1. app.options.projectId
  /// 2. ServiceAccountCredential.projectId
  /// 3. GOOGLE_CLOUD_PROJECT or GCLOUD_PROJECT environment variables
  ///
  /// Returns null if not found in any explicit source.
  String? _getExplicitProjectId() {
    // Priority 1: Explicitly provided in options
    if (app.projectId != null && app.projectId!.isNotEmpty) {
      return app.projectId;
    }

    final credential = app.options.credential;

    // Priority 2: From ServiceAccountCredential
    if (credential is ServiceAccountCredential) {
      return credential.projectId;
    }

    // Priority 3: From environment variables
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;
    final projectId = env['GOOGLE_CLOUD_PROJECT'] ?? env['GCLOUD_PROJECT'];
    if (projectId != null && projectId.isNotEmpty) {
      return projectId;
    }

    return null;
  }

  /// Determines the Google Cloud project ID associated with the Firebase app.
  ///
  /// First checks explicit sources via [_getExplicitProjectId]. If not found
  /// and the app uses ApplicationDefaultCredential, attempts to discover the
  /// project ID from the metadata service.
  ///
  /// Returns null if project ID cannot be determined.
  Future<String?> _findProjectId() async {
    final projectId = _getExplicitProjectId();
    if (projectId != null) {
      return projectId;
    }

    final credential = app.options.credential;
    if (credential is ApplicationDefaultCredential) {
      return credential.getProjectId();
    }

    return null;
  }
}
