import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

FirebaseAdminApp createApp() {
  final credential = Credential.fromApplicationDefaultCredentials();
  return FirebaseAdminApp.initializeApp(projectId, credential)..useEmulator();
}

Firestore createInstance() => Firestore(createApp());

Matcher isArgumentError({String? message}) {
  var matcher = isA<ArgumentError>();
  if (message != null) {
    matcher = matcher.having((e) => e.message, 'message', message);
  }

  return matcher;
}

Matcher throwsArgumentError({String? message}) {
  return throwsA(isArgumentError(message: message));
}
