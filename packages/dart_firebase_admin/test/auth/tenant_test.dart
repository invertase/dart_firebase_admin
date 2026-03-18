// Copyright 2024, the dart_firebase_admin project authors. All rights reserved.
// Use of this source code is governed by an Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';

void main() {
  group('Tenant', () {
    test('UpdateTenantRequest creates request with all fields', () {
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
        smsRegionConfig: const AllowByDefaultSmsRegionConfig(
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

    test('UpdateTenantRequest creates request with no fields', () {
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

    test('UpdateTenantRequest creates request with partial fields', () {
      final request = UpdateTenantRequest(
        displayName: 'Updated Name',
        anonymousSignInEnabled: false,
      );

      expect(request.displayName, equals('Updated Name'));
      expect(request.anonymousSignInEnabled, isFalse);
      expect(request.emailSignInConfig, isNull);
      expect(request.multiFactorConfig, isNull);
    });

    test('CreateTenantRequest is an alias for UpdateTenantRequest', () {
      final request = CreateTenantRequest(displayName: 'New Tenant');

      expect(request, isA<UpdateTenantRequest>());
      expect(request.displayName, equals('New Tenant'));
    });
  });
}
