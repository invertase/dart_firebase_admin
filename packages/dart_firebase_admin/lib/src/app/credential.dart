part of '../app.dart';

/// Authentication information for Firebase Admin SDK.
class Credential {
  Credential._(
    this.serviceAccountCredentials, {
    this.serviceAccountId,
  }) : assert(
          serviceAccountId == null || serviceAccountCredentials == null,
          'Cannot specify both serviceAccountId and serviceAccountCredentials',
        );

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
  Credential.fromApplicationDefaultCredentials({String? serviceAccountId})
      : this._(
          null,
          serviceAccountId: serviceAccountId,
        );

  @internal
  final String? serviceAccountId;

  @internal
  final auth.ServiceAccountCredentials? serviceAccountCredentials;

  @internal
  Future<auth.AuthClient> getAuthClient(List<String> scopes) {
    final serviceAccountCredentials = this.serviceAccountCredentials;
    if (serviceAccountCredentials == null) {
      return auth.clientViaApplicationDefaultCredentials(scopes: scopes);
    }

    return auth.clientViaServiceAccount(serviceAccountCredentials, scopes);
  }
}
