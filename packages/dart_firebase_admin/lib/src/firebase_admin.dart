part of dart_firebase_admin;

class FirebaseAdminApp {
  factory FirebaseAdminApp.initializeApp(
      String projectId, Credential credential) {
    return FirebaseAdminApp._(projectId, credential);
  }

  FirebaseAdminApp._(this._projectId, this._credential);
  final String _projectId;
  final Credential _credential;
}

extension FirebaseAdminStringExtension on String {
  bool get isUid => this.isNotEmpty && this.length <= 128;
}
