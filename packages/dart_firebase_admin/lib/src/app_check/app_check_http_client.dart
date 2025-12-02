part of 'app_check.dart';

/// HTTP client for Firebase App Check API operations.
///
/// Handles HTTP client management, googleapis API client creation,
/// path builders, and simple API operations.
/// Does not handle emulator routing as App Check has no emulator support.
@internal
class AppCheckHttpClient {
  AppCheckHttpClient(this.app);

  final FirebaseApp app;

  /// Builds the app resource path for App Check operations.
  String buildAppPath(String projectId, String appId) {
    return 'projects/$projectId/apps/$appId';
  }

  /// Builds the project resource path for App Check operations.
  String buildProjectPath(String projectId) {
    return 'projects/$projectId';
  }

  Future<R> _run<R>(
    Future<R> Function(googleapis_auth.AuthClient client, String projectId) fn,
  ) async {
    final client = await app.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    return fn(client, projectId);
  }

  /// Executes an App Check v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(appcheck1.FirebaseappcheckApi client, String projectId)
    fn,
  ) => _run(
    (client, projectId) => fn(appcheck1.FirebaseappcheckApi(client), projectId),
  );

  /// Executes an App Check v1Beta API operation with automatic projectId injection.
  Future<R> v1Beta<R>(
    Future<R> Function(
      appcheck1_beta.FirebaseappcheckApi client,
      String projectId,
    )
    fn,
  ) => _run(
    (client, projectId) =>
        fn(appcheck1_beta.FirebaseappcheckApi(client), projectId),
  );

  /// Exchange a custom token for an App Check token (low-level API call).
  ///
  /// Returns the raw googleapis response without transformation.
  Future<appcheck1.GoogleFirebaseAppcheckV1AppCheckToken> exchangeCustomToken(
    String customToken,
    String appId,
  ) {
    return v1((client, projectId) async {
      return client.projects.apps.exchangeCustomToken(
        appcheck1.GoogleFirebaseAppcheckV1ExchangeCustomTokenRequest(
          customToken: customToken,
        ),
        buildAppPath(projectId, appId),
      );
    });
  }

  /// Verify an App Check token with replay protection (low-level API call).
  ///
  /// Returns the raw googleapis response without transformation.
  Future<appcheck1_beta.GoogleFirebaseAppcheckV1betaVerifyAppCheckTokenResponse>
  verifyAppCheckToken(String token) {
    return v1Beta((client, projectId) async {
      return client.projects.verifyAppCheckToken(
        appcheck1_beta.GoogleFirebaseAppcheckV1betaVerifyAppCheckTokenRequest(
          appCheckToken: token,
        ),
        buildProjectPath(projectId),
      );
    });
  }
}
