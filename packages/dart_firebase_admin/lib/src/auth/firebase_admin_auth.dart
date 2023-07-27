part of '../../dart_firebase_admin.dart';

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

        return response.sessionCookie ?? '';
      },
    );
  }

  Future<Object> createUser(
    CreateRequest properties,
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

  Future<String> generateEmailVerificationLink(
    String email, [
    Object? actionCodeSettings,
  ]) async {
    throw UnimplementedError();
  }

  Future<String> generatePasswordResetLink(
    String email, [
    Object? actionCodeSettings,
  ]) async {
    throw UnimplementedError();
  }

  Future<String> generateSignInWithEmailLink(
    String email,
    Object actionCodeSettings,
  ) async {
    throw UnimplementedError();
  }

  Future<Object> getProviderConfig(String providerId) async {
    throw UnimplementedError();
  }

  Future<UserRecord> _getUserRecord(
    firebase_auth_v1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest request,
  ) async {
    final response = await (await _v1()).projects.accounts_1.lookup(
          request,
          app._projectId,
        );

    if (response.users == null || response.users!.isEmpty) {
      throw FirebaseAuthAdminException.fromAuthClientErrorCode(
        AuthClientErrorCode.userNotFound,
      );
    }

    return UserRecord._(response.users!.first);
  }

  Future<UserRecord> getUser(String uid) async {
    return guard(
      () async {
        if (!uid.isUid) {
          throw FirebaseAuthAdminException.fromAuthClientErrorCode(
            AuthClientErrorCode.invalidUid,
          );
        }

        return _getUserRecord(
          firebase_auth_v1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
            localId: [uid],
          ),
        );
      },
    );
  }

  Future<Object> getUserByEmail(String email) async {
    return guard(
      () async {
        if (!email.isEmail) {
          throw FirebaseAuthAdminException.fromAuthClientErrorCode(
            AuthClientErrorCode.invalidEmail,
          );
        }

        return _getUserRecord(
          firebase_auth_v1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
            email: [email],
          ),
        );
      },
    );
  }

  Future<Object> getUserByPhoneNumber(String phoneNumber) async {
    return guard(
      () async {
        if (!phoneNumber.isPhoneNumber) {
          throw FirebaseAuthAdminException.fromAuthClientErrorCode(
            AuthClientErrorCode.invalidPhoneNumber,
          );
        }

        return _getUserRecord(
          firebase_auth_v1.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
            phoneNumber: [phoneNumber],
          ),
        );
      },
    );
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
    String providerId,
    Object updatedConfig,
  ) async {
    throw UnimplementedError();
  }

  Future<Object> updateUser(String uid, Object properties) async {
    throw UnimplementedError();
  }

  Future<Object> verifyIdToken(String idToken, {bool? checkRevoked}) async {
    throw UnimplementedError();
  }

  Future<Object> verifySessionCookie(
    String sessionCookie, {
    bool? checkRevoked,
  }) async {
    throw UnimplementedError();
  }
}
