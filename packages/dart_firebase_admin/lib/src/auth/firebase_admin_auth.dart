part of dart_firebase_admin;

class FirebaseAdminAuth {
  FirebaseAdminAuth(this.app);
  final FirebaseAdminApp app;

  auth.AuthClient? _client;

  Object tenantManager() {
    return {};
  }

  Future<auth.AuthClient> _getClient() async {
    return _client ??= await app._credential._getAuthClient([
      firebase_auth_v3.IdentityToolkitApi.cloudPlatformScope,
      firebase_auth_v3.IdentityToolkitApi.firebaseScope,
    ]);
  }

  Future<firebase_auth_v1.IdentityToolkitApi> _v1() async {
    return firebase_auth_v1.IdentityToolkitApi(await _getClient());
  }

  Future<firebase_auth_v2.IdentityToolkitApi> _v2() async {
    return firebase_auth_v2.IdentityToolkitApi(await _getClient());
  }

  Future<firebase_auth_v3.IdentityToolkitApi> _v3() async {
    return firebase_auth_v3.IdentityToolkitApi(await _getClient());
  }

  Future<String> createCustomToken(
    String uid, [
    Map<String, String>? developerClaims,
  ]) async {
    throw UnimplementedError();
  }

  Future<Object> createProviderConfig(Object config) async {
    throw UnimplementedError();
  }

  Future<String> createSessionCookie(String idToken, {int? expiresIn}) async {
    return guard(
      () async {
        final request = firebase_auth_v1
            .GoogleCloudIdentitytoolkitV1CreateSessionCookieRequest(
          idToken: idToken,
          validDuration: expiresIn?.toString(),
        );

        final response = await (await _v1()).projects.createSessionCookie(
              request,
              app._projectId,
            );

        return response.sessionCookie ?? "";
      },
    );
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

  Future<void> deleteUser(
    String uid,
  ) async {
    return guard(() async {
      final request =
          firebase_auth_v3.IdentitytoolkitRelyingpartyDeleteAccountRequest(
        localId: uid,
      );

      await (await _v3()).relyingparty.deleteAccount(request);
    });
  }

  Future<DeleteUsersResult> deleteUsers(
    List<String> uids,
  ) async {
    return guard(
      () async {
        final localIds = uids.where((element) => element.isUid).toList();

        final request = firebase_auth_v1
            .GoogleCloudIdentitytoolkitV1BatchDeleteAccountsRequest(
          localIds: localIds,
        );

        final response = await (await _v1()).projects.accounts_1.batchDelete(
              request,
              app._projectId,
            );

        return DeleteUsersResult._(localIds, response);
      },
    );
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
