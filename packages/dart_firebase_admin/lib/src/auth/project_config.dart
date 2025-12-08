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
// Mobile Links Configuration
// ============================================================================

/// Open code in app domain to use for app links and universal links.
enum MobileLinksDomain {
  /// Use Firebase Hosting domain.
  hostingDomain('HOSTING_DOMAIN'),

  /// Use Firebase Dynamic Link domain.
  firebaseDynamicLinkDomain('FIREBASE_DYNAMIC_LINK_DOMAIN');

  const MobileLinksDomain(this.value);
  final String value;

  static MobileLinksDomain fromString(String value) {
    return MobileLinksDomain.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'Invalid MobileLinksDomain value: $value',
      ),
    );
  }
}

/// Configuration for mobile links (app links and universal links).
class MobileLinksConfig {
  const MobileLinksConfig({this.domain});

  /// Use Firebase Hosting or dynamic link domain as the out-of-band code domain.
  final MobileLinksDomain? domain;

  Map<String, dynamic> toJson() => {
    if (domain != null) 'domain': domain!.value,
  };
}

/// Internal class for mobile links configuration.
class _MobileLinksAuthConfig implements MobileLinksConfig {
  _MobileLinksAuthConfig({this.domain});

  factory _MobileLinksAuthConfig.fromServerResponse(
    Map<String, dynamic> response,
  ) {
    final domainValue = response['domain'] as String?;
    return _MobileLinksAuthConfig(
      domain: domainValue != null
          ? MobileLinksDomain.fromString(domainValue)
          : null,
    );
  }

  @override
  final MobileLinksDomain? domain;

  @override
  Map<String, dynamic> toJson() => {
    if (domain != null) 'domain': domain!.value,
  };
}

// ============================================================================
// Update Project Config Request
// ============================================================================

/// Interface representing the properties to update on the provided project config.
class UpdateProjectConfigRequest {
  const UpdateProjectConfigRequest({
    this.smsRegionConfig,
    this.multiFactorConfig,
    this.recaptchaConfig,
    this.passwordPolicyConfig,
    this.emailPrivacyConfig,
    this.mobileLinksConfig,
  });

  /// The SMS configuration to update on the project.
  final SmsRegionConfig? smsRegionConfig;

  /// The multi-factor auth configuration to update on the project.
  final MultiFactorConfig? multiFactorConfig;

  /// The reCAPTCHA configuration to update on the project.
  /// By enabling reCAPTCHA Enterprise integration, you are
  /// agreeing to the reCAPTCHA Enterprise
  /// [Terms of Service](https://cloud.google.com/terms/service-terms).
  final RecaptchaConfig? recaptchaConfig;

  /// The password policy configuration to update on the project.
  final PasswordPolicyConfig? passwordPolicyConfig;

  /// The email privacy configuration to update on the project.
  final EmailPrivacyConfig? emailPrivacyConfig;

  /// The mobile links configuration for the project.
  final MobileLinksConfig? mobileLinksConfig;

  /// Validates the request. Throws an error on failure.
  void validate() {
    // Individual config validations would go here
    // For now, we'll rely on the individual config classes to validate themselves
  }

  /// Builds the server request from this config request.
  Map<String, dynamic> buildServerRequest() {
    validate();

    final request = <String, dynamic>{};

    if (smsRegionConfig != null) {
      request['smsRegionConfig'] = smsRegionConfig!.toJson();
    }

    if (multiFactorConfig != null) {
      request['mfa'] = _MultiFactorAuthConfig.buildServerRequest(
        multiFactorConfig!,
      );
    }

    if (recaptchaConfig != null) {
      request['recaptchaConfig'] = _RecaptchaAuthConfig.buildServerRequest(
        recaptchaConfig!,
      );
    }

    if (passwordPolicyConfig != null) {
      request['passwordPolicyConfig'] =
          _PasswordPolicyAuthConfig.buildServerRequest(passwordPolicyConfig!);
    }

    if (emailPrivacyConfig != null) {
      request['emailPrivacyConfig'] = emailPrivacyConfig!.toJson();
    }

    if (mobileLinksConfig != null) {
      request['mobileLinksConfig'] = mobileLinksConfig!.toJson();
    }

    return request;
  }
}

