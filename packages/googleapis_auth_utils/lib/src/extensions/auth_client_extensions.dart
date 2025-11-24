import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

part 'project_id_provider.dart';

extension AuthClientX on AuthClient {
  /// Discovers the Google Cloud project ID with support for explicit sources.
  ///
  /// Uses the singleton [_ProjectIdProvider] to discover and cache project IDs.
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
    return _ProjectIdProvider.instance.getProjectId(
      this,
      projectIdOverride: projectIdOverride,
      environment: environment,
    );
  }

  /// Gets the cached project ID from the [_ProjectIdProvider].
  ///
  /// Returns null if the project ID has not been discovered yet.
  String? get cachedProjectId => _ProjectIdProvider.instance.cachedProjectId;

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
      final response = await http.get(
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
