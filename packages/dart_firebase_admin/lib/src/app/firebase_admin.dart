part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(
    this.projectId,
    this.credential, {
    this.emulatorAuthHost = '127.0.0.1',
    this.emulatorAuthPort = 9099,
    this.emulatorFirestoreHost = '127.0.0.1',
    this.emulatorFirestorePort = 8080,
  });

  /// The ID of the Google Cloud project associated with the app.
  final String projectId;

  /// The [Credential] used to authenticate the Admin SDK.
  final Credential credential;

  /// The hostname of the Firebase Auth emulator.
  final String emulatorAuthHost;

  /// The port of the Firebase Auth emulator.
  final int emulatorAuthPort;

  /// The hostname of the Firestore emulator.
  final String emulatorFirestoreHost;

  /// The port of the Firestore emulator.
  final int emulatorFirestorePort;

  bool get isUsingEmulator => _isUsingEmulator;
  var _isUsingEmulator = false;

  @internal
  Uri authApiHost = Uri.https('identitytoolkit.googleapis.com', '/');
  @internal
  Uri firestoreApiHost = Uri.https('firestore.googleapis.com', '/');

  /// Use the Firebase Emulator Suite to run the app locally.
  void useEmulator() {
    _isUsingEmulator = true;
    authApiHost = Uri.http(
      '$emulatorAuthHost:$emulatorAuthPort',
      'identitytoolkit.googleapis.com/',
    );
    firestoreApiHost = Uri.http(
      '$emulatorFirestoreHost:$emulatorFirestorePort',
      '/',
    );
  }

  /// Stops the app and releases any resources associated with it.
  Future<void> close() async {
    final client = await credential.client;
    client.close();
  }
}
