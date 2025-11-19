import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

FirebaseApp createApp({
  FutureOr<void> Function()? tearDown,
  Client? client,
  bool useEmulator = true,
}) {
  final credential = Credential.fromApplicationDefaultCredentials();
  final app = FirebaseApp.initializeApp(
    projectId,
    credential,
    client: client,
  );
  if (useEmulator) app.useEmulator();

  addTearDown(() async {
    if (tearDown != null) {
      await tearDown();
    }
    await app.close();
  });

  return app;
}

Future<void> _recursivelyDeleteAllDocuments(Firestore firestore) async {
  Future<void> handleCollection(CollectionReference<void> collection) async {
    final docs = await collection.listDocuments();

    for (final doc in docs) {
      await doc.delete();

      final subcollections = await doc.listCollections();
      for (final subcollection in subcollections) {
        await handleCollection(subcollection);
      }
    }
  }

  final collections = await firestore.listCollections();
  for (final collection in collections) {
    await handleCollection(collection);
  }
}

Future<Firestore> createFirestore({
  Settings? settings,
  bool useEmulator = true,
}) async {
  final firestore = Firestore(
    createApp(useEmulator: useEmulator),
    settings: settings,
  );

  addTearDown(() => _recursivelyDeleteAllDocuments(firestore));

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
