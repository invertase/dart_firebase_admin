// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

part of '../app.dart';

/// HTTP client wrapper that adds Firebase and Google API client headers for usage tracking.
///
/// Wraps another HTTP client and injects:
/// - `X-Firebase-Client: fire-admin-dart/{version}`
/// - `X-Goog-Api-Client: gl-dart/{dartVersion} fire-admin-dart/{version}`
/// into every outgoing request so Firebase backend services can identify the SDK.
@internal
class FirebaseUserAgentClient extends BaseClient
    implements googleapis_auth.AuthClient {
  FirebaseUserAgentClient(this._client);

  final googleapis_auth.AuthClient _client;

  @override
  googleapis_auth.AccessCredentials get credentials => _client.credentials;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['X-Firebase-Client'] = 'fire-admin-dart/$packageVersion';
    request.headers['X-Goog-Api-Client'] =
        'gl-dart/$dartVersion fire-admin-dart/$packageVersion';
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
