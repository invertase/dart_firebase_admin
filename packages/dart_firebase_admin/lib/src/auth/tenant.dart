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

/// Interface representing the properties to update on the provided tenant.
class UpdateTenantRequest {
  UpdateTenantRequest({
    this.displayName,
    this.emailSignInConfig,
    this.anonymousSignInEnabled,
    this.multiFactorConfig,
    this.testPhoneNumbers,
    this.smsRegionConfig,
    this.recaptchaConfig,
    this.passwordPolicyConfig,
    this.emailPrivacyConfig,
  });

  /// The tenant display name.
  final String? displayName;

  /// The email sign in configuration.
  final EmailSignInProviderConfig? emailSignInConfig;

  /// Whether the anonymous provider is enabled.
  final bool? anonymousSignInEnabled;

  /// The multi-factor auth configuration to update on the tenant.
  final MultiFactorConfig? multiFactorConfig;

  /// The updated map containing the test phone number / code pairs for the tenant.
  /// Passing null clears the previously saved phone number / code pairs.
  final Map<String, String>? testPhoneNumbers;

  /// The SMS configuration to update on the project.
  final SmsRegionConfig? smsRegionConfig;

  /// The reCAPTCHA configuration to update on the tenant.
  /// By enabling reCAPTCHA Enterprise integration, you are
  /// agreeing to the reCAPTCHA Enterprise
  /// [Terms of Service](https://cloud.google.com/terms/service-terms).
  final RecaptchaConfig? recaptchaConfig;

  /// The password policy configuration for the tenant
  final PasswordPolicyConfig? passwordPolicyConfig;

  /// The email privacy configuration for the tenant
  final EmailPrivacyConfig? emailPrivacyConfig;
}

/// Interface representing the properties to set on a new tenant.
typedef CreateTenantRequest = UpdateTenantRequest;

/// Represents a tenant configuration.
///
/// Multi-tenancy support requires Google Cloud's Identity Platform
/// (GCIP). To learn more about GCIP, including pricing and features,
/// see the [GCIP documentation](https://cloud.google.com/identity-platform).
///
/// Before multi-tenancy can be used on a Google Cloud Identity Platform project,
/// tenants must be allowed on that project via the Cloud Console UI.
///
/// A tenant configuration provides information such as the display name, tenant
/// identifier and email authentication configuration.
/// For OIDC/SAML provider configuration management, `TenantAwareAuth` instances should
/// be used instead of a `Tenant` to retrieve the list of configured IdPs on a tenant.
/// When configuring these providers, note that tenants will inherit
/// whitelisted domains and authenticated redirect URIs of their parent project.
///
/// All other settings of a tenant will also be inherited. These will need to be managed
/// from the Cloud Console UI.
class Tenant {
  Tenant._({
    required this.tenantId,
    this.displayName,
    required this.anonymousSignInEnabled,
    this.testPhoneNumbers,
    _EmailSignInConfig? emailSignInConfig,
    _MultiFactorAuthConfig? multiFactorConfig,
    this.smsRegionConfig,
    _RecaptchaAuthConfig? recaptchaConfig,
    _PasswordPolicyAuthConfig? passwordPolicyConfig,
    this.emailPrivacyConfig,
  })  : _emailSignInConfig = emailSignInConfig,
        _multiFactorConfig = multiFactorConfig,
        _recaptchaConfig = recaptchaConfig,
        _passwordPolicyConfig = passwordPolicyConfig;

