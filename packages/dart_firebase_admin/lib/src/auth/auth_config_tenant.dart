// Copyright 2024 Google LLC
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

part of '../auth.dart';

// ============================================================================
// Email Sign-In Configuration
// ============================================================================

/// The email sign in provider configuration.
class EmailSignInProviderConfig {
  EmailSignInProviderConfig({required this.enabled, this.passwordRequired});

  /// Whether email provider is enabled.
  final bool enabled;

  /// Whether password is required for email sign-in. When not required,
  /// email sign-in can be performed with password or via email link sign-in.
  final bool? passwordRequired;

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (passwordRequired != null) 'passwordRequired': passwordRequired,
  };
}

/// Internal class for email sign-in configuration.
class _EmailSignInConfig implements EmailSignInProviderConfig {
  _EmailSignInConfig({required this.enabled, this.passwordRequired});

  factory _EmailSignInConfig.fromServerResponse(Map<String, dynamic> response) {
    final allowPasswordSignup = response['allowPasswordSignup'];
    if (allowPasswordSignup == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Invalid email sign-in configuration response',
      );
    }

    return _EmailSignInConfig(
      enabled: allowPasswordSignup as bool,
      passwordRequired: response['enableEmailLinkSignin'] != null
          ? !(response['enableEmailLinkSignin'] as bool)
          : null,
    );
  }

  static Map<String, dynamic> buildServerRequest(
    EmailSignInProviderConfig options,
  ) {
    final request = <String, dynamic>{};

    request['allowPasswordSignup'] = options.enabled;
    if (options.passwordRequired != null) {
      request['enableEmailLinkSignin'] = !options.passwordRequired!;
    }

    return request;
  }

  @override
  final bool enabled;

  @override
  final bool? passwordRequired;

  @override
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    if (passwordRequired != null) 'passwordRequired': passwordRequired,
  };
}

// ============================================================================
// Multi-Factor Authentication Configuration
// ============================================================================

/// Identifies a second factor type.
typedef AuthFactorType = String;

/// The 'phone' auth factor type constant.
const authFactorTypePhone = 'phone';

/// Identifies a multi-factor configuration state.
enum MultiFactorConfigState {
  enabled('ENABLED'),
  disabled('DISABLED');

  const MultiFactorConfigState(this.value);
  final String value;

  static MultiFactorConfigState fromString(String value) {
    return MultiFactorConfigState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'Invalid MultiFactorConfigState: $value',
      ),
    );
  }
}

/// Interface representing configuration settings for TOTP second factor auth.
class TotpMultiFactorProviderConfig {
  /// Creates a new [TotpMultiFactorProviderConfig] instance.
  TotpMultiFactorProviderConfig({this.adjacentIntervals}) {
    final intervals = adjacentIntervals;
    if (intervals != null && (intervals < 0 || intervals > 10)) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        '"adjacentIntervals" must be a valid number between 0 and 10 (both inclusive).',
      );
    }
  }

  /// The allowed number of adjacent intervals that will be used for verification
  /// to compensate for clock skew. Valid range is 0-10 (inclusive).
  final int? adjacentIntervals;

  Map<String, dynamic> toJson() {
    return {
      if (adjacentIntervals != null) 'adjacentIntervals': adjacentIntervals,
    };
  }
}

/// Interface representing a multi-factor auth provider configuration.
/// This interface is used for second factor auth providers other than SMS.
/// Currently, only TOTP is supported.
class MultiFactorProviderConfig {
  /// Creates a new [MultiFactorProviderConfig] instance.
  MultiFactorProviderConfig({required this.state, this.totpProviderConfig}) {
    // Since TOTP is the only provider config available right now, it must be defined
    if (totpProviderConfig == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidConfig,
        '"totpProviderConfig" must be defined.',
      );
    }
  }

  /// Indicates whether this multi-factor provider is enabled or disabled.
  final MultiFactorConfigState state;

  /// TOTP multi-factor provider config.
  final TotpMultiFactorProviderConfig? totpProviderConfig;

  Map<String, dynamic> toJson() {
    return {
      'state': state.value,
      if (totpProviderConfig != null)
        'totpProviderConfig': totpProviderConfig!.toJson(),
    };
  }
}

