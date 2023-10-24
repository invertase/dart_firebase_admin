part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(this.projectId, this.credential);

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

  /// Use the Firebase Emulator Suite to run the app locally.
  void useEmulator() {
    _isUsingEmulator = true;
    authApiHost = Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/');
    firestoreApiHost = Uri.http('127.0.0.1:8080', '/');
  }

  /// Stops the app and releases any resources associated with it.
  Future<void> close() async {
    final client = await credential.client;
    client.close();
  }
}
