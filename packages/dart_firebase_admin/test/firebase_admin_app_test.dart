import 'dart:async';

import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

void main() {
  group(FirebaseApp, () {
    test('initializeApp() creates a new FirebaseAdminApp', () {
      final app = FirebaseApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      expect(app, isA<FirebaseApp>());
      expect(app.authApiHost, Uri.https('identitytoolkit.googleapis.com', '/'));
      expect(
        app.firestoreApiHost,
        Uri.https('firestore.googleapis.com', '/'),
      );
    });

    test('useEmulator() sets the apiHost to the emulator', () {
      final app = FirebaseApp.initializeApp(
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
        'useEmulator() uses environment variables to set apiHost to the emulator',
        () async {
      const firebaseAuthEmulatorHost = '127.0.0.1:9000';
      const firestoreEmulatorHost = '127.0.0.1:8000';
      final testEnv = <String, String>{
        'FIREBASE_AUTH_EMULATOR_HOST': firebaseAuthEmulatorHost,
        'FIRESTORE_EMULATOR_HOST': firestoreEmulatorHost,
      };

      await runZoned(
        zoneValues: {envSymbol: testEnv},
        () async {
          final app = FirebaseApp.initializeApp(
            'dart-firebase-admin',
            Credential.fromApplicationDefaultCredentials(),
          );

          app.useEmulator();

          expect(
            app.authApiHost,
            Uri.http(
              firebaseAuthEmulatorHost,
              'identitytoolkit.googleapis.com/',
            ),
          );
          expect(
            app.firestoreApiHost,
            Uri.http(firestoreEmulatorHost, '/'),
          );
        },
      );
    });
  });
}
