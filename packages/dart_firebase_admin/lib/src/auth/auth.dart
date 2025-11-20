part of '../auth.dart';

/// Auth service bound to the provided app.
/// An Auth instance can have multiple tenants.
class Auth extends _BaseAuth implements FirebaseService {
  /// Creates or returns the cached Auth instance for the given app.
  factory Auth(FirebaseApp app) {
    return app.getOrInitService(
      'auth',
      Auth._,
    ) as Auth;
  }

  Auth._(FirebaseApp app)
      : super(
          app: app,
          authRequestHandler: _AuthRequestHandler(app),
        );

  @override
  Future<void> delete() async {
    // Auth service cleanup if needed
  }

  // TODO tenantManager
  // TODO projectConfigManager
}
