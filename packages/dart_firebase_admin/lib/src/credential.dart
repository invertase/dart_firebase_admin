part of '../dart_firebase_admin.dart';

class Credential {
  Credential._(this._serviceAccountCredentials);

  factory Credential.fromServiceAccount(File serviceAccountFile) {
    final content = serviceAccountFile.readAsStringSync();

    final json = jsonDecode(content);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid service account file');
    }

    final serviceAccountCredentials =
        auth.ServiceAccountCredentials.fromJson(json);

    return Credential._(serviceAccountCredentials);
  }

  Credential.fromApplicationDefaultCredentials() : this._(null);

  final auth.ServiceAccountCredentials? _serviceAccountCredentials;

  Future<auth.AuthClient> _getAuthClient(List<String> scopes) {
    final serviceAccountCredentials = _serviceAccountCredentials;
    if (serviceAccountCredentials == null) {
      return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
    }

    return auth.clientViaServiceAccount(serviceAccountCredentials, scopes);
  }
}
