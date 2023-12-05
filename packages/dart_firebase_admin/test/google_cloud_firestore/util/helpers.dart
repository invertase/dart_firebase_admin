import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

FirebaseAdminApp createApp() {
  final credential = Credential.fromApplicationDefaultCredentials();
  final app = FirebaseAdminApp.initializeApp(projectId, credential)
    ..useEmulator();

  addTearDown(app.close);

  return app;
}

Firestore createInstance([Settings? settings]) {
  return Firestore(createApp(), settings: settings);
}

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
