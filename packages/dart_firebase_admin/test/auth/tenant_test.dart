// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

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
