import 'package:freezed_annotation/freezed_annotation.dart';

import 'ap_check_api_internal.dart';
import 'app_check.dart';

class AppCheckToken {
  @internal
  AppCheckToken({required this.token, required this.ttlMillis});

  /// The Firebase App Check token.
  final String token;

  /// The time-to-live duration of the token in milliseconds.
  final int ttlMillis;
}

class AppCheckTokenOptions {
  AppCheckTokenOptions({
    this.ttlMillis,
  }) {
    if (ttlMillis case final ttlMillis?) {
      if (ttlMillis.inMinutes < 30 || ttlMillis.inDays > 7) {
        throw FirebaseAppCheckException(
          AppCheckErrorCode.invalidArgument,
          'ttlMillis must be a duration in milliseconds between 30 minutes and 7 days (inclusive).',
        );
      }
    }
  }

  /// The length of time, in milliseconds, for which the App Check token will
  /// be valid. This value must be between 30 minutes and 7 days, inclusive.
  final Duration? ttlMillis;
}

class VerifyAppCheckTokenOptions {
  /// To use the replay protection feature, set this to `true`. The [AppCheck.verifyToken]
  /// method will mark the token as consumed after verifying it.
  ///
  /// Tokens that are found to be already consumed will be marked as such in the response.
  ///
  /// Tokens are only considered to be consumed if it is sent to App Check backend by calling the
  /// [AppCheck.verifyToken] method with this field set to `true`; other uses of the token
  /// do not consume it.
  ///
  /// This replay protection feature requires an additional network call to the App Check backend
  /// and forces your clients to obtain a fresh attestation from your chosen attestation providers.
  /// This can therefore negatively impact performance and can potentially deplete your attestation
  /// providers' quotas faster. We recommend that you use this feature only for protecting
  /// low volume, security critical, or expensive operations.
  bool? consume;
}

class VerifyAppCheckTokenResponse {
  @internal
  VerifyAppCheckTokenResponse({
    required this.appId,
    required this.token,
    required this.alreadyConsumed,
  });

  /// The App ID corresponding to the App the App Check token belonged to.
  final String appId;

  /// The decoded Firebase App Check token.
  final DecodedAppCheckToken token;

  /// Indicates weather this token was already consumed.
  /// If this is the first time [AppCheck.verifyToken] method has seen this token,
  /// this field will contain the value `false`. The given token will then be
  /// marked as `already_consumed` for all future invocations of this [AppCheck.verifyToken]
  /// method for this token.
  ///
  /// When this field is `true`, the caller is attempting to reuse a previously consumed token.
  /// You should take precautions against such a caller; for example, you can take actions such as
  /// rejecting the request or ask the caller to pass additional layers of security checks.
  final bool? alreadyConsumed;
}

class DecodedAppCheckToken {
  DecodedAppCheckToken._({
    required this.iss,
    required this.sub,
    required this.aud,
    required this.exp,
    required this.iat,
    required this.appId,
  });

  DecodedAppCheckToken.fromMap(Map<String, dynamic> map)
      : this._(
          iss: map['iss'] as String,
          sub: map['sub'] as String,
          aud: (map['aud'] as List).cast<String>(),
          exp: map['exp'] as int,
          iat: map['iat'] as int,
          appId: map['sub'] as String,
        );

  /// The issuer identifier for the issuer of the response.
  /// This value is a URL with the format
  /// `https://firebaseappcheck.googleapis.com/<PROJECT_NUMBER>`, where `<PROJECT_NUMBER>` is the
  /// same project number specified in the [DecodedAppCheckToken.aud] property.
  final String iss;

  /// The Firebase App ID corresponding to the app the token belonged to.
  /// As a convenience, this value is copied over to the [appId] property.
  final String sub;

  /// The audience for which this token is intended.
  /// This value is a JSON array of two strings, the first is the project number of your
  /// Firebase project, and the second is the project ID of the same project.
  final List<String> aud;

  /// The App Check token's expiration time, in seconds since the Unix epoch. That is, the
  /// time at which this App Check token expires and should no longer be considered valid.
  final int exp;

  /// The App Check token's issued-at time, in seconds since the Unix epoch. That is, the
  /// time at which this App Check token was issued and should start to be considered
  /// valid.
  final int iat;

  /// The App ID corresponding to the App the App Check token belonged to.
  /// This value is not actually one of the JWT token claims. It is added as a
  /// convenience, and is set as the value of the [DecodedAppCheckToken.sub] property.
  final String appId;
}
