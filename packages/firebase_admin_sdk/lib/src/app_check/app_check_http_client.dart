// Copyright 2026 Google LLC
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
    final projectId = await app.getProjectId();
    try {
      return await fn(client, projectId);
    } on FirebaseAppCheckException {
      rethrow;
    } on appcheck1.DetailedApiRequestError catch (e, stack) {
      switch (e.jsonResponse) {
        case {'error': {'status': final String status}}:
          final code = appCheckErrorCodeMapping[status];
          if (code != null) {
            Error.throwWithStackTrace(
              FirebaseAppCheckException(code, e.message),
              stack,
            );
          }
      }
      Error.throwWithStackTrace(
        FirebaseAppCheckException(
          AppCheckErrorCode.unknownError,
          'Unexpected error: $e',
        ),
        stack,
      );
    }
  }

  /// Executes an App Check v1 API operation with automatic projectId injection.
  Future<R> v1<R>(
    Future<R> Function(appcheck1.FirebaseappcheckApi api, String projectId) fn,
  ) => _run(
    (client, projectId) => fn(appcheck1.FirebaseappcheckApi(client), projectId),
  );

  /// Exchange a custom token for an App Check token (low-level API call).
  ///
  /// Returns the raw googleapis response without transformation.
  Future<appcheck1.GoogleFirebaseAppcheckV1AppCheckToken> exchangeCustomToken(
    String customToken,
    String appId,
  ) {
    return v1((api, projectId) async {
      return api.projects.apps.exchangeCustomToken(
        appcheck1.GoogleFirebaseAppcheckV1ExchangeCustomTokenRequest(
          customToken: customToken,
        ),
        buildAppPath(projectId, appId),
      );
    });
  }

  /// Verify an App Check token with replay protection (low-level API call).
  ///
  /// Returns `true` if the token was already consumed, `false` otherwise.
  Future<bool> verifyAppCheckToken(String token) => _run(
    (client, projectId) async =>
        _verifyAppCheckTokenRest(client, projectId, token),
  );
}

/// See https://firebase.google.com/docs/reference/appcheck/rest/v1beta/projects/verifyAppCheckToken
Future<bool> _verifyAppCheckTokenRest(
  googleapis_auth.AuthClient client,
  String projectId,
  String token,
) async {
  final url =
      'https://firebaseappcheck.googleapis.com/v1beta/projects/$projectId:verifyAppCheckToken';
  final response = await client.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'appCheckToken': token}),
  );

  if (response.statusCode != 200) {
    Map<String, dynamic>? jsonResponse;
    try {
      jsonResponse = switch (jsonDecode(response.body)) {
        Map<String, dynamic> m => m,
        _ => null,
      };
    } catch (_) {
      // Ignore parsing errors or type mismatches.
    }

    throw appcheck1.DetailedApiRequestError(
      response.statusCode,
      response.body,
      jsonResponse: jsonResponse,
    );
  }

  final Object? data;
  try {
    data = jsonDecode(response.body);
  } catch (e) {
    throw FirebaseAppCheckException(
      AppCheckErrorCode.unknownError,
      'Failed to parse JSON response from verifyAppCheckToken: $e',
    );
  }

  return switch (data) {
    {'alreadyConsumed': bool consumed} => consumed,
    _ => throw FirebaseAppCheckException(
      AppCheckErrorCode.unknownError,
      'Unexpected response format from verifyAppCheckToken',
    ),
  };
}
