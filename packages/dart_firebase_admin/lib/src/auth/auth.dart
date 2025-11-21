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
    // Close HTTP client if we created it (emulator mode)
    // In production mode, we use app.client which is closed by the app
    if (Environment.isAuthEmulatorEnabled()) {
      try {
        final client = await _authRequestHandler._httpClient._client;
        client.close();
      } catch (_) {
        // Ignore errors if client wasn't initialized
      }
    }
  }

  // TODO tenantManager
  // TODO projectConfigManager
}
