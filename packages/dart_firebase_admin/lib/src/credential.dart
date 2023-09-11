part of 'dart_firebase_admin.dart';

/// Authentication informations for Firebase Admin SDK.
class Credential {
  Credential._(this._serviceAccountCredentials);

  /// Log in to firebase from a service account file.
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

  /// Log in to firebase using the environment variable.
  Credential.fromApplicationDefaultCredentials() : this._(null);

  final auth.ServiceAccountCredentials? _serviceAccountCredentials;

  @internal
  Future<auth.AuthClient> getAuthClient(List<String> scopes) {
    final serviceAccountCredentials = _serviceAccountCredentials;
    if (serviceAccountCredentials == null) {
      return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
    }

    return auth.clientViaServiceAccount(serviceAccountCredentials, scopes);
  }
}
