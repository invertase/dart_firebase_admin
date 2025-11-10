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
  EmailSignInProviderConfig({
    required this.enabled,
    this.passwordRequired,
  });

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
  _EmailSignInConfig({
    required this.enabled,
    this.passwordRequired,
  });

  factory _EmailSignInConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
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

/// Interface representing a multi-factor configuration.
class MultiFactorConfig {
  MultiFactorConfig({
    required this.state,
    this.factorIds,
  });

  /// The multi-factor config state.
  final MultiFactorConfigState state;

  /// The list of identifiers for enabled second factors.
  /// Currently only 'phone' is supported.
  final List<AuthFactorType>? factorIds;

  Map<String, dynamic> toJson() => {
        'state': state.value,
        if (factorIds != null) 'factorIds': factorIds,
      };
}

/// Internal class for multi-factor authentication configuration.
class _MultiFactorAuthConfig implements MultiFactorConfig {
  _MultiFactorAuthConfig({
    required this.state,
    this.factorIds,
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

    return _MultiFactorAuthConfig(
      state: MultiFactorConfigState.fromString(stateValue as String),
      factorIds: factorIds.isEmpty ? null : factorIds,
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

    return request;
  }

  @override
  final MultiFactorConfigState state;

  @override
  final List<AuthFactorType>? factorIds;

  @override
  Map<String, dynamic> toJson() => {
        'state': state.value,
        if (factorIds != null) 'factorIds': factorIds,
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
  const AllowByDefaultSmsRegionConfig({
    required this.disallowedRegions,
  });

  /// Two letter unicode region codes to disallow as defined by
  /// https://cldr.unicode.org/
  final List<String> disallowedRegions;

  @override
  Map<String, dynamic> toJson() => {
        'allowByDefault': {
          'disallowedRegions': disallowedRegions,
        },
      };
}

/// Defines a policy of only allowing regions by explicitly adding them to an
/// allowlist.
class AllowlistOnlySmsRegionConfig extends SmsRegionConfig {
  const AllowlistOnlySmsRegionConfig({
    required this.allowedRegions,
  });

  /// Two letter unicode region codes to allow as defined by
  /// https://cldr.unicode.org/
  final List<String> allowedRegions;

  @override
  Map<String, dynamic> toJson() => {
        'allowlistOnly': {
          'allowedRegions': allowedRegions,
        },
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

/// The request interface for updating a reCAPTCHA Config.
/// By enabling reCAPTCHA Enterprise Integration you are
/// agreeing to reCAPTCHA Enterprise
/// [Terms of Service](https://cloud.google.com/terms/service-terms).
class RecaptchaConfig {
  RecaptchaConfig({
    this.emailPasswordEnforcementState,
    this.phoneEnforcementState,
    this.useAccountDefender,
  });

  /// The enforcement state of the email password provider.
  final RecaptchaProviderEnforcementState? emailPasswordEnforcementState;

  /// The enforcement state of the phone provider.
  final RecaptchaProviderEnforcementState? phoneEnforcementState;

  /// Whether to use account defender for reCAPTCHA assessment.
  final bool? useAccountDefender;

  Map<String, dynamic> toJson() => {
        if (emailPasswordEnforcementState != null)
          'emailPasswordEnforcementState': emailPasswordEnforcementState!.value,
        if (phoneEnforcementState != null)
          'phoneEnforcementState': phoneEnforcementState!.value,
        if (useAccountDefender != null)
          'useAccountDefender': useAccountDefender,
      };
}

/// Internal class for reCAPTCHA authentication configuration.
class _RecaptchaAuthConfig implements RecaptchaConfig {
  _RecaptchaAuthConfig({
    this.emailPasswordEnforcementState,
    this.phoneEnforcementState,
    this.useAccountDefender,
  });

  factory _RecaptchaAuthConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
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
      useAccountDefender: response['useAccountDefender'] as bool?,
    );
  }

  static Map<String, dynamic> buildServerRequest(RecaptchaConfig options) {
    final request = <String, dynamic>{};

    if (options.emailPasswordEnforcementState != null) {
      request['emailPasswordEnforcementState'] =
          options.emailPasswordEnforcementState!.value;
    }
    if (options.phoneEnforcementState != null) {
      request['phoneEnforcementState'] = options.phoneEnforcementState!.value;
    }
    if (options.useAccountDefender != null) {
      request['useAccountDefender'] = options.useAccountDefender;
    }

    return request;
  }

  @override
  final RecaptchaProviderEnforcementState? emailPasswordEnforcementState;

  @override
  final RecaptchaProviderEnforcementState? phoneEnforcementState;

  @override
  final bool? useAccountDefender;

  @override
  Map<String, dynamic> toJson() => {
        if (emailPasswordEnforcementState != null)
          'emailPasswordEnforcementState': emailPasswordEnforcementState!.value,
        if (phoneEnforcementState != null)
          'phoneEnforcementState': phoneEnforcementState!.value,
        if (useAccountDefender != null)
          'useAccountDefender': useAccountDefender,
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
        if (enforcementState != null)
          'enforcementState': enforcementState!.value,
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
      enforcementState:
          PasswordPolicyEnforcementState.fromString(stateValue as String),
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
        if (enforcementState != null)
          'enforcementState': enforcementState!.value,
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
  EmailPrivacyConfig({
    this.enableImprovedEmailPrivacy,
  });

  /// Whether enhanced email privacy is enabled.
  final bool? enableImprovedEmailPrivacy;

  Map<String, dynamic> toJson() => {
        if (enableImprovedEmailPrivacy != null)
          'enableImprovedEmailPrivacy': enableImprovedEmailPrivacy,
      };
}
