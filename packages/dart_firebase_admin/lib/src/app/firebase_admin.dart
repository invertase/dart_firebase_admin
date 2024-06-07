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
  void useEmulator({Emulator? authEmulator, Emulator? firestoreEmulator}) {
    useAuthEmulator(emulator: authEmulator);
    useFirestoreEmulator(emulator: firestoreEmulator);
  }

  /// Use the Firebase Auth Emulator to run the app locally.
  void useAuthEmulator({Emulator? emulator}) {
    _isUsingAuthEmulator = true;
    final host = emulator?.host ?? '127.0.0.1';
    final port = emulator?.port ?? 9099;
    authApiHost = Uri.http('$host:$port', 'identitytoolkit.googleapis.com/');
  }

  /// Use the Firebase Firestore Emulator to run the app locally.
  void useFirestoreEmulator({Emulator? emulator}) {
    _isUsingFirestoreEmulator = true;
    final host = emulator?.host ?? '127.0.0.1';
    final port = emulator?.port ?? 8080;
    firestoreApiHost = Uri.http('$host:$port', '/');
  }

  /// Stops the app and releases any resources associated with it.
  Future<void> close() async {
    final client = await credential.client;
    client.close();
  }
}
