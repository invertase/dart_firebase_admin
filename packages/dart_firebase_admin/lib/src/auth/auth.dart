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
//
// SPDX-License-Identifier: Apache-2.0

part of '../auth.dart';

/// Auth service bound to the provided app.
/// An Auth instance can have multiple tenants.
class Auth extends _BaseAuth implements FirebaseService {
  /// Creates or returns the cached Auth instance for the given app.
  @internal
  factory Auth.internal(
    FirebaseApp app, {
    AuthRequestHandler? requestHandler,
    FirebaseTokenVerifier? idTokenVerifier,
    FirebaseTokenVerifier? sessionCookieVerifier,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.auth.name,
      (app) => Auth._(
        app,
        requestHandler: requestHandler,
        idTokenVerifier: idTokenVerifier,
        sessionCookieVerifier: sessionCookieVerifier,
      ),
    );
  }

  Auth._(
    FirebaseApp app, {
    AuthRequestHandler? requestHandler,
    super.idTokenVerifier,
    super.sessionCookieVerifier,
  }) : super(
         app: app,
         authRequestHandler: requestHandler ?? AuthRequestHandler(app),
       );

  @override
  Future<void> delete() async {
    // Close HTTP client if we created it (emulator mode)
    // In production mode, we use app.client which is closed by the app
    if (Environment.isAuthEmulatorEnabled()) {
      try {
        final client = await _authRequestHandler.httpClient.client;
        client.close();
      } catch (_) {
        // Ignore errors if client wasn't initialized
      }
    }
  }

  TenantManager? _tenantManager;

  /// The [TenantManager] instance associated with the current project.
  ///
  /// This provides tenant management capabilities for multi-tenant applications.
  /// Multi-tenancy support requires Google Cloud's Identity Platform (GCIP).
  /// To learn more about GCIP, including pricing and features, see the
  /// [GCIP documentation](https://cloud.google.com/identity-platform).
  TenantManager get tenantManager {
    return _tenantManager ??= TenantManager._(app);
  }

  ProjectConfigManager? _projectConfigManager;

  /// The [ProjectConfigManager] instance associated with the current project.
  ///
  /// This provides methods to get and update the project configuration,
  /// including SMS regions, multi-factor authentication, reCAPTCHA, password policy,
  /// email privacy, and mobile links settings.
  ProjectConfigManager get projectConfigManager {
    return _projectConfigManager ??= ProjectConfigManager._(app);
  }
}
