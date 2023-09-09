import '../dart_firebase_admin.dart';
import '../utils/error.dart';
import '../utils/jwt.dart';

class FirebaseTokenInfo {
  FirebaseTokenInfo({
    required this.url,
    required this.verifyApiName,
    required this.jwtName,
    required this.shortName,
    required this.expiredErrorCode,
  }) {
    if (verifyApiName.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'The JWT verify API name must be a non-empty string.',
      );
    }
    if (jwtName.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'The JWT public full name must be a non-empty string.',
      );
    }
    if (shortName.isEmpty) {
      throw FirebaseAuthAdminException(
        AuthClientErrorCode.invalidArgument,
        'The JWT public full name must be a non-empty string.',
      );
    }
  }

  /// Documentation URL.
  final Uri url;

  /// verify API name.
  final String verifyApiName;

  /// The JWT full name.
  final String jwtName;

  /// The JWT short name.
  final String shortName;

  /// JWT Expiration error code.
  final ErrorInfo expiredErrorCode;
}

class FirebaseTokenVerifier {
  FirebaseTokenVerifier({
    required Uri clientCertUrl,
    required this.issuer,
    required this.tokenInfo,
    required this.app,
  })  : _shortNameArticle = RegExp('[aeiou]', caseSensitive: false)
                .hasMatch(tokenInfo.shortName[0])
            ? 'an'
            : 'a',
        _signatureVerifier =
            PublicKeySignatureVerifier.withCertificateUrl(clientCertUrl);

  final String _shortNameArticle;
  final Uri issuer;
  final FirebaseAdminApp app;
  final FirebaseTokenInfo tokenInfo;
  final SignatureVerifier _signatureVerifier;
}

class TokenProvider {
  // TODO  optional parameters
  TokenProvider({
    required this.identities,
    required this.signInProvider,
    required this.signInSecondFactor,
    required this.secondFactorIdentifier,
    required this.tenant,
  });

  /// Provider-specific identity details corresponding
  /// to the provider used to sign in the user.
  final Map<String, Object?> identities;

  /// The ID of the provider used to sign in the user.
  /// One of `"anonymous"`, `"password"`, `"facebook.com"`, `"github.com"`,
  /// `"google.com"`, `"twitter.com"`, `"apple.com"`, `"microsoft.com"`,
  /// `"yahoo.com"`, `"phone"`, `"playgames.google.com"`, `"gc.apple.com"`,
  /// or `"custom"`.
  ///
  /// Additional Identity Platform provider IDs include `"linkedin.com"`,
  /// OIDC and SAML identity providers prefixed with `"saml."` and `"oidc."`
  /// respectively.
  final String signInProvider;

  /// The type identifier or `factorId` of the second factor, provided the
  /// ID token was obtained from a multi-factor authenticated user.
  /// For phone, this is `"phone"`.
  final String? signInSecondFactor;

  /// The `uid` of the second factor used to sign in, provided the
  /// ID token was obtained from a multi-factor authenticated user.
  final String? secondFactorIdentifier;

  /// The ID of the tenant the user belongs to, if available.
  final String? tenant;
  // TODO allow any key
  // [key: string]: any;
}

/// Interface representing a decoded Firebase ID token, returned from the
/// {@link BaseAuth.verifyIdToken} method.
///
/// Firebase ID tokens are OpenID Connect spec-compliant JSON Web Tokens (JWTs).
/// See the
/// [ID Token section of the OpenID Connect spec](http://openid.net/specs/openid-connect-core-1_0.html#IDToken)
/// for more information about the specific properties below.
class DecodedIdToken {
  // TODO  optional parameters
  DecodedIdToken({
    required this.aud,
    required this.authTime,
    required this.email,
    required this.emailVerified,
    required this.exp,
    required this.firebase,
    required this.iat,
    required this.iss,
    required this.phoneNumber,
    required this.picture,
    required this.sub,
    required this.uid,
  });

  /// The audience for which this token is intended.
  ///
  /// This value is a string equal to your Firebase project ID, the unique
  /// identifier for your Firebase project, which can be found in [your project's
  /// settings](https://console.firebase.google.com/project/_/settings/general/android:com.random.android).
  final String aud;

  /// Time, in seconds since the Unix epoch, when the end-user authentication
  /// occurred.
  ///
  /// This value is not set when this particular ID token was created, but when the
  /// user initially logged in to this session. In a single session, the Firebase
  /// SDKs will refresh a user's ID tokens every hour. Each ID token will have a
  /// different [`iat`](#iat) value, but the same `auth_time` value.
  final DateTime authTime;

  /// The email of the user to whom the ID token belongs, if available.
  final String? email;

  /// Whether or not the email of the user to whom the ID token belongs is
  /// verified, provided the user has an email.
  final bool? emailVerified;

  /// The ID token's expiration time, in seconds since the Unix epoch. That is, the
  /// time at which this ID token expires and should no longer be considered valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with up to a one hour expiration.
  final int exp;

  /// Information about the sign in event, including which sign in provider was
  /// used and provider-specific identity details.
  ///
  /// This data is provided by the Firebase Authentication service and is a
  /// reserved claim in the ID token.
  final TokenProvider firebase;

  /// The ID token's issued-at time, in seconds since the Unix epoch. That is, the
  /// time at which this ID token was issued and should start to be considered
  /// valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with a new issued-at time. If you want to get the time at which the
  /// user session corresponding to the ID token initially occurred, see the
  /// [`auth_time`](#auth_time) property.
  final int iat;

  /// The issuer identifier for the issuer of the response.
  ///
  /// This value is a URL with the format
  /// `https://securetoken.google.com/<PROJECT_ID>`, where `<PROJECT_ID>` is the
  /// same project ID specified in the [`aud`](#aud) property.
  final String iss;

  /// The phone number of the user to whom the ID token belongs, if available.
  final String? phoneNumber;

  /// The photo URL for the user to whom the ID token belongs, if available.
  final String? picture;

  /// The `uid` corresponding to the user who the ID token belonged to.
  ///
  /// As a convenience, this value is copied over to the [`uid`](#uid) property.
  final String sub;

  /// The `uid` corresponding to the user who the ID token belonged to.
  ///
  /// This value is not actually in the JWT token claims itself. It is added as a
  /// convenience, and is set as the value of the [`sub`](#sub) property.
  final String uid;

  /**
   * Other arbitrary claims included in the ID token.
   */
  // TODO allow any key
  // [key: string]: any;
}
