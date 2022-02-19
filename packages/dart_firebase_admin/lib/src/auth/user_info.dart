part of dart_firebase_admin;

class UserInfo {
  UserInfo._(this._delegate);

  final firebase_auth_v1.GoogleCloudIdentitytoolkitV1ProviderUserInfo _delegate;

  String get displayName => _delegate.displayName!;

  String get email => _delegate.email!;

  String get phoneNumber => _delegate.phoneNumber!;

  String get photoURL => _delegate.photoUrl!;

  String get providerId => _delegate.providerId!;

  String get uid => _delegate.rawId!;
}