  /// Factory constructor to create a Tenant from a server response.
  factory Tenant._fromResponse(Map<String, dynamic> response) {
    final tenantId = _getTenantIdFromResourceName(response['name'] as String?);
    if (tenantId == null) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.internalError,
        'INTERNAL ASSERT FAILED: Invalid tenant response',
      );
    }

    _EmailSignInConfig? emailSignInConfig;
    try {
      emailSignInConfig = _EmailSignInConfig.fromServerResponse(response);
    } catch (e) {
      // If allowPasswordSignup is undefined, it is disabled by default.
      emailSignInConfig = _EmailSignInConfig(
        enabled: false,
        passwordRequired: true,
      );
    }

    _MultiFactorAuthConfig? multiFactorConfig;
    if (response['mfaConfig'] != null) {
      multiFactorConfig = _MultiFactorAuthConfig.fromServerResponse(
        response['mfaConfig'] as Map<String, dynamic>,
      );
    }

    Map<String, String>? testPhoneNumbers;
    if (response['testPhoneNumbers'] != null) {
      testPhoneNumbers = Map<String, String>.from(
        response['testPhoneNumbers'] as Map<String, dynamic>,
      );
    }

    SmsRegionConfig? smsRegionConfig;
    if (response['smsRegionConfig'] != null) {
      final config = response['smsRegionConfig'] as Map<String, dynamic>;
      if (config['allowByDefault'] != null) {
        final allowByDefault = config['allowByDefault'] as Map<String, dynamic>;
        smsRegionConfig = AllowByDefaultSmsRegionConfig(
          disallowedRegions: List<String>.from(
            (allowByDefault['disallowedRegions'] as List<dynamic>?) ?? [],
          ),
        );
      } else if (config['allowlistOnly'] != null) {
        final allowlistOnly = config['allowlistOnly'] as Map<String, dynamic>;
        smsRegionConfig = AllowlistOnlySmsRegionConfig(
          allowedRegions: List<String>.from(
            (allowlistOnly['allowedRegions'] as List<dynamic>?) ?? [],
          ),
        );
      }
    }

    _RecaptchaAuthConfig? recaptchaConfig;
    if (response['recaptchaConfig'] != null) {
      recaptchaConfig = _RecaptchaAuthConfig.fromServerResponse(
        response['recaptchaConfig'] as Map<String, dynamic>,
      );
    }

    _PasswordPolicyAuthConfig? passwordPolicyConfig;
    if (response['passwordPolicyConfig'] != null) {
      passwordPolicyConfig = _PasswordPolicyAuthConfig.fromServerResponse(
        response['passwordPolicyConfig'] as Map<String, dynamic>,
      );
    }

    EmailPrivacyConfig? emailPrivacyConfig;
    if (response['emailPrivacyConfig'] != null) {
      final config = response['emailPrivacyConfig'] as Map<String, dynamic>;
      emailPrivacyConfig = EmailPrivacyConfig(
        enableImprovedEmailPrivacy:
            config['enableImprovedEmailPrivacy'] as bool?,
      );
    }

    return Tenant._(
      tenantId: tenantId,
      displayName: response['displayName'] as String?,
      emailSignInConfig: emailSignInConfig,
      anonymousSignInEnabled: response['enableAnonymousUser'] as bool? ?? false,
      multiFactorConfig: multiFactorConfig,
      testPhoneNumbers: testPhoneNumbers,
      smsRegionConfig: smsRegionConfig,
      recaptchaConfig: recaptchaConfig,
      passwordPolicyConfig: passwordPolicyConfig,
      emailPrivacyConfig: emailPrivacyConfig,
    );
  }

  /// The tenant identifier.
  final String tenantId;

  /// The tenant display name.
  final String? displayName;

  /// Whether anonymous sign-in is enabled.
  final bool anonymousSignInEnabled;

  /// The map containing the test phone number / code pairs for the tenant.
  final Map<String, String>? testPhoneNumbers;

  /// The SMS Regions Config to update a tenant.
  /// Configures the regions where users are allowed to send verification SMS.
  /// This is based on the calling code of the destination phone number.
  final SmsRegionConfig? smsRegionConfig;

  /// The email privacy configuration for the tenant
  final EmailPrivacyConfig? emailPrivacyConfig;

  final _EmailSignInConfig? _emailSignInConfig;
  final _MultiFactorAuthConfig? _multiFactorConfig;
  final _RecaptchaAuthConfig? _recaptchaConfig;
  final _PasswordPolicyAuthConfig? _passwordPolicyConfig;

  /// The email sign in provider configuration.
  EmailSignInProviderConfig? get emailSignInConfig => _emailSignInConfig;

  /// The multi-factor auth configuration on the current tenant.
  MultiFactorConfig? get multiFactorConfig => _multiFactorConfig;

  /// The recaptcha config auth configuration of the current tenant.
  RecaptchaConfig? get recaptchaConfig => _recaptchaConfig;

  /// The password policy configuration for the tenant
  PasswordPolicyConfig? get passwordPolicyConfig => _passwordPolicyConfig;

  /// Builds the corresponding server request for a TenantOptions object.
  ///
  /// [tenantOptions] - The properties to convert to a server request.
  /// [createRequest] - Whether this is a create request.
  /// Returns the equivalent server request.
  static Map<String, dynamic> _buildServerRequest(
    UpdateTenantRequest tenantOptions,
    bool createRequest,
  ) {
    _validate(tenantOptions, createRequest);
    final request = <String, dynamic>{};

    if (tenantOptions.emailSignInConfig != null) {
      final emailConfig = _EmailSignInConfig.buildServerRequest(
        tenantOptions.emailSignInConfig!,
      );
      request.addAll(emailConfig);
    }

    if (tenantOptions.displayName != null) {
      request['displayName'] = tenantOptions.displayName;
    }

    if (tenantOptions.anonymousSignInEnabled != null) {
      request['enableAnonymousUser'] = tenantOptions.anonymousSignInEnabled;
    }

    if (tenantOptions.multiFactorConfig != null) {
      request['mfaConfig'] = _MultiFactorAuthConfig.buildServerRequest(
        tenantOptions.multiFactorConfig!,
      );
    }

    if (tenantOptions.testPhoneNumbers != null) {
      // null will clear existing test phone numbers. Translate to empty object.
      request['testPhoneNumbers'] = tenantOptions.testPhoneNumbers ?? {};
    }

    if (tenantOptions.smsRegionConfig != null) {
      request['smsRegionConfig'] = tenantOptions.smsRegionConfig!.toJson();
    }

    if (tenantOptions.recaptchaConfig != null) {
      request['recaptchaConfig'] = _RecaptchaAuthConfig.buildServerRequest(
        tenantOptions.recaptchaConfig!,
      );
    }

    if (tenantOptions.passwordPolicyConfig != null) {
      request['passwordPolicyConfig'] =
          _PasswordPolicyAuthConfig.buildServerRequest(
        tenantOptions.passwordPolicyConfig!,
      );
    }

    if (tenantOptions.emailPrivacyConfig != null) {
      request['emailPrivacyConfig'] =
          tenantOptions.emailPrivacyConfig!.toJson();
    }

    return request;
  }

  /// Returns the tenant ID corresponding to the resource name if available.
  ///
  /// [resourceName] - The server side resource name
  /// Returns the tenant ID corresponding to the resource, null otherwise.
  static String? _getTenantIdFromResourceName(String? resourceName) {
    if (resourceName == null) return null;
    // name is of form projects/project1/tenants/tenant1
    final match = RegExp(r'/tenants/(.*)$').firstMatch(resourceName);
    if (match == null || match.groupCount < 1) {
      return null;
    }
    return match.group(1);
  }

  /// Validates a tenant options object. Throws an error on failure.
  ///
  /// [request] - The tenant options object to validate.
  /// [createRequest] - Whether this is a create request.
  static void _validate(UpdateTenantRequest request, bool createRequest) {
    final label = createRequest ? 'CreateTenantRequest' : 'UpdateTenantRequest';

    // Validate displayName if provided.
    if (request.displayName != null && request.displayName!.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        '"$label.displayName" must be a valid non-empty string.',
      );
    }

    // Validate testPhoneNumbers if provided.
    if (request.testPhoneNumbers != null) {
      _validateTestPhoneNumbers(request.testPhoneNumbers!);
    } else if (request.testPhoneNumbers == null && createRequest) {
      // null is not allowed for create operations.
      // Empty map is allowed though.
    }
  }

  /// Validates the provided map of test phone number / code pairs.
  static void _validateTestPhoneNumbers(Map<String, String> testPhoneNumbers) {
    const maxTestPhoneNumbers = 10;

    if (testPhoneNumbers.length > maxTestPhoneNumbers) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.maximumTestPhoneNumberExceeded,
        'Maximum of $maxTestPhoneNumbers test phone numbers allowed.',
      );
    }

    testPhoneNumbers.forEach((phoneNumber, code) {
      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidTestingPhoneNumber,
          '"$phoneNumber" is not a valid E.164 standard compliant phone number.',
        );
      }

      // Validate code format (6 digits)
      if (!RegExp(r'^\d{6}$').hasMatch(code)) {
        throw FirebaseAuthAdminException(
          AuthClientErrorCode.invalidTestingPhoneNumber,
          '"$code" is not a valid 6 digit code string.',
        );
      }
    });
  }

  /// Basic phone number validation (E.164 format).
  static bool _isValidPhoneNumber(String phoneNumber) {
    // E.164 format: +[country code][number]
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phoneNumber);
  }

  /// Returns a JSON-serializable representation of this object.
  Map<String, dynamic> toJson() {
    final sms = smsRegionConfig;
    final emailPrivacy = emailPrivacyConfig;

    final json = <String, dynamic>{
      'tenantId': tenantId,
      if (displayName != null) 'displayName': displayName,
      if (_emailSignInConfig != null)
        'emailSignInConfig': _emailSignInConfig.toJson(),
      if (_multiFactorConfig != null)
        'multiFactorConfig': _multiFactorConfig.toJson(),
      'anonymousSignInEnabled': anonymousSignInEnabled,
      if (testPhoneNumbers != null) 'testPhoneNumbers': testPhoneNumbers,
      if (sms != null) 'smsRegionConfig': sms.toJson(),
      if (_recaptchaConfig != null)
        'recaptchaConfig': _recaptchaConfig.toJson(),
      if (_passwordPolicyConfig != null)
        'passwordPolicyConfig': _passwordPolicyConfig.toJson(),
      if (emailPrivacy != null) 'emailPrivacyConfig': emailPrivacy.toJson(),
    };
    return json;
  }
}
