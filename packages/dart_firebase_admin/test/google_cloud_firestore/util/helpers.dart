import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

FirebaseAdminApp createApp({
  FutureOr<void> Function()? tearDown,
  Client? client,
}) {
  final credential = Credential.fromApplicationDefaultCredentials();
  final app = FirebaseAdminApp.initializeApp(
    projectId,
    credential,
    client: client,
  )..useEmulator();

  addTearDown(() async {
    if (tearDown != null) {
      await tearDown();
    }
    await app.close();
  });

  return app;
}

Firestore createFirestore([Settings? settings]) {
  final firestore = Firestore(createApp(), settings: settings);

  addTearDown(() async {
    final collections = await firestore.listCollections();

    for (final collection in collections) {
      final docs = await collection.get();

      await Future.wait([
        for (final doc in docs.docs) doc.ref.delete(),
      ]);
    }
  });

  return firestore;
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