/// Interface representing a multi-factor configuration.
class MultiFactorConfig {
  MultiFactorConfig({
    required this.state,
    this.factorIds,
    this.providerConfigs,
  });

  /// The multi-factor config state.
  final MultiFactorConfigState state;

  /// The list of identifiers for enabled second factors.
  /// Currently 'phone' and 'totp' are supported.
  final List<AuthFactorType>? factorIds;

  /// The configuration for multi-factor auth providers.
  final List<MultiFactorProviderConfig>? providerConfigs;

  Map<String, dynamic> toJson() => {
    'state': state.value,
    if (factorIds != null) 'factorIds': factorIds,
    if (providerConfigs != null)
      'providerConfigs': providerConfigs!.map((e) => e.toJson()).toList(),
  };
}

/// Internal class for multi-factor authentication configuration.
class _MultiFactorAuthConfig implements MultiFactorConfig {
  _MultiFactorAuthConfig({
    required this.state,
    this.factorIds,
    this.providerConfigs,
  });

  factory _MultiFactorAuthConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
    final stateValue = response['state'];
    if (stateValue == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Invalid multi-factor configuration response',
      );
    }

    final enabledProviders = response['enabledProviders'] as List<dynamic>?;
    final factorIds = <AuthFactorType>[];

    if (enabledProviders != null) {
      for (final provider in enabledProviders) {
        // Map server types to client types
        if (provider == 'PHONE_SMS') {
          factorIds.add(authFactorTypePhone);
        }
      }
    }

    // Parse provider configs
    final providerConfigsData = response['providerConfigs'] as List<dynamic>?;
    final providerConfigs = <MultiFactorProviderConfig>[];

    if (providerConfigsData != null) {
      for (final configData in providerConfigsData) {
        if (configData is! Map<String, dynamic>) continue;

        final configState = configData['state'] as String?;
        if (configState == null) continue;

        final totpConfigData =
            configData['totpProviderConfig'] as Map<String, dynamic>?;
        if (totpConfigData != null) {
          final adjacentIntervals = totpConfigData['adjacentIntervals'] as int?;
          providerConfigs.add(
            MultiFactorProviderConfig(
              state: MultiFactorConfigState.fromString(configState),
              totpProviderConfig: TotpMultiFactorProviderConfig(
                adjacentIntervals: adjacentIntervals,
              ),
            ),
          );
        }
      }
    }

    return _MultiFactorAuthConfig(
      state: MultiFactorConfigState.fromString(stateValue as String),
      factorIds: factorIds.isEmpty ? null : factorIds,
      providerConfigs:
          providerConfigs, // Always return list, never null (matches Node.js SDK)
    );
  }

  static Map<String, dynamic> buildServerRequest(MultiFactorConfig options) {
    final request = <String, dynamic>{};

    request['state'] = options.state.value;

    if (options.factorIds != null) {
      final enabledProviders = <String>[];
      for (final factorId in options.factorIds!) {
        // Map client types to server types
        if (factorId == authFactorTypePhone) {
          enabledProviders.add('PHONE_SMS');
        }
      }
      request['enabledProviders'] = enabledProviders;
    }

    // Build provider configs
    if (options.providerConfigs != null) {
      final providerConfigsData = <Map<String, dynamic>>[];
      for (final config in options.providerConfigs!) {
        final configData = <String, dynamic>{'state': config.state.value};

        if (config.totpProviderConfig != null) {
          final totpData = <String, dynamic>{};
          if (config.totpProviderConfig!.adjacentIntervals != null) {
            totpData['adjacentIntervals'] =
                config.totpProviderConfig!.adjacentIntervals;
          }
          configData['totpProviderConfig'] = totpData;
        }

        providerConfigsData.add(configData);
      }
      request['providerConfigs'] = providerConfigsData;
    }

    return request;
  }

  @override
  final MultiFactorConfigState state;

  @override
  final List<AuthFactorType>? factorIds;

  @override
  final List<MultiFactorProviderConfig>? providerConfigs;

  @override
  Map<String, dynamic> toJson() => {
    'state': state.value,
    if (factorIds != null) 'factorIds': factorIds,
    if (providerConfigs != null)
      'providerConfigs': providerConfigs!.map((e) => e.toJson()).toList(),
  };
}

