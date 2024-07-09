import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

void main() {
  group(FirebaseAdminApp, () {
    test('initializeApp() creates a new FirebaseAdminApp', () {
      final app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      expect(app, isA<FirebaseAdminApp>());
      expect(app.authApiHost, Uri.https('identitytoolkit.googleapis.com', '/'));
      expect(
        app.firestoreApiHost,
        Uri.https('firestore.googleapis.com', '/'),
      );
    });

    test('useEmulator() sets the apiHost to the emulator', () {
      final app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      app.useEmulator();

      expect(
        app.authApiHost,
        Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.http('127.0.0.1:8080', '/'),
      );
    });
  });
}
