part of dart_firebase_admin;

class FirebaseAdminAuth {
  FirebaseAdminAuth(this.app);
  final FirebaseAdminApp app;

  auth.AuthClient? _client;

  Object tenantManager() {
    return {};
  }

  Future<firebase_auth.IdentityToolkitApi> _getApi() async {
    final client = _client ??= await app._credential._getAuthClient([]);
    return firebase_auth.IdentityToolkitApi(client);
  }

  Future<String> createCustomToken(String uid,
      [Map<String, String>? developerClaims]) async {
    throw UnimplementedError();
  }

  Future<Object> createProviderConfig(Object config) async {
    throw UnimplementedError();
  }

  Future<String> createSessionCookie(
    String idToken,
    Object sessionCookieOptions,
  ) async {
    throw UnimplementedError();
  }

  Future<Object> createUser(
    Object properties,
  ) async {
    throw UnimplementedError();
  }

  Future<void> deleteProviderConfig(
    String providerId,
  ) async {
    return;
  }

  Future<Object> deleteUser(
    String uid,
  ) async {
    throw UnimplementedError();
  }

  Future<Object> deleteUsers(
    List<String> uids,
  ) async {
    throw UnimplementedError();
  }

  Future<String> generateEmailVerificationLink(String email,
      [Object? actionCodeSettings]) async {
    throw UnimplementedError();
  }

  Future<String> generatePasswordResetLink(String email,
      [Object? actionCodeSettings]) async {
    throw UnimplementedError();
  }

  Future<String> generateSignInWithEmailLink(
      String email, Object actionCodeSettings) async {
    throw UnimplementedError();
  }

  Future<Object> getProviderConfig(String providerId) async {
    throw UnimplementedError();
  }

  Future<Object> getUser(String uid) async {
    throw UnimplementedError();
  }

  Future<Object> getUserByEmail(String email) async {
    throw UnimplementedError();
  }

  Future<Object> getUserByPhoneNumber(String phoneNumber) async {
    throw UnimplementedError();
  }

  Future<Object> getUserByProviderUid(String providerId, String uid) async {
    throw UnimplementedError();
  }

  Future<Object> getUsers(List<Object> identifiers) async {
    throw UnimplementedError();
  }

  Future<Object> importUsers(List<Object> users, [Object? options]) async {
    throw UnimplementedError();
  }

  Future<Object> listProviderConfigs(Object options) async {
    throw UnimplementedError();
  }

  Future<Object> listUsers({int? maxResults = 1000, String? pageToken}) async {
    throw UnimplementedError();
  }

  Future<void> revokeRefreshTokens(String uid) async {
    throw UnimplementedError();
  }

  Future<void> setCustomUserClaims(String uid, Object? customUserClaims) async {
    throw UnimplementedError();
  }

  Future<Object> updateProviderConfig(
      String providerId, Object updatedConfig) async {
    throw UnimplementedError();
  }

  Future<Object> updateUser(String uid, Object properties) async {
    throw UnimplementedError();
  }

  Future<Object> verifyIdToken(String idToken, [bool? checkRevoked]) async {
    throw UnimplementedError();
  }

  Future<Object> verifySessionCookie(String sessionCookie,
      [bool? checkRevoked]) async {
    throw UnimplementedError();
  }
}
