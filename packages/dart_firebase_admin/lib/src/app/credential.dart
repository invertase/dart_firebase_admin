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

  /// Log in to firebase from a service account file parameters.
  factory Credential.fromServiceAccountParams({
    required String clientId,
    required String privateKey,
    required String email,
  }) {
    final serviceAccountCredentials = auth.ServiceAccountCredentials(
      email,
      ClientId(clientId),
      privateKey,
    );

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
  late final client = _getClient(
    [
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ],
  );

  Future<AutoRefreshingAuthClient> _getClient(List<String> scopes) async {
    final serviceAccountCredentials = this.serviceAccountCredentials;
    final client = serviceAccountCredentials == null
        ? await auth.clientViaApplicationDefaultCredentials(scopes: scopes)
        : await auth.clientViaServiceAccount(serviceAccountCredentials, scopes);

    return client;
  }
}
