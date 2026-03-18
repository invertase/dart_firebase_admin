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
      final config = MultiFactorConfig(state: MultiFactorConfigState.enabled);

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
        const config = AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        );

        expect(config.disallowedRegions, containsAll(['US', 'CA']));
      });

      test('serializes to JSON', () {
        const config = AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        );

        final json = config.toJson();
        final allowByDefault = json['allowByDefault'] as Map<String, dynamic>;

        expect(allowByDefault, isNotNull);
        expect(allowByDefault['disallowedRegions'], containsAll(['US', 'CA']));
      });

      test('handles empty disallowed regions', () {
        const config = AllowByDefaultSmsRegionConfig(disallowedRegions: []);

        final json = config.toJson();
        final allowByDefault = json['allowByDefault'] as Map<String, dynamic>;

        expect(allowByDefault['disallowedRegions'], isEmpty);
      });
    });

    group('AllowlistOnlySmsRegionConfig', () {
      test('creates config with allowed regions', () {
        const config = AllowlistOnlySmsRegionConfig(
          allowedRegions: ['US', 'GB'],
        );

        expect(config.allowedRegions, containsAll(['US', 'GB']));
      });

      test('serializes to JSON', () {
        const config = AllowlistOnlySmsRegionConfig(
          allowedRegions: ['US', 'GB'],
        );

        final json = config.toJson();
        final allowlistOnly = json['allowlistOnly'] as Map<String, dynamic>;

        expect(allowlistOnly, isNotNull);
        expect(allowlistOnly['allowedRegions'], containsAll(['US', 'GB']));
      });

      test('handles empty allowed regions', () {
        const config = AllowlistOnlySmsRegionConfig(allowedRegions: []);

        final json = config.toJson();
        final allowlistOnly = json['allowlistOnly'] as Map<String, dynamic>;

        expect(allowlistOnly['allowedRegions'], isEmpty);
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

  group('RecaptchaAction', () {
    test('has correct value', () {
      expect(RecaptchaAction.block.value, equals('BLOCK'));
    });

    test('fromString returns correct enum', () {
      expect(
        RecaptchaAction.fromString('BLOCK'),
        equals(RecaptchaAction.block),
      );
      expect(
        RecaptchaAction.fromString('INVALID'),
        equals(RecaptchaAction.block),
      ); // Default fallback
    });
  });

  group('RecaptchaKeyClientType', () {
    test('has correct values', () {
      expect(RecaptchaKeyClientType.web.value, equals('WEB'));
      expect(RecaptchaKeyClientType.ios.value, equals('IOS'));
      expect(RecaptchaKeyClientType.android.value, equals('ANDROID'));
    });

    test('fromString returns correct enum', () {
      expect(
        RecaptchaKeyClientType.fromString('WEB'),
        equals(RecaptchaKeyClientType.web),
      );
      expect(
        RecaptchaKeyClientType.fromString('IOS'),
        equals(RecaptchaKeyClientType.ios),
      );
      expect(
        RecaptchaKeyClientType.fromString('ANDROID'),
        equals(RecaptchaKeyClientType.android),
      );
      expect(
        RecaptchaKeyClientType.fromString('INVALID'),
        equals(RecaptchaKeyClientType.web),
      ); // Default fallback
    });
  });

  group('RecaptchaManagedRule', () {
    test('creates rule with required fields', () {
      const rule = RecaptchaManagedRule(endScore: 0.5);

      expect(rule.endScore, equals(0.5));
      expect(rule.action, isNull);
    });

    test('creates rule with action', () {
      const rule = RecaptchaManagedRule(
        endScore: 0.5,
        action: RecaptchaAction.block,
      );

      expect(rule.endScore, equals(0.5));
      expect(rule.action, equals(RecaptchaAction.block));
    });

    test('serializes to JSON', () {
      const rule = RecaptchaManagedRule(
        endScore: 0.5,
        action: RecaptchaAction.block,
      );

      final json = rule.toJson();

      expect(json['endScore'], equals(0.5));
      expect(json['action'], equals('BLOCK'));
    });

    test('serializes to JSON without action', () {
      const rule = RecaptchaManagedRule(endScore: 0.5);

      final json = rule.toJson();

      expect(json['endScore'], equals(0.5));
      expect(json.containsKey('action'), isFalse);
    });
  });

  group('RecaptchaTollFraudManagedRule', () {
    test('creates rule with required fields', () {
      const rule = RecaptchaTollFraudManagedRule(startScore: 0.3);

      expect(rule.startScore, equals(0.3));
      expect(rule.action, isNull);
    });

    test('creates rule with action', () {
      const rule = RecaptchaTollFraudManagedRule(
        startScore: 0.3,
        action: RecaptchaAction.block,
      );

      expect(rule.startScore, equals(0.3));
      expect(rule.action, equals(RecaptchaAction.block));
    });

    test('serializes to JSON', () {
      const rule = RecaptchaTollFraudManagedRule(
        startScore: 0.3,
        action: RecaptchaAction.block,
      );

      final json = rule.toJson();

      expect(json['startScore'], equals(0.3));
      expect(json['action'], equals('BLOCK'));
    });
  });

  group('RecaptchaKey', () {
    test('creates key with required fields', () {
      const key = RecaptchaKey(key: 'test-key');

      expect(key.key, equals('test-key'));
      expect(key.type, isNull);
    });

    test('creates key with type', () {
      const key = RecaptchaKey(
        key: 'test-key',
        type: RecaptchaKeyClientType.web,
      );

      expect(key.key, equals('test-key'));
      expect(key.type, equals(RecaptchaKeyClientType.web));
    });

    test('serializes to JSON', () {
      const key = RecaptchaKey(
        key: 'test-key',
        type: RecaptchaKeyClientType.ios,
      );

      final json = key.toJson();

      expect(json['key'], equals('test-key'));
      expect(json['type'], equals('IOS'));
    });
  });

  group('RecaptchaConfig', () {
    test('creates config with all fields', () {
      final config = RecaptchaConfig(
        emailPasswordEnforcementState:
            RecaptchaProviderEnforcementState.enforce,
        phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
        managedRules: [const RecaptchaManagedRule(endScore: 0.5)],
        recaptchaKeys: [
          const RecaptchaKey(key: 'test-key', type: RecaptchaKeyClientType.web),
        ],
        useAccountDefender: true,
        useSmsBotScore: true,
        useSmsTollFraudProtection: false,
        smsTollFraudManagedRules: [
          const RecaptchaTollFraudManagedRule(startScore: 0.3),
        ],
      );

      expect(
        config.emailPasswordEnforcementState,
        equals(RecaptchaProviderEnforcementState.enforce),
      );
      expect(
        config.phoneEnforcementState,
        equals(RecaptchaProviderEnforcementState.audit),
      );
      expect(config.managedRules, isNotNull);
      expect(config.managedRules!.length, equals(1));
      expect(config.recaptchaKeys, isNotNull);
      expect(config.recaptchaKeys!.length, equals(1));
      expect(config.useAccountDefender, isTrue);
      expect(config.useSmsBotScore, isTrue);
      expect(config.useSmsTollFraudProtection, isFalse);
      expect(config.smsTollFraudManagedRules, isNotNull);
      expect(config.smsTollFraudManagedRules!.length, equals(1));
    });

    test('creates config with no fields', () {
      final config = RecaptchaConfig();

      expect(config.emailPasswordEnforcementState, isNull);
      expect(config.phoneEnforcementState, isNull);
      expect(config.managedRules, isNull);
      expect(config.recaptchaKeys, isNull);
      expect(config.useAccountDefender, isNull);
      expect(config.useSmsBotScore, isNull);
      expect(config.useSmsTollFraudProtection, isNull);
      expect(config.smsTollFraudManagedRules, isNull);
    });

    test('serializes to JSON', () {
      final config = RecaptchaConfig(
        emailPasswordEnforcementState:
            RecaptchaProviderEnforcementState.enforce,
        phoneEnforcementState: RecaptchaProviderEnforcementState.audit,
        managedRules: [
          const RecaptchaManagedRule(
            endScore: 0.5,
            action: RecaptchaAction.block,
          ),
        ],
        recaptchaKeys: [
          const RecaptchaKey(key: 'test-key', type: RecaptchaKeyClientType.web),
        ],
        useAccountDefender: true,
        useSmsBotScore: true,
        useSmsTollFraudProtection: false,
        smsTollFraudManagedRules: [
          const RecaptchaTollFraudManagedRule(
            startScore: 0.3,
            action: RecaptchaAction.block,
          ),
        ],
      );

      final json = config.toJson();

      expect(json['emailPasswordEnforcementState'], equals('ENFORCE'));
      expect(json['phoneEnforcementState'], equals('AUDIT'));
      expect(json['useAccountDefender'], isTrue);
      expect(json['useSmsBotScore'], isTrue);
      expect(json['useSmsTollFraudProtection'], isFalse);
      expect(json['managedRules'], isA<List<dynamic>>());
      final managedRulesList = json['managedRules'] as List<dynamic>;
      final managedRule = managedRulesList[0] as Map<String, dynamic>;
      expect(managedRule['endScore'], equals(0.5));
      expect(managedRule['action'], equals('BLOCK'));
      expect(json['recaptchaKeys'], isA<List<dynamic>>());
      final recaptchaKeysList = json['recaptchaKeys'] as List<dynamic>;
      final recaptchaKey = recaptchaKeysList[0] as Map<String, dynamic>;
      expect(recaptchaKey['key'], equals('test-key'));
      expect(recaptchaKey['type'], equals('WEB'));
      expect(json['smsTollFraudManagedRules'], isA<List<dynamic>>());
      final smsTollFraudRulesList =
          json['smsTollFraudManagedRules'] as List<dynamic>;
      final smsTollFraudRule = smsTollFraudRulesList[0] as Map<String, dynamic>;
      expect(smsTollFraudRule['startScore'], equals(0.3));
      expect(smsTollFraudRule['action'], equals('BLOCK'));
    });
  });

  group('PasswordPolicyEnforcementState', () {
    test('has correct values', () {
      expect(PasswordPolicyEnforcementState.enforce.value, equals('ENFORCE'));
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
      final constraints = json['constraints'] as Map<String, dynamic>;

      expect(json['enforcementState'], equals('ENFORCE'));
      expect(json['forceUpgradeOnSignin'], isTrue);
      expect(constraints, isNotNull);
      expect(constraints['requireUppercase'], isTrue);
      expect(constraints['minLength'], equals(8));
    });
  });

  group('EmailPrivacyConfig', () {
    test('creates config with improved privacy enabled', () {
      final config = EmailPrivacyConfig(enableImprovedEmailPrivacy: true);

      expect(config.enableImprovedEmailPrivacy, isTrue);
    });

    test('creates config with improved privacy disabled', () {
      final config = EmailPrivacyConfig(enableImprovedEmailPrivacy: false);

      expect(config.enableImprovedEmailPrivacy, isFalse);
    });

    test('creates config with no field', () {
      final config = EmailPrivacyConfig();

      expect(config.enableImprovedEmailPrivacy, isNull);
    });

    test('serializes to JSON', () {
      final config = EmailPrivacyConfig(enableImprovedEmailPrivacy: true);

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

  group('TotpMultiFactorProviderConfig', () {
    test('creates config without adjacentIntervals', () {
      final config = TotpMultiFactorProviderConfig();

      expect(config.adjacentIntervals, isNull);
    });

    test('creates config with valid adjacentIntervals', () {
      final config = TotpMultiFactorProviderConfig(adjacentIntervals: 5);

      expect(config.adjacentIntervals, equals(5));
    });

    test('creates config with minimum adjacentIntervals (0)', () {
      final config = TotpMultiFactorProviderConfig(adjacentIntervals: 0);

      expect(config.adjacentIntervals, equals(0));
    });

    test('creates config with maximum adjacentIntervals (10)', () {
      final config = TotpMultiFactorProviderConfig(adjacentIntervals: 10);

      expect(config.adjacentIntervals, equals(10));
    });

    test('throws when adjacentIntervals is negative', () {
      expect(
        () => TotpMultiFactorProviderConfig(adjacentIntervals: -1),
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.invalidArgument,
          ),
        ),
      );
    });

    test('throws when adjacentIntervals exceeds maximum', () {
      expect(
        () => TotpMultiFactorProviderConfig(adjacentIntervals: 11),
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.invalidArgument,
          ),
        ),
      );
    });

    test('serializes to JSON with adjacentIntervals', () {
      final config = TotpMultiFactorProviderConfig(adjacentIntervals: 3);

      final json = config.toJson();

      expect(json['adjacentIntervals'], equals(3));
    });

    test('serializes to JSON without adjacentIntervals', () {
      final config = TotpMultiFactorProviderConfig();

      final json = config.toJson();

      expect(json.containsKey('adjacentIntervals'), isFalse);
    });
  });

  group('MultiFactorProviderConfig', () {
    test('creates config with required fields', () {
      final config = MultiFactorProviderConfig(
        state: MultiFactorConfigState.enabled,
        totpProviderConfig: TotpMultiFactorProviderConfig(),
      );

      expect(config.state, equals(MultiFactorConfigState.enabled));
      expect(config.totpProviderConfig, isNotNull);
    });

    test('throws when totpProviderConfig is not provided', () {
      expect(
        () => MultiFactorProviderConfig(state: MultiFactorConfigState.enabled),
        throwsA(
          isA<FirebaseAuthAdminException>().having(
            (e) => e.errorCode,
            'errorCode',
            AuthClientErrorCode.invalidConfig,
          ),
        ),
      );
    });

    test('serializes to JSON correctly', () {
      final config = MultiFactorProviderConfig(
        state: MultiFactorConfigState.enabled,
        totpProviderConfig: TotpMultiFactorProviderConfig(adjacentIntervals: 5),
      );

      final json = config.toJson();

      expect(json['state'], equals('ENABLED'));
      expect(json['totpProviderConfig'], isA<Map<String, dynamic>>());
      expect(
        (json['totpProviderConfig']
            as Map<String, dynamic>)['adjacentIntervals'],
        equals(5),
      );
    });

    test('serializes to JSON with disabled state', () {
      final config = MultiFactorProviderConfig(
        state: MultiFactorConfigState.disabled,
        totpProviderConfig: TotpMultiFactorProviderConfig(),
      );

      final json = config.toJson();

      expect(json['state'], equals('DISABLED'));
      expect(json['totpProviderConfig'], isA<Map<String, dynamic>>());
    });
  });

  group('MultiFactorConfig', () {
    test('creates config with providerConfigs', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.enabled,
        providerConfigs: [
          MultiFactorProviderConfig(
            state: MultiFactorConfigState.enabled,
            totpProviderConfig: TotpMultiFactorProviderConfig(
              adjacentIntervals: 3,
            ),
          ),
        ],
      );

      expect(config.providerConfigs, isNotNull);
      expect(config.providerConfigs, hasLength(1));
      expect(
        config.providerConfigs![0].totpProviderConfig?.adjacentIntervals,
        equals(3),
      );
    });

    test('serializes to JSON with providerConfigs', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.enabled,
        providerConfigs: [
          MultiFactorProviderConfig(
            state: MultiFactorConfigState.enabled,
            totpProviderConfig: TotpMultiFactorProviderConfig(
              adjacentIntervals: 7,
            ),
          ),
        ],
      );

      final json = config.toJson();

      expect(json['providerConfigs'], isList);
      expect(json['providerConfigs'], hasLength(1));
      final providerConfig =
          (json['providerConfigs'] as List)[0] as Map<String, dynamic>;
      expect(providerConfig['state'], equals('ENABLED'));
      expect(
        (providerConfig['totpProviderConfig']
            as Map<String, dynamic>)['adjacentIntervals'],
        equals(7),
      );
    });

    test('serializes to JSON without providerConfigs', () {
      final config = MultiFactorConfig(
        state: MultiFactorConfigState.disabled,
        factorIds: [authFactorTypePhone],
      );

      final json = config.toJson();

      expect(json.containsKey('providerConfigs'), isFalse);
      expect(json['factorIds'], isNotNull);
    });
  });
}
