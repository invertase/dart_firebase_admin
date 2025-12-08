import 'package:dart_firebase_admin/auth.dart';
import 'package:test/test.dart';

void main() {
  group('MobileLinksDomain', () {
    test('has correct string values', () {
      expect(MobileLinksDomain.hostingDomain.value, equals('HOSTING_DOMAIN'));
      expect(
        MobileLinksDomain.firebaseDynamicLinkDomain.value,
        equals('FIREBASE_DYNAMIC_LINK_DOMAIN'),
      );
    });

    test('fromString creates correct enum value for HOSTING_DOMAIN', () {
      final domain = MobileLinksDomain.fromString('HOSTING_DOMAIN');
      expect(domain, equals(MobileLinksDomain.hostingDomain));
    });

    test(
      'fromString creates correct enum value for FIREBASE_DYNAMIC_LINK_DOMAIN',
      () {
        final domain = MobileLinksDomain.fromString(
          'FIREBASE_DYNAMIC_LINK_DOMAIN',
        );
        expect(domain, equals(MobileLinksDomain.firebaseDynamicLinkDomain));
      },
    );

    test('fromString throws on invalid value', () {
      expect(
        () => MobileLinksDomain.fromString('INVALID_DOMAIN'),
        throwsA(isA<FirebaseAuthAdminException>()),
      );
    });
  });

  group('MobileLinksConfig', () {
    test('creates config with domain', () {
      const config = MobileLinksConfig(domain: MobileLinksDomain.hostingDomain);

      expect(config.domain, equals(MobileLinksDomain.hostingDomain));
    });

    test('creates config without domain', () {
      const config = MobileLinksConfig();

      expect(config.domain, isNull);
    });

    test('toJson includes domain when set', () {
      const config = MobileLinksConfig(
        domain: MobileLinksDomain.firebaseDynamicLinkDomain,
      );

      final json = config.toJson();

      expect(json['domain'], equals('FIREBASE_DYNAMIC_LINK_DOMAIN'));
    });

    test('toJson excludes domain when null', () {
      const config = MobileLinksConfig();

      final json = config.toJson();

      expect(json.containsKey('domain'), isFalse);
    });
  });

  group('UpdateProjectConfigRequest', () {
    test('creates request with all properties', () {
      final request = UpdateProjectConfigRequest(
        smsRegionConfig: const AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        ),
        multiFactorConfig: MultiFactorConfig(
          state: MultiFactorConfigState.enabled,
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
        mobileLinksConfig: const MobileLinksConfig(
          domain: MobileLinksDomain.hostingDomain,
        ),
      );

      expect(request.smsRegionConfig, isA<AllowByDefaultSmsRegionConfig>());
      expect(request.multiFactorConfig, isA<MultiFactorConfig>());
      expect(request.recaptchaConfig, isA<RecaptchaConfig>());
      expect(request.passwordPolicyConfig, isA<PasswordPolicyConfig>());
      expect(request.emailPrivacyConfig, isA<EmailPrivacyConfig>());
      expect(request.mobileLinksConfig, isA<MobileLinksConfig>());
    });

    test('creates request with only some properties', () {
      final request = UpdateProjectConfigRequest(
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: true,
        ),
        mobileLinksConfig: const MobileLinksConfig(
          domain: MobileLinksDomain.firebaseDynamicLinkDomain,
        ),
      );

      expect(request.smsRegionConfig, isNull);
      expect(request.multiFactorConfig, isNull);
      expect(request.recaptchaConfig, isNull);
      expect(request.passwordPolicyConfig, isNull);
      expect(request.emailPrivacyConfig, isNotNull);
      expect(request.mobileLinksConfig, isNotNull);
    });

    test('buildServerRequest includes all set properties', () {
      final request = UpdateProjectConfigRequest(
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: true,
        ),
        mobileLinksConfig: const MobileLinksConfig(
          domain: MobileLinksDomain.hostingDomain,
        ),
      );

      final serverRequest = request.buildServerRequest();

      expect(serverRequest.containsKey('emailPrivacyConfig'), isTrue);
      expect(serverRequest.containsKey('mobileLinksConfig'), isTrue);
      expect(
        (serverRequest['mobileLinksConfig'] as Map<String, dynamic>)['domain'],
        equals('HOSTING_DOMAIN'),
      );
    });

    test('buildServerRequest excludes null properties', () {
      final request = UpdateProjectConfigRequest(
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: false,
        ),
      );

      final serverRequest = request.buildServerRequest();

      expect(serverRequest.containsKey('smsRegionConfig'), isFalse);
      expect(serverRequest.containsKey('multiFactorConfig'), isFalse);
      expect(serverRequest.containsKey('recaptchaConfig'), isFalse);
      expect(serverRequest.containsKey('passwordPolicyConfig'), isFalse);
      expect(serverRequest.containsKey('mobileLinksConfig'), isFalse);
      expect(serverRequest.containsKey('emailPrivacyConfig'), isTrue);
    });
  });

  group('ProjectConfig', () {
    test('creates config with all properties', () {
      final config = ProjectConfig(
        smsRegionConfig: const AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US'],
        ),
        multiFactorConfig: MultiFactorConfig(
          state: MultiFactorConfigState.enabled,
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
        mobileLinksConfig: const MobileLinksConfig(
          domain: MobileLinksDomain.hostingDomain,
        ),
      );

      expect(config.smsRegionConfig, isA<AllowByDefaultSmsRegionConfig>());
      expect(config.multiFactorConfig, isA<MultiFactorConfig>());
      expect(config.recaptchaConfig, isA<RecaptchaConfig>());
      expect(config.passwordPolicyConfig, isA<PasswordPolicyConfig>());
      expect(config.emailPrivacyConfig, isA<EmailPrivacyConfig>());
      expect(config.mobileLinksConfig, isA<MobileLinksConfig>());
    });

    test('creates config with no properties', () {
      const config = ProjectConfig();

      expect(config.smsRegionConfig, isNull);
      expect(config.multiFactorConfig, isNull);
      expect(config.recaptchaConfig, isNull);
      expect(config.passwordPolicyConfig, isNull);
      expect(config.emailPrivacyConfig, isNull);
      expect(config.mobileLinksConfig, isNull);
    });

    test('fromServerResponse parses all properties', () {
      final serverResponse = {
        'smsRegionConfig': {
          'allowByDefault': {
            'disallowedRegions': ['US', 'CA'],
          },
        },
        'mfa': {'state': 'ENABLED'},
        'recaptchaConfig': {'emailPasswordEnforcementState': 'ENFORCE'},
        'passwordPolicyConfig': {'passwordPolicyEnforcementState': 'ENFORCE'},
        'emailPrivacyConfig': {'enableImprovedEmailPrivacy': true},
        'mobileLinksConfig': {'domain': 'HOSTING_DOMAIN'},
      };

      final config = ProjectConfig.fromServerResponse(serverResponse);

      expect(config.smsRegionConfig, isA<AllowByDefaultSmsRegionConfig>());
      expect(
        (config.smsRegionConfig! as AllowByDefaultSmsRegionConfig)
            .disallowedRegions,
        equals(['US', 'CA']),
      );
      expect(
        config.multiFactorConfig!.state,
        equals(MultiFactorConfigState.enabled),
      );
      expect(
        config.recaptchaConfig!.emailPasswordEnforcementState,
        equals(RecaptchaProviderEnforcementState.enforce),
      );
      expect(
        config.passwordPolicyConfig!.enforcementState,
        equals(PasswordPolicyEnforcementState.enforce),
      );
      expect(
        config.emailPrivacyConfig!.enableImprovedEmailPrivacy,
        equals(true),
      );
      expect(
        config.mobileLinksConfig!.domain,
        equals(MobileLinksDomain.hostingDomain),
      );
    });

    test('fromServerResponse handles allowlistOnly SMS region config', () {
      final serverResponse = {
        'smsRegionConfig': {
          'allowlistOnly': {
            'allowedRegions': ['GB', 'FR'],
          },
        },
      };

      final config = ProjectConfig.fromServerResponse(serverResponse);

      expect(config.smsRegionConfig, isA<AllowlistOnlySmsRegionConfig>());
      expect(
        (config.smsRegionConfig! as AllowlistOnlySmsRegionConfig)
            .allowedRegions,
        equals(['GB', 'FR']),
      );
    });

    test('fromServerResponse handles empty response', () {
      final serverResponse = <String, dynamic>{};

      final config = ProjectConfig.fromServerResponse(serverResponse);

      expect(config.smsRegionConfig, isNull);
      expect(config.multiFactorConfig, isNull);
      expect(config.recaptchaConfig, isNull);
      expect(config.passwordPolicyConfig, isNull);
      expect(config.emailPrivacyConfig, isNull);
      expect(config.mobileLinksConfig, isNull);
    });

    test('toJson includes all set properties', () {
      final config = ProjectConfig(
        emailPrivacyConfig: EmailPrivacyConfig(
          enableImprovedEmailPrivacy: true,
        ),
        mobileLinksConfig: const MobileLinksConfig(
          domain: MobileLinksDomain.firebaseDynamicLinkDomain,
        ),
      );

      final json = config.toJson();

      expect(json.containsKey('emailPrivacyConfig'), isTrue);
      expect(json.containsKey('mobileLinksConfig'), isTrue);
      expect(
        (json['mobileLinksConfig'] as Map<String, dynamic>)['domain'],
        equals('FIREBASE_DYNAMIC_LINK_DOMAIN'),
      );
    });

    test('toJson excludes null properties', () {
      const config = ProjectConfig(
        mobileLinksConfig: MobileLinksConfig(
          domain: MobileLinksDomain.hostingDomain,
        ),
      );

      final json = config.toJson();

      expect(json.containsKey('smsRegionConfig'), isFalse);
      expect(json.containsKey('multiFactorConfig'), isFalse);
      expect(json.containsKey('recaptchaConfig'), isFalse);
      expect(json.containsKey('passwordPolicyConfig'), isFalse);
      expect(json.containsKey('emailPrivacyConfig'), isFalse);
      expect(json.containsKey('mobileLinksConfig'), isTrue);
    });

    test('toJson handles SMS region config with allowByDefault', () {
      const config = ProjectConfig(
        smsRegionConfig: AllowByDefaultSmsRegionConfig(
          disallowedRegions: ['US', 'CA'],
        ),
      );

      final json = config.toJson();

      expect(
        (json['smsRegionConfig'] as Map<String, dynamic>)['allowByDefault'],
        isNotNull,
      );
      expect(
        ((json['smsRegionConfig'] as Map<String, dynamic>)['allowByDefault']
            as Map<String, dynamic>)['disallowedRegions'],
        equals(['US', 'CA']),
      );
    });

    test('toJson handles SMS region config with allowlistOnly', () {
      const config = ProjectConfig(
        smsRegionConfig: AllowlistOnlySmsRegionConfig(
          allowedRegions: ['GB', 'FR', 'DE'],
        ),
      );

      final json = config.toJson();

      expect(
        (json['smsRegionConfig'] as Map<String, dynamic>)['allowlistOnly'],
        isNotNull,
      );
      expect(
        ((json['smsRegionConfig'] as Map<String, dynamic>)['allowlistOnly']
            as Map<String, dynamic>)['allowedRegions'],
        equals(['GB', 'FR', 'DE']),
      );
    });
  });
}
