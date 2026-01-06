// Firebase Tenant Integration Tests - Production Only
//
// These tests require production Firebase (GOOGLE_APPLICATION_CREDENTIALS)
// because they test features not available in the emulator:
// - Multi-factor authentication with TOTP (requires GCIP)
// - Tenant-scoped user operations (not fully supported in emulator)
//
// **REQUIREMENTS:**
// 1. Production Firebase project with multi-tenancy ENABLED
//    - Enable multi-tenancy in Firebase Console: Authentication > Settings > Multi-tenancy
//    - Or enable Google Cloud Identity Platform (GCIP) for your project
// 2. GOOGLE_APPLICATION_CREDENTIALS environment variable set
//
// **IMPORTANT:** These tests use runZoned with zoneValues to temporarily
// disable the emulator environment variable. This allows them to run in the
// coverage script (which has emulator vars set) by connecting to production
// only for these specific tests.
//
// For basic tenant operations that work with the emulator, see tenant_integration_test.dart
//
// Run standalone with:
//   GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test test/auth/tenant_integration_prod_test.dart

import 'dart:async';
import 'dart:io';

import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:googleapis/identitytoolkit/v1.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../google_cloud_firestore/util/helpers.dart';

const _uid = Uuid();

void main() {
  group('TenantManager (Production)', () {
    group('createTenant - TOTP/MFA', () {
      test(
        'creates tenant with TOTP provider config',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'TOTP-Tenant',
                  multiFactorConfig: MultiFactorConfig(
                    state: MultiFactorConfigState.enabled,
                    providerConfigs: [
                      MultiFactorProviderConfig(
                        state: MultiFactorConfigState.enabled,
                        totpProviderConfig: TotpMultiFactorProviderConfig(
                          adjacentIntervals: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              expect(tenant.tenantId, isNotEmpty);
              expect(tenant.displayName, equals('TOTP-Tenant'));

              if (tenant.multiFactorConfig != null) {
                expect(
                  tenant.multiFactorConfig!.state,
                  equals(MultiFactorConfigState.enabled),
                );
                final providerConfigs =
                    tenant.multiFactorConfig!.providerConfigs;
                if (providerConfigs != null && providerConfigs.isNotEmpty) {
                  expect(
                    providerConfigs[0].state,
                    equals(MultiFactorConfigState.enabled),
                  );
                  expect(
                    providerConfigs[0].totpProviderConfig?.adjacentIntervals,
                    equals(5),
                  );
                }
              }
            } finally {
              if (tenant != null) {
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'creates tenant with both SMS and TOTP MFA',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'Combined-MFA-Tenant',
                  multiFactorConfig: MultiFactorConfig(
                    state: MultiFactorConfigState.enabled,
                    factorIds: ['phone'],
                    providerConfigs: [
                      MultiFactorProviderConfig(
                        state: MultiFactorConfigState.enabled,
                        totpProviderConfig: TotpMultiFactorProviderConfig(
                          adjacentIntervals: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              expect(tenant.tenantId, isNotEmpty);

              if (tenant.multiFactorConfig != null) {
                expect(
                  tenant.multiFactorConfig!.state,
                  equals(MultiFactorConfigState.enabled),
                );
                expect(tenant.multiFactorConfig!.factorIds, contains('phone'));
                final providerConfigs =
                    tenant.multiFactorConfig!.providerConfigs;
                if (providerConfigs != null && providerConfigs.isNotEmpty) {
                  expect(
                    providerConfigs[0].totpProviderConfig?.adjacentIntervals,
                    equals(3),
                  );
                }
              }
            } finally {
              if (tenant != null) {
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });

    group('updateTenant - TOTP/MFA', () {
      test(
        'updates tenant with TOTP provider config',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(displayName: 'TOTP-Update-Test'),
              );

              final updatedTenant = await tenantManager.updateTenant(
                tenant.tenantId,
                UpdateTenantRequest(
                  multiFactorConfig: MultiFactorConfig(
                    state: MultiFactorConfigState.enabled,
                    providerConfigs: [
                      MultiFactorProviderConfig(
                        state: MultiFactorConfigState.enabled,
                        totpProviderConfig: TotpMultiFactorProviderConfig(
                          adjacentIntervals: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              expect(updatedTenant.tenantId, equals(tenant.tenantId));

              if (updatedTenant.multiFactorConfig != null) {
                final providerConfigs =
                    updatedTenant.multiFactorConfig!.providerConfigs;
                if (providerConfigs != null && providerConfigs.isNotEmpty) {
                  expect(
                    providerConfigs[0].totpProviderConfig?.adjacentIntervals,
                    equals(7),
                  );
                }
              }
            } finally {
              if (tenant != null) {
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'updates tenant with combined SMS and TOTP MFA',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(displayName: 'Combined-MFA-Update'),
              );

              final updatedTenant = await tenantManager.updateTenant(
                tenant.tenantId,
                UpdateTenantRequest(
                  multiFactorConfig: MultiFactorConfig(
                    state: MultiFactorConfigState.enabled,
                    factorIds: ['phone'],
                    providerConfigs: [
                      MultiFactorProviderConfig(
                        state: MultiFactorConfigState.enabled,
                        totpProviderConfig: TotpMultiFactorProviderConfig(
                          adjacentIntervals: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              expect(updatedTenant.tenantId, equals(tenant.tenantId));

              if (updatedTenant.multiFactorConfig != null) {
                expect(
                  updatedTenant.multiFactorConfig!.state,
                  equals(MultiFactorConfigState.enabled),
                );
                expect(
                  updatedTenant.multiFactorConfig!.factorIds,
                  contains('phone'),
                );
                final providerConfigs =
                    updatedTenant.multiFactorConfig!.providerConfigs;
                if (providerConfigs != null && providerConfigs.isNotEmpty) {
                  expect(
                    providerConfigs[0].totpProviderConfig?.adjacentIntervals,
                    equals(5),
                  );
                }
              }
            } finally {
              if (tenant != null) {
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });

    group('authForTenant - User Operations', () {
      test(
        'tenant auth can create users',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            UserRecord? user;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'User-Creation-Test',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

              // Use unique email to avoid conflicts with previous test runs
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final email = 'tenant-user-$timestamp@example.com';

              user = await tenantAuth.createUser(CreateRequest(email: email));

              expect(user.uid, isNotEmpty);
              expect(user.email, equals(email));
            } finally {
              if (user != null && tenant != null) {
                final tenantAuth = tenantManager.authForTenant(tenant.tenantId);
                await tenantAuth.deleteUser(user.uid);
              }
              if (tenant != null) {
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv ? false : 'Requires production Firebase',
      );

      test(
        'tenant auth can list users',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            UserRecord? user1;
            UserRecord? user2;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'List-Users-Test',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

              // Clean up any existing users in the tenant from previous test runs
              final existingUsers = await tenantAuth.listUsers();
              await Future.wait([
                for (final existingUser in existingUsers.users)
                  tenantAuth.deleteUser(existingUser.uid),
              ]);

              // Use unique emails to avoid conflicts with previous test runs
              final timestamp = DateTime.now().millisecondsSinceEpoch;

              // Create multiple users
              user1 = await tenantAuth.createUser(
                CreateRequest(email: 'user1-$timestamp@example.com'),
              );
              user2 = await tenantAuth.createUser(
                CreateRequest(email: 'user2-$timestamp@example.com'),
              );

              final users = await tenantAuth.listUsers();

              expect(users.users.length, equals(2));
              expect(
                users.users.map((u) => u.uid),
                containsAll([user1.uid, user2.uid]),
              );
            } finally {
              if (tenant != null) {
                final tenantAuth = tenantManager.authForTenant(tenant.tenantId);
                await Future.wait([
                  if (user1 != null) tenantAuth.deleteUser(user1.uid),
                  if (user2 != null) tenantAuth.deleteUser(user2.uid),
                ]);
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv ? false : 'Requires production Firebase',
      );
    });

    group('authForTenant - Session Cookies', () {
      test(
        'tenant auth creates and verifies a valid session cookie',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            UserRecord? user;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'Session-Cookie-Test',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

              // Helper function to exchange custom token for ID token (tenant-scoped)
              Future<String> getIdTokenFromCustomToken(
                String customToken,
                String tenantId,
              ) async {
                final client = await testAuth.app.client;
                final api = IdentityToolkitApi(client);

                final request =
                    GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                      token: customToken,
                      returnSecureToken: true,
                      tenantId: tenantId,
                    );

                final response = await api.accounts.signInWithCustomToken(
                  request,
                );

                if (response.idToken == null || response.idToken!.isEmpty) {
                  throw Exception(
                    'Failed to exchange custom token for ID token: No idToken in response',
                  );
                }

                return response.idToken!;
              }

              user = await tenantAuth.createUser(CreateRequest(uid: _uid.v4()));

              final customToken = await tenantAuth.createCustomToken(user.uid);
              final idToken = await getIdTokenFromCustomToken(
                customToken,
                tenant.tenantId,
              );

              const expiresIn = 24 * 60 * 60 * 1000; // 24 hours
              final sessionCookie = await tenantAuth.createSessionCookie(
                idToken,
                const SessionCookieOptions(expiresIn: expiresIn),
              );

              expect(sessionCookie, isNotEmpty);

              final decodedToken = await tenantAuth.verifySessionCookie(
                sessionCookie,
              );
              expect(decodedToken.uid, equals(user.uid));
              expect(decodedToken.iss, contains('session.firebase.google.com'));
              expect(decodedToken.firebase.tenant, equals(tenant.tenantId));
            } finally {
              if (tenant != null) {
                final tenantAuth = tenantManager.authForTenant(tenant.tenantId);
                if (user != null) {
                  await tenantAuth.deleteUser(user.uid);
                }
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Session cookies require GCIP (not available in emulator)',
      );

      test(
        'tenant auth creates a revocable session cookie',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant;
            UserRecord? user;
            try {
              tenant = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'RevocableSession',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

              // Helper function to exchange custom token for ID token (tenant-scoped)
              Future<String> getIdTokenFromCustomToken(
                String customToken,
                String tenantId,
              ) async {
                final client = await testAuth.app.client;
                final api = IdentityToolkitApi(client);

                final request =
                    GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                      token: customToken,
                      returnSecureToken: true,
                      tenantId: tenantId,
                    );

                final response = await api.accounts.signInWithCustomToken(
                  request,
                );

                if (response.idToken == null || response.idToken!.isEmpty) {
                  throw Exception(
                    'Failed to exchange custom token for ID token: No idToken in response',
                  );
                }

                return response.idToken!;
              }

              user = await tenantAuth.createUser(CreateRequest(uid: _uid.v4()));

              final customToken = await tenantAuth.createCustomToken(user.uid);
              final idToken = await getIdTokenFromCustomToken(
                customToken,
                tenant.tenantId,
              );

              const expiresIn = 24 * 60 * 60 * 1000;
              final sessionCookie = await tenantAuth.createSessionCookie(
                idToken,
                const SessionCookieOptions(expiresIn: expiresIn),
              );

              final decodedToken = await tenantAuth.verifySessionCookie(
                sessionCookie,
              );
              expect(decodedToken.uid, equals(user.uid));
              expect(decodedToken.firebase.tenant, equals(tenant.tenantId));

              await Future<void>.delayed(const Duration(seconds: 2));
              await tenantAuth.revokeRefreshTokens(user.uid);

              // Without checkRevoked, should not throw
              await tenantAuth.verifySessionCookie(sessionCookie);

              // With checkRevoked: true, should throw
              await expectLater(
                () => tenantAuth.verifySessionCookie(
                  sessionCookie,
                  checkRevoked: true,
                ),
                throwsA(
                  isA<FirebaseAuthAdminException>().having(
                    (e) => e.code,
                    'code',
                    'auth/session-cookie-revoked',
                  ),
                ),
              );
            } finally {
              if (tenant != null) {
                final tenantAuth = tenantManager.authForTenant(tenant.tenantId);
                if (user != null) {
                  await tenantAuth.deleteUser(user.uid);
                }
                await tenantManager.deleteTenant(tenant.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Session cookies require GCIP (not available in emulator)',
      );

      test(
        'tenant auth verifySessionCookie rejects session cookie from different tenant',
        () {
          // Remove emulator env var from the zone environment
          final prodEnv = Map<String, String>.from(Platform.environment);
          prodEnv.remove(Environment.firebaseAuthEmulatorHost);

          return runZoned(() async {
            final appName =
                'prod-test-${DateTime.now().microsecondsSinceEpoch}';
            final app = FirebaseApp.initializeApp(name: appName);
            final testAuth = Auth.internal(app);
            final tenantManager = testAuth.tenantManager;

            Tenant? tenant1;
            Tenant? tenant2;
            UserRecord? user1;
            UserRecord? user2;
            try {
              // Create two tenants
              tenant1 = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'Tenant1SessionCookie',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              tenant2 = await tenantManager.createTenant(
                CreateTenantRequest(
                  displayName: 'Tenant2SessionCookie',
                  emailSignInConfig: EmailSignInProviderConfig(
                    enabled: true,
                    passwordRequired: false,
                  ),
                ),
              );

              final tenantAuth1 = tenantManager.authForTenant(tenant1.tenantId);
              final tenantAuth2 = tenantManager.authForTenant(tenant2.tenantId);

              // Helper function to exchange custom token for ID token (tenant-scoped)
              Future<String> getIdTokenFromCustomToken(
                String customToken,
                String tenantId,
              ) async {
                final client = await testAuth.app.client;
                final api = IdentityToolkitApi(client);

                final request =
                    GoogleCloudIdentitytoolkitV1SignInWithCustomTokenRequest(
                      token: customToken,
                      returnSecureToken: true,
                      tenantId: tenantId,
                    );

                final response = await api.accounts.signInWithCustomToken(
                  request,
                );

                if (response.idToken == null || response.idToken!.isEmpty) {
                  throw Exception(
                    'Failed to exchange custom token for ID token: No idToken in response',
                  );
                }

                return response.idToken!;
              }

              // Create users in both tenants
              user1 = await tenantAuth1.createUser(
                CreateRequest(uid: _uid.v4()),
              );
              user2 = await tenantAuth2.createUser(
                CreateRequest(uid: _uid.v4()),
              );

              // Create session cookie for tenant1 user
              final customToken1 = await tenantAuth1.createCustomToken(
                user1.uid,
              );
              final idToken1 = await getIdTokenFromCustomToken(
                customToken1,
                tenant1.tenantId,
              );

              const expiresIn = 24 * 60 * 60 * 1000;
              final sessionCookie1 = await tenantAuth1.createSessionCookie(
                idToken1,
                const SessionCookieOptions(expiresIn: expiresIn),
              );

              // Try to verify tenant1's session cookie with tenant2's auth
              // This should fail because the tenant IDs don't match
              await expectLater(
                () => tenantAuth2.verifySessionCookie(sessionCookie1),
                throwsA(
                  isA<FirebaseAuthAdminException>().having(
                    (e) => e.code,
                    'code',
                    'auth/mismatching-tenant-id',
                  ),
                ),
              );
            } finally {
              if (tenant1 != null) {
                final tenantAuth1 = tenantManager.authForTenant(
                  tenant1.tenantId,
                );
                if (user1 != null) {
                  await tenantAuth1.deleteUser(user1.uid);
                }
                await tenantManager.deleteTenant(tenant1.tenantId);
              }
              if (tenant2 != null) {
                final tenantAuth2 = tenantManager.authForTenant(
                  tenant2.tenantId,
                );
                if (user2 != null) {
                  await tenantAuth2.deleteUser(user2.uid);
                }
                await tenantManager.deleteTenant(tenant2.tenantId);
              }
              await app.close();
            }
          }, zoneValues: {envSymbol: prodEnv});
        },
        skip: hasGoogleEnv
            ? false
            : 'Session cookies require GCIP (not available in emulator)',
      );
    });
  });
}
