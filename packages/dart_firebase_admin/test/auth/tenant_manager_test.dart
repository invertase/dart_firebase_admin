import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:test/test.dart';

void main() {
  group('TenantManager', () {
    group('authForTenant', () {
      test('returns TenantAwareAuth instance for valid tenant ID', () {
        final app = _createMockApp();
        final auth = Auth(app);
        final tenantManager = auth.tenantManager;

        final tenantAuth = tenantManager.authForTenant('test-tenant-id');

        expect(tenantAuth, isA<TenantAwareAuth>());
        expect(tenantAuth.tenantId, equals('test-tenant-id'));
      });

      test('returns cached instance for same tenant ID', () {
        final app = _createMockApp();
        final auth = Auth(app);
        final tenantManager = auth.tenantManager;

        final tenantAuth1 = tenantManager.authForTenant('test-tenant-id');
        final tenantAuth2 = tenantManager.authForTenant('test-tenant-id');

        expect(identical(tenantAuth1, tenantAuth2), isTrue);
      });

      test('returns different instances for different tenant IDs', () {
        final app = _createMockApp();
        final auth = Auth(app);
        final tenantManager = auth.tenantManager;

        final tenantAuth1 = tenantManager.authForTenant('tenant-1');
        final tenantAuth2 = tenantManager.authForTenant('tenant-2');

        expect(identical(tenantAuth1, tenantAuth2), isFalse);
        expect(tenantAuth1.tenantId, equals('tenant-1'));
        expect(tenantAuth2.tenantId, equals('tenant-2'));
      });

      test('throws on empty tenant ID', () {
        final app = _createMockApp();
        final auth = Auth(app);
        final tenantManager = auth.tenantManager;

        expect(
          () => tenantManager.authForTenant(''),
          throwsA(isA<FirebaseAuthAdminException>()),
        );
      });
    });

    test('tenantManager getter returns same instance', () {
      final app = _createMockApp();
      final auth = Auth(app);

      final tenantManager1 = auth.tenantManager;
      final tenantManager2 = auth.tenantManager;

      expect(identical(tenantManager1, tenantManager2), isTrue);
    });
  });

  group('ListTenantsResult', () {
    test('creates result with page token', () {
      final tenants = <Tenant>[];
      const pageToken = 'next-page-token';

      final result = ListTenantsResult(
        tenants: tenants,
        pageToken: pageToken,
      );

      expect(result.tenants, equals(tenants));
      expect(result.pageToken, equals(pageToken));
    });

    test('creates result without page token', () {
      final tenants = <Tenant>[];

      final result = ListTenantsResult(tenants: tenants);

      expect(result.tenants, equals(tenants));
      expect(result.pageToken, isNull);
    });

    test('creates result with empty tenants list', () {
      final result = ListTenantsResult(tenants: []);

      expect(result.tenants, isEmpty);
      expect(result.pageToken, isNull);
    });
  });

  group('TenantAwareAuth', () {
    test('has correct tenant ID', () {
      final app = _createMockApp();
      final auth = Auth(app);
      final tenantManager = auth.tenantManager;

      final tenantAuth = tenantManager.authForTenant('test-tenant-id');

      expect(tenantAuth.tenantId, equals('test-tenant-id'));
    });

    test('is instance of BaseAuth', () {
      final app = _createMockApp();
      final auth = Auth(app);
      final tenantManager = auth.tenantManager;

      final tenantAuth = tenantManager.authForTenant('test-tenant-id');

      // TenantAwareAuth extends _BaseAuth which provides all auth methods
      expect(tenantAuth, isA<TenantAwareAuth>());
    });
  });

  group('UpdateTenantRequest', () {
    test('creates request with all fields', () {
      final request = UpdateTenantRequest(
        displayName: 'Test Tenant',
        emailSignInConfig: EmailSignInProviderConfig(
          enabled: true,
          passwordRequired: false,
        ),
        anonymousSignInEnabled: true,
        multiFactorConfig: MultiFactorConfig(
          state: MultiFactorConfigState.enabled,
          factorIds: ['phone'],
        ),
        testPhoneNumbers: {'+1234567890': '123456'},
        smsRegionConfig: AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US'],
        ),
        recaptchaConfig: RecaptchaConfig(
          emailPasswordEnforcementState:
              RecaptchaProviderEnforcementState.enforce,
        ),
        passwordPolicyConfig: PasswordPolicyConfig(
          enforcementState: PasswordPolicyEnforcementState.enforce,
        ),
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: true,
        ),
      );

      expect(request.displayName, equals('Test Tenant'));
      expect(request.emailSignInConfig, isNotNull);
      expect(request.anonymousSignInEnabled, isTrue);
      expect(request.multiFactorConfig, isNotNull);
      expect(request.testPhoneNumbers, isNotNull);
      expect(request.smsRegionConfig, isNotNull);
      expect(request.recaptchaConfig, isNotNull);
      expect(request.passwordPolicyConfig, isNotNull);
      expect(request.emailPrivacyConfig, isNotNull);
    });

    test('creates request with no fields', () {
      final request = UpdateTenantRequest();

      expect(request.displayName, isNull);
      expect(request.emailSignInConfig, isNull);
      expect(request.anonymousSignInEnabled, isNull);
      expect(request.multiFactorConfig, isNull);
      expect(request.testPhoneNumbers, isNull);
      expect(request.smsRegionConfig, isNull);
      expect(request.recaptchaConfig, isNull);
      expect(request.passwordPolicyConfig, isNull);
      expect(request.emailPrivacyConfig, isNull);
    });
  });

  group('CreateTenantRequest', () {
    test('is an alias for UpdateTenantRequest', () {
      final request = CreateTenantRequest(
        displayName: 'New Tenant',
      );

      expect(request, isA<UpdateTenantRequest>());
      expect(request.displayName, equals('New Tenant'));
    });
  });
}

// Mock app for testing
FirebaseAdminApp _createMockApp() {
  return FirebaseAdminApp.initializeApp(
    'test-project',
    _MockCredential(),
  );
}

class _MockCredential implements Credential {
  @override
  Future<String> getAccessToken() async => 'mock-token';

  @override
  String? get serviceAccountId => null;

  @override
  auth.ServiceAccountCredentials? get serviceAccountCredentials => null;
}
