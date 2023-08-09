import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:test/test.dart';

void main() {
  group(FirebaseAdminApp, () {
    test('initializeApp() creates a new FirebaseAdminApp', () {
      final app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      expect(app, isA<FirebaseAdminApp>());
      expect(app.apiHost, Uri.https('identitytoolkit.googleapis.com', '/'));
    });

    test('useEmulator() sets the apiHost to the emulator', () {
      final app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      app.useEmulator();

      expect(
        app.apiHost,
        Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/'),
      );
    });
  });
}
