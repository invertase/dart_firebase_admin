part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(this.projectId, this.credential);

  /// The ID of the Google Cloud project associated with the app.
  final String projectId;

  /// The [Credential] used to authenticate the Admin SDK.
  final Credential credential;

  bool get isUsingAuthEmulator => _isUsingAuthEmulator;

  bool get isUsingFirestoreEmulator => _isUsingFirestoreEmulator;

  bool get isUsingEmulator => _isUsingAuthEmulator || _isUsingFirestoreEmulator;

  var _isUsingAuthEmulator = false;
  var _isUsingFirestoreEmulator = false;

  @internal
  Uri authApiHost = Uri.https('identitytoolkit.googleapis.com', '/');
  @internal
  Uri firestoreApiHost = Uri.https('firestore.googleapis.com', '/');

  /// Use the Firebase Emulator suite to run the app locally.
  void useEmulator({
    Emulator authEmulator = const Emulator.defaultAuth(),
    Emulator firestoreEmulator = const Emulator.defaultFirestore(),
  }) {
    useAuthEmulator(emulator: authEmulator);
    useFirestoreEmulator(emulator: firestoreEmulator);
  }

  /// Use the Firebase Auth Emulator to run the app locally.
  void useAuthEmulator({
    Emulator emulator = const Emulator.defaultAuth(),
  }) {
    _isUsingAuthEmulator = true;
    authApiHost = Uri.http(
        '${emulator.host}:${emulator.port}', 'identitytoolkit.googleapis.com/');
  }

  /// Use the Firebase Firestore Emulator to run the app locally.
  void useFirestoreEmulator({
    Emulator emulator = const Emulator.defaultFirestore(),
  }) {
    _isUsingFirestoreEmulator = true;
    firestoreApiHost = Uri.http('${emulator.host}:${emulator.port}', '/');
  }

  @internal
  late final client = _getClient(
    [
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ],
  );

  Future<Client> _getClient(List<String> scopes) async {
    if (isUsingEmulator) {
      return _EmulatorClient(Client());
    }

    final serviceAccountCredentials = credential.serviceAccountCredentials;
    final client = serviceAccountCredentials == null
        ? await auth.clientViaApplicationDefaultCredentials(scopes: scopes)
        : await auth.clientViaServiceAccount(serviceAccountCredentials, scopes);

    return client;
  }

  /// Stops the app and releases any resources associated with it.
  Future<void> close() async {
    final client = await this.client;
    client.close();
  }
}
