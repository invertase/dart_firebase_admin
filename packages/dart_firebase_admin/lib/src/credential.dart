part of '../dart_firebase_admin.dart';

class Credential {
  Credential._(this._json);

  factory Credential.fromServiceAccount(File serviceAccountFile) {
    if (!serviceAccountFile.existsSync()) {
      throw ArgumentError.value(
        serviceAccountFile,
        'serviceAccountFile',
        'File does not exist',
      );
    }

    return Credential._(serviceAccountFile.readAsStringSync());
  }

  Credential.fromApplicationDefaultCredentials() : this._(null);

  final String? _json;

  Future<auth.AuthClient> _getAuthClient(List<String> scopes) {
    if (_json == null) {
      return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
    }

    return auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_json),
      scopes,
    );
  }
}
