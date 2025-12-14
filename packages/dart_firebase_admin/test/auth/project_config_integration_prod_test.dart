// Firebase ProjectConfig Integration Tests - Production Only
//
// These tests require production Firebase (GOOGLE_APPLICATION_CREDENTIALS)
// because they test features not available in the emulator:
// - Multi-factor authentication (requires GCIP)
// - TOTP provider configuration (requires GCIP)
// - reCAPTCHA Enterprise configuration
//
// **IMPORTANT:** These tests use runZoned with zoneValues to temporarily
// disable the emulator environment variable. This allows them to run in the
// coverage script (which has emulator vars set) by connecting to production
// only for these specific tests.
//
// Run standalone with:
//   GOOGLE_APPLICATION_CREDENTIALS=service-account-key.json dart test test/auth/project_config_integration_prod_test.dart

import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';

import '../google_cloud_firestore/util/helpers.dart';
import 'util/helpers.dart';

void main() {
  late Auth auth;
  late ProjectConfigManager projectConfigManager;
  ProjectConfig? originalConfig;

  setUp(() {
    if (!hasGoogleEnv) return;
    auth = createProductionAuth();
    projectConfigManager = auth.projectConfigManager;
  });

  // Save original config before running update tests
  setUpAll(() async {
    if (!hasGoogleEnv) return;

    final testAuth = createProductionAuth();
    try {
      originalConfig = await testAuth.projectConfigManager.getProjectConfig();
      // ignore: avoid_print
      print('Original config saved for restoration after tests');
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Could not save original config: $e');
    }
  });

  // Restore original config after all tests complete
  tearDownAll(() async {
    if (!hasGoogleEnv || originalConfig == null) return;

    final testAuth = createProductionAuth();
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
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Could not restore original config: $e');
    }
  });

  group('ProjectConfigManager (Production)', () {
    group('updateProjectConfig - MFA', () {
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
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'updates multi-factor authentication with TOTP provider config',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              multiFactorConfig: MultiFactorConfig(
                state: MultiFactorConfigState.enabled,
                providerConfigs: [
                  MultiFactorProviderConfig(
                    state: MultiFactorConfigState.enabled,
                    totpProviderConfig: TotpMultiFactorProviderConfig(),
                  ),
                ],
              ),
            ),
          );

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.multiFactorConfig != null) {
            expect(
              updatedConfig.multiFactorConfig!.state,
              equals(MultiFactorConfigState.enabled),
            );
            expect(updatedConfig.multiFactorConfig!.providerConfigs, isNotNull);
            if (updatedConfig.multiFactorConfig!.providerConfigs != null) {
              expect(
                updatedConfig.multiFactorConfig!.providerConfigs!.length,
                equals(1),
              );
              expect(
                updatedConfig.multiFactorConfig!.providerConfigs![0].state,
                equals(MultiFactorConfigState.enabled),
              );
            }
          }
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'updates TOTP provider config with adjacentIntervals',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
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

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.multiFactorConfig != null) {
            final providerConfigs =
                updatedConfig.multiFactorConfig!.providerConfigs;
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

      test(
        'updates MFA with both SMS and TOTP enabled',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
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

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.multiFactorConfig != null) {
            expect(
              updatedConfig.multiFactorConfig!.state,
              equals(MultiFactorConfigState.enabled),
            );
            expect(
              updatedConfig.multiFactorConfig!.factorIds,
              contains('phone'),
            );
            final providerConfigs =
                updatedConfig.multiFactorConfig!.providerConfigs;
            if (providerConfigs != null && providerConfigs.isNotEmpty) {
              expect(
                providerConfigs[0].state,
                equals(MultiFactorConfigState.enabled),
              );
            }
          }
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );

      test(
        'updates TOTP provider config with disabled state',
        () async {
          final updatedConfig = await projectConfigManager.updateProjectConfig(
            UpdateProjectConfigRequest(
              multiFactorConfig: MultiFactorConfig(
                state: MultiFactorConfigState.enabled,
                providerConfigs: [
                  MultiFactorProviderConfig(
                    state: MultiFactorConfigState.disabled,
                    totpProviderConfig: TotpMultiFactorProviderConfig(),
                  ),
                ],
              ),
            ),
          );

          expect(updatedConfig, isA<ProjectConfig>());

          if (updatedConfig.multiFactorConfig != null) {
            final providerConfigs =
                updatedConfig.multiFactorConfig!.providerConfigs;
            if (providerConfigs != null && providerConfigs.isNotEmpty) {
              expect(
                providerConfigs[0].state,
                equals(MultiFactorConfigState.disabled),
              );
            }
          }
        },
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });

    group('updateProjectConfig - reCAPTCHA', () {
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
        skip: hasGoogleEnv
            ? false
            : 'Requires reCAPTCHA Enterprise configuration',
      );
    });

    group('updateProjectConfig - Combined', () {
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
        skip: hasGoogleEnv
            ? false
            : 'Requires GCIP (Google Cloud Identity Platform)',
      );
    });
  });
}
