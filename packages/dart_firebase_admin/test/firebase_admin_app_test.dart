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
      expect(
        app.authApiHost,
        Uri.https('identitytoolkit.googleapis.com', '/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.https('firestore.googleapis.com', '/'),
      );
    });

    test('useEmulator() sets the default emulator hosts to the emulator', () {
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

    test(
      'useEmulator() leverages custom hosts and ports',
      () {
        final app = FirebaseAdminApp.initializeApp(
          'dart-firebase-admin',
          Credential.fromApplicationDefaultCredentials(),
          emulatorAuthHost: 'localhost',
          emulatorAuthPort: 1099,
          emulatorFirestoreHost: 'localhost',
          emulatorFirestorePort: 1080,
        );

        app.useEmulator();

        expect(
          app.authApiHost,
          Uri.http('localhost:1099', 'identitytoolkit.googleapis.com/'),
        );
        expect(
          app.firestoreApiHost,
          Uri.http('localhost:1080', '/'),
        );
      },
    );
  });
}
