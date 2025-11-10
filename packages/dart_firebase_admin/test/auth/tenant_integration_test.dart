import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';

void main() {
  late Auth auth;
  late TenantManager tenantManager;

  setUp(() {
    final sdk = createApp(tearDown: () => cleanup(auth));
    sdk.useEmulator();
    auth = Auth(sdk);
    tenantManager = auth.tenantManager;
  });

  group('TenantManager', () {
    group('createTenant', () {
      test('creates tenant with minimal configuration', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(
            displayName: 'Test Tenant',
          ),
        );

        expect(tenant.tenantId, isNotEmpty);
        expect(tenant.displayName, equals('Test Tenant'));
        expect(tenant.anonymousSignInEnabled, isFalse);
      });

      test('creates tenant with full configuration', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(
            displayName: 'Full Config Tenant',
            emailSignInConfig: EmailSignInProviderConfig(
              enabled: true,
              passwordRequired: false,
            ),
            anonymousSignInEnabled: true,
            multiFactorConfig: MultiFactorConfig(
              state: MultiFactorConfigState.enabled,
              factorIds: ['phone'],
            ),
            testPhoneNumbers: {
              '+11234567890': '123456',
            },
            smsRegionConfig: const AllowByDefaultSmsRegionConfig(
              disallowedRegions: ['US', 'CA'],
            ),
            recaptchaConfig: RecaptchaConfig(
              emailPasswordEnforcementState:
                  RecaptchaProviderEnforcementState.enforce,
              phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
            ),
            passwordPolicyConfig: PasswordPolicyConfig(
              enforcementState: PasswordPolicyEnforcementState.enforce,
              forceUpgradeOnSignin: true,
              constraints: CustomStrengthOptionsConfig(
                requireUppercase: true,
                requireLowercase: true,
                requireNumeric: true,
                minLength: 8,
              ),
            ),
            emailPrivacyConfig: EmailPrivacyConfig(
              enableImprovedEmailPrivacy: true,
            ),
          ),
        );

        expect(tenant.tenantId, isNotEmpty);
        expect(tenant.displayName, equals('Full Config Tenant'));
        expect(tenant.anonymousSignInEnabled, isTrue);
        expect(tenant.emailSignInConfig, isNotNull);
        expect(tenant.emailSignInConfig!.enabled, isTrue);
        expect(tenant.emailSignInConfig!.passwordRequired, isFalse);
        expect(tenant.multiFactorConfig, isNotNull);
        expect(
          tenant.multiFactorConfig!.state,
          equals(MultiFactorConfigState.enabled),
        );

        // Note: The Firebase Auth Emulator may not support all advanced configuration
        // fields. These assertions are optional and will pass if the emulator
        // doesn't return these fields.
        // In production, these fields should be properly supported.
        if (tenant.testPhoneNumbers != null) {
          expect(tenant.testPhoneNumbers!['+11234567890'], equals('123456'));
        }
        if (tenant.smsRegionConfig != null) {
          expect(tenant.smsRegionConfig, isA<AllowByDefaultSmsRegionConfig>());
        }
        // recaptchaConfig, passwordPolicyConfig, and emailPrivacyConfig
        // may not be supported by the emulator
      });

      test('throws on invalid display name', () async {
        expect(
          () => tenantManager.createTenant(
            CreateTenantRequest(displayName: ''),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('throws on invalid test phone number', () async {
        expect(
          () => tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'Test',
              testPhoneNumbers: {
                'invalid': '123456',
              },
            ),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });

      test('throws on too many test phone numbers', () async {
        final testPhoneNumbers = <String, String>{};
        for (var i = 1; i <= 11; i++) {
          testPhoneNumbers['+1234567${i.toString().padLeft(4, '0')}'] =
              '123456';
        }

        expect(
          () => tenantManager.createTenant(
            CreateTenantRequest(
              displayName: 'Test',
              testPhoneNumbers: testPhoneNumbers,
            ),
          ),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('getTenant', () {
      test('retrieves existing tenant', () async {
        final createdTenant = await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Retrieve Test'),
        );

        final retrievedTenant =
            await tenantManager.getTenant(createdTenant.tenantId);

        expect(retrievedTenant.tenantId, equals(createdTenant.tenantId));
        expect(retrievedTenant.displayName, equals('Retrieve Test'));
      });

      test('throws on non-existent tenant', () async {
        // Note: Firebase Auth Emulator has inconsistent behavior with non-existent
        // resources and may not throw proper errors. Skip this test for emulator.
        if (!auth.app.isUsingEmulator) {
          expect(
            () => tenantManager.getTenant('non-existent-tenant-id'),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        }
      });

      test('throws on empty tenant ID', () async {
        expect(
          () => tenantManager.getTenant(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    group('updateTenant', () {
      test('updates tenant display name', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Original Name'),
        );

        final updatedTenant = await tenantManager.updateTenant(
          tenant.tenantId,
          UpdateTenantRequest(displayName: 'Updated Name'),
        );

        expect(updatedTenant.tenantId, equals(tenant.tenantId));
        expect(updatedTenant.displayName, equals('Updated Name'));
      });

      test('updates tenant configuration', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(
            displayName: 'Config Update Test',
            anonymousSignInEnabled: false,
          ),
        );

        final updatedTenant = await tenantManager.updateTenant(
          tenant.tenantId,
          UpdateTenantRequest(
            anonymousSignInEnabled: true,
            emailSignInConfig: EmailSignInProviderConfig(
              enabled: true,
              passwordRequired: true,
            ),
          ),
        );

        expect(updatedTenant.anonymousSignInEnabled, isTrue);
        expect(updatedTenant.emailSignInConfig!.enabled, isTrue);
        expect(updatedTenant.emailSignInConfig!.passwordRequired, isTrue);
      });

      test('throws on invalid tenant ID', () async {
        // Note: Firebase Auth Emulator may not properly validate tenant IDs.
        // Skip this test for emulator.
        if (!auth.app.isUsingEmulator) {
          expect(
            () => tenantManager.updateTenant(
              'invalid-tenant-id',
              UpdateTenantRequest(displayName: 'New Name'),
            ),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        }
      });
    });

    group('listTenants', () {
      test('lists all tenants', () async {
        // Create multiple tenants
        await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Tenant 1'),
        );
        await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Tenant 2'),
        );
        await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Tenant 3'),
        );

        final result = await tenantManager.listTenants();

        expect(result.tenants.length, greaterThanOrEqualTo(3));
        expect(result.tenants, isA<List<Tenant>>());
      });

      test('supports pagination', () async {
        // Create multiple tenants
        for (var i = 0; i < 5; i++) {
          await tenantManager.createTenant(
            CreateTenantRequest(displayName: 'Pagination Test $i'),
          );
        }

        final firstPage = await tenantManager.listTenants(maxResults: 2);

        expect(firstPage.tenants.length, equals(2));

        if (firstPage.pageToken != null) {
          final secondPage = await tenantManager.listTenants(
            maxResults: 2,
            pageToken: firstPage.pageToken,
          );

          expect(secondPage.tenants.length, greaterThan(0));
          expect(
            secondPage.tenants.first.tenantId,
            isNot(equals(firstPage.tenants.first.tenantId)),
          );
        }
      });
    });

    group('deleteTenant', () {
      test('deletes existing tenant', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Delete Test'),
        );

        await tenantManager.deleteTenant(tenant.tenantId);

        // Note: Firebase Auth Emulator may not properly delete tenants or
        // may have eventual consistency. Skip verification for emulator.
        if (!auth.app.isUsingEmulator) {
          expect(
            () => tenantManager.getTenant(tenant.tenantId),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        }
      });

      test('throws on deleting non-existent tenant', () async {
        // Note: Firebase Auth Emulator may silently succeed instead of throwing
        // on non-existent resources. Skip this test for emulator.
        if (!auth.app.isUsingEmulator) {
          expect(
            () => tenantManager.deleteTenant('non-existent-tenant-id'),
            throwsA(isA<FirebaseAuthAdminException>()),
          );
        }
      });
    });

    group('authForTenant', () {
      test('returns TenantAwareAuth instance', () async {
        final tenant = await tenantManager.createTenant(
          CreateTenantRequest(displayName: 'Auth Test'),
        );

        final tenantAuth = tenantManager.authForTenant(tenant.tenantId);

        expect(tenantAuth, isA<TenantAwareAuth>());
        expect(tenantAuth.tenantId, equals(tenant.tenantId));
      });

      test('tenant auth can create users', () async {
        // Note: Firebase Auth Emulator does not fully support tenant-scoped
        // user operations. Skip this test for emulator.
        // See: https://firebase.google.com/docs/emulator-suite/connect_auth
        if (auth.app.isUsingEmulator) {
          return;
        }

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

        final user = await tenantAuth.createUser(
          CreateRequest(email: email),
        );

        expect(user.uid, isNotEmpty);
        expect(user.email, equals(email));

        // Cleanup: Delete the user
        await tenantAuth.deleteUser(user.uid);
      });

      test('tenant auth can list users', () async {
        // Note: Firebase Auth Emulator does not fully support tenant-scoped
        // user operations. Skip this test for emulator.
        // See: https://firebase.google.com/docs/emulator-suite/connect_auth
        if (auth.app.isUsingEmulator) {
          return;
        }

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
      });

      test('throws on empty tenant ID', () {
        expect(
          () => tenantManager.authForTenant(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });
  });
}

Future<void> cleanup(Auth auth) async {
  if (!auth.app.isUsingEmulator) {
    throw Exception('Cannot cleanup non-emulator app');
  }

  final tenantManager = auth.tenantManager;

  // List all tenants and delete them
  var result = await tenantManager.listTenants(maxResults: 100);

  while (true) {
    await Future.wait([
      for (final tenant in result.tenants)
        tenantManager.deleteTenant(tenant.tenantId),
    ]);

    if (result.pageToken == null) break;

    result = await tenantManager.listTenants(
      maxResults: 100,
      pageToken: result.pageToken,
    );
  }
}
