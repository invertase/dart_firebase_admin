part of dart_firebase_admin;

class Credential {
  Credential._(this._json);

  final String? _json;

  factory Credential.fromServiceAccount(File serviceAccountFile) {
    if (!serviceAccountFile.existsSync()) {
      throw ArgumentError.value(
          serviceAccountFile, 'serviceAccountFile', 'File does not exist');
    }

    return Credential._(serviceAccountFile.readAsStringSync());
  }

  factory Credential.fromApplicationDefaultCredentials() {
    return Credential._(null);
  }

  Future<auth.AuthClient> _getAuthClient(List<String> scopes) {
    if (_json == null) {
      return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
    }

    return auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(
          _json,
        ),
        scopes);
  }
}
