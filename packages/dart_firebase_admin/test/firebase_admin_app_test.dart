import 'dart:io';

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

    test(
        'useEmulator() uses environment variables to set apiHost to the emulator',
        () {
      assert(Platform.environment['FIREBASE_AUTH_EMULATOR_HOST'] != null,
          'FIREBASE_AUTH_EMULATOR_HOST is not set');
      assert(Platform.environment['FIRESTORE_EMULATOR_HOST'] != null,
          'FIRESTORE_EMULATOR_HOST is not set');
      final firebaseAuthEmulatorHost =
          Platform.environment['FIREBASE_AUTH_EMULATOR_HOST']!;
      final firestoreEmulatorHost =
          Platform.environment['FIRESTORE_EMULATOR_HOST']!;

      final app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      app.useEmulator();

      expect(
        app.authApiHost,
        Uri.http(firebaseAuthEmulatorHost, 'identitytoolkit.googleapis.com/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.http(firestoreEmulatorHost, '/'),
      );
    });
  });
}
