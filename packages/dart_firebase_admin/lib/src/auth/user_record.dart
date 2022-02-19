part of dart_firebase_admin;

class UserRecord {
  UserRecord._(this._delegate);

  final firebase_auth_v1.GoogleCloudIdentitytoolkitV1UserInfo _delegate;

  Map<String, Object>? get customClaims => _delegate.customAttributes == null
      ? null
      : jsonDecode(_delegate.customAttributes!);

  bool get disabled => _delegate.disabled ?? false;

  String? get displayName => _delegate.displayName;

  String? get email => _delegate.email;

  UserMetadata get metadata => UserMetadata._(_delegate);

  Object get multiFactor => {};

  String? get passwordHash => _delegate.passwordHash;

  String? get passwordSalt => _delegate.salt;

  String? get phoneNumber => _delegate.phoneNumber;

  String? get photoURL => _delegate.photoUrl;

  List<UserInfo> get providerData =>
      _delegate.providerUserInfo?.map((p) => UserInfo._(p)).toList() ?? [];

  String? get tenantId => _delegate.tenantId;

  DateTime? get tokensValidAfterTime => _delegate.validSince == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          int.parse(_delegate.validSince! * 1000),
        );

  String get uid => _delegate.localId!;
}
