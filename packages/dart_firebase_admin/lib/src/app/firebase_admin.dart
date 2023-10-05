part of '../app.dart';

class FirebaseAdminApp {
  FirebaseAdminApp.initializeApp(this.projectId, this.credential);

  final String projectId;
  final Credential credential;

  bool get isUsingEmulator => _isUsingEmulator;
  var _isUsingEmulator = false;

  @internal
  Uri authApiHost = Uri.https('identitytoolkit.googleapis.com', '/');
  @internal
  Uri firestoreApiHost = Uri.https('firestore.googleapis.com', '/');

  void useEmulator() {
    _isUsingEmulator = true;
    authApiHost = Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/');
    firestoreApiHost = Uri.http('127.0.0.1:8080', '/');
  }
}
