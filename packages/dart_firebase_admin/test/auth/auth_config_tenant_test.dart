import 'package:dart_firebase_admin/src/auth.dart';
import 'package:test/test.dart';

void main() {
  group('EmailSignInProviderConfig', () {
    test('creates config with required fields', () {
      final config = EmailSignInProviderConfig(enabled: true);

      expect(config.enabled, isTrue);
      expect(config.passwordRequired, isNull);
    });

    test('creates config with all fields', () {
      final config = EmailSignInProviderConfig(
        enabled: true,
        passwordRequired: false,
      );

      expect(config.enabled, isTrue);
      expect(config.passwordRequired, isFalse);
    });

    test('serializes to JSON correctly', () {
      final config = EmailSignInProviderConfig(
        enabled: true,
        passwordRequired: false,
      );

      final json = config.toJson();

      expect(json['enabled'], isTrue);
      expect(json['passwordRequired'], isFalse);
    });

    test('serializes to JSON without optional fields', () {
      final config = EmailSignInProviderConfig(enabled: false);

      final json = config.toJson();

      expect(json['enabled'], isFalse);
      expect(json['passwordRequired'], isNull);
    });
  });

  group('MultiFactorConfigState', () {
    test('has correct values', () {
      expect(MultiFactorConfigState.enabled.value, equals('ENABLED'));
      expect(MultiFactorConfigState.disabled.value, equals('DISABLED'));
    });
  });

  group('MultiFactorConfig', () {
    test('creates config with state only', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.enabled,
      );

      expect(config.state, equals(MultiFactorConfigState.enabled));
      expect(config.factorIds, isNull);
    });

    test('creates config with factor IDs', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.enabled,
        factorIds: ['phone'],
      );

      expect(config.state, equals(MultiFactorConfigState.enabled));
      expect(config.factorIds, contains('phone'));
    });

    test('serializes to JSON', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.enabled,
        factorIds: ['phone'],
      );

      final json = config.toJson();

      expect(json['state'], equals('ENABLED'));
      expect(json['factorIds'], contains('phone'));
    });
  });

  group('SmsRegionConfig', () {
    group('AllowByDefaultSmsRegionConfig', () {
      test('creates config with disallowed regions', () {
        final config = AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        );

        expect(config.disallowedRegions, containsAll(['US', 'CA']));
      });

      test('serializes to JSON', () {
        final config = AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        );

        final json = config.toJson();

        expect(json['allowByDefault'], isNotNull);
        expect(
          json['allowByDefault']['disallowedRegions'],
          containsAll(['US', 'CA']),
        );
      });

      test('handles empty disallowed regions', () {
        final config = AllowByDefaultSmsRegionConfig(
          disallowedRegions: [],
        );

        final json = config.toJson();

        expect(json['allowByDefault']['disallowedRegions'], isEmpty);
      });
    });

    group('AllowlistOnlySmsRegionConfig', () {
      test('creates config with allowed regions', () {
        final config = AllowlistOnlySmsRegionConfig(
          allowedRegions: ['US', 'GB'],
        );

        expect(config.allowedRegions, containsAll(['US', 'GB']));
      });

      test('serializes to JSON', () {
        final config = AllowlistOnlySmsRegionConfig(
          allowedRegions: ['US', 'GB'],
        );

        final json = config.toJson();

        expect(json['allowlistOnly'], isNotNull);
        expect(
          json['allowlistOnly']['allowedRegions'],
          containsAll(['US', 'GB']),
        );
      });

      test('handles empty allowed regions', () {
        final config = AllowlistOnlySmsRegionConfig(
          allowedRegions: [],
        );

        final json = config.toJson();

        expect(json['allowlistOnly']['allowedRegions'], isEmpty);
      });
    });
  });

  group('RecaptchaProviderEnforcementState', () {
    test('has correct values', () {
      expect(RecaptchaProviderEnforcementState.off.value, equals('OFF'));
      expect(RecaptchaProviderEnforcementState.audit.value, equals('AUDIT'));
      expect(
        RecaptchaProviderEnforcementState.enforce.value,
        equals('ENFORCE'),
      );
    });
  });

  group('RecaptchaConfig', () {
    test('creates config with all fields', () {
      final config = RecaptchaConfig(
        emailPasswordEnforcementState:
            RecaptchaProviderEnforcementState.enforce,
        phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
        useAccountDefender: true,
      );

      expect(
        config.emailPasswordEnforcementState,
        equals(RecaptchaProviderEnforcementState.enforce),
      );
      expect(
        config.phoneEnforcementState,
        equals(RecaptchaProviderEnforcementState.audit),
      );
      expect(config.useAccountDefender, isTrue);
    });

    test('creates config with no fields', () {
      final config = RecaptchaConfig();

      expect(config.emailPasswordEnforcementState, isNull);
      expect(config.phoneEnforcementState, isNull);
      expect(config.useAccountDefender, isNull);
    });

    test('serializes to JSON', () {
      final config = RecaptchaConfig(
        emailPasswordEnforcementState:
            RecaptchaProviderEnforcementState.enforce,
        phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
        useAccountDefender: true,
      );

      final json = config.toJson();

      expect(json['emailPasswordEnforcementState'], equals('ENFORCE'));
      expect(json['phoneEnforcementState'], equals('AUDIT'));
      expect(json['useAccountDefender'], isTrue);
    });
  });

  group('PasswordPolicyEnforcementState', () {
    test('has correct values', () {
      expect(
        PasswordPolicyEnforcementState.enforce.value,
        equals('ENFORCE'),
      );
      expect(PasswordPolicyEnforcementState.off.value, equals('OFF'));
    });
  });

  group('CustomStrengthOptionsConfig', () {
    test('creates config with all fields', () {
      final config = CustomStrengthOptionsConfig(
        requireUppercase: true,
        requireLowercase: true,
        requireNonAlphanumeric: true,
        requireNumeric: true,
        minLength: 8,
        maxLength: 128,
      );

      expect(config.requireUppercase, isTrue);
      expect(config.requireLowercase, isTrue);
      expect(config.requireNonAlphanumeric, isTrue);
      expect(config.requireNumeric, isTrue);
      expect(config.minLength, equals(8));
      expect(config.maxLength, equals(128));
    });

    test('creates config with no fields', () {
      final config = CustomStrengthOptionsConfig();

      expect(config.requireUppercase, isNull);
      expect(config.requireLowercase, isNull);
      expect(config.requireNonAlphanumeric, isNull);
      expect(config.requireNumeric, isNull);
      expect(config.minLength, isNull);
      expect(config.maxLength, isNull);
    });

    test('serializes to JSON', () {
      final config = CustomStrengthOptionsConfig(
        requireUppercase: true,
        requireLowercase: true,
        requireNonAlphanumeric: true,
        requireNumeric: true,
        minLength: 8,
        maxLength: 128,
      );

      final json = config.toJson();

      expect(json['requireUppercase'], isTrue);
      expect(json['requireLowercase'], isTrue);
      expect(json['requireNonAlphanumeric'], isTrue);
      expect(json['requireNumeric'], isTrue);
      expect(json['minLength'], equals(8));
      expect(json['maxLength'], equals(128));
    });
  });

  group('PasswordPolicyConfig', () {
    test('creates config with all fields', () {
      final config = PasswordPolicyConfig(
        enforcementState: PasswordPolicyEnforcementState.enforce,
        forceUpgradeOnSignin: true,
        constraints: CustomStrengthOptionsConfig(
          requireUppercase: true,
          minLength: 8,
        ),
      );

      expect(
        config.enforcementState,
        equals(PasswordPolicyEnforcementState.enforce),
      );
      expect(config.forceUpgradeOnSignin, isTrue);
      expect(config.constraints, isNotNull);
      expect(config.constraints!.requireUppercase, isTrue);
      expect(config.constraints!.minLength, equals(8));
    });

    test('creates config with no fields', () {
      final config = PasswordPolicyConfig();

      expect(config.enforcementState, isNull);
      expect(config.forceUpgradeOnSignin, isNull);
      expect(config.constraints, isNull);
    });

    test('serializes to JSON', () {
      final config = PasswordPolicyConfig(
        enforcementState: PasswordPolicyEnforcementState.enforce,
        forceUpgradeOnSignin: true,
        constraints: CustomStrengthOptionsConfig(
          requireUppercase: true,
          minLength: 8,
        ),
      );

      final json = config.toJson();

      expect(json['enforcementState'], equals('ENFORCE'));
      expect(json['forceUpgradeOnSignin'], isTrue);
      expect(json['constraints'], isNotNull);
      expect(json['constraints']['requireUppercase'], isTrue);
      expect(json['constraints']['minLength'], equals(8));
    });
  });

  group('EmailPrivacyConfig', () {
    test('creates config with improved privacy enabled', () {
      final config = EmailPrivacyConfig(
        enableImprovedEmailPrivacy: true,
      );

      expect(config.enableImprovedEmailPrivacy, isTrue);
    });

    test('creates config with improved privacy disabled', () {
      final config = EmailPrivacyConfig(
        enableImprovedEmailPrivacy: false,
      );

      expect(config.enableImprovedEmailPrivacy, isFalse);
    });

    test('creates config with no field', () {
      final config = EmailPrivacyConfig();

      expect(config.enableImprovedEmailPrivacy, isNull);
    });

    test('serializes to JSON', () {
      final config = EmailPrivacyConfig(
        enableImprovedEmailPrivacy: true,
      );

      final json = config.toJson();

      expect(json['enableImprovedEmailPrivacy'], isTrue);
    });

    test('serializes to JSON without field', () {
      final config = EmailPrivacyConfig();

      final json = config.toJson();

      expect(json['enableImprovedEmailPrivacy'], isNull);
    });
  });

  group('authFactorTypePhone', () {
    test('has correct value', () {
      expect(authFactorTypePhone, equals('phone'));
    });
  });
}
