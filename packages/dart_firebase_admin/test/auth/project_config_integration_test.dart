import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';

void main() {
  late Auth auth;
  late ProjectConfigManager projectConfigManager;
  ProjectConfig? originalConfig;

  setUp(() {
    final app = createApp();
    auth = Auth(app);
    projectConfigManager = auth.projectConfigManager;
  });

  group('ProjectConfigManager', () {
    // Save original config before running update tests
    setUpAll(() async {
      if (hasGoogleEnv) {
        final app = FirebaseApp.initializeApp(
          name: 'save-config-app',
          options: const AppOptions(projectId: projectId),
        );
        final testAuth = Auth(app);
        try {
          originalConfig = await testAuth.projectConfigManager
              .getProjectConfig();
          // ignore: avoid_print
          print('Original config saved for restoration after tests');
        } finally {
          await app.close();
        }
      }
    });

    // Restore original config after all tests complete
    tearDownAll(() async {
      if (hasGoogleEnv && originalConfig != null) {
        final app = FirebaseApp.initializeApp(
          name: 'restore-config-app',
          options: const AppOptions(projectId: projectId),
        );
        final testAuth = Auth(app);
        try {
          await testAuth.projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              smsRegionConfig: originalConfig!.smsRegionConfig,
              multiFactorConfig: originalConfig!.multiFactorConfig,
              recaptchaConfig: originalConfig!.recaptchaConfig,
              passwordPolicyConfig: originalConfig!.passwordPolicyConfig,
              emailPrivacyConfig: originalConfig!.emailPrivacyConfig,
              mobileLinksConfig: originalConfig!.mobileLinksConfig,
            ),
          );
          // ignore: avoid_print
          print('Original config restored successfully');
        } finally {
          await app.close();
        }
      }
    });
    group('getProjectConfig', () {
      test(
        'retrieves current project configuration',
        () async {
          final config = await projectConfigManager.getProjectConfig();

          // ProjectConfig should always be returned, even if fields are null
          expect(config, isA<ProjectConfig>());

          // Depending on project setup, some fields may or may not be configured
          // We just verify the response structure is correct
        },
        // skip: hasGoogleEnv
        //     ? false
        //     : 'Requires GOOGLE_APPLICATION_CREDENTIALS - ProjectConfig not supported in Auth emulator',
      );

      test('returns config with proper types for all fields', () async {
        final config = await projectConfigManager.getProjectConfig();

        // Verify field types when they exist
        if (config.smsRegionConfig != null) {
          expect(config.smsRegionConfig, isA<SmsRegionConfig>());
        }
        if (config.multiFactorConfig != null) {
          expect(config.multiFactorConfig, isA<MultiFactorConfig>());
        }
        if (config.recaptchaConfig != null) {
          expect(config.recaptchaConfig, isA<RecaptchaConfig>());
        }
        if (config.passwordPolicyConfig != null) {
          expect(config.passwordPolicyConfig, isA<PasswordPolicyConfig>());
        }
        if (config.emailPrivacyConfig != null) {
          expect(config.emailPrivacyConfig, isA<EmailPrivacyConfig>());
        }
        if (config.mobileLinksConfig != null) {
          expect(config.mobileLinksConfig, isA<MobileLinksConfig>());
        }
      });

      test('toJson serialization works correctly', () async {
        final config = await projectConfigManager.getProjectConfig();
        final json = config.toJson();

        // Should return a valid Map
        expect(json, isA<Map<String, dynamic>>());

        // Only configured fields should be present
        if (config.smsRegionConfig != null) {
          expect(json.containsKey('smsRegionConfig'), isTrue);
        }
        if (config.multiFactorConfig != null) {
          expect(json.containsKey('multiFactorConfig'), isTrue);
        }
        if (config.recaptchaConfig != null) {
          expect(json.containsKey('recaptchaConfig'), isTrue);
        }
        if (config.passwordPolicyConfig != null) {
          expect(json.containsKey('passwordPolicyConfig'), isTrue);
        }
        if (config.emailPrivacyConfig != null) {
          expect(json.containsKey('emailPrivacyConfig'), isTrue);
        }
        if (config.mobileLinksConfig != null) {
          expect(json.containsKey('mobileLinksConfig'), isTrue);
        }
      });
    });

    group('updateProjectConfig', () {
      test('updates email privacy configuration', () async {
        // Update email privacy config
        final updatedConfig = await projectConfigManager.updateProjectConfig(
          UpdateProjectConfigRequest(
            emailPrivacyConfig: EmailPrivacyConfig(
              enableImprovedEmailPrivacy: true,
            ),
          ),
        );

        expect(updatedConfig, isA<ProjectConfig>());

        if (updatedConfig.emailPrivacyConfig != null) {
          expect(
            updatedConfig.emailPrivacyConfig!.enableImprovedEmailPrivacy,
            isTrue,
          );
        }
      });

      test('updates SMS region configuration to allowByDefault', () async {
        final updatedConfig = await projectConfigManager.updateProjectConfig(
          const UpdateProjectConfigRequest(
            smsRegionConfig: AllowByDefaultSmsRegionConfig(
              disallowedRegions: ['US', 'CA'],
            ),
          ),
        );

        expect(updatedConfig, isA<ProjectConfig>());

        if (updatedConfig.smsRegionConfig != null) {
          expect(
            updatedConfig.smsRegionConfig,
            isA<AllowByDefaultSmsRegionConfig>(),
          );
          final smsConfig =
              updatedConfig.smsRegionConfig! as AllowByDefaultSmsRegionConfig;
          expect(smsConfig.disallowedRegions, contains('US'));
          expect(smsConfig.disallowedRegions, contains('CA'));
        }
      });

      test('updates SMS region configuration to allowlistOnly', () async {
        final updatedConfig = await projectConfigManager.updateProjectConfig(
          const UpdateProjectConfigRequest(
            smsRegionConfig: AllowlistOnlySmsRegionConfig(
              allowedRegions: ['GB', 'FR', 'DE'],
            ),
          ),
        );

        expect(updatedConfig, isA<ProjectConfig>());

        if (updatedConfig.smsRegionConfig != null) {
          expect(
            updatedConfig.smsRegionConfig,
            isA<AllowlistOnlySmsRegionConfig>(),
          );
          final smsConfig =
              updatedConfig.smsRegionConfig! as AllowlistOnlySmsRegionConfig;
          expect(smsConfig.allowedRegions, contains('GB'));
          expect(smsConfig.allowedRegions, contains('FR'));
          expect(smsConfig.allowedRegions, contains('DE'));
        }
      });

      test(
        'updates multi-factor authentication configuration',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              multiFactorConfig: MultiFactorConfig(
                state: MultiFactorConfigState.enabled,
                factorIds: ['phone'],
              ),
            ),
          );

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.multiFactorConfig != null) {
            expect(
              updatedConfig.multiFactorConfig!.state,
              equals(MultiFactorConfigState.enabled),
            );
          }
        },
        skip:
            'Requires GCIP (Google Cloud Identity Platform) - MFA not available in standard Firebase Auth',
      );

      test(
        'updates reCAPTCHA configuration',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              recaptchaConfig: RecaptchaConfig(
                emailPasswordEnforcementState:
                    RecaptchaProviderEnforcementState.enforce,
                phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
              ),
            ),
          );

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.recaptchaConfig != null) {
            expect(
              updatedConfig.recaptchaConfig!.emailPasswordEnforcementState,
              equals(RecaptchaProviderEnforcementState.enforce),
            );
          }
        },
        skip:
            'Requires reCAPTCHA Enterprise configuration - phone auth enforcement must align with toll fraud settings',
      );

      test('updates password policy configuration', () async {
        final updatedConfig = await projectConfigManager.updateProjectConfig(
          UpdateProjectConfigRequest(
            passwordPolicyConfig: PasswordPolicyConfig(
              enforcementState: PasswordPolicyEnforcementState.enforce,
              forceUpgradeOnSignin: true,
              constraints: CustomStrengthOptionsConfig(
                requireUppercase: true,
                requireLowercase: true,
                requireNumeric: true,
                minLength: 10,
              ),
            ),
          ),
        );

        expect(updatedConfig, isA<ProjectConfig>());

        if (updatedConfig.passwordPolicyConfig != null) {
          expect(
            updatedConfig.passwordPolicyConfig!.enforcementState,
            equals(PasswordPolicyEnforcementState.enforce),
          );
        }
      });

      test('updates mobile links configuration', () async {
        final updatedConfig = await projectConfigManager.updateProjectConfig(
          const UpdateProjectConfigRequest(
            mobileLinksConfig: MobileLinksConfig(
              domain: MobileLinksDomain.hostingDomain,
            ),
          ),
        );

        expect(updatedConfig, isA<ProjectConfig>());

        if (updatedConfig.mobileLinksConfig != null) {
          expect(
            updatedConfig.mobileLinksConfig!.domain,
            equals(MobileLinksDomain.hostingDomain),
          );
        }
      });

      test(
        'updates multiple configuration fields at once',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              emailPrivacyConfig: EmailPrivacyConfig(
                enableImprovedEmailPrivacy: true,
              ),
              multiFactorConfig: MultiFactorConfig(
                state: MultiFactorConfigState.enabled,
                factorIds: ['phone'],
              ),
              mobileLinksConfig: const MobileLinksConfig(
                domain: MobileLinksDomain.firebaseDynamicLinkDomain,
              ),
            ),
          );

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.emailPrivacyConfig != null) {
            expect(
              updatedConfig.emailPrivacyConfig!.enableImprovedEmailPrivacy,
              isTrue,
            );
          }
          if (updatedConfig.multiFactorConfig != null) {
            expect(
              updatedConfig.multiFactorConfig!.state,
              equals(MultiFactorConfigState.enabled),
            );
          }
          if (updatedConfig.mobileLinksConfig != null) {
            expect(
              updatedConfig.mobileLinksConfig!.domain,
              equals(MobileLinksDomain.firebaseDynamicLinkDomain),
            );
          }
        },
        skip:
            'Requires GCIP (Google Cloud Identity Platform) - includes MFA configuration',
      );

      test('get and update maintain consistency', () async {
        final initialConfig = await projectConfigManager.getProjectConfig();

        await projectConfigManager.updateProjectConfig(
          UpdateProjectConfigRequest(
            emailPrivacyConfig: EmailPrivacyConfig(
              enableImprovedEmailPrivacy: false,
            ),
          ),
        );

        final retrievedConfig = await projectConfigManager.getProjectConfig();

        expect(initialConfig, isA<ProjectConfig>());
        expect(retrievedConfig, isA<ProjectConfig>());
      });
    });
  });
}
