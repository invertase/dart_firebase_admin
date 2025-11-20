import 'dart:async';

import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/src/app.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

const projectId = 'dart-firebase-admin';

/// Creates a FirebaseApp for testing.
///
/// Note: Tests should be run with the following environment variables set:
/// - FIRESTORE_EMULATOR_HOST=localhost:8080
/// - FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
///
/// The emulator will be auto-detected from these environment variables.
FirebaseApp createApp({
  FutureOr<void> Function()? tearDown,
  Client? client,
}) {
  final app = FirebaseApp.initializeApp(
    options: AppOptions(
      credential: Credential.fromApplicationDefaultCredentials(),
      httpClient: client,
    ),
  );

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

/// Creates a Firestore instance for testing.
///
/// Automatically cleans up all documents after each test.
///
/// Note: Tests should be run with FIRESTORE_EMULATOR_HOST=localhost:8080
/// environment variable set. The emulator will be auto-detected.
Future<Firestore> createFirestore({
  Settings? settings,
}) async {
  final firestore = Firestore(
    createApp(),
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