// ============================================================================
// SMS Region Configuration
// ============================================================================

/// The request interface for updating a SMS Region Config.
/// Configures the regions where users are allowed to send verification SMS.
/// This is based on the calling code of the destination phone number.
sealed class SmsRegionConfig {
  const SmsRegionConfig();

  Map<String, dynamic> toJson();
}

/// Defines a policy of allowing every region by default and adding disallowed
/// regions to a disallow list.
class AllowByDefaultSmsRegionConfig extends SmsRegionConfig {
  const AllowByDefaultSmsRegionConfig({required this.disallowedRegions});

  /// Two letter unicode region codes to disallow as defined by
  /// https://cldr.unicode.org/
  final List<String> disallowedRegions;

  @override
  Map<String, dynamic> toJson() => {
    'allowByDefault': {'disallowedRegions': disallowedRegions},
  };
}

/// Defines a policy of only allowing regions by explicitly adding them to an
/// allowlist.
class AllowlistOnlySmsRegionConfig extends SmsRegionConfig {
  const AllowlistOnlySmsRegionConfig({required this.allowedRegions});

  /// Two letter unicode region codes to allow as defined by
  /// https://cldr.unicode.org/
  final List<String> allowedRegions;

  @override
  Map<String, dynamic> toJson() => {
    'allowlistOnly': {'allowedRegions': allowedRegions},
  };
}

// ============================================================================
// reCAPTCHA Configuration
// ============================================================================

/// Enforcement state of reCAPTCHA protection.
enum RecaptchaProviderEnforcementState {
  off('OFF'),
  audit('AUDIT'),
  enforce('ENFORCE');

  const RecaptchaProviderEnforcementState(this.value);
  final String value;

  static RecaptchaProviderEnforcementState fromString(String value) {
    return RecaptchaProviderEnforcementState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecaptchaProviderEnforcementState.off,
    );
  }
}

/// The actions to take for reCAPTCHA-protected requests.
enum RecaptchaAction {
  block('BLOCK');

  const RecaptchaAction(this.value);
  final String value;

  static RecaptchaAction fromString(String value) {
    return RecaptchaAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecaptchaAction.block,
    );
  }
}

/// The key's platform type.
enum RecaptchaKeyClientType {
  web('WEB'),
  ios('IOS'),
  android('ANDROID');

  const RecaptchaKeyClientType(this.value);
  final String value;

  static RecaptchaKeyClientType fromString(String value) {
    return RecaptchaKeyClientType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecaptchaKeyClientType.web,
    );
  }
}

/// The config for a reCAPTCHA action rule.
class RecaptchaManagedRule {
  const RecaptchaManagedRule({required this.endScore, this.action});

  /// The action will be enforced if the reCAPTCHA score of a request is larger than endScore.
  final double endScore;

  /// The action for reCAPTCHA-protected requests.
  final RecaptchaAction? action;

  Map<String, dynamic> toJson() => {
    'endScore': endScore,
    if (action != null) 'action': action!.value,
  };
}

/// The managed rules for toll fraud provider, containing the enforcement status.
/// The toll fraud provider contains all SMS related user flows.
class RecaptchaTollFraudManagedRule {
  const RecaptchaTollFraudManagedRule({required this.startScore, this.action});

  /// The action will be enforced if the reCAPTCHA score of a request is larger than startScore.
  final double startScore;

  /// The action for reCAPTCHA-protected requests.
  final RecaptchaAction? action;

  Map<String, dynamic> toJson() => {
    'startScore': startScore,
    if (action != null) 'action': action!.value,
  };
}

/// The reCAPTCHA key config.
class RecaptchaKey {
  const RecaptchaKey({required this.key, this.type});

  /// The reCAPTCHA site key.
  final String key;

  /// The key's client platform type.
  final RecaptchaKeyClientType? type;

