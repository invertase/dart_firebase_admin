part of dart_firebase_admin;

class FirebaseAdminApp {
  factory FirebaseAdminApp.initializeApp(Credential credential) {
    return FirebaseAdminApp._(credential);
  }

  FirebaseAdminApp._(this._credential);
  final Credential _credential;
}


