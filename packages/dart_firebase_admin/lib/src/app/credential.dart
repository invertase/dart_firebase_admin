class ServiceAccount {
  ServiceAccount({
    required this.projectId,
    required this.clientEmail,
    required this.privateKey,
  });

  final String? projectId;
  final String? clientEmail;
  final String? privateKey;
}

/// Interface for Google OAuth 2.0 access tokens.
class GoogleOAuthAccessToken {
  GoogleOAuthAccessToken({required this.accessToken, required this.expiresIn});

  final String accessToken;
  final int expiresIn;
}

/// Interface that provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
///
/// In most cases, you will not need to implement this yourself and can instead
/// use the default implementations provided by the `firebase-admin/app` module.
abstract class Credential {
  /// Returns a Google OAuth2 access token object used to authenticate with
  /// Firebase services.
  ///
  /// @returns A Google OAuth2 access token object.
  Future<GoogleOAuthAccessToken> getAccessToken();
}