  Map<String, dynamic> toJson() => {
    'key': key,
    if (type != null) 'type': type!.value,
  };
}

/// The request interface for updating a reCAPTCHA Config.
/// By enabling reCAPTCHA Enterprise Integration you are
/// agreeing to reCAPTCHA Enterprise
/// [Terms of Service](https://cloud.google.com/terms/service-terms).
class RecaptchaConfig {
  RecaptchaConfig({
    this.emailPasswordEnforcementState,
    this.phoneEnforcementState,
    this.managedRules,
    this.recaptchaKeys,
    this.useAccountDefender,
    this.useSmsBotScore,
    this.useSmsTollFraudProtection,
    this.smsTollFraudManagedRules,
  });

  /// The enforcement state of the email password provider.
  final RecaptchaProviderEnforcementState? emailPasswordEnforcementState;

  /// The enforcement state of the phone provider.
  final RecaptchaProviderEnforcementState? phoneEnforcementState;

  /// The reCAPTCHA managed rules.
  final List<RecaptchaManagedRule>? managedRules;

  /// The reCAPTCHA keys.
  final List<RecaptchaKey>? recaptchaKeys;

  /// Whether to use account defender for reCAPTCHA assessment.
  final bool? useAccountDefender;

  /// Whether to use the rCE bot score for reCAPTCHA phone provider.
  /// Can only be true when the phone_enforcement_state is AUDIT or ENFORCE.
  final bool? useSmsBotScore;

  /// Whether to use the rCE SMS toll fraud protection risk score for reCAPTCHA phone provider.
  /// Can only be true when the phone_enforcement_state is AUDIT or ENFORCE.
  final bool? useSmsTollFraudProtection;

  /// The managed rules for toll fraud provider, containing the enforcement status.
  /// The toll fraud provider contains all SMS related user flows.
  final List<RecaptchaTollFraudManagedRule>? smsTollFraudManagedRules;

  Map<String, dynamic> toJson() => {
    if (emailPasswordEnforcementState != null)
      'emailPasswordEnforcementState': emailPasswordEnforcementState!.value,
    if (phoneEnforcementState != null)
      'phoneEnforcementState': phoneEnforcementState!.value,
    if (managedRules != null)
      'managedRules': managedRules!.map((e) => e.toJson()).toList(),
    if (recaptchaKeys != null)
      'recaptchaKeys': recaptchaKeys!.map((e) => e.toJson()).toList(),
    if (useAccountDefender != null) 'useAccountDefender': useAccountDefender,
    if (useSmsBotScore != null) 'useSmsBotScore': useSmsBotScore,
    if (useSmsTollFraudProtection != null)
      'useSmsTollFraudProtection': useSmsTollFraudProtection,
    if (smsTollFraudManagedRules != null)
      'smsTollFraudManagedRules': smsTollFraudManagedRules!
          .map((e) => e.toJson())
          .toList(),
  };
}

/// Internal class for reCAPTCHA authentication configuration.
class _RecaptchaAuthConfig implements RecaptchaConfig {
  _RecaptchaAuthConfig({
    this.emailPasswordEnforcementState,
    this.phoneEnforcementState,
    this.managedRules,
    this.recaptchaKeys,
    this.useAccountDefender,
    this.useSmsBotScore,
    this.useSmsTollFraudProtection,
    this.smsTollFraudManagedRules,
  });

  factory _RecaptchaAuthConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
    List<RecaptchaManagedRule>? managedRules;
    if (response['managedRules'] != null) {
      final rulesList = response['managedRules'] as List<dynamic>;
      managedRules = rulesList.map((rule) {
        final ruleMap = rule as Map<String, dynamic>;
        return RecaptchaManagedRule(
          endScore: (ruleMap['endScore'] as num).toDouble(),
          action: ruleMap['action'] != null
              ? RecaptchaAction.fromString(ruleMap['action'] as String)
              : null,
        );
      }).toList();
    }

