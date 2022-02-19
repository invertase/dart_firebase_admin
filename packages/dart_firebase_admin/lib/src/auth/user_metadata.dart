part of dart_firebase_admin;

class UserMetadata {
  UserMetadata._(this._delegate);

  final firebase_auth_v1.GoogleCloudIdentitytoolkitV1UserInfo _delegate;

  DateTime get creationTime => DateTime.fromMillisecondsSinceEpoch(
        int.parse(_delegate.createdAt!),
      );

  DateTime get lastSignInTime => DateTime.fromMillisecondsSinceEpoch(
        int.parse(_delegate.lastLoginAt!),
      );

  DateTime? get lastRefreshTime => _delegate.lastRefreshAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          int.parse(_delegate.lastRefreshAt!),
        );
}
