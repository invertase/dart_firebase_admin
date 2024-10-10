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
      var app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      /// Use both auth and firestore emulator.
      app.useEmulator();

      expect(app.isUsingAuthEmulator, true);
      expect(app.isUsingFirestoreEmulator, true);
      expect(app.isUsingEmulator, true);

      expect(
        app.authApiHost,
        Uri.http('127.0.0.1:9099', 'identitytoolkit.googleapis.com/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.http('127.0.0.1:8080', '/'),
      );

      /// Use only auth emulator.
      app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      app.useAuthEmulator(
        emulator: const Emulator('192.168.1.1', 9),
      );

      expect(app.isUsingAuthEmulator, true);
      expect(app.isUsingFirestoreEmulator, false);
      expect(app.isUsingEmulator, true);

      expect(
        app.authApiHost,
        Uri.http('192.168.1.1:9', 'identitytoolkit.googleapis.com/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.https('firestore.googleapis.com', '/'),
      );

      /// Use only firestore emulator.
      app = FirebaseAdminApp.initializeApp(
        'dart-firebase-admin',
        Credential.fromApplicationDefaultCredentials(),
      );

      app.useFirestoreEmulator();

      expect(app.isUsingAuthEmulator, false);
      expect(app.isUsingFirestoreEmulator, true);
      expect(app.isUsingEmulator, true);

      expect(
        app.authApiHost,
        Uri.https('identitytoolkit.googleapis.com', '/'),
      );
      expect(
        app.firestoreApiHost,
        Uri.http('127.0.0.1:8080', '/'),
      );
    });

    test('Emulator is initiated as expected', () {
      /// Test the parsing part of env string to Uri.
      var emulator = Emulator.fromEnvString('192.168.0.1:9999');
      expect(emulator.host, '192.168.0.1');
      expect(emulator.port, 9999);

      /// Test the default auth emulator is using the default host and port.
      emulator = Emulator.auth();
      expect(emulator.host, '127.0.0.1');
      expect(emulator.port, 9099);

      emulator = Emulator.firestore();
      expect(emulator.host, '127.0.0.1');
      expect(emulator.port, 8080);
    });
  });
}
