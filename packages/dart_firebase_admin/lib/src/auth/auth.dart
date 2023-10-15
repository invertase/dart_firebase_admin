part of '../auth.dart';

/// Auth service bound to the provided app.
/// An Auth instance can have multiple tenants.
class Auth extends _BaseAuth {
  Auth(FirebaseAdminApp app)
      : super(
          app: app,
          authRequestHandler: _AuthRequestHandler(app),
        );

  // TODO tenantManager
  // TODO projectConfigManager
}