// ============================================================================
// Project Config
// ============================================================================

/// Represents a project configuration.
class ProjectConfig {
  const ProjectConfig({
    this.smsRegionConfig,
    this.multiFactorConfig,
    this.recaptchaConfig,
    this.passwordPolicyConfig,
    this.emailPrivacyConfig,
    this.mobileLinksConfig,
  });

  /// Creates a ProjectConfig from a server response.
  factory ProjectConfig.fromServerResponse(Map<String, dynamic> response) {
    // Parse SMS Region Config
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

    // Parse Email Privacy Config
    EmailPrivacyConfig? emailPrivacyConfig;
    if (response['emailPrivacyConfig'] != null) {
      final config = response['emailPrivacyConfig'] as Map<String, dynamic>;
      emailPrivacyConfig = EmailPrivacyConfig(
        enableImprovedEmailPrivacy:
            config['enableImprovedEmailPrivacy'] as bool?,
      );
    }

    return ProjectConfig(
      smsRegionConfig: smsRegionConfig,
      // Backend API returns "mfa" for project config
      multiFactorConfig: response['mfa'] != null
          ? _MultiFactorAuthConfig.fromServerResponse(
              response['mfa'] as Map<String, dynamic>,
            )
          : null,
      recaptchaConfig: response['recaptchaConfig'] != null
          ? _RecaptchaAuthConfig.fromServerResponse(
              response['recaptchaConfig'] as Map<String, dynamic>,
            )
          : null,
      passwordPolicyConfig: response['passwordPolicyConfig'] != null
          ? _PasswordPolicyAuthConfig.fromServerResponse(
              response['passwordPolicyConfig'] as Map<String, dynamic>,
            )
          : null,
      emailPrivacyConfig: emailPrivacyConfig,
      mobileLinksConfig: response['mobileLinksConfig'] != null
          ? _MobileLinksAuthConfig.fromServerResponse(
              response['mobileLinksConfig'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The SMS Regions Config for the project.
  /// Configures the regions where users are allowed to send verification SMS.
  /// This is based on the calling code of the destination phone number.
  final SmsRegionConfig? smsRegionConfig;

  /// The project's multi-factor auth configuration.
  /// Supports only phone and TOTP.
  final MultiFactorConfig? multiFactorConfig;

  /// The reCAPTCHA configuration for the project.
  /// By enabling reCAPTCHA Enterprise integration, you are
  /// agreeing to the reCAPTCHA Enterprise
  /// [Terms of Service](https://cloud.google.com/terms/service-terms).
  final RecaptchaConfig? recaptchaConfig;

  /// The password policy configuration for the project.
  final PasswordPolicyConfig? passwordPolicyConfig;

  /// The email privacy configuration for the project.
  final EmailPrivacyConfig? emailPrivacyConfig;

  /// The mobile links configuration for the project.
  final MobileLinksConfig? mobileLinksConfig;

  /// Returns a JSON-serializable representation of this object.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (smsRegionConfig != null) {
      json['smsRegionConfig'] = smsRegionConfig!.toJson();
    }
    if (multiFactorConfig != null) {
      json['multiFactorConfig'] = multiFactorConfig!.toJson();
    }
    if (recaptchaConfig != null) {
      json['recaptchaConfig'] = recaptchaConfig!.toJson();
    }
    if (passwordPolicyConfig != null) {
      json['passwordPolicyConfig'] = passwordPolicyConfig!.toJson();
    }
    if (emailPrivacyConfig != null) {
      json['emailPrivacyConfig'] = emailPrivacyConfig!.toJson();
    }
    if (mobileLinksConfig != null) {
      json['mobileLinksConfig'] = mobileLinksConfig!.toJson();
    }

    return json;
  }
}