    List<RecaptchaKey>? recaptchaKeys;
    if (response['recaptchaKeys'] != null) {
      final keysList = response['recaptchaKeys'] as List<dynamic>;
      recaptchaKeys = keysList.map((key) {
        final keyMap = key as Map<String, dynamic>;
        return RecaptchaKey(
          key: keyMap['key'] as String,
          type: keyMap['type'] != null
              ? RecaptchaKeyClientType.fromString(keyMap['type'] as String)
              : null,
        );
      }).toList();
    }

    List<RecaptchaTollFraudManagedRule>? smsTollFraudManagedRules;
    // Server response uses 'tollFraudManagedRules' but client uses 'smsTollFraudManagedRules'
    final tollFraudRules =
        response['tollFraudManagedRules'] ??
        response['smsTollFraudManagedRules'];
    if (tollFraudRules != null) {
      final rulesList = tollFraudRules as List<dynamic>;
      smsTollFraudManagedRules = rulesList.map((rule) {
        final ruleMap = rule as Map<String, dynamic>;
        return RecaptchaTollFraudManagedRule(
          startScore: (ruleMap['startScore'] as num).toDouble(),
          action: ruleMap['action'] != null
              ? RecaptchaAction.fromString(ruleMap['action'] as String)
              : null,
        );
      }).toList();
    }

    return _RecaptchaAuthConfig(
      emailPasswordEnforcementState:
          response['emailPasswordEnforcementState'] != null
          ? RecaptchaProviderEnforcementState.fromString(
              response['emailPasswordEnforcementState'] as String,
            )
          : null,
      phoneEnforcementState: response['phoneEnforcementState'] != null
          ? RecaptchaProviderEnforcementState.fromString(
              response['phoneEnforcementState'] as String,
            )
          : null,
      managedRules: managedRules,
      recaptchaKeys: recaptchaKeys,
      useAccountDefender: response['useAccountDefender'] as bool?,
      useSmsBotScore: response['useSmsBotScore'] as bool?,
      useSmsTollFraudProtection: response['useSmsTollFraudProtection'] as bool?,
      smsTollFraudManagedRules: smsTollFraudManagedRules,
    );
  }

  static Map<String, dynamic> buildServerRequest(RecaptchaConfig options) {
    _validate(options);

    final request = <String, dynamic>{};

    if (options.emailPasswordEnforcementState != null) {
      request['emailPasswordEnforcementState'] =
          options.emailPasswordEnforcementState!.value;
    }
    if (options.phoneEnforcementState != null) {
      request['phoneEnforcementState'] = options.phoneEnforcementState!.value;
    }
    if (options.managedRules != null) {
      request['managedRules'] = options.managedRules!
          .map((e) => e.toJson())
          .toList();
    }
    if (options.recaptchaKeys != null) {
      request['recaptchaKeys'] = options.recaptchaKeys!
          .map((e) => e.toJson())
          .toList();
    }
    if (options.useAccountDefender != null) {
      request['useAccountDefender'] = options.useAccountDefender;
    }
    if (options.useSmsBotScore != null) {
      request['useSmsBotScore'] = options.useSmsBotScore;
    }
    if (options.useSmsTollFraudProtection != null) {
      request['useSmsTollFraudProtection'] = options.useSmsTollFraudProtection;
    }
    // Server expects 'tollFraudManagedRules' but client uses 'smsTollFraudManagedRules'
    if (options.smsTollFraudManagedRules != null) {
      request['tollFraudManagedRules'] = options.smsTollFraudManagedRules!
          .map((e) => e.toJson())
          .toList();
    }

    return request;
  }

  static void _validate(RecaptchaConfig options) {
    if (options.managedRules != null) {
      options.managedRules!.forEach(_validateManagedRule);
    }

    // Note: In Dart, bool? is already type-checked at compile time, so we don't need runtime validation
    // But we keep the validation structure for consistency with Node.js SDK

    if (options.smsTollFraudManagedRules != null) {
      options.smsTollFraudManagedRules!.forEach(_validateTollFraudManagedRule);
    }
  }

  static void _validateManagedRule(RecaptchaManagedRule rule) {
    if (rule.action != null && rule.action != RecaptchaAction.block) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidConfig,
        '"RecaptchaManagedRule.action" must be "BLOCK".',
      );
    }
  }

  static void _validateTollFraudManagedRule(
    RecaptchaTollFraudManagedRule rule,
  ) {
    if (rule.action != null && rule.action != RecaptchaAction.block) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidConfig,
        '"RecaptchaTollFraudManagedRule.action" must be "BLOCK".',
      );
    }
  }

  @override
  final RecaptchaProviderEnforcementState? emailPasswordEnforcementState;

  @override
  final RecaptchaProviderEnforcementState? phoneEnforcementState;

  @override
  final List<RecaptchaManagedRule>? managedRules;

  @override
  final List<RecaptchaKey>? recaptchaKeys;

  @override
  final bool? useAccountDefender;

  @override
  final bool? useSmsBotScore;

  @override
  final bool? useSmsTollFraudProtection;

  @override
  final List<RecaptchaTollFraudManagedRule>? smsTollFraudManagedRules;

  @override
  Map<String, dynamic> toJson() => {
    if (emailPasswordEnforcementState != null)
      'emailPasswordEnforcementState': emailPasswordEnforcementState!.value,
    if (phoneEnforcementState != null)
      'phoneEnforcementState': phoneEnforcementState!.value,
    if (managedRules != null)
      'managedRules': managedRules!.map((e) => e.toJson()).toList(),
    if (recaptchaKeys != null)
      'recaptchaKeys': recaptchaKeys!.map((e) => e.toJson()).toList(),
    if (useAccountDefender != null) 'useAccountDefender': useAccountDefender,
    if (useSmsBotScore != null) 'useSmsBotScore': useSmsBotScore,
    if (useSmsTollFraudProtection != null)
      'useSmsTollFraudProtection': useSmsTollFraudProtection,
    if (smsTollFraudManagedRules != null)
      'smsTollFraudManagedRules': smsTollFraudManagedRules!
          .map((e) => e.toJson())
          .toList(),
  };
}

