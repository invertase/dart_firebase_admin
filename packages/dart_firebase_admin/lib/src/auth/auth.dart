part of '../auth.dart';

/// Auth service bound to the provided app.
/// An Auth instance can have multiple tenants.
class Auth extends _BaseAuth implements FirebaseService {
  /// Creates or returns the cached Auth instance for the given app.
  factory Auth(
    FirebaseApp app, {
    @internal AuthRequestHandler? requestHandler,
  }) {
    return app.getOrInitService(
      FirebaseServiceType.auth.name,
      (app) => Auth._(app, requestHandler: requestHandler),
    );
  }

  Auth._(FirebaseApp app, {@internal AuthRequestHandler? requestHandler})
    : super(
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
