// Firebase Tenant Integration Tests - Production Only
//
// These tests require production Firebase (GOOGLE_APPLICATION_CREDENTIALS)
// because they test features not available in the emulator:
// - Multi-factor authentication with TOTP (requires GCIP)
// - Tenant-scoped user operations (not fully supported in emulator)
//
// **IMPORTANT:** These tests use runZoned with zoneValues to temporarily
// disable the emulator environment variable. This allows them to run in the
// coverage script (which has emulator vars set) by connecting to production
// only for these specific tests.
//
// Run standalone with:
//   GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test test/auth/tenant_integration_prod_test.dart

import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import 'util/helpers.dart';

void main() {
  late Auth auth;
  late TenantManager tenantManager;

  setUp(() {
    if (!hasGoogleEnv) return;
    auth = createProductionAuth();
    tenantManager = auth.tenantManager;
  });

  tearDown(() async {
    if (!hasGoogleEnv) return;
    // Clean up tenants created in tests
    try {
      final result = await tenantManager.listTenants(maxResults: 100);
      await Future.wait([
        for (final tenant in result.tenants)
          tenantManager.deleteTenant(tenant.tenantId),
      ]);
    } catch (_) {
      // Ignore cleanup errors
    }
  });

  group('TenantManager (Production)', () {
    group('createTenant - TOTP/MFA', () {
      test(
        'creates tenant with TOTP provider config',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'TOTP Tenant',
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
          expect(tenant.displayName, equals('TOTP Tenant'));

          if (tenant.multiFactorConfig != null) {
            expect(
              tenant.multiFactorConfig!.state,
              equals(MultiFactorConfigState.enabled),
            );
            final providerConfigs = tenant.multiFactorConfig!.providerConfigs;
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
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'creates tenant with both SMS and TOTP MFA',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'Combined MFA Tenant',
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
            final providerConfigs = tenant.multiFactorConfig!.providerConfigs;
            if (providerConfigs != null && providerConfigs.isNotEmpty) {
              expect(
                providerConfigs[0].totpProviderConfig?.adjacentIntervals,
                equals(3),
              );
            }
          }
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });

    group('updateTenant - TOTP/MFA', () {
      test(
        'updates tenant with TOTP provider config',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(displayName: 'TOTP Update Test'),
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
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'updates tenant with combined SMS and TOTP MFA',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(displayName: 'Combined MFA Update Test'),
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
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });

    group('authForTenant - User Operations', () {
      test(
        'tenant auth can create users',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'User Creation Test',
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

          final user = await tenantAuth.createUser(CreateRequest(email: email));

          expect(user.uid, isNotEmpty);
          expect(user.email, equals(email));

          // Cleanup: Delete the user
          await tenantAuth.deleteUser(user.uid);
        },
        skip: hasGoogleEnv ? false : 'Requires production Firebase',
      );

      test(
        'tenant auth can list users',
        () async {
          final tenant = await tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'List Users Test',
              emailSignInConfig: EmailSignInProviderConfig(
                enabled: true,
                passwordRequired: false,
              ),
            ),
          );

          final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

          // Use unique emails to avoid conflicts with previous test runs
          final timestamp = DateTime.now().millisecondsSinceEpoch;

          // Create multiple users
          final user1 = await tenantAuth.createUser(
            CreateRequest(email: 'user1-$timestamp@example.com'),
          );
          final user2 = await tenantAuth.createUser(
            CreateRequest(email: 'user2-$timestamp@example.com'),
          );

          final users = await tenantAuth.listUsers();

          expect(users.users.length, equals(2));
          expect(
            users.users.map((u) => u.uid),
            containsAll([user1.uid, user2.uid]),
          );

          // Cleanup: Delete the users
          await tenantAuth.deleteUser(user1.uid);
          await tenantAuth.deleteUser(user2.uid);
        },
        skip: hasGoogleEnv ? false : 'Requires production Firebase',
      );
    });
  });
}