// ============================================================================
// Password Policy Configuration
// ============================================================================

/// A password policy's enforcement state.
enum PasswordPolicyEnforcementState {
  enforce('ENFORCE'),
  off('OFF');

  const PasswordPolicyEnforcementState(this.value);
  final String value;

  static PasswordPolicyEnforcementState fromString(String value) {
    return PasswordPolicyEnforcementState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PasswordPolicyEnforcementState.off,
    );
  }
}

/// Constraints to be enforced on the password policy
class CustomStrengthOptionsConfig {
  CustomStrengthOptionsConfig({
    this.requireUppercase,
    this.requireLowercase,
    this.requireNonAlphanumeric,
    this.requireNumeric,
    this.minLength,
    this.maxLength,
  });

  /// The password must contain an upper case character
  final bool? requireUppercase;

  /// The password must contain a lower case character
  final bool? requireLowercase;

  /// The password must contain a non-alphanumeric character
  final bool? requireNonAlphanumeric;

  /// The password must contain a number
  final bool? requireNumeric;

  /// Minimum password length. Valid values are from 6 to 30
  final int? minLength;

  /// Maximum password length. No default max length
  final int? maxLength;

  Map<String, dynamic> toJson() => {
    if (requireUppercase != null) 'requireUppercase': requireUppercase,
    if (requireLowercase != null) 'requireLowercase': requireLowercase,
    if (requireNonAlphanumeric != null)
      'requireNonAlphanumeric': requireNonAlphanumeric,
    if (requireNumeric != null) 'requireNumeric': requireNumeric,
    if (minLength != null) 'minLength': minLength,
    if (maxLength != null) 'maxLength': maxLength,
  };
}

/// A password policy configuration for a project or tenant
class PasswordPolicyConfig {
  PasswordPolicyConfig({
    this.enforcementState,
    this.forceUpgradeOnSignin,
    this.constraints,
  });

  /// Enforcement state of the password policy
  final PasswordPolicyEnforcementState? enforcementState;

  /// Require users to have a policy-compliant password to sign in
  final bool? forceUpgradeOnSignin;

  /// The constraints that make up the password strength policy
  final CustomStrengthOptionsConfig? constraints;

