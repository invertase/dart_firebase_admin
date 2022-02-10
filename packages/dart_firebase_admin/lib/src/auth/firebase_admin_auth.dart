part of dart_firebase_admin;

class FirebaseAdminAuth {
  FirebaseAdminAuth(this.app);
  final FirebaseAdminApp app;

  auth.AuthClient? _client;

  Future<firebase_auth.IdentityToolkitApi> _getApi() async {
    final client = _client ??= await app._credential._getAuthClient([]);
    return firebase_auth.IdentityToolkitApi(client);
  }

  Future getUser() async {
    final api = await _getApi();
    final response = await api.accounts.lookup(
      firebase_auth.GoogleCloudIdentitytoolkitV1GetAccountInfoRequest(
        email: [''],
      ),
    );

    return;
  }
}
