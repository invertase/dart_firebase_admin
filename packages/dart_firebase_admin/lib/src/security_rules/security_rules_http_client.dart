part of 'security_rules.dart';

/// HTTP client for Firebase Security Rules API operations.
///
/// Handles HTTP client management, googleapis API client creation,
/// and path builders.
/// Does not handle emulator routing as Security Rules has no emulator support.
class SecurityRulesHttpClient {
  SecurityRulesHttpClient(this.app);

  final FirebaseApp app;

  /// Builds the project path for Security Rules operations.
  String buildProjectPath(String projectId) {
    return 'projects/$projectId';
  }

  /// Builds the ruleset resource path.
  String buildRulesetPath(String projectId, String name) {
    return 'projects/$projectId/rulesets/$name';
  }

  /// Builds the release resource path.
  String buildReleasePath(String projectId, String name) {
    return 'projects/$projectId/releases/$name';
  }

  Future<R> _run<R>(
    Future<R> Function(googleapis_auth.AuthClient client, String projectId) fn,
  ) async {
    final client = await app.client;
    final projectId = await client.getProjectId(
      projectIdOverride: app.options.projectId,
      environment: Zone.current[envSymbol] as Map<String, String>?,
    );
    try {
      return await fn(client, projectId);
    } on FirebaseSecurityRulesException {
      rethrow;
    } on firebase_rules_v1.DetailedApiRequestError catch (e, stack) {
      switch (e.jsonResponse) {
        case {'error': {'status': final status}}:
          final code = _errorMapping[status];
          if (code == null) break;

          Error.throwWithStackTrace(
            FirebaseSecurityRulesException(code, e.message),
            stack,
          );
      }

      Error.throwWithStackTrace(
        FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.unknownError,
          'Unexpected error: $e',
        ),
        stack,
      );
    } catch (e, stack) {
      Error.throwWithStackTrace(
        FirebaseSecurityRulesException(
          FirebaseSecurityRulesErrorCode.unknownError,
          'Unexpected error: $e',
        ),
        stack,
      );
    }
  }

  /// Executes a Security Rules v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(firebase_rules_v1.FirebaseRulesApi api, String projectId)
    fn,
  ) => _run(
    (client, projectId) =>
        fn(firebase_rules_v1.FirebaseRulesApi(client), projectId),
  );
}
