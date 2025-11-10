part of '../auth.dart';

/// Auth service bound to the provided app.
/// An Auth instance can have multiple tenants.
class Auth extends _BaseAuth {
  Auth(FirebaseAdminApp app)
      : super(
          app: app,
          authRequestHandler: _AuthRequestHandler(app),
        );

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

  // TODO projectConfigManager
}
