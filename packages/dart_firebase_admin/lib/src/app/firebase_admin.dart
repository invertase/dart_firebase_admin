part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(
    this.projectId,
    this.credential, {
    Client? client,
  }) : _clientOverride = client;

  /// The ID of the Google Cloud project associated with the app.
  final String projectId;

  /// The [Credential] used to authenticate the Admin SDK.
  final Credential credential;

  bool get isUsingEmulator => _isUsingEmulator;
  var _isUsingEmulator = false;

  @internal
  Uri authApiHost = Uri.https('identitytoolkit.googleapis.com', '/');
  @internal
  Uri firestoreApiHost = Uri.https('firestore.googleapis.com', '/');
  @internal
  Uri storageApiHost = Uri.https('storage.googleapis.com', '/');
  @internal
  String tasksEmulatorHost = 'https://cloudfunctions.googleapis.com/';

  /// Use the Firebase Emulator Suite to run the app locally.
  void useEmulator() {
    _isUsingEmulator = true;
    final env =
        Zone.current[envSymbol] as Map<String, String>? ?? Platform.environment;

    authApiHost = Uri.http(
      env['FIREBASE_AUTH_EMULATOR_HOST'] ?? '127.0.0.1:9099',
      'identitytoolkit.googleapis.com/',
    );
    firestoreApiHost = Uri.http(
      env['FIRESTORE_EMULATOR_HOST'] ?? '127.0.0.1:8080',
      '/',
    );
    storageApiHost = Uri.http(
      env['FIREBASE_STORAGE_EMULATOR_HOST'] ?? '127.0.0.1:9199',
      '/',
    );
    tasksEmulatorHost = Uri.http(
      env['CLOUD_TASKS_EMULATOR_HOST'] ?? '127.0.0.1:5001',
      '/',
    ).toString();
  }

  @internal
  late final client = _getClient(
    [
      auth3.IdentityToolkitApi.cloudPlatformScope,
      auth3.IdentityToolkitApi.firebaseScope,
    ],
  );
  final Client? _clientOverride;

  Future<Client> _getClient(List<String> scopes) async {
    if (_clientOverride != null) {
      return _clientOverride;
    }

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
