// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    final projectId = await app.getProjectId();
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