  Map<String, dynamic> toJson() => {
    if (enforcementState != null) 'enforcementState': enforcementState!.value,
    if (forceUpgradeOnSignin != null)
      'forceUpgradeOnSignin': forceUpgradeOnSignin,
    if (constraints != null) 'constraints': constraints!.toJson(),
  };
}

/// Internal class for password policy authentication configuration.
class _PasswordPolicyAuthConfig implements PasswordPolicyConfig {
  _PasswordPolicyAuthConfig({
    this.enforcementState,
    this.forceUpgradeOnSignin,
    this.constraints,
  });

  factory _PasswordPolicyAuthConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
    final stateValue = response['passwordPolicyEnforcementState'];
    if (stateValue == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Invalid password policy configuration response',
      );
    }

    CustomStrengthOptionsConfig? constraints;
    final policyVersions = response['passwordPolicyVersions'] as List<dynamic>?;
    if (policyVersions != null && policyVersions.isNotEmpty) {
      final firstVersion = policyVersions.first as Map<String, dynamic>;
      final options =
          firstVersion['customStrengthOptions'] as Map<String, dynamic>?;
      if (options != null) {
        constraints = CustomStrengthOptionsConfig(
          requireLowercase: options['containsLowercaseCharacter'] as bool?,
          requireUppercase: options['containsUppercaseCharacter'] as bool?,
          requireNonAlphanumeric:
              options['containsNonAlphanumericCharacter'] as bool?,
          requireNumeric: options['containsNumericCharacter'] as bool?,
          minLength: options['minPasswordLength'] as int?,
          maxLength: options['maxPasswordLength'] as int?,
        );
      }
    }

    return _PasswordPolicyAuthConfig(
      enforcementState: PasswordPolicyEnforcementState.fromString(
        stateValue as String,
      ),
      forceUpgradeOnSignin: response['forceUpgradeOnSignin'] as bool? ?? false,
      constraints: constraints,
    );
  }

  static Map<String, dynamic> buildServerRequest(PasswordPolicyConfig options) {
    final request = <String, dynamic>{};

    if (options.enforcementState != null) {
      request['passwordPolicyEnforcementState'] =
          options.enforcementState!.value;
    }
    request['forceUpgradeOnSignin'] = options.forceUpgradeOnSignin ?? false;

    if (options.constraints != null) {
      final constraintsRequest = <String, dynamic>{
        'containsUppercaseCharacter':
            options.constraints!.requireUppercase ?? false,
        'containsLowercaseCharacter':
            options.constraints!.requireLowercase ?? false,
        'containsNonAlphanumericCharacter':
            options.constraints!.requireNonAlphanumeric ?? false,
        'containsNumericCharacter':
            options.constraints!.requireNumeric ?? false,
        'minPasswordLength': options.constraints!.minLength ?? 6,
        'maxPasswordLength': options.constraints!.maxLength ?? 4096,
      };
      request['passwordPolicyVersions'] = [
        {'customStrengthOptions': constraintsRequest},
      ];
    }

    return request;
  }

  @override
  final PasswordPolicyEnforcementState? enforcementState;

  @override
  final bool? forceUpgradeOnSignin;

  @override
  final CustomStrengthOptionsConfig? constraints;

  @override
  Map<String, dynamic> toJson() => {
    if (enforcementState != null) 'enforcementState': enforcementState!.value,
    if (forceUpgradeOnSignin != null)
      'forceUpgradeOnSignin': forceUpgradeOnSignin,
    if (constraints != null) 'constraints': constraints!.toJson(),
  };
}

// ============================================================================
// Email Privacy Configuration
// ============================================================================

/// The email privacy configuration of a project or tenant.
class EmailPrivacyConfig {
  EmailPrivacyConfig({this.enableImprovedEmailPrivacy});

  /// Whether enhanced email privacy is enabled.
  final bool? enableImprovedEmailPrivacy;

  Map<String, dynamic> toJson() => {
    if (enableImprovedEmailPrivacy != null)
      'enableImprovedEmailPrivacy': enableImprovedEmailPrivacy,
  };
}
