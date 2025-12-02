import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:meta/meta.dart';

part 'project_id_provider.dart';

extension AuthClientX on AuthClient {
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
}
